# Bismillah — Milestone: Qwen3.5-2B GPU Ready on RX580

**Date (UTC):** 2026-03-16
**Status:** ✅ Completed
**Owner:** Melikşah

## What was achieved

Qwen3.5-2B was successfully converted and quantized into a GGUF format that loads on RX580 via Vulkan.

- HF snapshot → GGUF (f16)
- GGUF f16 → GGUF q4_k_m
- Loaded with `llama-server` (build b8368) on Vulkan
- Verified GPU offload and successful inference endpoint response

## Artifacts

### Model files
- `/mnt/data/melikshah-hf/gguf/Qwen3.5-2B-f16.gguf`
- `/mnt/data/melikshah-hf/gguf/Qwen3.5-2B-q4_k_m.gguf`

### Sizes
- `Qwen3.5-2B-f16.gguf`: **3.6G**
- `Qwen3.5-2B-q4_k_m.gguf`: **1.2G**

### SHA256
- `Qwen3.5-2B-f16.gguf`
  - `9494e489554a5efe5d0ec28113753ac82ef19da7901447ced7d6fc59c5591a35`
- `Qwen3.5-2B-q4_k_m.gguf`
  - `4a6d7da3b0a0cb3432d819393818b81d2e0f9a971f271f6b7a4c13312e489af9`

## Exact commands used

```bash
# 1) Convert HF -> GGUF f16
cd /home/melikshah/llama.cpp
python3 convert_hf_to_gguf.py /mnt/data/melikshah-hf/Qwen3.5-2B \
  --outfile /mnt/data/melikshah-hf/gguf/Qwen3.5-2B-f16.gguf \
  --outtype f16

# 2) Quantize f16 -> q4_k_m
/home/melikshah/llama-vulkan/llama-b8368/llama-quantize \
  /mnt/data/melikshah-hf/gguf/Qwen3.5-2B-f16.gguf \
  /mnt/data/melikshah-hf/gguf/Qwen3.5-2B-q4_k_m.gguf \
  q4_k_m

# 3) Run Vulkan server (test)
/home/melikshah/llama-vulkan/llama-b8368/llama-server \
  -m /mnt/data/melikshah-hf/gguf/Qwen3.5-2B-q4_k_m.gguf \
  --host 127.0.0.1 --port 11440 -ngl 99 -c 2048 --flash-attn off
```

## Verification evidence

- Model loaded with no rope section mismatch error
- Server log includes:
  - `offloading 23 repeating layers to GPU`
  - `offloaded 25/25 layers to GPU`
- `/v1/chat/completions` returned HTTP 200

## Notes

- Previous error (`qwen35.rope.dimension_sections expected 4 got 3`) did **not** appear after this pipeline.
- `--flash-attn` requires explicit value (`on|off|auto`) in this build.

## Next recommended step

Use the deploy kit in `deploy/qwen35-rx580` to run this with one command (`docker compose up -d --build`).
