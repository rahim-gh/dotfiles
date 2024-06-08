-- Some options are enabled through mini.basics

--CONTEXT
vim.o.colorcolumn    = ''
vim.o.lcs            = "eol:↴"
vim.o.list           = true
vim.o.relativenumber = true
vim.o.ruler          = true
vim.o.scrolloff      = 4
vim.o.sidescrolloff  = 4
vim.o.syntax         = 'on'

if vim.fn.hostname() == 'pop-os' then
  vim.o.numberwidth    = 4
  vim.o.scrolloff      = 8
else
  vim.o.numberwidth    = 3
  vim.o.scrolloff      = 4
end

--FILETYPE
vim.o.encoding       = 'utf-8'
vim.o.fileencoding   = 'utf-8'
vim.o.termencoding   = 'utf-8'

--WHITESPACE
vim.o.expandtab      = true
vim.o.shiftwidth     = 4
vim.o.softtabstop    = 4
vim.o.tabstop        = 4

--WRAP
vim.o.lbr            = true
vim.o.wrap           = true
vim.o.whichwrap      = '<,>,h,l' -- move up/down at line-end

--FOLD
vim.o.foldenable     = true
vim.o.foldlevel      = 99
vim.o.foldmethod     = 'indent' --manual, indent, syntax, expr, marker

--HISTORY
vim.o.swapfile       = false
vim.o.undodir        = os.getenv("HOME") .. "/.config/nvim/.undo-history/"

--GENERAL
vim.o.autoread       = true
vim.o.ch             = 1 --commandbar height
vim.o.grepprg        = 'rg' --default grep
vim.o.lazyredraw     = true
vim.o.termguicolors  = true
vim.o.ls             = 2 --statusbar height
vim.o.spell          = false
vim.o.showmatch      = true
vim.o.timeoutlen     = 1000  --key timeout
vim.o.updatetime     = 50  --decrease update time
vim.o.formatprg      = 'jq'

--From: https://this-week-in-neovim.org/2023/Jan/9
local ns = vim.api.nvim_create_namespace('toggle_hlsearch')

local function toggle_hlsearch(char)
  if vim.fn.mode() == 'n' then
    local keys = { '<CR>', 'n', 'N', '*', '#', '?', '/' }
    local new_hlsearch = vim.tbl_contains(keys, vim.fn.keytrans(char))

    if vim.opt.hlsearch:get() ~= new_hlsearch then
      vim.opt.hlsearch = new_hlsearch
    end

  end
end

vim.on_key(toggle_hlsearch, ns)
