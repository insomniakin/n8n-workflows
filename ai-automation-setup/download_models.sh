#!/bin/bash

# AI Automation System - Model Download Script
# Downloads essential AI models for image and video generation

set -e

echo "================================================"
echo "AI Automation System - Model Download"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MODELS_DIR=~/ai-automation/comfyui/ComfyUI/models

# Check if ComfyUI is installed
if [ ! -d "$MODELS_DIR" ]; then
    echo -e "${RED}ComfyUI models directory not found. Please run install_comfyui.sh first${NC}"
    exit 1
fi

echo -e "${BLUE}This script will download several large AI models.${NC}"
echo -e "${BLUE}Total download size: ~20-30 GB${NC}"
echo -e "${BLUE}Make sure you have enough disk space and a stable internet connection.${NC}"
echo ""
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Function to download with progress
download_file() {
    local url=$1
    local output=$2
    local description=$3
    
    echo -e "${GREEN}Downloading: $description${NC}"
    wget --progress=bar:force:noscroll -c "$url" -O "$output"
    echo -e "${GREEN}✓ Downloaded: $description${NC}"
    echo ""
}

# Download SDXL Base Model
echo -e "${YELLOW}=== Downloading Stable Diffusion XL Base ===${NC}"
cd $MODELS_DIR/checkpoints
if [ ! -f "sd_xl_base_1.0.safetensors" ]; then
    download_file \
        "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" \
        "sd_xl_base_1.0.safetensors" \
        "SDXL Base Model (6.9 GB)"
else
    echo -e "${GREEN}✓ SDXL Base already downloaded${NC}"
fi

# Download SDXL VAE
echo -e "${YELLOW}=== Downloading SDXL VAE ===${NC}"
cd $MODELS_DIR/vae
if [ ! -f "sdxl_vae.safetensors" ]; then
    download_file \
        "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors" \
        "sdxl_vae.safetensors" \
        "SDXL VAE (335 MB)"
else
    echo -e "${GREEN}✓ SDXL VAE already downloaded${NC}"
fi

# Download Stable Video Diffusion
echo -e "${YELLOW}=== Downloading Stable Video Diffusion ===${NC}"
cd $MODELS_DIR/checkpoints
if [ ! -f "svd_xt.safetensors" ]; then
    download_file \
        "https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt/resolve/main/svd_xt.safetensors" \
        "svd_xt.safetensors" \
        "Stable Video Diffusion XT (9.8 GB)"
else
    echo -e "${GREEN}✓ SVD XT already downloaded${NC}"
fi

# Optional: Download Realistic Vision (photorealistic model)
echo ""
echo -e "${BLUE}Optional: Download Realistic Vision model for photorealistic images?${NC}"
read -p "Download Realistic Vision? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd $MODELS_DIR/checkpoints
    if [ ! -f "realistic_vision_v5.safetensors" ]; then
        echo -e "${YELLOW}Note: This requires a Civitai account and API key${NC}"
        echo -e "${YELLOW}You can download manually from: https://civitai.com/models/4201${NC}"
        echo -e "${YELLOW}Place the file in: $MODELS_DIR/checkpoints/${NC}"
    else
        echo -e "${GREEN}✓ Realistic Vision already downloaded${NC}"
    fi
fi

# Install ComfyUI Manager (for easy custom node installation)
echo ""
echo -e "${YELLOW}=== Installing ComfyUI Manager ===${NC}"
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes
if [ ! -d "ComfyUI-Manager" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    echo -e "${GREEN}✓ ComfyUI Manager installed${NC}"
else
    echo -e "${GREEN}✓ ComfyUI Manager already installed${NC}"
fi

# Install Video Helper Suite
echo -e "${YELLOW}=== Installing Video Helper Suite ===${NC}"
if [ ! -d "ComfyUI-VideoHelperSuite" ]; then
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
    cd ComfyUI-VideoHelperSuite
    ~/ai-automation/comfyui/ComfyUI/venv/bin/pip install -r requirements.txt
    cd ..
    echo -e "${GREEN}✓ Video Helper Suite installed${NC}"
else
    echo -e "${GREEN}✓ Video Helper Suite already installed${NC}"
fi

# Install AnimateDiff
echo -e "${YELLOW}=== Installing AnimateDiff ===${NC}"
if [ ! -d "ComfyUI-AnimateDiff-Evolved" ]; then
    git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
    cd ComfyUI-AnimateDiff-Evolved
    ~/ai-automation/comfyui/ComfyUI/venv/bin/pip install -r requirements.txt
    
    # Download AnimateDiff motion module
    mkdir -p models
    cd models
    if [ ! -f "mm_sd_v15_v2.ckpt" ]; then
        download_file \
            "https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt" \
            "mm_sd_v15_v2.ckpt" \
            "AnimateDiff Motion Module (1.7 GB)"
    fi
    cd ../..
    echo -e "${GREEN}✓ AnimateDiff installed${NC}"
else
    echo -e "${GREEN}✓ AnimateDiff already installed${NC}"
fi

# Restart ComfyUI to load new nodes
echo ""
echo -e "${YELLOW}Restarting ComfyUI to load new custom nodes...${NC}"
sudo systemctl restart comfyui
sleep 5

echo ""
echo "================================================"
echo -e "${GREEN}Model Download Completed!${NC}"
echo "================================================"
echo ""
echo "Downloaded models:"
echo "  ✓ SDXL Base (text-to-image)"
echo "  ✓ SDXL VAE"
echo "  ✓ Stable Video Diffusion (image-to-video)"
echo "  ✓ AnimateDiff (text-to-video)"
echo ""
echo "Installed custom nodes:"
echo "  ✓ ComfyUI Manager"
echo "  ✓ Video Helper Suite"
echo "  ✓ AnimateDiff Evolved"
echo ""
echo "Models location: $MODELS_DIR"
echo ""
echo "Next steps:"
echo "1. Access ComfyUI at http://localhost:8188"
echo "2. Test image generation with SDXL"
echo "3. Try video generation workflows"
echo "4. Install AudioCraft for music generation (./install_audiocraft.sh)"
echo ""