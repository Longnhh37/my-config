-- plugins/treesitter.lua

local ft_to_parser = {
	javascriptreact = "javascript",
	typescriptreact = "typescript",
	scss = "css",
	less = "css",
}

local parsers = {
	-- core
	"lua",
	"vim",
	"vimdoc",
	-- cpp.lua
	"c",
	"cpp",
	-- python.lua
	"python",
	-- web.lua
	"html",
	"css",
	"javascript",
	"typescript",
	"json",
	-- rust_bacon.lua
	"rust",
	-- extras
	"yaml",
	"markdown",
	"markdown_inline",
}

local ts_indent = {
	rust = true,
	c = true,
	cpp = true,
	lua = true,
	javascript = true,
	typescript = true,
}

local all_fts =
	vim.list_extend(vim.deepcopy(parsers), { "javascriptreact", "typescriptreact", "scss", "less", "objc", "objcpp" })

local known_parsers = {}
for _, p in ipairs(parsers) do
	known_parsers[p] = true
end

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	},
	build = function()
		require("nvim-treesitter").install(parsers)
	end,
	config = function()
		require("nvim-treesitter").setup({})

		-- ── Textobjects ────────────────────────────────────────────────────────
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@function.outer"] = "V",
					["@class.outer"] = "V",
				},
				include_surrounding_whitespace = false,
			},
			move = {
				set_jumps = true,
			},
		})

		-- ── Select keymaps (x = visual, o = operator-pending) ─────────────────
		local select = require("nvim-treesitter-textobjects.select")
		local function sel(query)
			return function()
				select.select_textobject(query, "textobjects")
			end
		end

		-- functions
		vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "outer function" })
		vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "inner function" })
		-- classes
		vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "outer class" })
		vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "inner class" })
		-- conditionals
		vim.keymap.set({ "x", "o" }, "ai", sel("@conditional.outer"), { desc = "outer conditional" })
		vim.keymap.set({ "x", "o" }, "ii", sel("@conditional.inner"), { desc = "inner conditional" })
		-- loops
		vim.keymap.set({ "x", "o" }, "al", sel("@loop.outer"), { desc = "outer loop" })
		vim.keymap.set({ "x", "o" }, "il", sel("@loop.inner"), { desc = "inner loop" })
		-- parameters
		vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer"), { desc = "outer parameter" })
		vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner"), { desc = "inner parameter" })

		-- ── Move keymaps ───────────────────────────────────────────────────────
		local move = require("nvim-treesitter-textobjects.move")

		-- next start
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })
		vim.keymap.set({ "n", "x", "o" }, "]c", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })
		vim.keymap.set({ "n", "x", "o" }, "]i", function()
			move.goto_next_start("@conditional.outer", "textobjects")
		end, { desc = "Next conditional start" })
		vim.keymap.set({ "n", "x", "o" }, "]l", function()
			move.goto_next_start("@loop.outer", "textobjects")
		end, { desc = "Next loop start" })
		-- next end
		vim.keymap.set({ "n", "x", "o" }, "]F", function()
			move.goto_next_end("@function.outer", "textobjects")
		end, { desc = "Next function end" })
		vim.keymap.set({ "n", "x", "o" }, "]C", function()
			move.goto_next_end("@class.outer", "textobjects")
		end, { desc = "Next class end" })
		-- prev start
		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Prev function start" })
		vim.keymap.set({ "n", "x", "o" }, "[c", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Prev class start" })
		vim.keymap.set({ "n", "x", "o" }, "[i", function()
			move.goto_previous_start("@conditional.outer", "textobjects")
		end, { desc = "Prev conditional start" })
		vim.keymap.set({ "n", "x", "o" }, "[l", function()
			move.goto_previous_start("@loop.outer", "textobjects")
		end, { desc = "Prev loop start" })
		-- prev end
		vim.keymap.set({ "n", "x", "o" }, "[F", function()
			move.goto_previous_end("@function.outer", "textobjects")
		end, { desc = "Prev function end" })
		vim.keymap.set({ "n", "x", "o" }, "[C", function()
			move.goto_previous_end("@class.outer", "textobjects")
		end, { desc = "Prev class end" })

		-- ── Swap keymaps ───────────────────────────────────────────────────────
		local swap = require("nvim-treesitter-textobjects.swap")
		vim.keymap.set("n", "<leader>an", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap param next" })
		vim.keymap.set("n", "<leader>ap", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap param prev" })

		-- ── Auto install khi mở file ───────────────────────────────────────────
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_auto_install", { clear = true }),
			callback = function(ev)
				local ft = vim.bo[ev.buf].filetype
				local parser = ft_to_parser[ft] or ft
				if not known_parsers[parser] then
					return
				end
				if not pcall(vim.treesitter.language.inspect, parser) then
					require("nvim-treesitter").install({ parser })
				end
			end,
		})

		-- ── Highlight + indent + folding ───────────────────────────────────────
		local group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = all_fts,
			callback = function(ev)
				local buf = ev.buf
				local ft = vim.bo[buf].filetype
				local parser = ft_to_parser[ft] or ft

				pcall(vim.treesitter.start, buf, parser)

				if ts_indent[parser] then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end

				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo.foldlevel = 99
			end,
		})
	end,
}
