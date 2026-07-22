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

# ═══════════════════════════════════════════════════════════════════════════════
# OpenCode launch shortcuts
# ═══════════════════════════════════════════════════════════════════════════════
alias oc-or="ollama launch opencode --model ornith-local"
alias oc-gpt="ollama launch opencode --model gpt-oss:120b-cloud"