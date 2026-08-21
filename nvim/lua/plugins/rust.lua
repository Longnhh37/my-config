-- plugins/rust.lua
return {
	{
		"mrcjkb/rustaceanvim",
		version = "9",
		lazy = false,

		config = function()
			local keymaps = require("lsp.lsp_keymaps")
			local codelldb = require("utils.codelldb")

			local capabilities = require("blink.cmp").get_lsp_capabilities()
			capabilities.general = {
				positionEncodings = { "utf-8" },
			}

			vim.g.rustaceanvim = {

				dap = {
					adapter = codelldb.rustaceanvim_adapter(),
				},

				server = {
					capabilities = capabilities,
					settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								buildScripts = { enable = true },
							},
							procMacro = { enable = true },
							checkOnSave = false,
							diagnostics = { enable = false },
							rustfmt = { extraArgs = { "--edition", "2024" } },
							inlayHints = {
								bindingModeHints = { enable = true },
								chainingHints = { enable = true },
								parameterHints = { enable = true },
								typeHints = { enable = true },
								lifetimeElisionHints = { enable = "always" },
							},
						},
					},

					on_attach = function(client, bufnr)
						keymaps.on_attach(client, bufnr)

						local map = function(key, cmd, desc)
							vim.keymap.set("n", key, cmd, { buffer = bufnr, silent = true, desc = desc })
						end

						map("<leader>ra", function()
							vim.cmd.RustLsp("codeAction")
						end, "Rust: Code Action")
						map("<leader>rr", function()
							vim.cmd.RustLsp("runnables")
						end, "Rust: Runnables")
						map("<leader>rt", function()
							vim.cmd.RustLsp("testables")
						end, "Rust: Testables")
						map("<leader>rd", function()
							vim.cmd.RustLsp("debuggables")
						end, "Rust: Debuggables")
						map("<leader>re", function()
							vim.cmd.RustLsp("expandMacro")
						end, "Rust: Expand Macro")
						map("<leader>rp", function()
							vim.cmd.RustLsp("parentModule")
						end, "Rust: Parent Module")
						map("<leader>rh", function()
							vim.cmd.RustLsp({ "hover", "actions" })
						end, "Rust: Hover Actions")
						map("<leader>ro", function()
							vim.cmd.RustLsp("openDocs")
						end, "Rust: Open docs.rs")

						-- rc: mở Cargo.toml của crate hiện tại
						map("<leader>rc", function()
							vim.cmd.RustLsp("openCargo")
						end, "Rust: Open Cargo.toml (crate)")

						-- rC: mở Cargo.toml của workspace root
						map("<leader>rC", function()
							local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "rust-analyzer" })
							local root = (clients[1] and clients[1].config.root_dir) or vim.fn.getcwd()
							vim.cmd.edit(root .. "/Cargo.toml")
						end, "Rust: Open Cargo.toml (workspace)")

						map("<leader>rw", function()
							vim.cmd.RustLsp("reloadWorkspace")
						end, "Rust: Reload Workspace")
						map("<leader>rm", function()
							vim.cmd.RustLsp("joinLines")
						end, "Rust: Join Lines")
					end,
				},

				tools = { enable_progress_notifications = false },
			}
		end,
	},

	{
		"Saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		opts = {
			completion = { crates = { enabled = true } },
			lsp = { enabled = true, actions = true, completion = true, hover = true },
		},
	},
}
