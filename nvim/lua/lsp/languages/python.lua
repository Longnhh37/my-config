-- =============================================================================
-- lsp/languages/python.lua
-- =============================================================================
-- Servers : pyright (type checking) + ruff LSP (lint + code actions)
-- Format  : ruff_format + ruff_organize_imports via conform.nvim
-- =============================================================================

local M = {}

function M.setup(on_attach, capabilities)
    local python3 = vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
        or vim.fn.exepath("python")
        or "python3"

    -- ── Pyright: type checking only ───────────────────────────────────────────
    vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,

        handlers = {
            -- Chỉ giữ error + warning, bỏ hint/info (ruff lo phần đó)
            ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
                if result and result.diagnostics then
                    result.diagnostics = vim.tbl_filter(function(d)
                        return d.severity and d.severity <= 2
                    end, result.diagnostics)
                end
                vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
            end,
        },

        settings = {
            pyright = { disableOrganizeImports = true },  -- ruff lo
            python = {
                pythonPath = python3,
                analysis = {
                    typeCheckingMode = "standard",
                    diagnosticMode = "workspace",
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticSeverityOverrides = {
                        reportUnusedImport            = "none",  -- ruff F401
                        reportUnusedVariable          = "none",  -- ruff F841
                        reportDuplicateImport         = "none",  -- ruff F811
                        reportWildcardImportFromLibrary = "none", -- ruff F403
                    },
                },
            },
        },
    })

    -- ── Ruff: lint + code actions (không format, không hover) ─────────────────
    vim.lsp.config("ruff", {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
        capabilities = capabilities,

        on_attach = function(client, bufnr)
            -- Tắt các capability pyright đã lo
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            on_attach(client, bufnr)
        end,

        init_options = {
            settings = {
                lint = {
                    select = { "E", "W", "F", "SLF", "N", "PL" },
                    ignore = {
                        "F821",
                        "F405",
                        "D203",  -- conflicts với D211
                        "D213",  -- conflicts với D212
                    },
                },
            },
        },
    })

    return { "pyright", "ruff" }
end

return M
