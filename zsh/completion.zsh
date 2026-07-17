# ═══════════════════════════════════════════════════════════════
# ~/.zsh/completion.zsh — Completion system
# ═══════════════════════════════════════════════════════════════

# docker completion
typeset -U fpath
fpath=(~/.docker/completions $fpath)
autoload -Uz compinit && compinit

# zsh autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
