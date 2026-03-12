# 🏰 Heart Castle — AMD Radeon RX 580 + Ollama Kurulum Rehberi (ROCm)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![GPU: AMD RX 580](https://img.shields.io/badge/GPU-AMD_RX_580-orange.svg)
![OS: Ubuntu 22.04](https://img.shields.io/badge/OS-Ubuntu_22.04-blue.svg)

**Heart Castle**, eski nesil AMD ekran kartlarında (özellikle RX 580/570 8GB/4GB) Ollama ve ROCm kurulumunu çocuk oyuncağı haline getiren bir otomasyon sistemidir.

> **How to run local LLMs (DeepSeek, Llama 3, Qwen) on AMD RX 580?**
> This project provides the definitive answer and a one-click install script for Ubuntu 22.04.

## Hızlı Kurulum (Önerilen)

```bash
# 1. Bu repoyu klonla
git clone https://github.com/Prens-Nan-Chan/heart-castle-setup.git
cd heart-castle-setup

# 2. Script'e izin ver
chmod +x install.sh

# 3. Tek komutla kur
bash install.sh

# 4. Sistemi yeniden başlat (ROCm için zorunlu)
sudo reboot
```

## Alternatif: Docker ile Kurulum

```bash
# Docker kurulu değilse önce kur
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Compose ile başlat
docker compose up -d

# Logları izle
docker compose logs -f
```

## Kurulum Sonrası Test

```bash
# Lokal test
curl http://localhost:11434/api/tags

# GPU kullanımını kontrol et
rocm-smi

# Model test (hızlı)
ollama run qwen2.5:3b "Merhaba, çalışıyor musun?"
```

## Xeon'dan Erişim

Heart Castle'ın Tailscale IP'sini bulduktan sonra:

```bash
# Tailscale IP'yi öğren (Heart Castle'da çalıştır)
tailscale ip

# Xeon'dan test et
curl http://HEART_CASTLE_TAILSCALE_IP:11434/api/tags
```

## OpenClaw Entegrasyonu

Xeon'daki openclaw config'ine ekle:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/deepseek-r1:7b"
      }
    }
  },
  "providers": {
    "ollama": {
      "baseUrl": "http://HEART_CASTLE_TAILSCALE_IP:11434"
    }
  }
}
```

## Kurulu Modeller

| Model | VRAM | Hız (RX580) | Kullanım |
|-------|------|-------------|----------|
| DeepSeek R1 7B | ~6GB | ~24 tok/s | Reasoning, kod |
| Qwen2.5 7B | ~6GB | ~24 tok/s | Genel amaç |
| Qwen2.5 3B | ~3GB | ~71 tok/s | Hızlı görevler |
| Llama 3.2 3B | ~3GB | ~70 tok/s | Hızlı görevler |

## Sorun Giderme

**GPU görünmüyorsa:**
```bash
rocminfo | grep "Agent"
# HSA_OVERRIDE_GFX_VERSION=10.3.0 gerekli RX580 için
```

**Ollama başlamıyorsa:**
```bash
sudo systemctl status ollama
sudo journalctl -u ollama -n 50
```

**Yeniden başlatmak için:**
```bash
sudo systemctl restart ollama
```

---

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakabilirsiniz.

---

### Keywords for search:
`run llm on rx580`, `ollama amd gpu setup`, `rocm rx580 ubuntu`, `deepseek r1 rx580`, `amd radeon 580 local ai`, `ollama rocm tutorial`, `heart castle setup`.
