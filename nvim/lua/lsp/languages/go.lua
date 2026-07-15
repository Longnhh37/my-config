-- =============================================================================
-- lsp/languages/go.lua
-- =============================================================================
-- Server  : gopls (diagnostics, completion, staticcheck, vet, inlay hints)
-- Lint    : gopls (vet + staticcheck) + golangci-lint qua nvim-lint (plugins/go.lua)
--           -> gopls lo real-time trong buffer, golangci-lint lo bộ linter đầy đủ
--              (revive, gosec, gocritic, ...) khi save/insert-leave, tương tự
--              bacon-ls chạy nền và stream diagnostics.
-- Format  : goimports + gofumpt via conform.nvim (KHÔNG dùng gopls format để
--           tránh double-format / conflict với conform)
-- Debug   : delve via nvim-dap-go (plugins/go.lua)
-- =============================================================================

local M = {}

function M.setup(on_attach, capabilities)
	if vim.fn.executable("gopls") == 0 then
		vim.notify("gopls not found. Run: go install golang.org/x/tools/gopls@latest", vim.log.levels.WARN)
		return {}
	end

	vim.lsp.config("gopls", {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_markers = { "go.work", "go.mod", ".git" },
		capabilities = capabilities,

		-- gofumpt CLI (conform.nvim) đã lo format -> tắt formatting provider của
		-- gopls để tránh 2 formatter tranh nhau trên BufWritePre, giống cách
		-- ruff.lua tắt hover/format vì pyright/ruff chia việc nhau.
		on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			on_attach(client, bufnr)
		end,

		settings = {
			gopls = {
				staticcheck = true,
				usePlaceholders = true,
				completeUnimported = true,

				analyses = {
					unusedparams = true,
					unusedwrite = true,
					nilness = true,
					useany = true,
					shadow = true,
				},

				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},

				codelenses = {
					gc_details = false,
					generate = true,
					regenerate_cgo = true,
					run_govulncheck = true,
					test = true,
					tidy = true,
					upgrade_dependency = true,
					vendor = true,
				},

				directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
			},
		},
	})

	return { "gopls" }
end

return M
