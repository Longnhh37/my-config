-- =============================================================================
-- init.lua  –  Entry point
-- =============================================================================
--  Order: core modules → lazy-setup (plugin manager).
-- =============================================================================

-- Core (không phụ thuộc plugin)
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.filetypes")
require("core.diagnostics")
require("core.clipboard")
require("core.lsp_init")

-- Plugins (lazy.nvim scan lua/plugins/*.lua)
require("lazy-setup")
