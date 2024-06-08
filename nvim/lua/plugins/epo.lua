return {
  'nvimdev/epo.nvim',
  event = 'LspAttach',
  config = function()
    require('epo').setup({
      -- fuzzy match
      fuzzy = false,
      -- increase this value can aviod trigger complete when delete character.
      debounce = 50,
      -- when completion confrim auto show a signature help floating window.
      signature = false,
      -- border for lsp signature popup, :h nvim_open_win
      signature_border = 'rounded',
      -- lsp kind formatting, k is kind string "Field", "Struct", "Keyword" etc.
      kind_format = function(k)
        return k:lower():sub(1, 1)
      end
    })
  end,
}
