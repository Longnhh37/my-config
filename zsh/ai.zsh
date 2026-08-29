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
# MLX server (Apple Silicon, gpt-oss-20b)
# ═══════════════════════════════════════════════════════════════════════════════

# Start MLX server with any model: mlx_start <model> [port]
mlx_start() {
  if [[ -z "$1" ]]; then
    echo "❌ Missing model name. Usage: mlx_start <model> [port]" >&2
    return 1
  fi
  local model="$1"
  local port="${2:-8080}"
  local logdir="$HOME/.mlx_logs"
  mkdir -p "$logdir"
  local logfile="$logdir/mlx_${port}.log"
  local pidfile="$logdir/mlx_${port}.pid"

  echo "● Starting MLX server: $model (port $port)..."
  nohup mlx_lm.server --model "$model" --port "$port" \
    > "$logfile" 2>&1 &
  local pid=$!
  disown "$pid"
  echo "$pid" > "$pidfile"

  echo "✅ Started (PID $pid). Log: $logfile"
}

mlx_stop() {
  local port="${1:-8080}"
  local pidfile="$HOME/.mlx_logs/mlx_${port}.pid"
  if [[ ! -f "$pidfile" ]]; then
    echo "❌ No PID file for port $port" >&2
    return 1
  fi
  local pid
  pid=$(cat "$pidfile")
  if kill "$pid" 2>/dev/null; then
    echo "🛑 Stopped MLX server (PID $pid, port $port)"
    rm -f "$pidfile"
  else
    echo "❌ Process $pid not running (stale pidfile removed)" >&2
    rm -f "$pidfile"
  fi
}

mlx_log() {
  local port="${1:-8080}"
  tail -f "$HOME/.mlx_logs/mlx_${port}.log"
}


# Start MLX server fixed to gpt-oss-20b, port 8080
mlx_start_oss() {
  mlx_start "mlx-community/gpt-oss-20b-MXFP4-Q4" 8080
}

# Stop any running mlx server
mlx_stop() {
  if pgrep -f "mlx_lm.server" >/dev/null 2>&1; then
    pkill -f "mlx_lm.server"
    echo "■ MLX server stopped."
  else
    echo "ℹ️  No MLX server currently running."
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# OpenCode launch shortcuts
# ═══════════════════════════════════════════════════════════════════════════════

alias oc-or="ollama launch opencode --model ornith-local"
alias oc-gpt="ollama launch opencode --model gpt-oss:120b-cloud"

# opencode + gpt-oss-20b via MLX (does not touch the global ~/.config/opencode/opencode.json)
oc-oss-20b() {
  local model_id="mlx-community/gpt-oss-20b-MXFP4-Q4"
  local port=8080
  local cache_dir="$HOME/.cache/huggingface/hub/models--mlx-community--gpt-oss-20b-MXFP4-Q4"
  local cfg_file="/tmp/opencode-oss-20b.json"

  if [[ ! -d "$cache_dir" ]]; then
    echo "❌ Model not downloaded yet. Run 'mlx_start_oss' first so mlx-lm pulls it automatically." >&2
    return 1
  fi

  if ! curl -s "http://localhost:${port}/v1/models" >/dev/null 2>&1; then
    echo "❌ MLX server not running on port ${port}. Run 'mlx_start_oss' in another terminal first." >&2
    return 1
  fi

  cat > "$cfg_file" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "mlx-local/gpt-oss-20b",
  "provider": {
    "mlx-local": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "MLX Local",
      "options": {
        "baseURL": "http://localhost:${port}/v1",
        "apiKey": "none"
      },
      "models": {
        "gpt-oss-20b": { "name": "${model_id}" }
      }
    }
  }
}
EOF

  echo "✅ Model ready, server running on port ${port}. Starting opencode..."
  OPENCODE_CONFIG="$cfg_file" opencode
}
