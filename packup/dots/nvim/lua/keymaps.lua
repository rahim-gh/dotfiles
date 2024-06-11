-- Set <Space> as Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- clipboard (termux)
--set clipboard+=unnamedplus
vim.opt.clipboard:append("unnamedplus")

-- Declare variables
local map = vim.keymap.set
local default = { noremap=true, silent=true }
local allow_remap = { noremap=false, silent=true }
local expr = { expr=true, silent=true }

-- General
map('n', '<Leader>=', ':set spell!<CR>', {desc='Toggle spell check'})
map('n', '<Leader>8', ':execute "set cc=" . (&cc == "" ? "80" : "")<CR>', default, {desc='Toggle character column'})
map('n', 'X', ':keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==^<CR>', {desc='Split line'})
map('i', '<C-z>', '<C-g>u<Esc>[S1z=`]a<C-g>u', {desc='Fix spelling'})

-- Better indenting
map('v', '<', '<gv^')
map('v', '>', '>gv^')

-- Command mode movement
map('c', '<C-a>', '<Home>')
map('c', '<C-n>', '<Down>')
map('c', '<C-p>', '<Up>')

-- Less cursor movement
map('', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', '*', '*zz')
map('n', '#', '#zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '{', '{zz')
map('n', '}', '}zz')
map('n', 'zo', 'zozz')
map('n', 'zr', 'zrzz')
map('n', 'zR', 'zRzz')
map('n', 'zc', 'zczz')
map('n', 'zm', 'zmzz')
map('n', 'zM', 'zMzz')
map('v', 'y', 'ygv<Esc>')

-- Add undo break-points
map('i', ',', ',<C-g>u')
map('i', '.', '.<C-g>u')
map('i', ';', ';<C-g>u')

-- Explorer, Tabs, windows, frequent files
map('n', '\\c', ":tab drop ~/ARCHIVE/Journals/Backlog/capture.txt<CR>", {desc='Open backlog.txt'})
map('n', '<C-t>', ':15Le %:p:h<CR>', default, {desc='Open netrw in file directory'})
map('n', '<C-e-t>', ':15Le<CR>', default, {desc='Open netrw in working directory'})

-- Diagnostic keymaps
map('n', '<Leader>e', vim.diagnostic.open_float)
map('n', '<leader>q', vim.diagnostic.setloclist, default)

-- Smart `dd` (don't yank blank lines)
-- https://nanotipsforvim.prose.sh/keeping-your-register-clean-from-dd
map('n', 'dd', function () if vim.fn.getline(".") == "" then return '"_dd' end return 'dd' end, {expr = true})

-- .repeat & macro on visually selected
map("x", ".", ":norm .<CR>")
map("x", "@", ":norm @q<CR>")

-- mini.basic
map({ 'n', 'i', 'x' }, '<C-s>', '<Nop>')

-- mini.pick / mini.extra
map('n', '<Leader>1', '<Cmd>lua MiniExtra.pickers.oldfiles()<CR>', {desc='Recent files'})
map('n', '<Leader>2', '<Cmd>lua MiniPick.builtin.resume()<CR>', {desc='Resume pick'})
map('n', '<Leader>Q', '<Cmd>lua MiniExtra.pickers.diagnostic()<CR>', {desc='Diagnostics'})
map('n', '<Leader>b', '<Cmd>lua MiniPick.builtin.buffers()<CR>', {desc='Pick buffers'})
map('n', '<Leader>c', '<Cmd>lua MiniExtra.pickers.list({ scope = "change" })<CR>', {desc='Changelist'})
map('n', '<Leader>fd', '<Cmd>lua MiniPick.builtin.files()<CR>', {desc='Find files'})
map('n', '<Leader>gc', '<Cmd>lua MiniExtra.pickers.git_commits()<CR>', {desc='Git Commits'})
map('n', '<Leader>gh', '<Cmd>lua MiniExtra.pickers.git_hunks()<CR>', {desc='Git Hunks'})
map('n', '<Leader>j', '<Cmd>lua MiniExtra.pickers.list({ scope = "jump" })<CR>', {desc='Jumplist'})
map('n', '<Leader>n', '<Cmd>lua MiniExtra.pickers.treesitter()<CR>', {desc='Treesitter Jump'})
map('n', '<Leader>q', '<Cmd>lua MiniExtra.pickers.list({ scope = "quickfix" })<CR>', {desc='Quickfix List'})
map('n', '<Leader>rg', '<Cmd>lua MiniPick.builtin.grep_live()<CR>', {desc='Grep'})
map('n', '<Leader>y', '<Cmd>lua MiniExtra.pickers.registers()<CR>', {desc='Registers'})

-- mini.trailspace
map('n', '<Leader>t', '<Cmd>lua MiniTrailspace.trim()<CR>', {desc='Trim trailing space'})
map('n', '<Leader>T', '<Cmd>lua MiniTrailspace.trim_last_lines()<CR>', {desc='Trim trailing lines'})

-- mini.diff
map('n', '<Leader>hp', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', {desc='Hunk Preview'})

-- mini.ai
local nxo = {'n','x','o'}
map(nxo, ']a', "<Cmd>lua MiniAi.move_cursor('left', 'i', 'a')<CR>", {desc='Next argument'})
map(nxo, '[a', "<Cmd>lua MiniAi.move_cursor('left', 'i', 'a', {search_method='prev'})<CR>", {desc='Previous argument'})
map(nxo, ']F', "<Cmd>lua MiniAi.move_cursor('left', 'i', 'f')<CR>", {desc='Next function'})
map(nxo, '[F', "<Cmd>lua MiniAi.move_cursor('left', 'i', 'f', {search_method='prev'})<CR>", {desc='Previous function'})
