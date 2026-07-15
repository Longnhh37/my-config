-- =============================================================================
-- lsp/languages/cpp.lua
-- =============================================================================
-- Servers : clangd (diagnostics, completion, clang-tidy via --clang-tidy flag)
-- Lint    : clang-tidy embedded trong clangd
-- Format  : clang-format via conform.nvim
-- Note    : cppcheck/cpplint → chạy thủ công từ terminal nếu cần
-- =============================================================================

local M = {}

function M.setup(on_attach, capabilities)
	vim.lsp.config("clangd", {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--completion-style=detailed",
			"--header-insertion=iwyu",
		},
		filetypes = { "c", "cpp", "objc", "objcpp" },
		root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
		capabilities = capabilities,
		on_attach = on_attach,
	})
	return { "clangd" }
end

return M
