-- =============================================================================
-- lua/utils/codelldb.lua
-- Shared codelldb adapter config for nvim-dap (C/C++) and rustaceanvim.
--
-- Usage in dap.lua:
--   local codelldb = require("utils.codelldb")
--   dap.adapters.codelldb  = codelldb.adapter
--   dap.configurations.c   = codelldb.configurations()
--
-- Usage in rust.lua:
--   local codelldb = require("utils.codelldb")
--   vim.g.rustaceanvim = { dap = { adapter = codelldb.rustaceanvim_adapter() } }
-- =============================================================================
local M = {}

-- Plain adapter table — no external deps at load time.
M.adapter = {
	type = "server",
	port = "${port}",
	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}

-- Launch/attach configs for C / C++ / Rust (call inside dap config fn so dap.utils is already loaded).
function M.configurations()
	return {
		{
			name = "Launch (codelldb)",
			type = "codelldb",
			request = "launch",
			program = function()
				return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			terminal = "integrated",
		},
		{
			name = "Attach (codelldb)",
			type = "codelldb",
			request = "attach",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
		},
	}
end

-- rustaceanvim needs the raw codelldb + liblldb paths from the Mason package.
function M.rustaceanvim_adapter()
	local base = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension"
	return require("rustaceanvim.config").get_codelldb_adapter(
		base .. "/adapter/codelldb",
		base .. "/lldb/lib/liblldb.dylib"
	)
end

return M
