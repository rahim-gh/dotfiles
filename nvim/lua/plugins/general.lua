return{
  -- https://github.com/tzachar/highlight-undo.nvim
  {
    'tzachar/highlight-undo.nvim',
    lazy = true,
    keys = {
      { 'u', 'undo', {}},
      { '<C-r>', 'redo', {}},
    },
    config = true
  },
}
