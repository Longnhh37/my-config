# ═══════════════════════════════════════════════════════════════
# ~/.zsh/options.zsh — Shell options & keybindings
# ═══════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
# EMACS KEY BINDING
# (preferred over vi — faster for editing command line)
# ─────────────────────────────────────────────
bindkey -e
bindkey -M emacs -r '^['        # free up ESC so Alt-combos work cleanly

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^[v' edit-command-line  # Alt-v → open current line in $VISUAL

# ─────────────────────────────────────────────
# HISTORY
# ─────────────────────────────────────────────
setopt HIST_IGNORE_SPACE       # don't record lines starting with space
setopt HIST_IGNORE_ALL_DUPS    # remove older duplicate entries
setopt HIST_REDUCE_BLANKS      # trim extra blanks

# ─────────────────────────────────────────────
# MISC KEYS
# ─────────────────────────────────────────────
stty -ixon                     # disable Ctrl-S/Q flow control in terminal
bindkey '^S' clear-screen      # Ctrl-S → clear (safe now that ixon is off)
