-- =============================================================================
-- lsp/languages/lua_lang.lua
-- =============================================================================
-- Servers : lua_ls (diagnostics, completion, type inference)
-- Lint    : lua_ls
-- Format  : stylua via conform.nvim
-- =============================================================================

local M = {}

function M.setup(on_attach, capabilities)
    vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
            },
        },
    })

    return { "lua_ls" }
end

return M
