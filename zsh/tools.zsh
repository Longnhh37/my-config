# ═══════════════════════════════════════════════════════════════
# ~/.zsh/tools.zsh — CLI tool configuration
# Tools: bat · delta · fzf · zoxide · eza · dust · procs · btm
#        + rg · fd · sd helpers (functions in zshrc_dev_extras)
# ═══════════════════════════════════════════════════════════════


# ─────────────────────────────────────────────
# BAT — theme + man pager
# ─────────────────────────────────────────────
export BAT_THEME="Catppuccin Frappe"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFF_OPT="-c"


# ─────────────────────────────────────────────
# DELTA — git diff pager
# Config lives in ~/.gitconfig [delta] section
# ─────────────────────────────────────────────
export DELTA_PAGER="less -RF"


# ─────────────────────────────────────────────
# FZF — enable + Catppuccin Frappé theme
# ─────────────────────────────────────────────
source <(fzf --zsh)

export FZF_DEFAULT_OPTS="
  --color=bg:#303446,bg+:#414559,fg:#c6d0f5,fg+:#c6d0f5
  --color=hl:#e78284,hl+:#e78284
  --color=info:#ca9ee6,prompt:#8caaee,pointer:#f2d5cf
  --color=marker:#a6d189,spinner:#f2d5cf,header:#e78284
  --color=border:#626880,label:#c6d0f5,query:#c6d0f5
  --border=rounded
  --prompt='  '
  --pointer='▸ '
  --marker='✓ '
  --separator='─'
  --scrollbar='│'"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}' --preview-window 'right:60%:wrap' --bind 'ctrl-/:toggle-preview'"
export FZF_ALT_C_OPTS="--preview 'eza -T --icons --color=always {} | head -80' --preview-window 'right:50%'"


# ─────────────────────────────────────────────
# ZOXIDE — smarter cd with frequency
# ─────────────────────────────────────────────
eval "$(zoxide init zsh --cmd z)"

# ─────────────────────────────────────────────
# DUST — du replacement (tree-style disk usage)
# brew install dust
# ─────────────────────────────────────────────
# dust is aliased as `du` in aliases.zsh
# Common flags reference:
#   dust           current dir, tree view
#   dust -d 2      max depth 2
#   dust -n 20     show 20 entries
#   dust -r        sort ascending (smallest first)
#   dust -x        stay on same filesystem (no cross-mount)
#   dust /path     specific path


# ─────────────────────────────────────────────
# PROCS — ps replacement (colored, tree, search)
# brew install procs
# ─────────────────────────────────────────────
# procs is aliased as `ps` in aliases.zsh
# Common flags reference:
#   procs                     all processes
#   procs <name|pid>          filter by name or PID
#   procs --tree              process tree view
#   procs --watch             auto-refresh (like top)
#   procs --sortd cpu         sort by CPU descending
#   procs --sortd mem         sort by MEM descending
#   procs --no-header         pipe-friendly


# ─────────────────────────────────────────────
# BTM (bottom) — top/htop replacement
# brew install bottom
# ─────────────────────────────────────────────
# btm is aliased as `top` and `htop` in aliases.zsh
# Config: ~/.config/bottom/bottom.toml  (optional, see below)
#
# Keybinds in btm TUI:
#   q / Ctrl-C    Quit
#   ?             Help
#   Tab / Shift-Tab  Cycle between widgets
#   e             Expand widget to full screen
#   /             Filter processes
#   dd            Kill selected process
#   s             Sort column
#   t             Toggle tree view (process widget)
#   m             Sort by memory
#   p             Sort by PID
#   n             Sort by name
#
# CLI flags (quick launch modes):
#   btm --basic           minimal layout, no graphs
#   btm --battery         show battery widget
#   btm --celsius / --fahrenheit
#   btm -c <config>       use specific config file
#
# Widget aliases in aliases.zsh:
#   btm-cpu   btm-mem   btm-net   btm-proc

# Recommended ~/.config/bottom/bottom.toml:
# [flags]
# color = "catppuccin-frappe"
# battery = true
# rate = "500ms"
# default_widget_type = "proc"
