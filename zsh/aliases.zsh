# ═══════════════════════════════════════════════════════════════
# ~/.zsh/aliases.zsh — All aliases, grouped by tool
# ═══════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
# GO
# ─────────────────────────────────────────────
alias gob="go build ./..."
alias gor="go run ."
alias got="go test ./... -v"
alias gotc="go test ./... -cover"
alias gotb="go test -bench=. -benchmem ./..."
alias gom="go mod tidy"
alias gomv="go mod verify"
alias gov="govulncheck ./..."
alias gol="golangci-lint run ./..."
alias golfix="golangci-lint run --fix ./..."
alias gofmt="gofmt -l -w ."
alias gofumpt="gofumpt -l -w ."
alias goi="goimports -w ."
gobr() {
    go build -ldflags='-s -w' -o "./bin/$(basename "$PWD")" .
}

# ─────────────────────────────────────────────
# DOCKER
# ─────────────────────────────────────────────
alias d="docker"
alias dc="docker compose"

alias dps="docker ps"
alias dpa="docker ps -a"
alias dstop="docker stop"
alias drm="docker rm"

alias di="docker images"
alias drmi="docker rmi"

alias dlog="docker logs -f"
alias dex="docker exec -it"

alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcb="docker compose build"

alias dclean="docker system prune -af && docker volume prune -f"

# ─────────────────────────────────────────────
# NEOVIM
# ─────────────────────────────────────────────
alias vim='nvim'
alias vim_reset='rm -rf ~/.local/state/nvim ~/.cache/nvim'

# ─────────────────────────────────────────────
# PYTHON
# ─────────────────────────────────────────────
alias py='python3'

# ─────────────────────────────────────────────
# RUST / CARGO
# ─────────────────────────────────────────────
alias cb="cargo build"
alias cbr="cargo build --release"
alias cr="cargo run"
alias crb="cargo run --bin"
alias ct="cargo test"
alias ctb="cargo test --bin"
alias cnr="cargo nextest run"
alias cnrb="cargo nextest run --bin"
alias cc="cargo clippy --all-targets --all-features"
alias cfix="cargo clippy --fix"
alias cfmt="cargo fmt"
alias cex="cargo expand"

alias bac="bacon"
alias bacbin="bacon -- --bin"
alias bact="bacon test"
alias bacclip="bacon clippy"

# ─────────────────────────────────────────────
# TMUX
# ─────────────────────────────────────────────
alias ta="tmux attach -t"
alias tl="tmux list-sessions"
alias tn="tmux new -s"

# ─────────────────────────────────────────────
# GIT
# ─────────────────────────────────────────────
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph"

# ─────────────────────────────────────────────
# MODERN CLI REPLACEMENTS
# du → dust  |  ps → procs  |  top/htop → btm
# ─────────────────────────────────────────────
alias du="dust"
alias ps="procs"
alias top="btm"
alias htop="btm"

# btm quick views (no prefix needed)
alias btm-cpu="btm --default-widget-type cpu"
alias btm-mem="btm --default-widget-type mem"
alias btm-net="btm --default-widget-type net"
alias btm-proc="btm --default-widget-type proc"

# ─────────────────────────────────────────────
# CONFIG & SYSTEM
# ─────────────────────────────────────────────

# quick-edit shortcuts — update if module paths change
alias zshrc="nvim ~/.zshrc"
alias zshe="nvim ~/.zsh/env.zsh"
alias zshopt="nvim ~/.zsh/options.zsh"
alias zsha="nvim ~/.zsh/aliases.zsh"
alias zshf="nvim ~/.zsh/functions.zsh"
alias zsht="nvim ~/.zsh/tools.zsh"
alias zshx="nvim ~/.zsh/dev_extras.zsh"
alias zshai="nvim ~/.zsh/ai.zsh"
alias vimconf="nvim ~/.config/nvim/lua"

alias reload="source ~/.zshrc && echo '✓ reloaded'"
alias doc="nvim ~/code/zshrc_dev_guide.txt"
alias showpath='echo $PATH | tr ":" "\n" | bat --plain --language=ini'
alias showfpath='echo $FPATH | tr ":" "\n" | bat --plain --language=ini'

# clear screen + scrollback buffer
alias cls=' printf "\033[2J\033[3J\033[H"'

