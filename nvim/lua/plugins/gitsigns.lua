return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		sign_priority = 120,
		signs_staged_enable = true,
		current_line_blame = true,
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end
			-- ── UI ───────────────────────────────────────────────
			map("n", "<leader>hg", function()
				local root = vim.fn.finddir(".git", ".;")
				if root == "" then
					vim.notify("Not a git repo", vim.log.levels.WARN)
					return
				end
				local buf = vim.api.nvim_create_buf(false, true)
				local width = math.floor(vim.o.columns * 0.9)
				local height = math.floor(vim.o.lines * 0.9)
				vim.api.nvim_open_win(buf, true, {
					relative = "editor",
					width = width,
					height = height,
					row = math.floor((vim.o.lines - height) / 2),
					col = math.floor((vim.o.columns - width) / 2),
					style = "minimal",
					border = "rounded",
				})
				vim.fn.termopen("lazygit", {
					on_exit = function()
						vim.api.nvim_win_close(0, true)
						vim.cmd("checktime") -- reload buffers nếu có thay đổi
					end,
				})
				vim.cmd("startinsert")
			end, "Git: Open lazygit")
			-- ── Navigation ───────────────────────────────────────────────
			map("n", "]h", function()
				gs.nav_hunk("next")
			end, "Git: Next hunk")
			map("n", "[h", function()
				gs.nav_hunk("prev")
			end, "Git: Prev hunk")
			map("n", "]H", function()
				gs.nav_hunk("last")
			end, "Git: Last hunk")
			map("n", "[H", function()
				gs.nav_hunk("first")
			end, "Git: First hunk")
			-- ── Hunk actions  (<leader>h) ────────────────────────────────
			-- stage / reset work in visual mode too (partial-hunk selection)
			map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "Git: Stage hunk")
			map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "Git: Reset hunk")
			map("n", "<leader>hS", gs.stage_buffer, "Git: Stage buffer")
			map("n", "<leader>hR", gs.reset_buffer, "Git: Reset buffer")
			-- ── Preview / inspect ────────────────────────────────────────
			map("n", "<leader>hp", gs.preview_hunk, "Git: Preview hunk (popup)")
			map("n", "<leader>hi", gs.preview_hunk_inline, "Git: Preview hunk inline")
			map("n", "<leader>hb", function()
				gs.blame_line({ full = true })
			end, "Git: Blame line (full)")
			-- ── Diff ─────────────────────────────────────────────────────
			map("n", "<leader>hd", gs.diffthis, "Git: Diff this (index)")
			map("n", "<leader>hD", function()
				gs.diffthis("~")
			end, "Git: Diff against last commit (~)")
			-- ── Toggle  (<leader>ht) ──────────────────────────────────────
			map("n", "<leader>hts", gs.toggle_signs, "Git: Toggle signs")
			map("n", "<leader>htb", gs.toggle_current_line_blame, "Git: Toggle current line blame")
			map("n", "<leader>htd", gs.toggle_deleted, "Git: Toggle deleted lines")
			map("n", "<leader>htw", gs.toggle_word_diff, "Git: Toggle word diff")
		end,
	},
}
