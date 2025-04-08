-- HELLO, welcome to NormalNvim!
-- ----------------------------------------
-- Here you can define your nvim variables.
-- ----------------------------------------

-- Theme
-- vim.g.default_colorscheme = "tokyonight-night"
--vim.g.default_colorscheme = "monokai-pro"
if vim.g.neovide then
  vim.g.neovide_scale_factor=0.7
end


-- Options --------------------------------------------------------------------
vim.opt.breakindent = true -- Wrap indent to match  line start.
vim.opt.clipboard = "unnamedplus" -- Connection to the system clipboard.
vim.opt.cmdheight = 0 -- Hide command line unless needed.
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Options for insert mode completion.
vim.opt.copyindent = true -- Copy the previous indentation on autoindenting.
vim.opt.cursorline = true -- Highlight the text line of the cursor.
vim.opt.expandtab = true -- Enable the use of space in tab.
vim.opt.fileencoding = "utf-8" -- File content encoding for the buffer.
vim.opt.fillchars = { eob = " " } -- Disable `~` on nonexistent lines.
vim.opt.foldenable = true -- Enable fold for nvim-ufo.
vim.opt.foldlevel = 99 -- set highest foldlevel for nvim-ufo.
vim.opt.foldlevelstart = 99 -- Start with all code unfolded.
vim.opt.foldcolumn = "1" -- Show foldcolumn in nvim 0.9+.
vim.opt.ignorecase = true -- Case insensitive searching.
vim.opt.infercase = true -- Infer cases in keyword completion.

vim.opt.laststatus = 3 -- Global statusline.
vim.opt.linebreak = true -- Wrap lines at 'breakat'.
vim.opt.number = true -- Show numberline.
vim.opt.preserveindent = true -- Preserve indent structure as much as possible.
vim.opt.pumheight = 10 -- Height of the pop up menu.
vim.opt.relativenumber = false -- Show relative numberline.
vim.opt.shiftwidth = 2 -- Number of space inserted for indentation.
vim.opt.showmode = true -- Disable showing modes in command line.
vim.opt.showtabline = 2 -- always display tabline.
vim.opt.signcolumn = "no" -- Always show the sign column.
vim.opt.smartcase = true -- Case sensitivie searching.
vim.opt.smartindent = true -- Smarter autoindentation.
vim.opt.splitbelow = true -- Splitting a new window below the current one.
vim.opt.splitright = true -- Splitting a new window at the right of the current one.
vim.opt.tabstop = 2 -- Number of space in a tab.

vim.opt.termguicolors = true -- Enable 24-bit RGB color in the TUI.
vim.opt.undofile = true -- Enable persistent undo between session and reboots.
vim.opt.updatetime = 300 -- Length of time to wait before triggering the plugin.
vim.opt.virtualedit = "block" -- Allow going past end of line in visual block mode.
vim.opt.writebackup = false -- Disable making a backup before overwriting a file.
vim.opt.shada = "!,'1000,<50,s10,h" -- Remember the last 1000 opened files
vim.opt.history = 1000 -- Number of commands to remember in a history table (per buffer).
vim.opt.swapfile = false -- Ask what state to recover when opening a file that was not saved.
vim.opt.wrap = false-- Disable wrapping of lines longer than the width of window.
vim.opt.colorcolumn = "80" -- PEP8 like character limit vertical bar.
vim.opt.mousescroll = "ver:1,hor:0" -- Disables hozirontal scroll in neovim.
vim.opt.guicursor = "n:blinkon200,i-ci-ve:ver25" -- Enable cursor blink.
vim.opt.autochdir = true -- Use current file dir as working dir (See project.nvim).
vim.opt.scrolloff = 1000 -- Number of lines to leave before/after the cursor when scrolling. Setting a high value keep the cursor centered.
vim.opt.sidescrolloff = 8 -- Same but for side scrolling.
vim.opt.selection = "old" -- Don't select the newline symbol when using <End> on visual mode.

vim.opt.viewoptions:remove "curdir" -- Disable saving current directory with views.
vim.opt.shortmess:append { s = true, I = true } -- Disable startup message.
vim.opt.backspace:append { "nostop" } -- Don't stop backspace at insert.
vim.opt.diffopt:append { "algorithm:histogram", "linematch:60" } -- Enable linematch diff algorithm

local is_android = vim.fn.isdirectory('/data') == 1
if is_android then vim.opt.mouse = "v" else vim.opt.mouse = "a" end -- Enable scroll for android

-- Globals --------------------------------------------------------------------
vim.g.mapleader = " " -- Set leader key.
vim.g.maplocalleader = "," -- Set default local leader key.
vim.g.big_file = { size = 1024 * 5000, lines = 50000 } -- For files bigger than this, disable 'treesitter' (+5Mb).

-- The next globals are toggleable with <space + l + u>
vim.g.autoformat_enabled = false -- Enable auto formatting at start.
vim.g.autopairs_enabled = true -- Enable autopairs at start.
vim.g.cmp_enabled = true -- Enable completion at start.
vim.g.codeactions_enabled = true -- Enable displaying 💡 where code actions can be used.
vim.g.codelens_enabled = true -- Enable automatic codelens refreshing for lsp that support it.
vim.g.diagnostics_mode = 3 -- Set code linting (0=off, 1=only show in status line, 2=virtual text off, 3=all on).
vim.g.fallback_icons_enabled = false -- Enable it if you need to use Neovim in a machine without nerd fonts.
vim.g.inlay_hints_enabled = true -- Enable always show function parameter names.
vim.g.lsp_round_borders_enabled = true -- Enable round borders for lsp hover and signatureHelp.
vim.g.lsp_signature_enabled = true -- Enable automatically showing lsp help as you write function parameters.
vim.g.notifications_enabled = true -- Enable notifications.
vim.g.semantic_tokens_enabled = true -- Enable lsp semantic tokens at start.
vim.g.url_effect_enabled = true -- Highlight URLs with an underline effect.

-- Lazygit options
vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
vim.g.lazygit_floating_window_border_chars = {'╭','─', '╮', '│', '╯','─', '╰', '│'} -- customize lazygit popup window border characters
vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

vim.g.lazygit_use_custom_config_file_path = 0 -- config file path is evaluated if this value is 1
vim.g.lazygit_config_file_path = '' -- custom config file path
-- OR
vim.g.lazygit_config_file_path = {} -- table of custom config file paths

vim.g.lazygit_on_exit_callback = nil -- optional function callback when exiting lazygit (useful for example to refresh some UI elements after lazy git has made some changes)
