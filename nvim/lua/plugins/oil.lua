-- =============================================================================
-- plugins/oil.lua  –  File manager as a buffer  (stevearc/oil.nvim)
-- =============================================================================
-- GLOBAL KEYMAPS:
--   n  -          open oil in parent directory of current file (+ auto preview)
--   <leader>o.    go to ~/.config/nvim/lua
--   <leader>o~    go to HOME (~)
--   <leader>or    go to project root (.git / pyproject.toml / etc.)
--   <leader>oc    go to CWD
--   <leader>od    prompt for arbitrary directory path
--   <leader>oM    :cd into currently open oil directory
--   <leader>oy    yank absolute path of entry to + register
--   <leader>oY    yank filename only to + register
--
-- OIL BUFFER KEYMAPS  (active only inside oil buffers):
--   Navigation & core:
--     q / <Esc>   close oil (smart, preserves layout via mini.bufremove)
--     <CR>        open entry / confirm rename
--     - / `       go up one directory
--     <leader>R   refresh (reopen current dir, discards unsaved changes)
--     <leader>w   apply / save all pending changes (rename, delete, create)
--
--   Open modes:
--     <leader>ov  open entry in vertical split
--     <leader>oh  open entry in horizontal split
--     <leader>ot  open entry in new tab
--     <leader>op  toggle preview pane
--     gx          open with system default app (xdg-open / open)
--
--   File view:
--     g.          toggle hidden files
--
-- OPTIONS:
--   Sorted: directories first, then by name.
--   preview auto-opens and updates on cursor move.
--   delete_to_trash = true (macOS trash / system trash).
--   Hidden files are hidden by default (toggle with g.).
--
-- =============================================================================

return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-mini/mini.icons" },
	cmd = "Oil",
	keys = {
		{
			"-",
			function()
				require("oil").open()
				vim.defer_fn(function()
					require("oil").open_preview()
				end, 100)
			end,
			desc = "Oil: open parent dir",
		},
		-- ── Directory shortcuts (global) ────────────────────────────────────────
		{
			"<leader>o.",
			function()
				require("oil").open(vim.fn.expand("~/.config/nvim/lua"))
			end,
			desc = "Oil: go nvim config",
		},
		{
			"<leader>o~",
			function()
				require("oil").open(vim.fn.expand("~"))
			end,
			desc = "Oil: go HOME",
		},
		{
			"<leader>or",
			function()
				local root = vim.fs.root(0, { ".git", "pyproject.toml", "package.json", "Makefile" })
				if root then
					require("oil").open(root)
				else
					vim.notify("No project root found", vim.log.levels.WARN)
				end
			end,
			desc = "Oil: go project root",
		},
		{
			"<leader>oc",
			function()
				require("oil").open(vim.fn.getcwd())
			end,
			desc = "Oil: go CWD",
		},
		{
			"<leader>od",
			function()
				local path = vim.fn.input("Oil: Go to directory: ", "", "dir")
				vim.api.nvim_echo({}, false, {})
				if path == nil or path == "" then
					return
				end
				require("oil").open(path)
			end,
			desc = "Oil: go directory",
		},
		{
			"<leader>oM",
			function()
				local dir = require("oil").get_current_dir()
				if dir then
					vim.cmd("cd " .. vim.fn.fnameescape(dir))
					vim.notify("cwd → " .. dir, vim.log.levels.INFO)
				else
					vim.notify("Not inside an oil buffer", vim.log.levels.WARN)
				end
			end,
			desc = "Oil: cd into current dir",
		},
		-- ── Clipboard (global) ───────────────────────────────────────────────────
		{
			"<leader>oy",
			function()
				local o = require("oil")
				local entry = o.get_cursor_entry()
				local dir = o.get_current_dir()
				if entry and dir then
					local full = dir .. entry.name
					vim.fn.setreg("+", full)
					vim.notify("Yanked: " .. full, vim.log.levels.INFO)
				else
					vim.notify("No oil entry under cursor", vim.log.levels.WARN)
				end
			end,
			desc = "Oil: yank path to clipboard",
		},
		{
			"<leader>oY",
			function()
				local entry = require("oil").get_cursor_entry()
				if entry then
					vim.fn.setreg("+", entry.name)
					vim.notify("Yanked name: " .. entry.name, vim.log.levels.INFO)
				else
					vim.notify("No oil entry under cursor", vim.log.levels.WARN)
				end
			end,
			desc = "Oil: yank filename",
		},
	},
	opts = {
		sort = {
			{ "type", "asc" },
			{ "name", "asc" },
		},
		use_default_keymaps = false,
		default_file_explorer = true,
		skip_confirm_for_simple_edits = true,
		delete_to_trash = true,
		view_options = { show_hidden = true },
		preview = {
			enabled = true,
			update_on_cursor_moved = true,
		},
	},
	config = function(_, opts)
		require("oil").setup(opts)

		-- ── Buffer-local keymaps (oil buffers only) ──────────────────────────────
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			desc = "Oil buffer-local keymaps",
			callback = function(args)
				local buf = args.buf
				local map = function(lhs, rhs, desc)
					vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
				end

				-- Navigation & core
				local function close_oil()
					require("mini.bufremove").delete(0, false)
				end
				map("q", close_oil, "Oil: close (keep layout)")
				map("<Esc>", close_oil, "Oil: close (keep layout)")
				map("<CR>", function()
					require("oil").select()
				end, "Oil: open / confirm edit")
				map("-", function()
					require("oil").open()
				end, "Oil: go up one dir")
				map("`", function()
					require("oil").open()
				end, "Oil: go up one dir (alt)")

				-- Refresh / discard changes
				map("<leader>R", function()
					require("oil").open(require("oil").get_current_dir())
				end, "Oil: refresh / discard changes")

				-- Save / apply changes
				map("<leader>w", function()
					require("oil").save()
				end, "Oil: apply changes")

				-- Toggle hidden files
				map("g.", function()
					require("oil").toggle_hidden()
				end, "Oil: toggle hidden files")

				-- Open modes
				map("<leader>ov", function()
					require("oil").select({ vertical = true })
				end, "Oil: open vsplit")
				map("<leader>oh", function()
					require("oil").select({ horizontal = true })
				end, "Oil: open hsplit")
				map("<leader>ot", function()
					require("oil").select({ tab = true })
				end, "Oil: open in new tab")
				map("<leader>op", function()
					require("oil").toggle_preview()
				end, "Oil: toggle preview")

				-- Open with system app
				map("gx", function()
					local o = require("oil")
					local entry = o.get_cursor_entry()
					local dir = o.get_current_dir()
					if entry and dir then
						vim.ui.open(dir .. entry.name)
					end
				end, "Oil: open with system app")
			end,
		})
	end,
}
