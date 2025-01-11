-- formatter
return {
	"stevearc/conform.nvim",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				go = { "goimports-reviser" }, -- gofmt is not in mason, it is a part of golang toolchain
				python = { "black" },
				lua = { "stylua" },
				html = { "prettier" },
				json = { "biome" },
				markdown = { "prettier" },
				javascript = { "biome" },
				typescript = { "biome" },
			},
			-- formatters = {
			-- 	golines = {
			-- 		command = "golines",
			-- 		args = {
			-- 			"-m",
			-- 			"100",
			-- 		},
			-- 	},
			-- },
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 500, lsp_format = "fallback" }
			end,
		})
		-- Helper function to check if there is a visual selection
		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 500 })
		end, { desc = "Format file" })
	end,
}
