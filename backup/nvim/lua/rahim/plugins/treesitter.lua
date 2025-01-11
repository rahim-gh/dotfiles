return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- execute on install/update
		build = ":TSUpdate",
		opts = {
			-- ensure_installed = { "lua", "vim", "vimdoc", "go", "gomod", "gosum", "gowork", "zig", "python", "html"},
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"odin",
				"python",
				"html",
				"json",
			},
			highlight = { enable = true },
			indent = { enable = true },
			sync_install = false,
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup()
		end,
	},
}
