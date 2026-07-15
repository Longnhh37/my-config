local M = {}

function M.setup(on_attach, capabilities)
	local function get_cmd(binary_name)
		local mason_path = vim.fn.stdpath("data") .. "/mason/bin/" .. binary_name
		if vim.fn.executable(mason_path) == 1 then
			return mason_path
		end
		return binary_name
	end

	vim.lsp.config("html", {
		cmd = { get_cmd("vscode-html-language-server"), "--stdio" },
		filetypes = { "html" },
		root_markers = { ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})

	vim.lsp.config("cssls", {
		cmd = { get_cmd("vscode-css-language-server"), "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})

	vim.lsp.config("ts_ls", {
		cmd = { get_cmd("typescript-language-server"), "--stdio" },
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		},
		root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})

	vim.lsp.config("eslint", {
		cmd = { get_cmd("vscode-eslint-language-server"), "--stdio" },
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		},
		root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})

	vim.lsp.config("tailwindcss", {
		cmd = { get_cmd("tailwindcss-language-server"), "--stdio" },
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		},
		root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json", ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})

	vim.lsp.config("emmet_language_server", {
		cmd = { get_cmd("emmet-language-server"), "--stdio" },
		filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
		root_markers = { ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})

	return { "html", "cssls", "ts_ls", "eslint", "tailwindcss", "emmet_language_server" }
end

return M
