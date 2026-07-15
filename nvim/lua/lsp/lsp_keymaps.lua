-- =============================================================================
-- lsp/lsp_keymaps.lua  –  Buffer-local LSP keymaps (attached via on_attach)
-- =============================================================================
-- KEYMAPS  (all buffer-local, only set when server advertises capability):
--
--   Native LSP jumps (no Telescope):
--   n  gd     go to definition
--   n  gr     references
--   n  gi     go to implementation
--   n  gt     type definition
--   n  K      hover docs
--   i  <C-s>  signature help while typing
--
--   LSP actions (<leader>l):
--   n  <leader>lr   rename symbol
--   n  <leader>la   code action
--   n  <leader>lD   go to declaration
--   n  <leader>lt   go to type definition
--   n  <leader>lH   toggle inlay hints  (+ refresh lualine)
--   n  <leader>lh   apply inlay hints as real text into buffer
--
--   Telescope LSP pickers (optional, only if telescope is loaded):
--   n  <leader>ld   definitions        (Telescope)
--   n  <leader>lR   references         (Telescope)
--   n  <leader>li   implementations    (Telescope)
--   n  <leader>ls   document symbols   (Telescope)
--   n  <leader>lw   workspace symbols  (Telescope)
--.
-- =============================================================================

local M = {}

-- ── Helpers ───────────────────────────────────────────────────────────────────

--- Set a buffer-local keymap.
local function bmap(mode, lhs, rhs, desc, bufnr)
	vim.keymap.set(mode, lhs, rhs, {
		buffer = bufnr,
		silent = true,
		desc = desc,
	})
end

--- Set keymap only when the server advertises the required capability.
--- `cap` is a capability value (truthy = supported; nil = always set).
local function cap_bmap(mode, lhs, rhs, desc, bufnr, cap)
	if cap == nil or cap then
		bmap(mode, lhs, rhs, desc, bufnr)
	end
end

-- ── Inlay hints ───────────────────────────────────────────────────────────────
-- Inlay hints là LSP feature (spec 3.17+) — server gửi hint positions + labels,
-- Neovim render dưới dạng virtual text (vim.lsp.inlay_hint, có từ Nvim 0.10).

--- Guard: trả về false nếu không có LSP client nào attach vào buffer hiện tại.
local function has_lsp()
	return next(vim.lsp.get_clients({ bufnr = 0 })) ~= nil
end

--- <leader>ih — Toggle inlay hints on/off cho buffer hiện tại.
--- Refresh lualine để statusline phản ánh trạng thái mới.
local function toggle_inlay_hints()
	if not has_lsp() then
		return
	end
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
	require("lualine").refresh()
end

--- <leader>ia — Apply tất cả inlay hints vào buffer dưới dạng text thật.
---
--- Hints được insert theo thứ tự reverse (bottom→top, right→left) để tránh
--- column offset bị lệch sau mỗi lần chèn.
--- Sau khi apply, tắt virtual text hints để tránh double hiển thị.
local function apply_inlay_hints()
	if not has_lsp() then
		return
	end

	local hints = vim.lsp.inlay_hint.get({ bufnr = 0 })
	if not hints or #hints == 0 then
		vim.notify("No inlay hints found", vim.log.levels.INFO)
		return
	end

	-- Sort reverse: dòng lớn → nhỏ, col lớn → nhỏ
	table.sort(hints, function(a, b)
		local al = a.inlay_hint.position.line
		local bl = b.inlay_hint.position.line
		if al ~= bl then
			return al > bl
		end
		return a.inlay_hint.position.character > b.inlay_hint.position.character
	end)

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	for _, hint in ipairs(hints) do
		local label = hint.inlay_hint.label
		if type(label) == "table" then
			label = table.concat(
				vim.tbl_map(function(p)
					return p.value
				end, label),
				""
			)
		end

		if label == "" then
			goto continue
		end

		local row = hint.inlay_hint.position.line
		local col = hint.inlay_hint.position.character
		local line = lines[row + 1]
		if line then
			lines[row + 1] = line:sub(1, col) .. label .. line:sub(col + 1)
		end

		::continue::
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
	vim.notify("Applied " .. #hints .. " inlay hints", vim.log.levels.INFO)
end

function M.on_attach(client, bufnr)
	local caps = client.server_capabilities or {}

	-- ── Native LSP jumps (fast path, no Telescope) ───────────────────────────
	cap_bmap("n", "gd", vim.lsp.buf.definition, "Go to definition", bufnr, caps.definitionProvider)
	cap_bmap("n", "gr", vim.lsp.buf.references, "References", bufnr, caps.referencesProvider)
	cap_bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation", bufnr, caps.implementationProvider)
	cap_bmap("n", "gt", vim.lsp.buf.type_definition, "Type definition", bufnr, caps.typeDefinitionProvider)
	cap_bmap("n", "K", vim.lsp.buf.hover, "Hover docs", bufnr, caps.hoverProvider)

	-- Signature help while typing
	cap_bmap("i", "<C-s>", vim.lsp.buf.signature_help, "Signature help", bufnr, caps.signatureHelpProvider)

	-- ── LSP actions (<leader>l*) ─────────────────────────────────────────────
	cap_bmap("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol", bufnr, caps.renameProvider)
	cap_bmap("n", "<leader>la", vim.lsp.buf.code_action, "Code action", bufnr, caps.codeActionProvider)
	cap_bmap("n", "<leader>lD", vim.lsp.buf.declaration, "Go to declaration", bufnr, caps.declarationProvider)
	cap_bmap(
		"n",
		"<leader>lt",
		vim.lsp.buf.type_definition,
		"Go to type definition",
		bufnr,
		caps.typeDefinitionProvider
	)

	-- ── Inlay hints ─────────────────────────────────────────────
	-- Chỉ map nếu server support inlayHintProvider
	cap_bmap("n", "<leader>ih", toggle_inlay_hints, "LSP: toggle inlay hints", bufnr, caps.inlayHintProvider)
	cap_bmap("n", "<leader>ia", apply_inlay_hints, "LSP: apply inlay hints to buffer", bufnr, caps.inlayHintProvider)

	-- ── Telescope LSP pickers (optional) ─────────────────────────────────────
	local ok, tb = pcall(require, "telescope.builtin")
	if not ok then
		return
	end

	cap_bmap("n", "<leader>ld", tb.lsp_definitions, "Definitions (Telescope)", bufnr, caps.definitionProvider)
	cap_bmap("n", "<leader>lR", tb.lsp_references, "References (Telescope)", bufnr, caps.referencesProvider)
	cap_bmap(
		"n",
		"<leader>li",
		tb.lsp_implementations,
		"Implementations (Telescope)",
		bufnr,
		caps.implementationProvider
	)
	cap_bmap("n", "<leader>ls", tb.lsp_document_symbols, "Document symbols", bufnr, caps.documentSymbolProvider)
	cap_bmap("n", "<leader>lw", tb.lsp_workspace_symbols, "Workspace symbols", bufnr, caps.workspaceSymbolProvider)
end

return M
