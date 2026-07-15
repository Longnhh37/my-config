-- =============================================================================
-- plugins/dap.lua
-- =============================================================================
-- KEYMAPS:
--   <F3>         conditional breakpoint
--   <F4>         toggle breakpoint
--   <F5>         start / continue
--   <F6>         step over
--   <F7>         step into
--   <F8>         step out
--   <F9>         stop
--   <leader>dc   clear all breakpoints
--   <leader>dr   open REPL
--   <leader>dl   run last
--   [p / ]p      jump to prev / next breakpoint
-- =============================================================================

local function get_sorted_breakpoints()
	local bps = require("dap.breakpoints").get()
	local list = {}

	for bufnr, buf_bps in pairs(bps) do
		for _, bp in ipairs(buf_bps) do
			table.insert(list, { bufnr = bufnr, line = bp.line })
		end
	end

	table.sort(list, function(a, b)
		if a.bufnr == b.bufnr then
			return a.line < b.line
		end
		return a.bufnr < b.bufnr
	end)

	return list
end

return {
	-- ===========================================================================
	-- nvim-dap core
	-- ===========================================================================
	{
		"mfussenegger/nvim-dap",
		lazy = true,

		dependencies = {
			-- UI
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
			"theHamsta/nvim-dap-virtual-text",

			-- Python
			"mfussenegger/nvim-dap-python",

			-- JavaScript / TypeScript
			{
				"mxsdev/nvim-dap-vscode-js",
				dependencies = {
					{
						"microsoft/vscode-js-debug",
						build = "npm install --legacy-peer-deps --no-package-lock && npx gulp vsDebugServerBundle && mv dist out",
					},
				},
			},
		},

		config = function()
			local dap = require("dap")
			local codelldb = require("utils.codelldb")

			-- =========================================================
			-- Python
			-- =========================================================

			local function get_python_with_debugpy()
				-- 1. Ưu tiên môi trường Conda đang active hiện tại
				local conda_prefix = os.getenv("CONDA_PREFIX")
				if conda_prefix then
					local p = conda_prefix .. "/bin/python"
					if vim.fn.executable(p) == 1 then
						return p
					end
				end

				-- 2. Tự động tìm kiếm môi trường ảo cục bộ trong dự án hiện tại (.venv hoặc venv)
				local cwd = vim.fn.getcwd()
				local local_venvs = { cwd .. "/.venv/bin/python", cwd .. "/venv/bin/python" }
				for _, p in ipairs(local_venvs) do
					if vim.fn.executable(p) == 1 then
						return p
					end
				end

				-- 3. Fallback về lệnh python3 hệ thống có sẵn trong PATH
				return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3")
					or vim.fn.exepath("python")
					or "python3"
			end

			require("dap-python").setup(get_python_with_debugpy())

			-- =========================================================
			-- C / C++ / Rust  (shared via utils.codelldb)
			-- =========================================================

			dap.adapters.codelldb = codelldb.adapter

			local c_configs = codelldb.configurations()
			dap.configurations.c = c_configs
			dap.configurations.cpp = c_configs
			-- Rust configs are managed by rustaceanvim; no entry needed here.

			-- =========================================================
			-- JavaScript / TypeScript  (vscode-js-debug)
			-- =========================================================

			require("dap-vscode-js").setup({
				node_path = "node",
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				adapters = {
					"node",
					"pwa-node",
					"chrome",
					"pwa-chrome",
					"pwa-extensionHost",
				},
			})

			local js_configs = {
				-- ── Node: launch current file ──────────────────────────
				{
					type = "pwa-node",
					request = "launch",
					name = "Launch file (Node)",
					program = "${file}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					resolveSourceMapLocations = {
						"${workspaceFolder}/**",
						"!**/node_modules/**",
					},
				},
				-- ── Node: attach to running process ────────────────────
				{
					type = "pwa-node",
					request = "attach",
					name = "Attach (Node)",
					processId = require("dap.utils").pick_process,
					cwd = "${workspaceFolder}",
					sourceMaps = true,
				},
				-- ── Chrome: launch ─────────────────────────────────────
				{
					type = "pwa-chrome",
					request = "launch",
					name = "Launch Chrome",
					url = function()
						return vim.fn.input("URL: ", "http://localhost:3000")
					end,
					webRoot = "${workspaceFolder}",
					sourceMaps = true,
				},
				-- ── Chrome: attach to existing instance ────────────────
				{
					type = "pwa-chrome",
					request = "attach",
					name = "Attach Chrome (port 9222)",
					port = 9222,
					webRoot = "${workspaceFolder}",
					sourceMaps = true,
				},
			}

			for _, lang in ipairs({
				"javascript",
				"typescript",
				"javascriptreact",
				"typescriptreact",
				"vue",
			}) do
				dap.configurations[lang] = js_configs
			end

			-- =========================================================
			-- nvim-dap-virtual-text
			-- =========================================================

			require("nvim-dap-virtual-text").setup({ commented = true })

			-- =========================================================
			-- Custom signs
			-- =========================================================

			local red = "#e78284"
			local green = "#a6d189"
			local blue = "#8caaee"

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped" })

			vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = red })
			vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = blue })
			vim.api.nvim_set_hl(0, "DapStopped", { fg = green })

			-- =========================================================
			-- dap-ui  (auto-open on launch/attach, auto-close on exit)
			-- =========================================================

			local dapui = require("dapui")
			dapui.setup()

			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,

		keys = {
			{
				"<F3>",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "DAP: Conditional Breakpoint",
			},
			{
				"<F4>",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "DAP: Toggle Breakpoint",
			},
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "DAP: Start/Continue",
			},
			{
				"<F6>",
				function()
					require("dap").step_over()
				end,
				desc = "DAP: Step Over",
			},
			{
				"<F7>",
				function()
					require("dap").step_into()
				end,
				desc = "DAP: Step Into",
			},
			{
				"<F8>",
				function()
					require("dap").step_out()
				end,
				desc = "DAP: Step Out",
			},
			{
				"<F9>",
				function()
					require("dap").terminate()
				end,
				desc = "DAP: Stop Debug",
			},
			{
				"<leader>dc",
				function()
					require("dap").clear_breakpoints()
					vim.notify("All breakpoints cleared", vim.log.levels.INFO)
				end,
				desc = "DAP: Clear All Breakpoints",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "DAP: Open REPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "DAP: Run Last",
			},

			-- ── Previous breakpoint ──────────────────────────────────────────
			{
				"[p",
				function()
					local list = get_sorted_breakpoints()
					if #list == 0 then
						vim.notify("No breakpoints set", vim.log.levels.INFO)
						return
					end

					local cur_buf = vim.api.nvim_get_current_buf()
					local cur_line = vim.fn.line(".")
					local target = list[#list] -- default: wrap to last

					for i = #list, 1, -1 do
						local e = list[i]
						if e.bufnr < cur_buf or (e.bufnr == cur_buf and e.line < cur_line) then
							target = e
							break
						end
					end

					if vim.api.nvim_buf_is_valid(target.bufnr) then
						vim.cmd("buffer " .. target.bufnr)
						vim.api.nvim_win_set_cursor(0, { target.line, 0 })
					end
				end,
				desc = "DAP: Jump Prev Breakpoint",
			},

			-- ── Next breakpoint ──────────────────────────────────────────────
			{
				"]p",
				function()
					local list = get_sorted_breakpoints()
					if #list == 0 then
						vim.notify("No breakpoints set", vim.log.levels.INFO)
						return
					end

					local cur_buf = vim.api.nvim_get_current_buf()
					local cur_line = vim.fn.line(".")
					local target = list[1] -- default: wrap to first

					for _, e in ipairs(list) do
						if e.bufnr > cur_buf or (e.bufnr == cur_buf and e.line > cur_line) then
							target = e
							break
						end
					end

					if vim.api.nvim_buf_is_valid(target.bufnr) then
						vim.cmd("buffer " .. target.bufnr)
						vim.api.nvim_win_set_cursor(0, { target.line, 0 })
					end
				end,
				desc = "DAP: Jump Next Breakpoint",
			},
		},
	},
}
