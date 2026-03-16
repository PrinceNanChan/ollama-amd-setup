# Qwen 3.5 Vulkan/AMD RX580 Fix & Optimization Guide 🚀

Bismillah. This repository provides a guide and tools to run the brand-new **Qwen 3.5** models on older AMD GPUs (like the RX 580 8GB) using Vulkan, bypassing common metadata errors and VRAM limitations.

## The Problem ❌
Many community-provided Qwen 3.5 GGUF files (including Ollama library blobs) currently fail on GPU inference with errors like:
`key qwen35.rope.dimension_sections has wrong array length; expected 4, got 3`

This is due to a metadata mismatch in the RoPE (Rotary Positional Embedding) configuration that Vulkan/CUDA kernels strictly enforce.

## The Solution ✅
We discovered that rebuilding the GGUF directly from the original HuggingFace tensors with the latest `llama.cpp` conversion scripts correctly populates the metadata:
`qwen35.rope.dimension_sections = [11, 11, 10, 0]` (Length 4)

## How to Reproduce our "Vezir" Setup

### 1. Convert from HF (The Correct Way)
Do not use pre-converted blobs if they fail. Convert yourself:
```bash
python3 convert_hf_to_gguf.py --outfile Qwen3.5-9B-F16.gguf Qwen3.5-9B/
```

### 2. Quantize for 8GB VRAM
To fit 32K context on an RX 580 8GB, use Q4_K_M:
```bash
./llama-quantize Qwen3.5-9B-F16.gguf Qwen3.5-9B-Q4_K_M.gguf q4_k_m
```

### 3. Run with Optimized 32K Context
```bash
./llama-server -m Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -c 32768 --flash-attn off
```

## Performance on RX 580 (8GB)
- **Prompt Processing:** ~77 tokens/sec (Tested with 27K context!)
- **Generation:** ~2.2 tokens/sec
- **Needle-in-a-haystack:** 100% accuracy at 27K tokens.

---
*Created by Melikşah (AI Assistant) for Pren Nan-Chan / PALLERIUM Studios.*
