-- plugins/mini.lua
return {
	"nvim-mini/mini.nvim",
	lazy = false,
	priority = 100,

	config = function()
		-- ── Icons ──────────────────────────────────────────────────────────────
		require("mini.icons").setup()
		MiniIcons.mock_nvim_web_devicons()

		-- ── Buffer management ──────────────────────────────────────────────────
		require("mini.bufremove").setup()

		local closed_buffers = {}
		vim.api.nvim_create_autocmd("BufDelete", {
			callback = function(args)
				local name = vim.api.nvim_buf_get_name(args.buf)
				if name ~= "" and vim.fn.filereadable(name) == 1 then
					table.insert(closed_buffers, name)
				end
			end,
		})

		vim.keymap.set("n", "<leader>bf", function()
			require("mini.bufremove").delete(0, false)
		end, { desc = "Buffer: Delete" })
		vim.keymap.set("n", "<leader>bF", function()
			require("mini.bufremove").delete(0, true)
		end, { desc = "Buffer: Delete (force)" })
		vim.keymap.set("n", "<leader>br", function()
			if #closed_buffers == 0 then
				vim.notify("No recently closed buffer", vim.log.levels.INFO)
				return
			end
			vim.cmd("edit " .. vim.fn.fnameescape(table.remove(closed_buffers)))
		end, { desc = "Buffer: Reopen last" })
		vim.keymap.set("n", "<leader>ba", function()
			local bufs = vim.api.nvim_list_bufs()
			for _, buf in ipairs(bufs) do
				if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
					require("mini.bufremove").delete(buf, false)
				end
			end
		end, { desc = "Buffer: Delete all" })

		-- ── BufReadPre: surround, indentscope, operators ───────────────────────
		vim.api.nvim_create_autocmd("BufReadPre", {
			once = true,
			callback = function()
				require("mini.surround").setup({
					search_method = "cover_or_next",
					mappings = {
						add = "gsa",
						delete = "gsd",
						replace = "gsr",
						find = "",
						find_left = "",
						highlight = "",
						update_n_lines = "",
						suffix_last = "",
						suffix_next = "",
					},
				})

				require("mini.indentscope").setup({
					symbol = "│",
					mappings = { goto_top = "[o", goto_bottom = "]o" },
					options = { try_as_border = true },
				})
				vim.api.nvim_create_autocmd("FileType", {
					pattern = { "help", "dashboard", "lazy", "mason" },
					callback = function()
						vim.b.miniindentscope_disable = true
					end,
				})

				require("mini.operators").setup({
					exchange = { prefix = "cx" },
				})
			end,
		})

		-- ── Pairs ─────────────────────────────────────────────────
		require("mini.pairs").setup({
			modes = { insert = true, command = false, terminal = false },
			-- tránh đóng ngoặc khi ký tự trước/sau là 1 phần của identifier
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			skip_ts = { "string" },
			skip_unbalanced = true,
			markdown = true,
		})
	end,
}
