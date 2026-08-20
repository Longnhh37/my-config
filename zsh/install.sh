#!/usr/bin/env zsh
set -e

SRC_DIR="${1:-.}"
DEST_DIR="$HOME"

for f in zprofile zshenv zshrc; do
  if [[ -f "$SRC_DIR/$f" ]]; then
    cp "$SRC_DIR/$f" "$DEST_DIR/.$f"
    echo "✔ Đã copy $f -> $DEST_DIR/.$f"
  else
    echo "⚠ Không tìm thấy $SRC_DIR/$f, bỏ qua"
  fi
done

# Reload cấu hình zsh trong session hiện tại
source "$HOME/.zshenv" 2>/dev/null || true
source "$HOME/.zprofile" 2>/dev/null || true
source "$HOME/.zshrc" 2>/dev/null || true

echo "✅ Đã reload zsh"
