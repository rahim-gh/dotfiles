return {
	-- bottom bar
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lualine").setup({
			options = {
				-- theme = "kanagawa-",
				section_separators = { left = "", right = "" },
				component_separators = { left = "|", right = "|" },
			},
			sections = {
				lualine_c = {
					{
						"filename",
						-- path = 1,
					},
				},
				lualine_x = {
					"filetype",
				},
			},
			inactive_sections = {
				lualine_x = { "fileformat", "encoding" },
			},
		})
	end,
}

-- return {
-- 	{
-- 	    "SmiteshP/nvim-navic",
-- 	    dependencies = {
-- 	        "neovim/nvim-lspconfig"
-- 	    },
-- 	},
-- }
