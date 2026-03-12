#!/bin/bash
# ============================================================
# 🏰 HEART CASTLE — AMD RX580 Ollama Kurulum Scripti
# Ubuntu 22.04 | ROCm + Ollama + Modeller
# Tek komutla çalıştır: bash install.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ██╗  ██╗███████╗ █████╗ ██████╗ ████████╗"
echo "  ██║  ██║██╔════╝██╔══██╗██╔══██╗╚══██╔══╝"
echo "  ███████║█████╗  ███████║██████╔╝   ██║   "
echo "  ██╔══██║██╔══╝  ██╔══██║██╔══██╗   ██║   "
echo "  ██║  ██║███████╗██║  ██║██║  ██║   ██║   "
echo "  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝  "
echo "  🏰 CASTLE — AMD RX580 + Ollama Kurulumu"
echo -e "${NC}"

# ── 1. Sistem güncellemesi ve Ön Kontroller ───────────────────
echo -e "${YELLOW}[1/7] Ön kontroller yapılıyor...${NC}"

# GPU Kontrolü
if ! lspci | grep -i "AMD/ATI" > /dev/null; then
    echo -e "${RED}Hata: AMD GPU bulunamadı! Bu script RX 580 ve benzeri AMD kartlar için tasarlanmıştır.${NC}"
    exit 1
fi
echo -e "${GREEN}AMD GPU tespit edildi ✓${NC}"

# Tailscale Kontrolü (Sadece uyarı)
if ! command -v tailscale &> /dev/null; then
    echo -e "${YELLOW}Uyarı: Tailscale kurulu değil. Uzaktan erişim özellikleri kısıtlı olabilir.${NC}"
fi

echo -e "${YELLOW}Sistem güncelleniyor...${NC}"
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

# ── 2. Bağımlılıklar ───────────────────────────────────────
echo -e "${YELLOW}[2/7] Bağımlılıklar kuruluyor...${NC}"
sudo apt-get install -y -qq \
    curl wget git build-essential \
    software-properties-common \
    pciutils lshw

# ── 3. ROCm kurulumu (AMD RX580) ───────────────────────────
echo -e "${YELLOW}[3/7] ROCm kuruluyor (AMD GPU desteği)...${NC}"

# ROCm repo ekle
wget -q https://repo.radeon.com/amdgpu-install/6.3/ubuntu/jammy/amdgpu-install_6.3.60300-1_all.deb
sudo dpkg -i amdgpu-install_6.3.60300-1_all.deb
rm amdgpu-install_6.3.60300-1_all.deb

sudo amdgpu-install -y --usecase=rocm --no-dkms 2>/dev/null || \
sudo amdgpu-install -y --usecase=rocm

# Kullanıcıyı render ve video grubuna ekle
sudo usermod -a -G render,video $USER

# ROCm environment
echo 'export PATH=$PATH:/opt/rocm/bin' >> ~/.bashrc
echo 'export HSA_OVERRIDE_GFX_VERSION=10.3.0' >> ~/.bashrc
export PATH=$PATH:/opt/rocm/bin
export HSA_OVERRIDE_GFX_VERSION=10.3.0

echo -e "${GREEN}ROCm kuruldu ✓${NC}"

# ── 4. Ollama kurulumu ─────────────────────────────────────
echo -e "${YELLOW}[4/7] Ollama kuruluyor...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Ollama servis konfigürasyonu (Tailscale erişimi için)
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="HSA_OVERRIDE_GFX_VERSION=10.3.0"
Environment="ROCR_VISIBLE_DEVICES=0"
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama

echo -e "${GREEN}Ollama kuruldu ve başlatıldı ✓${NC}"

# ── 5. Modelleri indir ─────────────────────────────────────
echo -e "${YELLOW}[5/7] Modeller indiriliyor (bu biraz sürebilir)...${NC}"

# Ollama'nın başlamasını bekle
sleep 5

echo -e "${BLUE}  → DeepSeek R1 7B indiriliyor...${NC}"
ollama pull deepseek-r1:7b

echo -e "${BLUE}  → Qwen2.5 3B indiriliyor...${NC}"
ollama pull qwen2.5:3b

echo -e "${BLUE}  → Qwen2.5 7B indiriliyor...${NC}"
ollama pull qwen2.5:7b

echo -e "${BLUE}  → Llama 3.2 3B indiriliyor...${NC}"
ollama pull llama3.2:3b

echo -e "${GREEN}Tüm modeller indirildi ✓${NC}"

# ── 6. Firewall ayarları ───────────────────────────────────
echo -e "${YELLOW}[6/7] Firewall ayarlanıyor (sadece Tailscale)...${NC}"

# Sadece Tailscale interface'inden erişime izin ver
TAILSCALE_IF=$(ip link show | grep tailscale | awk -F: '{print $2}' | tr -d ' ' | head -1)

if [ -n "$TAILSCALE_IF" ]; then
    sudo ufw allow in on $TAILSCALE_IF to any port 11434
    echo -e "${GREEN}Ollama sadece Tailscale üzerinden erişilebilir ✓${NC}"
else
    echo -e "${YELLOW}Tailscale interface bulunamadı, manuel ayar gerekebilir${NC}"
fi

# ── 7. Test ────────────────────────────────────────────────
echo -e "${YELLOW}[7/7] Kurulum test ediliyor...${NC}"
sleep 3

if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo -e "${GREEN}Ollama API çalışıyor ✓${NC}"
    echo ""
    echo -e "${BLUE}Kurulu modeller:${NC}"
    ollama list
else
    echo -e "${RED}Ollama API'ye ulaşılamadı, manuel kontrol gerekiyor${NC}"
    echo "sudo systemctl status ollama"
fi

# ── Özet ──────────────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  🏰 Heart Castle kurulumu tamamlandı!  ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "Ollama API: ${BLUE}http://$(hostname -I | awk '{print $1}'):11434${NC}"
echo -e "Tailscale:  ${BLUE}http://$(tailscale ip 2>/dev/null | head -1):11434${NC}"
echo ""
echo -e "${YELLOW}⚠️  Sistemi yeniden başlat: sudo reboot${NC}"
echo -e "${YELLOW}   (ROCm grup değişiklikleri için gerekli)${NC}"
echo ""
echo -e "Xeon'dan test: ${BLUE}curl http://HEART_CASTLE_TAILSCALE_IP:11434/api/tags${NC}"
