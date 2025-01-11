return {
	-- advanced file explorer
	"stevearc/oil.nvim",
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		wrap = false,
        view_options = {
            show_hidden = true,
        }
	},
	keys = {
		{
			"<leader>e",
			function()
				require("oil").open()
			end,
			desc = "File explorer",
		},
	},
}
