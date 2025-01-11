return {
	-- {
	-- 	"NeogitOrg/neogit",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim", -- required
	-- 		"sindrets/diffview.nvim", -- optional - Diff integration
	--
	-- 		-- Only one of these is needed.
	-- 		"nvim-telescope/telescope.nvim", -- optional
	-- 	},
	-- 	config = true,
	-- },
	{
		"tpope/vim-fugitive",
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		keys = {
			    { "<leader>vh", "<cmd>Gitsigns preview_hunk<cr>", desc = "View git hunks/changes" },
			{ "<leader>vb", "<cmd>Gitsigns blame<cr>", desc = "Blame" },
		},
		opts = {

        },
	},
	{
		"sindrets/diffview.nvim",
	},
}
