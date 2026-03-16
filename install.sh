#!/bin/bash
# ============================================================
# 🏰 OLLAMA-AMD-SETUP — AMD RX580 Ollama Installation Script
# Ubuntu 22.04 | ROCm + Ollama + Models
# Run with: bash install.sh
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
echo "  🚀 OLLAMA-AMD-SETUP — One-Click AMD GPU Setup"
echo -e "${NC}"

# ── 1. System Updates and Pre-checks ───────────────────────────
echo -e "${YELLOW}[1/7] Performing pre-checks...${NC}"

# GPU Check
if ! lspci | grep -i "AMD/ATI" > /dev/null; then
    echo -e "${RED}Error: AMD GPU not found! This script is designed for RX 580 and similar AMD cards.${NC}"
    exit 1
fi
echo -e "${GREEN}AMD GPU detected ✓${NC}"

# Tailscale Check (Warning only)
if ! command -v tailscale &> /dev/null; then
    echo -e "${YELLOW}Warning: Tailscale not found. Remote access features might be limited.${NC}"
fi

echo -e "${YELLOW}Updating system...${NC}"
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

# ── 2. Dependencies ──────────────────────────────────────────
echo -e "${YELLOW}[2/7] Installing dependencies...${NC}"
sudo apt-get install -y -qq \
    curl wget git build-essential \
    software-properties-common \
    pciutils lshw

# ── 3. ROCm Installation (AMD RX580) ─────────────────────────
echo -e "${YELLOW}[3/7] Installing ROCm (AMD GPU support)...${NC}"

# Add ROCm repo
wget -q https://repo.radeon.com/amdgpu-install/6.3/ubuntu/jammy/amdgpu-install_6.3.60300-1_all.deb
sudo dpkg -i amdgpu-install_6.3.60300-1_all.deb
rm amdgpu-install_6.3.60300-1_all.deb

sudo amdgpu-install -y --usecase=rocm --no-dkms 2>/dev/null || \
sudo amdgpu-install -y --usecase=rocm

# Add user to render and video groups
sudo usermod -a -G render,video $USER

# ROCm environment
echo 'export PATH=$PATH:/opt/rocm/bin' >> ~/.bashrc
echo 'export HSA_OVERRIDE_GFX_VERSION=10.3.0' >> ~/.bashrc
export PATH=$PATH:/opt/rocm/bin
export HSA_OVERRIDE_GFX_VERSION=10.3.0

echo -e "${GREEN}ROCm installed ✓${NC}"

# ── 4. Ollama Installation ───────────────────────────────────
echo -e "${YELLOW}[4/7] Installing Ollama...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Ollama service configuration (for remote access)
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

echo -e "${GREEN}Ollama installed and started ✓${NC}"

# ── 5. Pull Models ───────────────────────────────────────────
echo -e "${YELLOW}[5/7] Pulling models (this may take a while)...${NC}"

# Wait for Ollama to start
sleep 5

echo -e "${BLUE}  → Pulling DeepSeek R1 7B...${NC}"
ollama pull deepseek-r1:7b

echo -e "${BLUE}  → Pulling Qwen2.5 3B...${NC}"
ollama pull qwen2.5:3b

echo -e "${BLUE}  → Pulling Qwen2.5 7B...${NC}"
ollama pull qwen2.5:7b

echo -e "${BLUE}  → Pulling Llama 3.2 3B...${NC}"
ollama pull llama3.2:3b

echo -e "${GREEN}All models downloaded ✓${NC}"

# ── 6. Firewall Settings ─────────────────────────────────────
echo -e "${YELLOW}[6/7] Configuring firewall (Tailscale only)...${NC}"

# Allow only from Tailscale interface
TAILSCALE_IF=$(ip link show | grep tailscale | awk -F: '{print $2}' | tr -d ' ' | head -1)

if [ -n "$TAILSCALE_IF" ]; then
    sudo ufw allow in on $TAILSCALE_IF to any port 11434
    echo -e "${GREEN}Ollama is now accessible via Tailscale ✓${NC}"
else
    echo -e "${YELLOW}Tailscale interface not found, manual configuration might be required${NC}"
fi

# ── 7. Test ──────────────────────────────────────────────────
echo -e "${YELLOW}[7/7] Testing installation...${NC}"
sleep 3

if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo -e "${GREEN}Ollama API is working ✓${NC}"
    echo ""
    echo -e "${BLUE}Installed models:${NC}"
    ollama list
else
    echo -e "${RED}Failed to reach Ollama API, manual check required${NC}"
    echo "sudo systemctl status ollama"
fi

# ── Summary ───────────────────────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}    Ollama-AMD-Setup is Complete!      ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "Ollama API: ${BLUE}http://$(hostname -I | awk '{print $1}'):11434${NC}"
echo -e "Tailscale:  ${BLUE}http://$(tailscale ip 2>/dev/null | head -1):11434${NC}"
echo ""
echo -e "${YELLOW}⚠️  Please reboot your system: sudo reboot${NC}"
echo -e "${YELLOW}   (Required for ROCm group changes)${NC}"
echo ""
echo -e "Test from another device: ${BLUE}curl http://AMD_HOST_TAILSCALE_IP:11434/api/tags${NC}"
