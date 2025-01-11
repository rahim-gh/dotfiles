-- linter
return {
	"mfussenegger/nvim-lint",
	event = {
		"BufREadPre",
		"BufNewFile",
	},
	config = function()
		local lint = require("lint")

		lint.linters.golangci_lint = {
			args = {
				"run",
				"--out-format",
				"line-number",
				"--max-line-len",
				"100",
			},
		}
		lint.linters_by_ft = {
			golang = { "golangci-lint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})

		vim.keymap.set("n", "<leader>cl", function()
			lint.try_lint()
		end, { desc = "Trigger linting" })
	end,
}
