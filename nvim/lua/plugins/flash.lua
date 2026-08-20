-- =============================================================================
-- plugins/flash.lua  –  Fast motion / jump  (folke/flash.nvim)
-- =============================================================================
-- KEYMAPS:
--   n/x/o  s   flash jump: jump to start of match
--   n/x/o  S   flash jump: jump to end of match
--
-- USAGE:
--   Press s/S, type 1–2 chars of the target word, then press the highlighted
--   label to jump.  Works in operator-pending mode (e.g. ds<label> to delete
--   to target, ys<label> to yank, cs<label> to change).
-- =============================================================================

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
		},
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					jump = { pos = "end" },
				})
			end,
		},
	},
}
