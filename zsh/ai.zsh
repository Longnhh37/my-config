# ═══════════════════════════════════════════════════════════════════════════════
# ~/.zsh/ai.zsh
# ═══════════════════════════════════════════════════════════════════════════════

# --- Ollama server ---
export OLLAMA_HOST="http://127.0.0.1:11434"
export OLLAMA_MAX_LOADED_MODELS=1
export OLLAMA_KEEP_ALIVE="2h"
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_KV_CACHE_TYPE="q8_0"

# --- Claude Code <-> Ollama ---
export ANTHROPIC_AUTH_TOKEN="ollama"
export ANTHROPIC_API_KEY=""
export ANTHROPIC_BASE_URL="http://127.0.0.1:11434"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1


# --- Ollama server control ---
alias olstart="nohup ollama serve > /dev/null 2>&1 & disown && echo '● Ollama server started in background.'"

olstop() {
  local pids
  pids=$(ollama ps 2>/dev/null | awk 'NR>1{print $1}')
  if [ -n "$pids" ]; then
    ollama stop $pids 2>/dev/null
  fi
  pkill ollama 2>/dev/null
  echo '■ Ollama stopped.'
}

alias olrestart="olstop; sleep 1; olstart"
alias olkill="pkill -9 ollama; echo '■ Ollama force killed.'"

# ornith-9b
alias clst-ornith-9b="ollama launch claude --model ornith:9b -- --bare"

clhere-ornith-9b() {
  ollama launch claude --model ornith:9b -- --add-dir "$(pwd)"
}

# ornith-35b
alias clst-ornith-35b="ollama launch claude --model ornith-35b:latest -- --bare"

clhere-ornith-35b() {
  ollama launch claude --model ornith-35b:latest -- --add-dir "$(pwd)"
}

# gpt-oss:cloud
alias clst-gpt="ollama launch claude --model gpt-oss:120b-cloud -- --bare"
clhere-gpt() {
  ollama launch claude --model gpt-oss:120b-cloud -- --add-dir "$(pwd)"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Claude Code session shortcuts
# ═══════════════════════════════════════════════════════════════════════════════

# --- Xoá toàn bộ session của project hiện tại (dọn dẹp) ---
clclean() {
  rm -rf ~/.claude/projects/$(pwd | sed 's/[^a-zA-Z0-9]/-/g')/*.jsonl \
    && echo 'Cleared sessions for this project.'
}

# --- Tạo session mới có tên ---
clnew() {
  if [ -z "$1" ]; then
    echo "Usage: clnew <session-name>"
    return 1
  fi
  claude -n "$1"
}

clhere-ornith-9b-named() {
  ollama launch claude --model ornith:9b -- --add-dir "$(pwd)" -n "$1"
}
clhere-ornith-35b-named() {
  ollama launch claude --model ornith-35b:latest -- --add-dir "$(pwd)" -n "$1"
}
