# ═══════════════════════════════════════════════════════════════════════════════
# ~/.zsh/dev_extras.zsh — Interactive FZF Engines & Modern CLI Helpers
# ═══════════════════════════════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────────────
# FZF SEARCH TOOLS — FILES, DIRS & TEXT
# ───────────────────────────────────────────────────────────────

# ff — Search all files (hidden included) and open the selection in Neovim
ff() {
  local file
  file=$(fd --type f --hidden --follow --exclude .git "${1:-.}" \
    | fzf \
        --preview 'bat --color=always --style=numbers {}' \
        --preview-window 'right:60%:wrap' \
        --bind 'ctrl-/:toggle-preview' \
        --bind 'ctrl-u:preview-half-page-up' \
        --bind 'ctrl-d:preview-half-page-down' \
        --prompt '  Files > ' \
        --header 'Enter: open nvim  │  Ctrl-/: toggle preview') \
  && nvim "$file"
}

# fdir — Find directories interactively and change directory (cd) into it
fdir() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git "${1:-.}" \
    | fzf \
        --preview 'eza -T --icons --color=always {} | head -80' \
        --preview-window 'right:50%:wrap' \
        --bind 'ctrl-/:toggle-preview' \
        --prompt '  Dirs > ' \
        --header 'Enter: cd  │  Ctrl-/: toggle preview') \
  && cd "$dir"
}

# fs — Grep text inside files and open nvim directly at the targeted line number
fs() {
  local sel file line
  sel=$(rg \
        --color=always \
        --line-number \
        --no-heading \
        --smart-case \
        "${1:-.}" \
    | fzf \
        --ansi \
        --delimiter ':' \
        --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
        --preview-window 'right:60%:+{2}-5:wrap' \
        --bind 'ctrl-/:toggle-preview' \
        --bind 'ctrl-u:preview-half-page-up' \
        --bind 'ctrl-d:preview-half-page-down' \
        --prompt '  Text > ' \
        --header 'Enter: open nvim at line  │  Ctrl-/: toggle preview') \
  || return

  file=$(echo "$sel" | cut -d: -f1)
  line=$(echo "$sel" | cut -d: -f2)
  nvim "$file" +"$line"
}

# frg — Live Ripgrep matching on-the-fly as you type (Telescope-like)
frg() {
  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
  local INITIAL="${1:-}"
  local result
  result=$(: | fzf \
      --ansi \
      --disabled \
      --query "$INITIAL" \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.05; $RG_PREFIX {q} || true" \
      --bind 'ctrl-/:toggle-preview' \
      --bind 'ctrl-u:preview-half-page-up' \
      --bind 'ctrl-d:preview-half-page-down' \
      --delimiter ':' \
      --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
      --preview-window 'right:60%:+{2}-5:wrap' \
      --prompt '  Live > ' \
      --header 'Type to search text · Enter: open in nvim') \
  || return

  local file line
  file=$(echo "$result" | cut -d: -f1)
  line=$(echo "$result" | cut -d: -f2)
  nvim "$file" +"$line"
}

# ───────────────────────────────────────────────────────────────
# FZF INTERACTIVE GIT EXTENSIONS
# ───────────────────────────────────────────────────────────────

# gb — Browse all local & remote branches to switch branches interactively
gb() {
  local branch
  branch=$(git branch --all --sort=-committerdate \
    | grep -v HEAD \
    | sed 's|remotes/origin/||;s/^[* ]*//' \
    | sort -u \
    | fzf \
        --preview 'git log --oneline --color=always --graph {1} | head -40' \
        --preview-window 'right:60%:wrap' \
        --prompt '  Branch > ' \
        --header 'Enter: checkout  │  Ctrl-/: toggle log graph') \
  && git checkout "$branch"
}

# glog — Browse interactive Git commit history tree with code diff preview panels
glog() {
  local commit
  commit=$(git log --oneline --color=always --graph --decorate \
    | fzf \
        --ansi \
        --preview 'git show --stat --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)' \
        --preview-window 'right:60%:wrap' \
        --bind 'ctrl-/:toggle-preview' \
        --prompt '  Log > ' \
        --header 'Enter: execute detailed git show') \
  && git show "$(echo "$commit" | grep -o '[a-f0-9]\{7,\}' | head -1)"
}

# gst — Multi-select files (using Tab key) to stage them to index (git add)
gst() {
  local selections
  selections=$(git -c color.status=always status --short \
    | fzf \
        --ansi \
        --multi \
        --preview 'git diff --color=always $(echo {} | sed "s/^...//" | tr -d " ")' \
        --preview-window 'right:70%:wrap' \
        --bind 'ctrl-/:toggle-preview' \
        --prompt '  Stage > ' \
        --header 'Tab: select multi files  │  Enter: execute git add') \
  && echo "$selections" \
    | sed 's/^...//' | tr -d ' ' \
    | xargs git add \
  && git status --short
}

