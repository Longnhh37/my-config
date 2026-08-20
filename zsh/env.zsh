# ═══════════════════════════════════════════════════════════════════════════════
# ~/.zsh/env.zsh — Môi trường hệ thống sạch
# ═══════════════════════════════════════════════════════════════════════════════
export VISUAL='nvim --clean'
export CARGO_TERM_COLOR=always
export icloud="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/code"
export GOPATH="$HOME/go"

# Khởi tạo PATH chuẩn
typeset -U path
path=(
  $HOME/.cargo/bin
  $GOPATH/bin
  /opt/homebrew/opt/fzf/bin
  $path
)
