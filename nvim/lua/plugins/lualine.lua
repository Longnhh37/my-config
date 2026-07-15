-- =============================================================================
-- plugins/lualine.lua  –  Status line  (nvim-lualine/lualine.nvim)
-- =============================================================================
-- SECTIONS:
--   lualine_a   mode (abbreviated: N / I / V / VL / VB / R / C / T)
--   lualine_b   git branch  |  diff (+~/-)
--   lualine_c   LSP diagnostics (x/!/i/?)  — center section
--   lualine_x   LSP client names
--   lualine_y   filetype
--   lualine_z   progress (%%)
--
-- DEPENDS ON:
--   nvim-tree/nvim-web-devicons  (Nerd Font icons)
--
-- NOTES:
--   globalstatus = true → single status line across all splits.
--   showmode = false in options.lua because lualine renders the mode.
--   Copilot attach như LSP bình thường
-- =============================================================================

return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	config = function()
		local lualine = require("lualine")

		-------------------------------------------------
		-- Icons
		-------------------------------------------------
		local Icons = {
			git_branch = "",
			git_added = "+",
			git_modified = "~",
			git_removed = "-",
			diag_error = "x",
			diag_warn = "!",
			diag_hint = "?",
			diag_info = "i",
		}

		-------------------------------------------------
		-- Lualine setup
		-------------------------------------------------
		lualine.setup({
			options = {
				icon_enabled = true,
				theme = "auto",
				globalstatus = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},

			sections = {

				lualine_a = {
					{
						"mode",
						fmt = function(mode)
							local map = {
								NORMAL = "N",
								INSERT = "I",
								VISUAL = "V",
								["V-LINE"] = "VL",
								["V-BLOCK"] = "VB",
								REPLACE = "R",
								COMMAND = "C",
								TERMINAL = "T",
							}
							return map[mode] or mode
						end,
					},
				},

				lualine_b = {
					{ "branch", icon = Icons.git_branch },
					{
						"diff",
						symbols = {
							added = Icons.git_added,
							modified = Icons.git_modified,
							removed = Icons.git_removed,
						},
					},
				},

				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = Icons.diag_error,
							warn = Icons.diag_warn,
							hint = Icons.diag_hint,
							info = Icons.diag_info,
						},
					},
				},

				lualine_x = {
					{
						function()
							return table.concat(
								vim.tbl_map(function(c)
									return c.name
								end, vim.lsp.get_clients({ bufnr = 0 })),
								" ∙ "
							)
						end,
						update_in_insert = false,
					},
				},

				lualine_y = { "filetype" },

				lualine_z = {
					{ "progress" },
				},
			},
		})
	end,
}
