-- =============================================================================
-- plugins/blink.cmp
-- =============================================================================
-- KEYMAPS:
--   <Tab> / <S-Tab>
--     - completion menu mở:
--         Tab     -> next item
--         S-Tab   -> prev item
--     - đang ở snippet:
--         Tab     -> jump next
--         S-Tab   -> jump prev
--     - fallback bình thường nếu không có gì
--
--   <C-j> / <C-k>   next / prev item
--   <CR>            confirm selected item
--   <Esc>           cancel popup nếu đang mở
--
-- SOURCES:
--   lsp → snippets → buffer → path
-- =============================================================================

local kind_icons = {
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "󰒓",
	Field = "󰜢",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "󰏗",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "󰕘",
	Keyword = "󰌋",
	Snippet = "󰘍",
	Color = "󰏘",
	File = "󰈙",
	Reference = "󰈇",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "󰙅",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰊄",
}

local menu_labels = {
	lsp = "[LSP]",
	snippets = "[Snippet]",
	buffer = "[Buffer]",
	path = "[Path]",
}

return {
	{
		"saghen/blink.cmp",
		version = "*",
		event = "InsertEnter",

		dependencies = {
			"L3MON4D3/LuaSnip",
		},

		opts = {
			snippets = {
				preset = "luasnip",
			},

			-- ── Sources ───────────────────────────────────────────────────
			sources = {
				default = { "lsp", "snippets", "buffer", "path" },
			},

			-- ── Keymaps ───────────────────────────────────────────────────
			keymap = {
				preset = "none",

				["<C-j>"] = {
					"select_next",
					"fallback",
				},

				["<C-k>"] = {
					"select_prev",
					"fallback",
				},

				-- Completion menu:
				--   Tab     -> next item
				--   S-Tab   -> prev item
				--
				-- Snippet:
				--   Tab     -> jump forward
				--   S-Tab   -> jump backward
				["<Tab>"] = {
					"select_next",
					"snippet_forward",
					"fallback",
				},

				["<S-Tab>"] = {
					"select_prev",
					"snippet_backward",
					"fallback",
				},

				["<CR>"] = {
					"accept",
					"fallback",
				},

				["<Esc>"] = {
					"cancel",
					"fallback",
				},
			},

			-- ── Completion ───────────────────────────────────────────────
			completion = {
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},

				menu = {
					border = "rounded",

					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", gap = 1 },
							{ "kind" },
							{ "source_name" },
						},

						components = {
							kind_icon = {
								text = function(ctx)
									return (kind_icons[ctx.kind] or "󰈔") .. " "
								end,
							},

							kind = {
								text = function(ctx)
									return ctx.kind
								end,
							},

							source_name = {
								text = function(ctx)
									return menu_labels[ctx.source_name] or ("[" .. ctx.source_name .. "]")
								end,
							},
						},
					},
				},

				documentation = {
					auto_show = true,

					window = {
						border = "rounded",
					},
				},
			},

			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "mono",
			},
		},
	},
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		build = "make install_jsregexp",
		dependencies = { "rafamadriz/friendly-snippets" },

		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()

			require("luasnip").config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = false,
			})
		end,
	},
}
