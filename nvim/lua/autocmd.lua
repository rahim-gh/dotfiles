local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Some commands are set by mini.basic

augroup('bufcheck', {clear=true})

-- Reload config file on change
autocmd('BufWritePost', {
  group   = 'bufcheck',
  pattern = vim.env.MYVIMRC,
  command = 'silent source %'
})

-- Resume previous position
autocmd('BufReadPost', {
  pattern = '*',
  command = [[ if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif ]],
})

-- Auto resize splits if window got resized
autocmd('VimResized', {
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Remove trailing whitespace on write
autocmd('BufWritePre', {
  pattern = '*',
  command = ":%s/\\s\\+$//e"
})

-- Format JSON on write
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup("format-file", {}),
  pattern = '*.json',
  command = ":%!jq"
})

-- Don't auto comment new lines
autocmd('BufEnter', {
  pattern = '*',
  command = 'set fo-=c fo-=r fo-=o'
})

-- No backup, swapfile, undofile for gopass
autocmd({'BufRead', 'BufNewFile'}, {
  pattern = { '/dev/shm/gopass*' },
  command = ' setlocal noswapfile nobackup noundofile shada="" '
})

--Fold
autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
  group = augroup('TS_FOLD_WORKAROUND', {}),
  callback = function()
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
  end
})

--Create directory on save
autocmd('BufWritePre', {
  pattern = "*",
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(ctx)
    local dir = vim.fn.fnamemodify(ctx.file, ":p:h")
    vim.fn.mkdir(dir, "p")
  end
})

-- Close some filetype with 'q'
-- Modified from https://github.com/loctvl842/nvim/blob/master/lua/tvl/core/autocmds.lua
autocmd("FileType", {
  group = augroup("close_with_q", {}),
  pattern = {
    "qf",
    -- "help",
    "man",
    "notify",
    "lspinfo",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Open help in a new buffer instead of a vsplit
autocmd('BufWinEnter', {
  pattern = '*',
  callback = function(event)
    if vim.bo[event.buf].filetype == 'help' then
      vim.cmd.only()
      vim.bo.buflisted = true
    end
  end,
})

--Toggle relative number in Insert mode
local numbertogglegroup = augroup("numbertoggle", { clear = true })

autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave' }, {
  pattern = '*',
  callback = function() vim.wo.relativenumber = true end,
  group = numbertogglegroup,
})
autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter' }, {
  pattern = '*',
  callback = function() vim.wo.relativenumber = false end,
  group = numbertogglegroup,
})


-- Highlights

autocmd('BufReadPost', {
  group = Date,
  callback = function() vim.cmd.hi('Date guifg=#FC4769') end,
})

autocmd('BufReadPost', {
  group = Url,
  callback = function() vim.cmd.hi('Url gui=underline,italic') end,
})


--SKELETON

--HTML
autocmd('BufNewFile', {
  pattern = '*.html',
  command = '0r ~/.config/nvim/skeletons/html-skeleton.html'
})

--CSS
autocmd('BufNewFile', {
  pattern = {'style.css', 'reset.css'},
  command = '0r ~/.config/nvim/skeletons/css-reset.css'
})
