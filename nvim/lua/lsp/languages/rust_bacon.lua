-- =============================================================================
-- lsp/languages/rust_bacon.lua
-- =============================================================================
-- Server  : bacon-ls (diagnostics only, bacon backend)
-- bacon-ls tự spawn bacon như subprocess → Neovim quản lý toàn bộ lifecycle
-- Requires: `cargo install --locked bacon bacon-ls`
-- Works alongside rustaceanvim (rust-analyzer) for all other LSP features
-- External `bacon` terminal: hoàn toàn optional, độc lập
--
-- rust-analyzer phải tắt diagnostics + checkOnSave
-- =============================================================================

local M = {}

function M.setup(on_attach, capabilities)
	if vim.fn.executable("bacon-ls") == 0 then
		vim.notify("bacon-ls not found. Run: cargo install --locked bacon bacon-ls", vim.log.levels.WARN)
		return {}
	end

	vim.lsp.config("bacon_ls", {
		cmd = { "bacon-ls" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", "Cargo.lock" },
		capabilities = capabilities,
		on_attach = on_attach,

		settings = {
			bacon_ls = {
				backend = "cargo",
				cargo = {
					command = "clippy",
					extraArgs = { "--workspace", "--all-targets", "--all-features" },
					checkOnSave = true,
				},
			},
		},
	})

	return { "bacon_ls" }
end

return M
