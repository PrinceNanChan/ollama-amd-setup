# Qwen3.5-2B RX580 Docker (Vulkan)

Bismillah. Tek komutla ayağa kaldırma paketi.

## 1) Hazırlık

Model dosyasının mevcut olduğundan emin ol:

- `/mnt/data/melikshah-hf/gguf/Qwen3.5-2B-q4_k_m.gguf`

## 2) Çalıştır (tek komut)

```bash
cd /home/melikshah/.openclaw/workspace/deploy/qwen35-rx580
docker compose up -d --build
```

## 3) Test

```bash
curl -s http://127.0.0.1:11440/v1/models

curl -s http://127.0.0.1:11440/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model":"Qwen3.5-2B-q4_k_m.gguf",
    "messages":[{"role":"user","content":"Reply exactly: OK"}],
    "max_tokens":8
  }'
```

## Opsiyonel ayarlar (.env)

Aynı klasöre `.env` açıp değiştirebilirsin:

```env
MODEL_DIR=/mnt/data/melikshah-hf/gguf
MODEL_PATH=/models/Qwen3.5-2B-q4_k_m.gguf
PORT=11440
CTX=2048
NGL=99
FLASH_ATTN=off
```

## Durdurma

```bash
docker compose down
```

## Notlar

- RX580 için `/dev/dri` mount edilir.
- Vulkan backend `llama.cpp` içinde build edilir.
- `FLASH_ATTN` bu model/build için varsayılan `off`.
