-- lua/plugins/trouble.lua
return {
	"folke/trouble.nvim",
	dependencies = { "echasnovski/mini.icons" },
	cmd = "Trouble",
	keys = {
		{
			"<leader>td",
			"<cmd>Trouble diagnostics toggle<CR>",
			desc = "Trouble: Workspace diagnostics",
		},
		{
			"<leader>tb",
			"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
			desc = "Trouble: Buffer diagnostics",
		},
		{
			"<leader>tq",
			"<cmd>Trouble qflist toggle<CR>",
			desc = "Trouble: Quickfix",
		},
		{
			"<leader>tl",
			"<cmd>Trouble loclist toggle<CR>",
			desc = "Trouble: Location list",
		},
		{
			"<leader>ts",
			"<cmd>Trouble symbols toggle focus=false<CR>",
			desc = "Trouble: Document symbols",
		},
		{
			"<leader>tL",
			"<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
			desc = "Trouble: LSP defs/refs",
		},
	},
	opts = {
    win = {
      position = "right",
      size = { width = 0.4 },
      wrap = true,
    },
		keys = {
			q = "close",
			["<esc>"] = "close",
		},
	},
}

