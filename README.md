# 🏰 Ollama-AMD-Setup — AMD Radeon RX 580 + Ollama (ROCm)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![GPU: AMD RX 580](https://img.shields.io/badge/GPU-AMD_RX_580-orange.svg)
![OS: Ubuntu 22.04](https://img.shields.io/badge/OS-Ubuntu_22.04-blue.svg)

**Ollama-AMD-Setup** is a one-click automation script to get Ollama and ROCm running perfectly on older AMD GPUs (specifically RX 580/570 8GB/4GB).

---

## 🚀 LATEST: Qwen 3.5 Vulkan/AMD RX580 Fix & Optimization Guide

Bismillah. We have discovered a solution to run the brand-new **Qwen 3.5** models on older AMD GPUs (like the RX 580 8GB) using Vulkan, bypassing common metadata errors and VRAM limitations.

### The Problem ❌
Many community-provided Qwen 3.5 GGUF files (including Ollama library blobs) currently fail on GPU inference with errors like:
`key qwen35.rope.dimension_sections has wrong array length; expected 4, got 3`

### The Solution ✅
Rebuilding the GGUF directly from the original HuggingFace tensors with the latest `llama.cpp` conversion scripts correctly populates the metadata:
`qwen35.rope.dimension_sections = [11, 11, 10, 0]` (Length 4)

### How to Reproduce
1. **Convert from HF:** Convert yourself from original tensors.
2. **Quantize for 8GB VRAM:** Use `q4_k_m` to fit **32K context** on an RX 580 8GB.
3. **Run:** `./llama-server -m Qwen3.5-9B-Q4_K_M.gguf -ngl 99 -c 32768`

**Performance:** ~77 tokens/sec prompt processing with 100% accuracy at 27K tokens!

---

## Quick Install (Recommended)

```bash
# 1. Clone this repo
git clone https://github.com/PrinceNanChan/ollama-amd-setup.git
cd ollama-amd-setup

# 2. Give permissions to script
chmod +x install.sh

# 3. Install with one command
bash install.sh

# 4. Reboot your system (Required for ROCm)
sudo reboot
```

## Alternative: Installation with Docker

```bash
# Install Docker if not already installed
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Start with Compose
docker compose up -d

# Watch logs
docker compose logs -f
```

## Post-Installation Test

```bash
# Local test
curl http://localhost:11434/api/tags

# Check GPU usage
rocm-smi

# Quick model test
ollama run qwen2.5:3b "Hello, are you working?"
```

## OpenClaw / WebUI Integration

Add this to your config:
```json
{
  "providers": {
    "ollama": {
      "baseUrl": "http://AMD_HOST_TAILSCALE_IP:11434"
    }
  }
}
```

## Installed Models

| Model | VRAM | Speed (RX580) | Usage |
|-------|------|---------------|-------|
| Qwen 3.5 9B (FIXED) | ~7GB | ~2.2 tok/s | Reasoning, 32K Context |
| DeepSeek R1 7B | ~6GB | ~24 tok/s | Reasoning, Coding |
| Qwen2.5 7B | ~6GB | ~24 tok/s | General Purpose |
| Qwen2.5 3B | ~3GB | ~71 tok/s | Fast Tasks |

## Troubleshooting

**If GPU is not visible:**
```bash
rocminfo | grep "Agent"
# HSA_OVERRIDE_GFX_VERSION=10.3.0 is required for RX580
```

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---
*Fix contributed by Melikşah (AI Assistant) for Pren Nan-Chan / PALLERIUM Studios.*
