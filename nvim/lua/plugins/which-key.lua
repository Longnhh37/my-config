-- plugins/which-key.lua
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		delay = 200,
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		wk.add({
			{ "s", desc = "flash jump" },
			{ "S", desc = "flash jump" },
			-- gs
			{ "gs", group = "surround" },
			-- <leader>
			{ "<leader>a", group = "Parameter swap" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>f", group = "Find" },
			{ "<leader>h", group = "Git (hunks)" },
			{ "<leader>ht",group = "Git (toggle)" },
			{ "<leader>g", group = "Go" },
			{ "<leader>i", group = "Inlay hint" },
			{ "<leader>l", group = "LSP" },
			{ "<leader>o", group = "Oil" },
			{ "<leader>s", group = "Spectre" },
			{ "<leader>t", group = "Trouble" },
			{ "<leader>T", group = "Tab" },
			{ "<leader>x", group = "Delete" },
			{ "<leader>r", group = "Rust" },
			-- Visual mode
			{ "<leader>l", group = "LSP", mode = "v" },
			{ "<leader>s", group = "Spectre", mode = "v" },
		})
		-- Hide buffer-jump keys (1–9) from popup — keymaps still work,
		-- registered in bufferline.lua. Shown slots = noise since count varies.
		do
			local hidden = {}
			for i = 1, 9 do
				table.insert(hidden, { "<leader>b" .. i, hidden = true })
			end
			wk.add(hidden)
		end
	end,
}
