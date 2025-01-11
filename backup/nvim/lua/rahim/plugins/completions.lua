return {
	{
		-- rich to the lsp for the completion recommendations and cmp will expand those extensions
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			-- LuaSnip completion engine
			"saadparwaiz1/cmp_luasnip",
			-- vscode snippets
			"rafamadriz/friendly-snippets",
		},
	},
	-- autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			-- snippets
		},
		config = function()
			local cmp = require("cmp")
			-- load vscode snippets to luasnip
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				sources = cmp.config.sources({
					-- sources to the completions
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["C-e"] = cmp.mapping.abort(),
					["C-p"] = cmp.mapping.select_prev_item(cmp),
					["C-n"] = cmp.mapping.select_next_item(cmp),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
				}),
				snippet = {
					-- run on snippet request
					expand = function(args)
						-- require("luasnip").lsp_expand(args.body) -- snipppet extension function
						vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
					end,
				},
			})
		end,
	},
}
