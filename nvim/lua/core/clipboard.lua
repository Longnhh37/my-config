-- ~/.config/nvim/lua/core/clipboard.lua
-- Tự detect local vs SSH, set clipboard phù hợp

local function setup_clipboard()
	vim.opt.clipboard = "unnamedplus"

	local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
	local in_tmux = vim.env.TMUX ~= nil

	if is_ssh then
		-- ── Remote (SSH) : OSC52 copy + tmux buffer paste ─────────────────────
		-- OSC52 gửi clipboard data qua SSH tunnel → ghostty → macOS clipboard
		-- Paste: dùng tmux buffer (tin cậy hơn OSC52 paste)
		vim.g.clipboard = {
			name = "OSC52+tmux",
			copy = {
				["+"] = require("vim.ui.clipboard.osc52").copy("+"),
				["*"] = require("vim.ui.clipboard.osc52").copy("*"),
			},
			paste = {
				["+"] = in_tmux and { "sh", "-c", "tmux save-buffer - 2>/dev/null || true" }
					or require("vim.ui.clipboard.osc52").paste("+"),
				["*"] = in_tmux and { "tmux", "save-buffer", "-" } or require("vim.ui.clipboard.osc52").paste("*"),
			},
			cache_enabled = 0,
		}
	else
		-- ── Local macOS : pbcopy/pbpaste ──────────────────────────────────────
		vim.g.clipboard = {
			name = "macOS-pbcopy",
			copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
			paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
			cache_enabled = 0,
		}
	end
end

setup_clipboard()

