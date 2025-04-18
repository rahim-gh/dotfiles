local helpers = require('test.gs_helpers')

local setup_gitsigns = helpers.setup_gitsigns
local feed = helpers.feed
local test_file = helpers.test_file
local edit = helpers.edit
local check = helpers.check
local exec_lua = helpers.exec_lua
local fn = helpers.fn
local system = fn.system
local test_config = helpers.test_config
local clear = helpers.clear
local setup_test_repo = helpers.setup_test_repo
local eq = helpers.eq
local expectf = helpers.expectf

helpers.env()

--- @param exp_hunks string[]
local function expect_hunks(exp_hunks)
  expectf(function()
    --- @type table[]
    local hunks = exec_lua("return require('gitsigns').get_hunks()")
    if #exp_hunks ~= #hunks then
      local msg = {} --- @type string[]
      msg[#msg + 1] = ''
      msg[#msg + 1] = string.format(
        'Number of hunks do not match. Expected: %d, passed in: %d',
        #exp_hunks,
        #hunks
      )

      msg[#msg + 1] = '\nExpected hunks:'
      for _, h in ipairs(exp_hunks) do
        msg[#msg + 1] = h
      end

      msg[#msg + 1] = '\nPassed in hunks:'
      for _, h in ipairs(hunks) do
        msg[#msg + 1] = h.head
      end

      error(table.concat(msg, '\n'))
    end

    for i, hunk in ipairs(hunks) do
      eq(exp_hunks[i], hunk.head)
    end
  end)
end

local delay = 10

local function command(cmd)
  helpers.sleep(delay)
  helpers.api.nvim_command(cmd)

  -- Flaky tests, add a large delay between commands.
  -- Flakyness is due to actions being async and problems occur when an action
  -- is run while another action or update is running.
  -- Must wait for actions and updates to finish.
  helpers.sleep(delay)
end

local function retry(f)
  local orig_delay = delay
  local ok, err

  for _ = 1, 20 do
    ok, err = pcall(f)
    if ok then
      return
    end
    delay = delay * 1.6
    print('failed, retrying with delay', delay)
  end

  if err then
    delay = orig_delay
    error(err)
  end
end

describe('actions', function()
  local orig_it = it
  local function it(desc, f)
    orig_it(desc, function()
      retry(f)
    end)
  end

  local config --- @type Gitsigns.Config

  before_each(function()
    clear()
    -- Make gitisigns available
    exec_lua('package.path = ...', package.path)
    config = vim.deepcopy(test_config)
    command('cd ' .. system({ 'dirname', os.tmpname() }))
    setup_gitsigns(config)
  end)

  it('works with commands', function()
    setup_test_repo()
    edit(test_file)

    feed('jjjccEDIT<esc>')
    check({
      status = { head = 'master', added = 0, changed = 1, removed = 0 },
      signs = { changed = 1 },
    })

    command('Gitsigns stage_hunk')
    check({
      status = { head = 'master', added = 0, changed = 0, removed = 0 },
      signs = {},
    })

    command('Gitsigns undo_stage_hunk')
    check({
      status = { head = 'master', added = 0, changed = 1, removed = 0 },
      signs = { changed = 1 },
    })

    -- Add multiple edits
    feed('ggccThat<esc>')

    check({
      status = { head = 'master', added = 0, changed = 2, removed = 0 },
      signs = { changed = 2 },
    })

    command('Gitsigns stage_buffer')
    check({
      status = { head = 'master', added = 0, changed = 0, removed = 0 },
      signs = {},
    })

    command('Gitsigns reset_buffer_index')
    check({
      status = { head = 'master', added = 0, changed = 2, removed = 0 },
      signs = { changed = 2 },
    })

    command('Gitsigns reset_hunk')
    check({
      status = { head = 'master', added = 0, changed = 1, removed = 0 },
      signs = { changed = 1 },
    })
  end)

  describe('staging partial hunks', function()
    setup(function()
      clear()
      setup_test_repo({ test_file_text = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H' } })
    end)

    before_each(function()
      helpers.git({ 'reset', '--hard' })
      edit(test_file)
    end)

    local function set_lines(start, dend, lines)
      helpers.api.nvim_buf_set_lines(0, start, dend, false, lines)
    end

    describe('can stage add hunks', function()
      before_each(function()
        set_lines(2, 2, { 'c1', 'c2', 'c3', 'c4' })
        expect_hunks({ '@@ -2 +3,4 @@' })
      end)

      it('contained in range', function()
        command([[1,7 Gitsigns stage_hunk]])
        expect_hunks({})
      end)

      it('containing range', function()
        command([[4,5 Gitsigns stage_hunk]])
        expect_hunks({
          '@@ -2 +3,1 @@',
          '@@ -4 +6,1 @@',
        })
      end)

      it('from top range', function()
        command([[1,4 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -4 +5,2 @@' })
      end)

      it('from bottom range', function()
        command([[4,7 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -2 +3,1 @@' })

        command([[Gitsigns reset_buffer_index]])
        expect_hunks({ '@@ -2 +3,4 @@' })

        command([[4,10 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -2 +3,1 @@' })
      end)
    end)

    describe('can stage modified-add hunks', function()
      before_each(function()
        set_lines(2, 4, { 'c1', 'c2', 'c3', 'c4', 'c5' })
        expect_hunks({ '@@ -3,2 +3,5 @@' })
      end)

      it('from top range containing mod', function()
        command([[2,3 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -4,1 +4,4 @@' })
      end)

      it('from top range containing mod-add', function()
        command([[2,5 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -5 +6,2 @@' })
      end)

      it('from bottom range containing add', function()
        command([[6,8 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -3,2 +3,3 @@' })
      end)

      it('containing range containing add', function()
        command('write')
        command([[5,6 Gitsigns stage_hunk]])
        expect_hunks({
          '@@ -3,2 +3,2 @@',
          '@@ -6 +7,1 @@',
        })
      end)
    end)

    describe('can stage modified-remove hunks', function()
      before_each(function()
        set_lines(2, 7, { 'c1', 'c2', 'c3' })
        command('write')
        expect_hunks({ '@@ -3,5 +3,3 @@' })
      end)

      it('from top range', function()
        expect_hunks({ '@@ -3,5 +3,3 @@' })

        command([[2,3 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -4,4 +4,2 @@' })

        command([[2,3 Gitsigns reset_buffer_index]])
        expect_hunks({ '@@ -3,5 +3,3 @@' })

        command([[2,4 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -5,3 +5,1 @@' })
      end)

      it('from bottom range', function()
        expect_hunks({ '@@ -3,5 +3,3 @@' })

        command([[4,6 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -3,1 +3,1 @@' })

        command([[2,3 Gitsigns reset_buffer_index]])
        expect_hunks({ '@@ -3,5 +3,3 @@' })

        command([[5,6 Gitsigns stage_hunk]])
        expect_hunks({ '@@ -3,2 +3,2 @@' })
      end)
    end)

    it('can stage remove hunks', function()
      set_lines(2, 5, {})
      expect_hunks({ '@@ -3,3 +2 @@' })

      command([[2 Gitsigns stage_hunk]])
      expect_hunks({})
    end)
  end)

  local function check_cursor(pos)
    eq(pos, helpers.api.nvim_win_get_cursor(0))
  end

  it('can navigate hunks', function()
    setup_test_repo()
    edit(test_file)

    feed('dd')
    feed('4Gx')
    feed('6Gx')

    expect_hunks({
      '@@ -1,1 +0 @@',
      '@@ -5,1 +4,1 @@',
      '@@ -7,1 +6,1 @@',
    })

    check_cursor({ 6, 0 })
    command('Gitsigns next_hunk') -- Wrap
    check_cursor({ 1, 0 })
    command('Gitsigns next_hunk')
    check_cursor({ 4, 0 })
    command('Gitsigns next_hunk')
    check_cursor({ 6, 0 })

    command('Gitsigns prev_hunk')
    check_cursor({ 4, 0 })
    command('Gitsigns prev_hunk')
    check_cursor({ 1, 0 })
    command('Gitsigns prev_hunk') -- Wrap
    check_cursor({ 6, 0 })
  end)

  it('can navigate hunks (nowrap)', function()
    setup_test_repo()
    edit(test_file)

    feed('4Gx')
    feed('6Gx')
    feed('gg')

    expect_hunks({
      '@@ -4,1 +4,1 @@',
      '@@ -6,1 +6,1 @@',
    })

    command('set nowrapscan')

    check_cursor({ 1, 0 })
    command('Gitsigns next_hunk')
    check_cursor({ 4, 0 })
    command('Gitsigns next_hunk')
    check_cursor({ 6, 0 })
    command('Gitsigns next_hunk')
    check_cursor({ 6, 0 })

    feed('G')
    check_cursor({ 18, 0 })
    command('Gitsigns prev_hunk')
    check_cursor({ 6, 0 })
    command('Gitsigns prev_hunk')
    check_cursor({ 4, 0 })
    command('Gitsigns prev_hunk')
    check_cursor({ 4, 0 })
  end)

  it('can stage hunks with no NL at EOF', function()
    setup_test_repo()
    local newfile = helpers.newfile
    exec_lua([[vim.g.editorconfig = false]])
    system("printf 'This is a file with no nl at eof' > " .. newfile)
    helpers.git({ 'add', newfile })
    helpers.git({ 'commit', '-m', 'commit on main' })

    edit(newfile)
    check({ status = { head = 'master', added = 0, changed = 0, removed = 0 } })
    feed('x')
    check({ status = { head = 'master', added = 0, changed = 1, removed = 0 } })
    command('Gitsigns stage_hunk')
    check({ status = { head = 'master', added = 0, changed = 0, removed = 0 } })
  end)
end)
