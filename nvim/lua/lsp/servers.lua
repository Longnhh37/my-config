local M = {}

function M.setup()
	local capabilities = require("blink.cmp").get_lsp_capabilities()
	capabilities.general = { positionEncodings = { "utf-8" } }

	local function on_attach(client, bufnr)
		require("lsp.lsp_keymaps").on_attach(client, bufnr)
	end

	local servers = {}
	local languages = {
		"lsp.languages.cpp",
    "lsp.languages.go",
		"lsp.languages.lua_lang",
		"lsp.languages.python",
		"lsp.languages.rust_bacon",
		"lsp.languages.web",
	}

	for _, lang in ipairs(languages) do
		local ok, mod = pcall(require, lang)
		if ok then
			vim.list_extend(servers, mod.setup(on_attach, capabilities))
		else
			vim.notify("lsp.servers: failed to load " .. lang .. "\n" .. mod, vim.log.levels.WARN)
		end
	end

	vim.lsp.enable(servers)
end

return M
