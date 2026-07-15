# Neovim Config — Prerequisites

This config does **not** auto-install LSP servers / formatters / linters via
Mason (`ensure_installed` is not set) — external tools must already be
available in your `$PATH` before opening Neovim, otherwise you'll get a
`vim.notify` warning or the LSP/formatter simply won't attach.

Install priority: **brew → cargo → uv (pip) → other**.

---

## 0. Required (core)

| Tool | Install via | Used for |
|---|---|---|
| `neovim` (>= 0.10, 0.11+ recommended) | `brew install neovim` | editor |
| `git` | `brew install git` | lazy.nvim, gitsigns, telescope git pickers |
| `ripgrep` | `brew install ripgrep` | Telescope `live_grep`, Spectre |
| `fd` | `brew install fd` | Telescope `find_files` (auto-used if present in PATH) |
| `lazygit` | `brew install lazygit` | `<leader>hg` in `gitsigns.lua` (opens lazygit float) |
| `make` | `brew install make` (or Xcode CLT on macOS) | building `telescope-fzf-native.nvim` |
| Nerd Font | `brew install --cask font-jetbrains-mono-nerd-font` (or any Nerd Font) | icons in `mini.icons`, `lualine`, `spectre`, `bufferline` |
| `tmux` | `brew install tmux` | `vim-tmux-navigator` (needs matching config in `~/.tmux.conf`) |

```bash
brew install neovim git ripgrep fd lazygit make tmux
brew install --cask font-jetbrains-mono-nerd-font
```

---

## 1. Lua

| Tool | Install via |
|---|---|
| `lua-language-server` | `brew install lua-language-server` |
| `stylua` | `brew install stylua` (or `cargo install stylua`) |

---

## 2. Python

| Tool | Install via | Used for |
|---|---|---|
| `python3` | bundled on macOS, or `brew install python` | interpreter |
| `uv` | `brew install uv` | fast venv/package management |
| `pyright` | `uv tool install pyright` (or `npm i -g pyright`) | type checking |
| `ruff` | `uv tool install ruff` (or `brew install ruff`) | lint + format |
| `debugpy` | `uv tool install debugpy` | `nvim-dap-python` |

```bash
brew install uv
uv tool install pyright
uv tool install ruff
uv tool install debugpy
```

> `ruff` is also available via brew (`brew install ruff`) if you'd rather skip uv for it.

---

## 3. Go

| Tool | Install via | Used for |
|---|---|---|
| `go` | `brew install go` | toolchain |
| `gopls` | `go install golang.org/x/tools/gopls@latest` | LSP |
| `golangci-lint` | `brew install golangci-lint` | `nvim-lint` (`<leader>gl`) |
| `goimports` | `go install golang.org/x/tools/cmd/goimports@latest` | formatting (conform) |
| `gofumpt` | `go install mvdan.cc/gofumpt@latest` | formatting (conform) |
| `delve` (`dlv`) | `go install github.com/go-delve/delve/cmd/dlv@latest` | debugging (`nvim-dap-go`) |
| `govulncheck` | `go install golang.org/x/vuln/cmd/govulncheck@latest` | `<leader>gv` |

```bash
brew install go golangci-lint
go install golang.org/x/tools/gopls@latest
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/vuln/cmd/govulncheck@latest
```

> Make sure `$(go env GOPATH)/bin` is on your `$PATH`.

---

## 4. Rust

| Tool | Install via | Used for |
|---|---|---|
| `rustup` + toolchain | `brew install rustup` then `rustup-init` | cargo, rustc, rustfmt |
| `rust-analyzer` | bundled automatically by `rustaceanvim` — no manual install needed | LSP |
| `bacon` + `bacon-ls` | `cargo install --locked bacon bacon-ls` | realtime diagnostics (`rust_bacon.lua`) |

```bash
brew install rustup
rustup-init
rustup component add rustfmt clippy
cargo install --locked bacon bacon-ls
```

---

## 5. C / C++

| Tool | Install via | Used for |
|---|---|---|
| `clangd` | `brew install llvm` (or Xcode CLT) | LSP + clang-tidy |
| `clang-format` | bundled with `llvm` | formatting (conform) |
| `codelldb` | via `:MasonInstall codelldb` inside Neovim | debugging C/C++/Rust (`utils/codelldb.lua`) |

```bash
brew install llvm
```

> `codelldb` is installed via Mason (`:Mason` → search `codelldb`), not brew/cargo.

---

## 6. Web (JS/TS/HTML/CSS)

| Tool | Install via | Used for |
|---|---|---|
| `node` + `npm` | `brew install node` | runtime for every web LSP + building `vscode-js-debug` |
| `typescript-language-server` | `npm i -g typescript-language-server typescript` | TS/JS LSP |
| `vscode-langservers-extracted` (html/css/eslint) | `npm i -g vscode-langservers-extracted` | html, css, eslint LSP |
| `@tailwindcss/language-server` | `npm i -g @tailwindcss/language-server` | Tailwind LSP |
| `emmet-language-server` | `npm i -g emmet-language-server` | Emmet LSP |
| `prettier` | `npm i -g prettier` | formatting (conform) |

```bash
brew install node
npm i -g typescript typescript-language-server \
  vscode-langservers-extracted \
  @tailwindcss/language-server \
  emmet-language-server \
  prettier
```

> `nvim-dap-vscode-js` builds `vscode-js-debug` itself via `npm install` + `npx gulp` the first time lazy.nvim installs the plugin — you just need `node`/`npm` available, no manual build step.

---

## 7. Verify after install

Open Neovim and run `:checkhealth` for a general sanity check, then open a
file of each type (`.py`, `.go`, `.rs`, `.lua`, `.ts`, ...) and check
`:LspInfo` to confirm the expected servers attach. If a binary is missing,
the files under `lua/lsp/languages/` will `vim.notify` a warning (already
wired up for `gopls` and `bacon-ls`).
