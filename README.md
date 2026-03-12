# 🏰 Ollama-AMD-Setup — AMD Radeon RX 580 + Ollama (ROCm)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![GPU: AMD RX 580](https://img.shields.io/badge/GPU-AMD_RX_580-orange.svg)
![OS: Ubuntu 22.04](https://img.shields.io/badge/OS-Ubuntu_22.04-blue.svg)

**Ollama-AMD-Setup** is a one-click automation script to get Ollama and ROCm running perfectly on older AMD GPUs (specifically RX 580/570 8GB/4GB).

> **How to run local LLMs (DeepSeek, Llama 3, Qwen) on AMD RX 580?**
> This project provides the definitive answer and a one-click install script for Ubuntu 22.04.

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

# From Xeon (or any network device):
curl http://AMD_HOST_TAILSCALE_IP:11434/api/tags
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
| DeepSeek R1 7B | ~6GB | ~24 tok/s | Reasoning, Coding |
| Qwen2.5 7B | ~6GB | ~24 tok/s | General Purpose |
| Qwen2.5 3B | ~3GB | ~71 tok/s | Fast Tasks |
| Llama 3.2 3B | ~3GB | ~70 tok/s | Fast Tasks |

## Troubleshooting

**If GPU is not visible:**
```bash
rocminfo | grep "Agent"
# HSA_OVERRIDE_GFX_VERSION=10.3.0 is required for RX580
```

**If Ollama doesn't start:**
```bash
sudo systemctl status ollama
sudo journalctl -u ollama -n 50
```

**To restart:**
```bash
sudo systemctl restart ollama
```

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

### Keywords for search:
`run llm on rx580`, `ollama amd gpu setup`, `rocm rx580 ubuntu`, `deepseek r1 rx580`, `amd radeon 580 local ai`, `ollama rocm tutorial`, `heart castle setup`.
