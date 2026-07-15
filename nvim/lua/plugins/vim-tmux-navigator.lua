-- =============================================================================
-- lua/plugins/vim-tmux-navigator.lua
--
-- Seamless C-h/j/k/l navigation between nvim splits AND tmux panes.
--
-- HOW IT WORKS:
--   nvim side  → plugin sends C-h/j/k/l; if at the edge of nvim,
--                it signals tmux to select-pane in that direction.
--   tmux side  → smart is_vim check: if nvim is focused, pass keystrokes
--                through to nvim; otherwise tmux handles pane selection.
--
-- REQUIREMENTS:
--   1. christoomey/vim-tmux-navigator (this file)
--   2. The matching smart bindings in ~/.tmux.conf
-- =============================================================================

return {
	"christoomey/vim-tmux-navigator",

	-- Load immediately — navigation must be available in every buffer
	lazy = false,

	init = function()
		-- Disable the plugin's own <C-\> mapping (rarely needed, saves a keyslot)
		vim.g.tmux_navigator_no_mappings = 1

		-- When nvim is the last window and you navigate out, don't close nvim
		vim.g.tmux_navigator_disable_when_zoomed = 1

		-- Save the current buffer before navigating away (optional, safe default)
		vim.g.tmux_navigator_save_on_switch = 2
	end,

	config = function()
		local map = vim.keymap.set
		local opts = { silent = true }

		-- Core navigation — same keys as tmux smart bindings
		map("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>",  vim.tbl_extend("force", opts, { desc = "Navigate left  (nvim/tmux)" }))
		map("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>",  vim.tbl_extend("force", opts, { desc = "Navigate down  (nvim/tmux)" }))
		map("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>",    vim.tbl_extend("force", opts, { desc = "Navigate up    (nvim/tmux)" }))
		map("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", vim.tbl_extend("force", opts, { desc = "Navigate right (nvim/tmux)" }))

		-- Also map in terminal mode so it works inside :term buffers
		map("t", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>",  opts)
		map("t", "<C-j>", "<Cmd>TmuxNavigateDown<CR>",  opts)
		map("t", "<C-k>", "<Cmd>TmuxNavigateUp<CR>",    opts)
		map("t", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", opts)
	end,
}
