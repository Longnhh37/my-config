local augroup = vim.api.nvim_create_augroup("FiletypeSettings", { clear = true })

local FILETYPES = {
    { pat = "python",  sw = 4, cc = "88",  et = true },
    { pat = "rust",    sw = 4, cc = "100", et = true },
    { pat = "lua",     sw = 2, cc = "120", et = true },
    { pat = "go",      sw = 4, cc = "100", et = false },

    {
        pat = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        sw = 2, cc = "100", et = true,
    },

    { pat = { "c", "cpp" }, sw = 4, cc = "100", et = true },

    {
        pat = { "json", "yaml", "html", "css", "scss" },
        sw = 2, et = true,
    },
}

for _, ft in ipairs(FILETYPES) do
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = ft.pat,

		callback = function()
			vim.opt_local.shiftwidth = ft.sw
			vim.opt_local.tabstop = ft.sw
			vim.opt_local.softtabstop = ft.sw
			vim.opt_local.expandtab = ft.et

			if ft.cc then
				vim.opt_local.colorcolumn = ft.cc
			end
		end,
	})
end
