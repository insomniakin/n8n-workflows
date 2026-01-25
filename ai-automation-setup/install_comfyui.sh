#!/bin/bash

# AI Automation System - ComfyUI Installation Script
# For Ubuntu Linux

set -e

echo "================================================"
echo "AI Automation System - ComfyUI Installation"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if CUDA is available
if ! command -v nvidia-smi &> /dev/null; then
    echo -e "${RED}NVIDIA driver not found. Please run install_prerequisites.sh first${NC}"
    exit 1
fi

# Create directory structure
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p ~/ai-automation/comfyui
cd ~/ai-automation/comfyui

# Clone ComfyUI
echo -e "${GREEN}Cloning ComfyUI repository...${NC}"
if [ -d "ComfyUI" ]; then
    echo -e "${YELLOW}ComfyUI directory already exists. Pulling latest changes...${NC}"
    cd ComfyUI
    git pull
    cd ..
else
    git clone https://github.com/comfyanonymous/ComfyUI.git
fi

cd ComfyUI

# Create virtual environment
echo -e "${GREEN}Creating Python virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate

# Install PyTorch with CUDA support
echo -e "${GREEN}Installing PyTorch with CUDA support...${NC}"
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install ComfyUI requirements
echo -e "${GREEN}Installing ComfyUI requirements...${NC}"
pip install -r requirements.txt

# Install additional dependencies
pip install aiohttp

# Test CUDA availability
echo -e "${GREEN}Testing CUDA availability...${NC}"
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else &quot;None&quot;}')"

# Create models directory structure
echo -e "${GREEN}Creating models directory structure...${NC}"
mkdir -p models/{checkpoints,vae,loras,controlnet,upscale_models,embeddings,clip,clip_vision,style_models,unet}

# Create startup script
echo -e "${GREEN}Creating startup script...${NC}"
cat > start_comfyui.sh << 'EOF'
#!/bin/bash
cd ~/ai-automation/comfyui/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8188
EOF

chmod +x start_comfyui.sh

# Create systemd service
echo -e "${GREEN}Creating systemd service...${NC}"
sudo tee /etc/systemd/system/comfyui.service << EOF
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/ai-automation/comfyui/ComfyUI
ExecStart=$HOME/ai-automation/comfyui/ComfyUI/venv/bin/python main.py --listen 0.0.0.0 --port 8188
Restart=on-failure
RestartSec=10
Environment="PATH=$HOME/ai-automation/comfyui/ComfyUI/venv/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="LD_LIBRARY_PATH=/usr/local/cuda/lib64"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
echo -e "${GREEN}Starting ComfyUI service...${NC}"
sudo systemctl enable comfyui
sudo systemctl start comfyui

# Wait for service to start
echo -e "${YELLOW}Waiting for ComfyUI to start...${NC}"
sleep 10

# Check service status
if sudo systemctl is-active --quiet comfyui; then
    echo -e "${GREEN}ComfyUI is running!${NC}"
    echo ""
    echo "================================================"
    echo -e "${GREEN}ComfyUI Installation Completed!${NC}"
    echo "================================================"
    echo ""
    echo "Access ComfyUI at: http://localhost:8188"
    echo ""
    echo "Service commands:"
    echo "  Check status: sudo systemctl status comfyui"
    echo "  View logs: sudo journalctl -u comfyui -f"
    echo "  Restart: sudo systemctl restart comfyui"
    echo "  Stop: sudo systemctl stop comfyui"
    echo ""
    echo "Next steps:"
    echo "1. Download AI models (run ./download_models.sh)"
    echo "2. Install custom nodes for video generation"
    echo "3. Test image generation in the web interface"
    echo ""
else
    echo -e "${RED}ComfyUI failed to start. Check logs with: sudo journalctl -u comfyui -n 50${NC}"
    exit 1
fi