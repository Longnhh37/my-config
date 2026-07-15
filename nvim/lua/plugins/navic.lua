return {
	"SmiteshP/nvim-navic",
	lazy = true,
	init = function()
		vim.g.navic_silence = true

		local function setup_highlights()
			local flavor = vim.g.catppuccin_flavour or "frappe"
			local color = require("catppuccin.palettes").get_palette(flavor)
			vim.api.nvim_set_hl(0, "WinBarPath", {
				bg = color.base,
				fg = color.subtext1,
			})
		end

		setup_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_highlights })

		-- =====================================================================
		-- LSP attach
		-- =====================================================================
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.server_capabilities.documentSymbolProvider then
					require("nvim-navic").attach(client, args.buf)
				end
			end,
		})

		-- =====================================================================
		-- Winbar logic
		-- =====================================================================
		local function short_filepath(max_depth)
			local path = vim.fn.expand("%:~:.")
			local parts = vim.split(path, "/", { trimempty = true })
			if #parts <= max_depth then
				return path
			end
			return table.concat(vim.list_slice(parts, #parts - max_depth + 1), "/")
		end

		local function update_winbar()
			if vim.api.nvim_win_get_config(0).relative ~= "" then
				return
			end
			if vim.bo.buftype ~= "" then
				return
			end
			if vim.api.nvim_buf_get_name(0) == "" then
				return
			end

			local navic = require("nvim-navic")
			local filename = short_filepath(4)
			local breadcrumb = navic.is_available() and navic.get_location() or ""

			local path_hl = "%#WinBarPath#" .. filename .. "%#WinBar#"
			local sep = "%#NavicSeparator# › %#WinBar#"

			if breadcrumb ~= "" then
				vim.wo.winbar = " " .. path_hl .. sep .. breadcrumb .. " "
			else
				vim.wo.winbar = " " .. path_hl .. " "
			end
		end

		vim.api.nvim_create_autocmd({
			"BufEnter",
			"CursorHold",
			"InsertLeave",
			"WinEnter",
		}, {
			callback = update_winbar,
		})
	end,
	opts = {
		separator = " › ",
		highlight = true,
		depth_limit = 5,
		lazy_update_context = true,
	},
}
