# ═══════════════════════════════════════════════════════════════════════════════
# ~/.zsh/functions.zsh — Custom System, Development & Network Functions
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────
# AIR — global config với local override (kiểu bacon)
# Ưu tiên .air.toml / .air-test.toml / .air-lint.toml ở project root,
# nếu không có thì fallback về config chung trong ~/.config/air/
# ─────────────────────────────────────────────

gow() {
  if [[ -f ".air.toml" ]]; then
    air "$@"
  else
    air -c "$HOME/.config/air/air.toml" "$@"
  fi
}

gowt() {
  if [[ -f ".air-test.toml" ]]; then
    air -c ".air-test.toml" "$@"
  else
    air -c "$HOME/.config/air/air-test.toml" "$@"
  fi
}

gowl() {
  if [[ -f ".air-lint.toml" ]]; then
    air -c ".air-lint.toml" "$@"
  else
    air -c "$HOME/.config/air/air-lint.toml" "$@"
  fi
}

# ─────────────────────────────────────────────
# NAVIGATION & DIRECTORY MANAGEMENT
# ─────────────────────────────────────────────

# mkcd — Create a directory (including parents) and immediately change into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# up — Move up N directories quickly (Defaults to 1 level)
up() {
  local d="" n="${1:-1}"
  for ((i=1;i<=n;i++)); do d="../$d"; done
  cd "$d"
}

# cdic — Jump directly to the iCloud Drive synced development directory
cdic() {
  cd "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/code"
}

# ─────────────────────────────────────────────
# DEVELOPMENT ASSISTANT & CONTEXT BUNDLING
# ─────────────────────────────────────────────

# tvim — Create a new empty file and immediately open it in Neovim
tvim() { 
  touch "$1" && nvim "$1" 
}

# cncd — Initialize a new Cargo project (Rust) and automatically cd into it
cncd() { 
  cargo new "$@" && cd "$1" 
}

# gen_mod — Scan surrounding .rs files and automatically declare 'pub mod' in mod.rs
gen_mod() {
  emulate -L zsh
  local dir="${1:-.}"
  local pub="${2:-pub }"

  if [[ ! -d "$dir" ]]; then
    echo "Directory not found: $dir" >&2
    return 1
  fi

  : > "$dir/mod.rs"

  fd -e rs -d 1 . "$dir" --exclude mod.rs | sort | while read -r file; do
    local name="${${file##*/}%.rs}"
    cat >> "$dir/mod.rs" <<< "${pub}mod ${name};"
  done
  echo "✓ Generated mod.rs structure"
}

# mk_mod — Create a new module directory, generate mod.rs, and setup sub-modules
mk_mod() {
  emulate -L zsh
  local dir="$1"; shift
  mkdir -p "$dir"
  : > "$dir/mod.rs"
  for name in "$@"; do
    name="${name%.rs}"
    touch "$dir/${name}.rs"
    cat >> "$dir/mod.rs" <<< "pub mod ${name};"
  done
  echo "✓ Module structure initialized successfully"
}

# dump — Package source code text from multiple dirs/files into a single flat file for LLM context
dump() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: dump <dir_or_file> [dir_or_file ...]"
    return 1
  fi

  local first_name="${${1:a}:t}"
  local rand=$RANDOM
  local output="$HOME/Downloads/dumped_${first_name}_${rand}.txt"

  while [[ -e "$output" ]]; do
    rand=$RANDOM
    output="$HOME/Downloads/dumped_${first_name}_${rand}.txt"
  done

  : > "$output"

  for target in "$@"; do
    if [[ -d "$target" ]]; then
      find "$target" -type f \
        ! -path "*/.git/*" \
        ! -name ".DS_Store" \
        ! -name "$(basename "$output")" | sort | while read -r file; do
        if file --brief --mime "$file" | grep -q 'binary\|image/\|audio/\|video/'; then
          continue
        fi
        {
          echo "=================================================="
          echo "FILE: $file"
          echo "=================================================="
          cat "$file"
          echo
          echo
        } >> "$output"
      done
    elif [[ -f "$target" ]]; then
      if file --brief --mime "$target" | grep -q 'binary\|image/\|audio/\|video/'; then
        echo "⚠ Skip (binary): $target"
        continue
      fi
      {
        echo "=================================================="
        echo "FILE: $target"
        echo "=================================================="
        cat "$target"
        echo
        echo
      } >> "$output"
    else
      echo "⚠ Skip (not found): $target"
    fi
  done

  local count
  count=$(grep -c '^FILE:' "$output" 2>/dev/null || echo 0)
  echo "✓ Packaged $count files → $output"
}

# ─────────────────────────────────────────────
# NETWORKING & PROTOCOLS (USING XH)
# ─────────────────────────────────────────────

# myip — Display both local and public IP addresses (Uses xh instead of curl)
myip() {
  echo "Local IP : $(ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print $1}')"
  echo "Public IP: $(xh -b GET ifconfig.me 2>/dev/null)"
}

# serve — Spin up a quick local HTTP web server using Python in the current directory
serve() {
  local port="${1:-8000}"
  echo "▶ HTTP Server running at: http://localhost:${port} ($(pwd))"
  python3 -m http.server "$port"
}

# headers — Fetch and inspect response headers of a specific URL (Uses xh)
headers() {
  [[ -z "$1" ]] && { echo "Usage: headers <url>"; return 1; }
  xh -h "$1"
}

