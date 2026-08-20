return {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	priority = 1000,
	opts = {
		transparent_background = false,
		integrations = {
			gitsigns = true,
			marks = true,
			treesitter = true,
			native_lsp = { enabled = true },
			navic = true,
			render_markdown = true,
		},
	},
	config = function(_, opts)
		vim.g.catppuccin_flavour = "frappe"
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin-nvim")
	end,
}