# gstash — Browse Git stash records and immediately apply the chosen one
gstash() {
  local stash
  stash=$(git stash list \
    | fzf \
        --preview 'git stash show -p --color=always $(echo {} | cut -d: -f1)' \
        --preview-window 'right:60%:wrap' \
        --bind 'ctrl-/:toggle-preview' \
        --prompt '  Stash > ' \
        --header 'Enter: execute stash apply') \
  && git stash apply "$(echo "$stash" | cut -d: -f1)"
}

# ───────────────────────────────────────────────────────────────
# FZF SYSTEM INTERACTIVES
# ───────────────────────────────────────────────────────────────

# fkill — Interactive target list of active processes to terminate
fkill() {
  local pid
  pid=$(command ps aux \
    | sed 1d \
    | fzf \
        --multi \
        --prompt '  Kill > ' \
        --header 'Tab: multi-select  │  Enter: execute kill' \
    | awk '{print $2}') \
  && echo "$pid" | xargs kill -"${1:-9}"
}

# fenv — Search environment variables and copy the value directly to clipboard
fenv() {
  local var
  var=$(env | sort \
    | fzf \
        --prompt '  Env > ' \
        --preview 'echo {}' \
        --preview-window 'down:3:wrap') \
  && echo "$var" | pbcopy \
  && echo "✓ Copied to clipboard: $var"
}

# ───────────────────────────────────────────────────────────────
# MODERN CLI HELPERS & ANALYSIS (BAT / SD / RG / FD)
# ───────────────────────────────────────────────────────────────

# bhelp — Colorized help documentation engine via Bat
bhelp() { "$@" --help 2>&1 | bat --plain --language=help; }

# bshow — View text files limited within specified starting/ending lines
bshow() { bat --color=always --style=numbers,grid --line-range "${2:-1}:${3:-50}" "$1"; }

# sdr — Match and replace exact text string across all sub-files using 'sd'
sdr() {
  [[ $# -lt 2 ]] && { echo "Usage: sdr <old_string> <new_string>"; return 1; }
  fd --type f --hidden --exclude .git \
    | while IFS= read -r f; do sd "$1" "$2" "$f"; done
  echo "✓ Replacement complete: '$1' → '$2'"
}

# sdp — Preview matching string line contexts before replacing with sd
sdp() {
  [[ $# -lt 1 ]] && { echo "Usage: sdp <keyword>"; return 1; }
  rg --color=always --heading --line-number "$1"
}

# rgt — Ripgrep utility scoped strictly within specific file extensions/types
rgt() {
  [[ $# -lt 2 ]] && { echo "Usage: rgt <file_type> <keyword>"; return 1; }
  rg --type "$1" --color=always --heading --line-number "${@:2}"
}

# rgc — Count matching string occurrences mapped per file
rgc() {
  [[ $# -lt 1 ]] && { echo "Usage: rgc <keyword>"; return 1; }
  rg --count --sort-files "$1"
}

# rgh — Deep Ripgrep scanning looking through hidden files and .gitignore contents
rgh() { rg --hidden --no-ignore "$@"; }

# fdx — Scan files filtering directly by file extensions
fdx() {
  [[ $# -lt 1 ]] && { echo "Usage: fdx <extension> [path]"; return 1; }
  fd --type f --extension "$1" "${2:-.}"
}

# fdr — List files modified within the last N minutes
fdr() { fd --type f --changed-within "${1:-30}min" .; }

# fdl — List and sort files whose sizes exceed the specified threshold (Default > 1MB)
fdl() {
  fd --type f --size "+${1:-1MB}" . \
    | xargs -I{} sh -c 'du -sh "{}" 2>/dev/null' \
    | sort -h
}

# fdempty — Locate empty directories under current workspace tree
fdempty() { fd --type d --empty "${1:-.}"; }

# als — Look up alias or custom function structures matching specified prefixes
als() {
  local pat="${1:-}"
  {
    if [[ -z "$pat" ]]; then
      alias
    else
      alias | grep "^${pat}"
    fi

    print -l ${(ok)functions} \
      | grep "^${pat}" \
      | grep -v '^_' \
      | sed 's/$/ ()/'
  } | sort | bat --plain --language=zsh
}

# ───────────────────────────────────────────────────────────────
# SYSTEM SUPPORT ALIASES (EZA / PORTS)
# ───────────────────────────────────────────────────────────────
alias l="eza --git --icons --group-directories-first"
alias la="eza -a --git --icons --group-directories-first"
alias lg="eza -l --git --icons --group-directories-first"
alias lga="eza -la --git --icons --group-directories-first"
alias lgt="eza -l --git --icons --sort=modified"
alias lgr="eza -lR --git --icons --level=2"
alias treeg="eza -T --icons --git-ignore"

alias ports="lsof -iTCP -sTCP:LISTEN -n -P"