# ─────────────────────────────────────────────
# SYSTEM UTILITIES & ENVIRONMENT VARIABLES
# ─────────────────────────────────────────────

# envload — Load environment variables from a .env file into the current shell session
envload() {
  local envfile="${1:-.env}"
  [[ ! -f "$envfile" ]] && { echo "File not found: $envfile"; return 1; }
  set -o allexport
  source "$envfile"
  set +o allexport
  echo "✓ Successfully loaded environment from: $envfile"
}

# json — Pretty-print and syntax-highlight JSON streams or files
json() {
  if [[ -n "$1" && "$1" != "-" ]]; then
    cat "$1"
  else
    cat
  fi | python3 -m json.tool | bat --plain --language=json
}

# ppath — Print system PATH variables clearly separated line-by-line
ppath() { 
  echo "$PATH" | tr ':' '\n' | bat --plain --language=ini;
}

# topmem — Monitor top resource-consuming processes grouped or detailed
topmem() {
  local cpu mem rss user proc
  local ps_snapshot
  ps_snapshot="$(command ps aux)"

  if [[ "$1" == "-f" ]]; then
    printf '\033[1;33m%s\033[0m\n' "DETAILED PROCESS MEMORY USAGE (FULL)"
    printf "\033[1;37m%8s  %8s  %10s  %-12s  %s\033[0m\n" "%CPU" "%MEM" "RSS(MB)" "USER" "PROCESS"
    print -r -- "$ps_snapshot" | awk 'NR>1 { cmd = $11; sub(/.*\//, "", cmd); sub(/\.app$/, "", cmd); rss_mb = $6 / 1024; printf "%.2f\t%.2f\t%.2f\t%s\t%s\n", $3, $4, rss_mb, $1, cmd }' | sort -t$'\t' -k3,3nr -k1,1nr -k2,2nr | head -8 | \
    while IFS=$'\t' read -r cpu mem rss user proc; do
      printf "\033[0;33m%8s\033[0m  \033[0;31m%8s\033[0m  \033[0;35m%10s\033[0m  \033[0;36m%-12s\033[0m  \033[0;32m%s\033[0m\n" "$cpu" "$mem" "$rss" "$user" "$proc"
    done
  else
    printf '\033[1;33m%s\033[0m\n' "AGGREGATED PROCESS MEMORY USAGE (GROUPED)"
    printf "\033[1;37m%8s  %8s  %10s  %s\033[0m\n" "%CPU" "%MEM" "RSS(MB)" "PROCESS"
    print -r -- "$ps_snapshot" | awk 'NR>1 { cmd = $11; sub(/.*\//, "", cmd); sub(/\.app$/, "", cmd); cmd = tolower(cmd); rss[cmd] += $6; mem[cmd] += $4; cpu[cmd] += $3 } END { for (c in rss) printf "%.2f\t%.2f\t%.2f\t%s\n", cpu[c], mem[c], rss[c]/1024, c }' | sort -t$'\t' -k3,3nr -k1,1nr -k2,2nr | head -8 | \
    while IFS=$'\t' read -r cpu mem rss proc; do
      printf "\033[0;33m%8s\033[0m  \033[0;31m%8s\033[0m  \033[0;35m%10s\033[0m  \033[0;32m%s\033[0m\n" "$cpu" "$mem" "$rss" "$proc"
    done
  fi

  printf "\033[1;30m%s\033[0m\n" "──────────────────────────────────────────"
  print -r -- "$ps_snapshot" | awk 'NR>1 { rss += $6; cpu += $3; mem += $4 } END { printf "\033[0;33m%8.2f\033[0m  \033[0;31m%8.2f\033[0m  \033[0;35m%10.2f\033[0m  \033[0;32m%s\033[0m\n", cpu, mem, rss/1024, "TOTAL SYSTEM USAGE" }'
}

# ─────────────────────────────────────────────
# TMUX DAEMON CONTROL
# ─────────────────────────────────────────────

# tmuxd-restart — Restart the TMUX status bar background rendering daemon if frozen
tmuxd-restart() {
  echo "Stopping old tmuxd process..."
  pkill -x tmuxd 2>/dev/null; sleep 0.3
  echo "Clearing socket cache files..."
  rm -f /tmp/tmuxd.sock /tmp/tmux_status_*
  echo "Restarting background service..."
  ~/.local/bin/tmuxd daemon &>/tmp/tmuxd.log &
  sleep 0.5
  if pgrep -x tmuxd > /dev/null; then
    echo "✓ Dịch vụ tmuxd đã hoạt động trở lại (PID: $(pgrep -x tmuxd))"
    tmux refresh-client -S 2>/dev/null
  else
    echo "✗ Khởi chạy thất bại — Tra cứu lỗi tại /tmp/tmuxd.log"
  fi
}

# ─────────────────────────────────────────────
# BASIC GIT NAVIGATION
# ─────────────────────────────────────────────

# groot — Navigate directly back to the root directory containing the repository's .git folder
groot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not inside a Git repo"; return 1; }
  cd "$root"
}

# gnew — Create a new Git branch and immediately switch to it
gnew() {
  [[ -z "$1" ]] && { echo "Usage: gnew <branch_name>"; return 1; }
  git switch -c "$1"
}

# greset — Hard discard all uncommitted changes on a single specified file
greset() {
  [[ -z "$1" ]] && { echo "Usage: greset <file_path>"; return 1; }
  git checkout -- "$1"
}
