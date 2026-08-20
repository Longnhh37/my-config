-- =============================================================================
-- plugins/go.lua
-- =============================================================================
--   rustc          -> go build / go run     (không cần plugin, gọi thẳng CLI)
--   cargo          -> go mod + go build/run/test (built-in, không cần plugin)
--   rust-analyzer  -> gopls                 (lsp/languages/go.lua)
--   clippy         -> golangci-lint         (nvim-lint, chạy async bên dưới)
--   bacon          -> air (watch + auto rebuild/rerun, cài riêng, xem README)
--   bacon-ls       -> nvim-lint golangcilint chạy on save/insert-leave,
--                     stream diagnostics thẳng vào vim.diagnostic (buffer-local),
--                     gần với UX của bacon-ls nhất có thể trong Neovim.
--   codelldb (dap) -> delve, qua leoluz/nvim-dap-go (zero-config adapter)
--
-- KEYMAPS (group <leader>G, xem which-key.lua):
--   <leader>Gr   go run %                (file hiện tại, floating terminal)
--   <leader>Gt   go test ./... -v        (toàn workspace)
--   <leader>GT   go test -run <fn> -v    (test function dưới cursor, cần gopls)
--   <leader>Gb   go build ./...
--   <leader>Gm   go mod tidy
--   <leader>Gv   govulncheck ./...
--   <leader>Gl   nvim-lint: chạy golangci-lint thủ công
--   <leader>Gd   dap-go: debug test function dưới cursor
--   F5/F4/...    debug chung, dùng chung keymap với plugins/dap.lua
-- =============================================================================

-- Floating terminal dùng chung cho mọi lệnh go (giống pattern lazygit trong
-- gitsigns.lua) — không cần thêm dependency toggleterm.
local function float_run(cmd, title)
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	})

	vim.fn.termopen(cmd, {
		on_exit = function()
			vim.notify(title .. " finished", vim.log.levels.INFO)
		end,
	})
	vim.cmd("startinsert")
end

-- ===========================================================================
-- Run / build / test / mod / vuln keymaps — buffer-local, set qua FileType
-- autocmd (chạy ngay khi file này được lazy.nvim require, giống cách
-- lsp_keymaps.lua định nghĩa keymap thay vì bọc trong 1 plugin spec giả).
-- ===========================================================================
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	group = vim.api.nvim_create_augroup("go_keymaps", { clear = true }),
	callback = function(ev)
		local map = function(lhs, cmd, title)
			vim.keymap.set("n", lhs, function()
				float_run(cmd, title)
			end, { buffer = ev.buf, desc = "Go: " .. title })
		end

		map("<leader>gr", { "go", "run", "." }, "go run .")
		map("<leader>gt", { "go", "test", "./...", "-v" }, "go test ./...")
		map("<leader>gb", { "go", "build", "./..." }, "go build ./...")
		map("<leader>gm", { "go", "mod", "tidy" }, "go mod tidy")
		map("<leader>gv", { "govulncheck", "./..." }, "govulncheck ./...")

		-- Test function dưới cursor: dùng LSP để lấy tên hàm gần nhất
		vim.keymap.set("n", "<leader>gT", function()
			local fn_name = vim.fn.expand("<cword>")
			local ts_ok, node = pcall(vim.treesitter.get_node)
			if ts_ok and node then
				while node do
					if node:type() == "function_declaration" then
						local name_node = node:field("name")[1]
						if name_node then
							fn_name = vim.treesitter.get_node_text(name_node, ev.buf)
						end
						break
					end
					node = node:parent()
				end
			end
			float_run({ "go", "test", "-run", "^" .. fn_name .. "$", "-v", "./..." }, "go test -run " .. fn_name)
		end, { buffer = ev.buf, desc = "Go: test function under cursor" })
	end,
})

return {
	-- ===========================================================================
	-- nvim-dap-go — zero-config delve adapter, plug vào dap.lua đã có sẵn
	-- ===========================================================================
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = { "mfussenegger/nvim-dap" },
		opts = {
			delve = {
				detached = vim.fn.has("win32") == 0,
			},
		},
	},

	-- ===========================================================================
	-- nvim-lint — chạy golangci-lint async, tương đương "bacon watch clippy"
	-- ===========================================================================
	{
		"mfussenegger/nvim-lint",
		ft = "go",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = lint.linters_by_ft or {}
			lint.linters_by_ft.go = { "golangcilint" }

			local group = vim.api.nvim_create_augroup("go_lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
				group = group,
				pattern = "*.go",
				callback = function()
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>gl", function()
				lint.try_lint()
			end, { desc = "Go: Lint (golangci-lint)" })
		end,
	},

}
