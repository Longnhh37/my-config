-- =============================================================================
-- plugins/spectre.lua  –  Search & Replace (project + current buffer)
-- =============================================================================
-- GLOBAL KEYMAPS:
--   <leader>sp   project search & replace
--   <leader>ss   current buffer search & replace
--   <leader>sw   search word under cursor / visual  → current buffer
--   <leader>sW   search word under cursor / visual  → project / dir
--
-- INSIDE SPECTRE PANEL:
--   <leader>st   toggle line (include/exclude)
--   <leader>sr   run replace-all
--   <leader>sc   replace current line
--   <Esc> / q    close panel
-- =============================================================================
return {
	"nvim-pack/nvim-spectre",
	cmd = "Spectre",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>sp", desc = "󰍉 Project search & replace", mode = "n" },
		{ "<leader>ss", desc = "󰍉 Current file search & replace", mode = "n" },
		{ "<leader>sw", desc = "󰍉 Search word under cursor (current file)", mode = { "n", "v" } },
		{ "<leader>sW", desc = "󰍉 Search word under cursor (project)", mode = { "n", "v" } },
	},
	config = function()
		local spectre = require("spectre")

		spectre.setup({
			open_in_new_tab = false,
			result_padding = "  ",
			line_sep_start = "┌─────────────────────────────",
			result_template = "│  [%s] %s",
			line_sep = "└─────────────────────────────",
			highlight = {
				ui = "String",
				search = "DiffChange",
				replace = "DiffDelete",
			},
			default = {
				replace = { cmd = "sed" },
			},
			mapping = {
				["toggle_line"] = {
					map = "<leader>st",
					cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
					desc = "󰒅 Toggle line (include/exclude)",
				},
				["replace_cmd"] = {
					map = "<leader>sr",
					cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
					desc = "󰛔 Run replace-all",
				},
				["run_current_replace"] = {
					map = "<leader>sc",
					cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
					desc = "󰛔 Replace current line",
				},
			},
		})

		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "*",
			callback = function(args)
				if vim.bo[args.buf].filetype == "spectre_panel" then
					vim.schedule(function()
						pcall(require("spectre").close)
					end)
				end
			end,
		})

		-- ========================
		-- GLOBAL KEYMAPS
		-- ========================
		vim.keymap.set("n", "<leader>sp", function()
			spectre.open()
		end, { desc = "󰍉 Project search & replace" })

		vim.keymap.set("n", "<leader>ss", function()
			spectre.open_file_search()
		end, { desc = "󰍉 Current file search & replace" })

		vim.keymap.set("n", "<leader>sw", function()
			spectre.open_file_search({ select_word = true })
		end, { desc = "󰍉 Search word under cursor (current file)" })
		vim.keymap.set("v", "<leader>sw", function()
			spectre.open_file_search()
		end, { desc = "󰍉 Search selection (current file)" })

		vim.keymap.set("n", "<leader>sW", function()
			spectre.open_visual({ select_word = true })
		end, { desc = "󰍉 Search word under cursor (project)" })
		vim.keymap.set("v", "<leader>sW", function()
			spectre.open_visual()
		end, { desc = "󰍉 Search selection (project)" })

		-- ========================
		-- PANEL LOCAL KEYMAPS
		-- ========================
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "spectre_panel",
			callback = function()
				vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = true })
				vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true })
			end,
		})
	end,
}
