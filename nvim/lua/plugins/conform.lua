return {
	"stevearc/conform.nvim",

	event = { "BufWritePre" },

	keys = {
		{
			"<leader>c",
			function()
				require("conform").format({ lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Conform",
		},
	},

	opts = {
		formatters_by_ft = {
			lua = { "stylua" },

			python = {
				"ruff_format",
				"ruff_organize_imports",
			},

      go = { "goimports", "gofumpt" },

			c = { "clang-format" },
			cpp = { "clang-format" },

			-- web/frontend
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },

			json = { "prettier" },
			markdown = { "prettier" },

			rust = { "rustfmt" },
		},
	},
}
