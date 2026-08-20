-- lua/core/options.lua
-- Core editor options

-- Indentation (defaults — filetype-specific overrides are in lua/core/filetypes.lua)
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tab line
vim.opt.showtabline = 1

-- Sign column
vim.opt.signcolumn = "auto:1-3"
vim.opt.numberwidth = 4

-- Scrolling and wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.scrolloff = 8

-- Display
vim.opt.termguicolors = true

-- Invisible characters
vim.opt.list = true
vim.opt.listchars = { tab = "→ ", trail = "·" }
vim.opt.fillchars:append({ eob = " " })

-- Timeouts
vim.opt.timeout = true
vim.opt.timeoutlen = 500
vim.opt.updatetime = 300

-- Split behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Disable backups and swapfiles, enable undo
vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.undolevels = 10000
vim.opt.history = 1000

-- Fold level
vim.opt.foldmethod = "manual"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- New UI for 0.12 + guard
pcall(function()
	require("vim._core.ui2").enable({
		enable = true,
	})
end)

-- Word case
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Mouse and cursor
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.showmode = false -- Don't show -- INSERT -- etc. since lualine already does this
