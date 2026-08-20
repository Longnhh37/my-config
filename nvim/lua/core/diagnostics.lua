-- =============================================================================
-- core/diagnostics.lua
-- =============================================================================

-- ── Core config ───────────────────────────────────────────────────────────────
vim.diagnostic.config({
	virtual_text = false,
	signs = {
		priority = 90,
		text = {
			[vim.diagnostic.severity.ERROR] = "x",
			[vim.diagnostic.severity.WARN] = "!",
			[vim.diagnostic.severity.HINT] = "?",
			[vim.diagnostic.severity.INFO] = "i",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded", source = "always" },
})

-- ── Navigation ────────────────────────────────────────────────────────────────
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN } })
end, { desc = "Prev error/warn" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN } })
end, { desc = "Next error/warn" })
vim.keymap.set("n", "D", function()
	vim.diagnostic.open_float(nil, { border = "rounded", source = "always" })
end, { desc = "Diagnostic float" })
