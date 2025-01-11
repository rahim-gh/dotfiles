-- my config
require("rahim")


-- Set clipboard to use xclip
vim.opt.clipboard = "unnamedplus"

-- Ensure xclip is used for clipboard operations
vim.g.clipboard = {
  name = 'xclip',
  copy = {
    ["+"] = 'xclip -selection clipboard',
    ["*"] = 'xclip -selection primary',
  },
  paste = {
    ["+"] = 'xclip -selection clipboard -o',
    ["*"] = 'xclip -selection primary -o',
  },
  cache_enabled = 1,
}
