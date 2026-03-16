#!/usr/bin/env bash
set -euo pipefail

MODEL_PATH="${MODEL_PATH:-/models/Qwen3.5-2B-q4_k_m.gguf}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-11440}"
CTX="${CTX:-2048}"
NGL="${NGL:-99}"
FLASH_ATTN="${FLASH_ATTN:-off}"

if [[ ! -f "$MODEL_PATH" ]]; then
  echo "[ERROR] Model not found: $MODEL_PATH"
  echo "Mount your model folder into /models or set MODEL_PATH correctly."
  exit 1
fi

exec /opt/llama.cpp/build/bin/llama-server \
  -m "$MODEL_PATH" \
  --host "$HOST" \
  --port "$PORT" \
  -ngl "$NGL" \
  -c "$CTX" \
  --flash-attn "$FLASH_ATTN"
