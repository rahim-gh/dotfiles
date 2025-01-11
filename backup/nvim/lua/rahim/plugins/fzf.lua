return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	opts = {
		oldfiles = {
			include_current_session = true,
		},
		previews = {
			builtin = {
				syntax_limit_b = 1024 * 100, -- 100KB
			},
		},
	},
	keys = {
		-- file picker
		-- { "<leader>p", "", desc = "File picker" },
		-- find files in current directory
		{ "<leader>f", "", { root = true }, desc = "Fuzzy find" },
		{ "<leader>ff", "<cmd>FzfLua files<cr>", { root = true }, desc = "Files" },
		{ "<leader>fo", "<cmd>FzfLua buffers<cr>", { root = true }, desc = "Buffers (opened)" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles<cr>", { root = true }, desc = "Old/recent files" },
		-- grep (live grep)
		{ "<leader>fg", "<cmd>FzfLua grep<cr>", { root = true }, desc = "Grep" },
		{ "<leader>fg", "<cmd>FzfLua grep_visual<cr>", mode = { "v" }, desc = "Visual Grep" },
		{ "<leader>fj", "<cmd>FzfLua jumps<cr>", { root = true }, desc = "Jumps" },
		{ "<leader>fp", "<cmd>FzfLua grep<cr>", { root = true }, desc = "Projects" },
		{ "<leader>fR", "<cmd>FzfLua lsp_references<cr>", { root = true }, desc = "References" },
		{ "<leader>fi", "<cmd>FzfLua lsp_implementations<cr>", { root = true }, desc = "Implementations" },
		{ "<leader>fd", "<cmd>FzfLua lsp_definitions<cr>", { root = true }, desc = "Definitions" },
		{ "<leader>fd", "<cmd>FzfLua lsp_declarations<cr>", { root = true }, desc = "Declarations" },
		{ "<leader>cs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Buffer symbols" },
		{ "<leader>ps", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace symbols" },
		{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps docs" },
		{ "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix" },

		{ "<leader>fc", "<cmd>FzfLua colorschemes<cr>", desc = "Colorschemes" },
		{ "<leader>fh", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
		-- leader h to switch hints
	},
}
