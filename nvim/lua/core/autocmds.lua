-- =============================================================================
-- core/autocmds.lua  –  General editor autocommands
-- =============================================================================
-- USAGE:
--   Plugin-specific autocommands live inside each plugin's own file.
--   This file only holds editor-level behaviour.
--
-- AUTOCOMMANDS:
--   TextYankPost              highlight yanked region for 200 ms (IncSearch hl)
--   FocusGained / BufEnter    checktime → auto-reload file changed externally
--   BufEnter                  remove 'c','r','o' from formatoptions
--                             (no auto-comment continuation on new lines)
--   BufWritePre               auto-create missing parent directories on save
--   TermOpen                  start insert mode + hide line numbers in :term
--   FileType qf               map 'q' → :cclose inside quickfix window
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup("GeneralAutocmds", { clear = true })

-- Brief yank highlight (msecs controlled by timeout).
autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
	desc = "Highlight yanked text",
})

-- Reload file when Neovim regains focus or a buffer is entered.
autocmd({ "FocusGained", "BufEnter" }, {
	group = augroup,
	command = "checktime",
	desc = "Auto-reload file when changed externally",
})

-- Prevent auto-continuation of comment leaders on new lines.
autocmd("BufEnter", {
	group = augroup,
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable comment continuation",
})
