# ═══════════════════════════════════════════════════════════════════════════════
# ~/.zsh/ai.zsh
# ═══════════════════════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════════════════════════════════════
# Ollama server
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
# MLX server
# ═══════════════════════════════════════════════════════════════════════════════

# Start MLX server với model bất kỳ: mlx_start <model> [port]
mlx_start() {
  if [[ -z "$1" ]]; then
    echo "❌ Thiếu tên model. Dùng: mlx_start <model> [port]" >&2
    return 1
  fi
  local model="$1"
  local port="${2:-8080}"
  echo "● Đang khởi động MLX server: $model (port $port)..."
  mlx_lm.server --model "$model" --port "$port"
}

# Start MLX server cố định với gpt-oss-20b, port 8080
mlx_start_oss() {
  mlx_start "mlx-community/gpt-oss-20b-MXFP4-Q4" 8080
}

# Dừng mọi mlx server đang chạy
mlx_stop() {
  if pgrep -f "mlx_lm.server" >/dev/null 2>&1; then
    pkill -f "mlx_lm.server"
    echo "■ Đã dừng MLX server."
  else
    echo "ℹ️  Không có MLX server nào đang chạy."
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# OpenCode launch shortcuts
# ═══════════════════════════════════════════════════════════════════════════════

alias oc-or="ollama launch opencode --model ornith-local"
alias oc-gpt="ollama launch opencode --model gpt-oss:120b-cloud"

# opencode + gpt-oss-20b qua MLX (không đụng ~/.config/opencode/opencode.json global)
oc-oss-20b() {
  local model_id="mlx-community/gpt-oss-20b-MXFP4-Q4"
  local port=8080
  local cache_dir="$HOME/.cache/huggingface/hub/models--mlx-community--gpt-oss-20b-MXFP4-Q4"
  local cfg_file="/tmp/opencode-oss-20b.json"

  if [[ ! -d "$cache_dir" ]]; then
    echo "❌ Model chưa được tải về. Chạy 'mlx_start_oss' trước để mlx-lm tự tải model." >&2
    return 1
  fi

  if ! curl -s "http://localhost:${port}/v1/models" >/dev/null 2>&1; then
    echo "❌ MLX server chưa chạy ở port ${port}. Chạy 'mlx_start_oss' ở terminal khác trước." >&2
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

  echo "✅ Model đã sẵn sàng, server đang chạy tại port ${port}. Khởi động opencode..."
  OPENCODE_CONFIG="$cfg_file" opencode
}
