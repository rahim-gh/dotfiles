return {
	"olexsmir/gopher.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("gopher").setup()
	end,
	ft = { "go", "gomod" },
}
