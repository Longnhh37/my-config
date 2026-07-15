-- =============================================================================
-- plugins/bufferline.lua  –  Buffer tab bar  (akinsho/bufferline.nvim)
-- =============================================================================
return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "VeryLazy",
	keys = function()
		local keys = {
			{ "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Buffer: Next" },
			{ "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Buffer: Previous" },
		}
		local max_slots = 9
		for i = 1, max_slots do
			table.insert(keys, {
				"<leader>b" .. i,
				function()
					require("bufferline").go_to(i, true)
				end,
				desc = "Buffer: Go to " .. i,
			})
		end
		return keys
	end,
	opts = {
		options = {
			diagnostics = false,
			show_buffer_icons = false,
			show_close_icon = false,
			show_buffer_close_icons = true,
			buffer_close_icon = "×",
			separator_style = "thin",
			-- [N]
			numbers = function(opts)
				return string.format("[%d]", opts.ordinal)
			end,
			-- Only show filename (no parent directory)
			name_formatter = function(buf)
				return vim.fn.fnamemodify(buf.path, ":t")
			end,
			-- ● when modified
			modified_icon = "●",
			close_icon = "",
		},
	},
}
