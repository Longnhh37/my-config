-- =============================================================================
-- lua/plugins/telescope.lua
-- Fuzzy finder via Telescope + fzf-native.
--
-- Find (<leader>f):
--   <leader>ff  – find files (cwd, incl. hidden)
--   <leader>fF  – find files (buffer dir, incl. hidden)
--   <leader>fr  – recent files
--   <leader>fH  – find files (HOME)
--
-- Grep (<leader>f):
--   <leader>fg  – live grep
--   <leader>fw  – grep word under cursor
--
-- Git (<leader>f):
--   <leader>fG  – git files
--   <leader>fc  – git commits
--   <leader>fC  – buffer commits
--
-- Buffer (<leader>f):
--   <leader>fb  – fuzzy search in current buffer
--
-- Picker mappings (insert mode):
--   <C-j>/<C-k> – move selection down/up
--   <Esc>       – close
--   <C-r>       – send to Spectre for search/replace
-- =============================================================================

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",

	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},

	keys = {
		-- ── Find ────────────────────────────────────────────────────────────

		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files({ hidden = true })
			end,
			desc = "Find files (cwd)",
		},

		{
			"<leader>fF",
			function()
				local buf_name = vim.api.nvim_buf_get_name(0)
				local cwd

				local oil_path = buf_name:match("^oil://(.*)")
				if oil_path then
					cwd = oil_path
				else
					cwd = vim.fn.expand("%:p:h")
				end

				require("telescope.builtin").find_files({
					cwd = cwd,
					hidden = true,
				})
			end,
			desc = "Find files (buffer dir)",
		},

		{ "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },

		{
			"<leader>fH",
			function()
				require("telescope.builtin").find_files({
					cwd = vim.uv.os_homedir(),
				})
			end,
			desc = "Find files (HOME)",
		},
		{
			"<leader>fd",
			function()
				local buf_name = vim.api.nvim_buf_get_name(0)
				local cwd

				local oil_path = buf_name:match("^oil://(.*)")
				if oil_path then
					cwd = oil_path
				else
					cwd = vim.fn.expand("%:p:h")
				end

				require("telescope.builtin").live_grep({
					cwd = cwd,
				})
			end,
			desc = "Live grep (buffer dir)",
		},

		-- ── Grep ────────────────────────────────────────────────────────────

		{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
		{ "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },

		-- ── Git ─────────────────────────────────────────────────────────────

		{ "<leader>fG", "<cmd>Telescope git_files<CR>", desc = "Git files" },
		{ "<leader>fc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
		{ "<leader>fC", "<cmd>Telescope git_bcommits<CR>", desc = "Buffer commits" },

		-- ── Buffer ──────────────────────────────────────────────────────────

		{
			"<leader>fb",
			"<cmd>Telescope current_buffer_fuzzy_find<CR>",
			desc = "Search in buffer",
		},
	},

	opts = {
		defaults = {
			layout_strategy = "horizontal",
			sorting_strategy = "ascending",

			layout_config = {
				prompt_position = "top",
				preview_width = 0.55,
			},

			file_ignore_patterns = {
				"node_modules",
				".git/",
				"target/",
				"dist/",
			},

			mappings = {
				i = {
					["<C-j>"] = "move_selection_next",
					["<C-k>"] = "move_selection_previous",
					["<Esc>"] = "close",

					-- Send selected result → Spectre for search/replace
					["<C-r>"] = function(prompt_bufnr)
						local sel = require("telescope.actions.state").get_selected_entry()
						if not sel then
							return
						end
						require("telescope.actions").close(prompt_bufnr)
						require("spectre").open({ search_text = sel.value or sel[1] })
					end,
				},

				n = {
					["<C-r>"] = function(prompt_bufnr)
						local sel = require("telescope.actions.state").get_selected_entry()
						if not sel then
							return
						end
						require("telescope.actions").close(prompt_bufnr)
						require("spectre").open({ search_text = sel.value or sel[1] })
					end,
				},
			},
		},

		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	},

	config = function(_, opts)
		local telescope = require("telescope")
		telescope.setup(opts)
		telescope.load_extension("fzf")
	end,
}
