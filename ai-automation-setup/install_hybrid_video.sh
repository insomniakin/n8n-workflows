#!/bin/bash

# AI Automation System - Hybrid Video Generation Installation
# Installs both self-hosted models and API gateway for premium services

set -e

echo "================================================"
echo "Hybrid AI Video Generation System Installation"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if ComfyUI is installed
if [ ! -d "$HOME/ai-automation/comfyui/ComfyUI" ]; then
    echo -e "${RED}ComfyUI not found. Please run install_comfyui.sh first${NC}"
    exit 1
fi

COMFYUI_DIR="$HOME/ai-automation/comfyui/ComfyUI"
CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"
MODELS_DIR="$COMFYUI_DIR/models"

echo -e "${BLUE}This script will install:${NC}"
echo "  • WAN 2.1 (Best open-source video model)"
echo "  • CogVideoX-5B (High quality text-to-video)"
echo "  • Mochi 1 (Alternative open-source)"
echo "  • API Gateway for Kling, Veo, Sora, Seedance"
echo "  • ComfyUI API integration nodes"
echo ""
echo -e "${YELLOW}Note: Model downloads are large (50+ GB total)${NC}"
echo ""

read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Activate ComfyUI virtual environment
source "$COMFYUI_DIR/venv/bin/activate"

# ============================================
# PART 1: Install Custom Nodes for Video
# ============================================

echo ""
echo -e "${GREEN}=== Part 1: Installing ComfyUI Custom Nodes ===${NC}"
echo ""

cd "$CUSTOM_NODES_DIR"

# WAN 2.1 Wrapper
echo -e "${GREEN}Installing WAN 2.1 Video Wrapper...${NC}"
if [ ! -d "ComfyUI-WanVideoWrapper" ]; then
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
    cd ComfyUI-WanVideoWrapper
    pip install -r requirements.txt 2>/dev/null || pip install einops
    cd ..
    echo -e "${GREEN}✓ WAN 2.1 Wrapper installed${NC}"
else
    echo -e "${YELLOW}WAN 2.1 Wrapper already installed${NC}"
fi

# CogVideoX Wrapper
echo -e "${GREEN}Installing CogVideoX Wrapper...${NC}"
if [ ! -d "ComfyUI-CogVideoXWrapper" ]; then
    git clone https://github.com/kijai/ComfyUI-CogVideoXWrapper.git
    cd ComfyUI-CogVideoXWrapper
    pip install -r requirements.txt 2>/dev/null || true
    cd ..
    echo -e "${GREEN}✓ CogVideoX Wrapper installed${NC}"
else
    echo -e "${YELLOW}CogVideoX Wrapper already installed${NC}"
fi

# Mochi Wrapper
echo -e "${GREEN}Installing Mochi Wrapper...${NC}"
if [ ! -d "ComfyUI-MochiWrapper" ]; then
    git clone https://github.com/kijai/ComfyUI-MochiWrapper.git
    cd ComfyUI-MochiWrapper
    pip install -r requirements.txt 2>/dev/null || true
    cd ..
    echo -e "${GREEN}✓ Mochi Wrapper installed${NC}"
else
    echo -e "${YELLOW}Mochi Wrapper already installed${NC}"
fi

# Kling API Node
echo -e "${GREEN}Installing Kling API Node...${NC}"
if [ ! -d "ComfyUI-KLingAI-API" ]; then
    git clone https://github.com/KlingTeam/ComfyUI-KLingAI-API.git
    cd ComfyUI-KLingAI-API
    pip install -r requirements.txt 2>/dev/null || true
    cd ..
    echo -e "${GREEN}✓ Kling API Node installed${NC}"
else
    echo -e "${YELLOW}Kling API Node already installed${NC}"
fi

# Fal.ai Integration (for Seedance, Nano Banana, etc.)
echo -e "${GREEN}Installing Fal.ai Integration...${NC}"
if [ ! -d "ComfyUI-fal-API" ]; then
    git clone https://github.com/badayvedat/ComfyUI-fal-API.git 2>/dev/null || \
    git clone https://github.com/fal-ai/comfyui-fal-api.git ComfyUI-fal-API 2>/dev/null || true
    if [ -d "ComfyUI-fal-API" ]; then
        cd ComfyUI-fal-API
        pip install -r requirements.txt 2>/dev/null || pip install fal-client
        cd ..
        echo -e "${GREEN}✓ Fal.ai Integration installed${NC}"
    fi
else
    echo -e "${YELLOW}Fal.ai Integration already installed${NC}"
fi

# ============================================
# PART 2: Create Model Directories
# ============================================

echo ""
echo -e "${GREEN}=== Part 2: Creating Model Directories ===${NC}"
echo ""

mkdir -p "$MODELS_DIR/wan"
mkdir -p "$MODELS_DIR/cogvideo"
mkdir -p "$MODELS_DIR/mochi"
mkdir -p "$MODELS_DIR/clip"
mkdir -p "$MODELS_DIR/t5"

echo -e "${GREEN}✓ Model directories created${NC}"

# ============================================
# PART 3: Download Models (Optional)
# ============================================

echo ""
echo -e "${BLUE}=== Part 3: Model Downloads ===${NC}"
echo ""
echo "Available models to download:"
echo "  1. WAN 2.1 T2V (14B) - ~28 GB - Best quality"
echo "  2. WAN 2.1 I2V (14B) - ~28 GB - Image to video"
echo "  3. CogVideoX-5B - ~10 GB - Good quality"
echo "  4. Mochi 1 Preview - ~10 GB - Alternative"
echo "  5. Skip downloads (download later)"
echo ""

read -p "Which models do you want to download? (1-5, or 'all'): " model_choice

download_wan_t2v() {
    echo -e "${GREEN}Downloading WAN 2.1 Text-to-Video model...${NC}"
    cd "$MODELS_DIR/wan"
    
    # Download from Hugging Face
    if command -v huggingface-cli &> /dev/null; then
        huggingface-cli download Wan-AI/Wan2.1-T2V-14B --local-dir . --include "*.safetensors"
    else
        echo -e "${YELLOW}Installing huggingface-cli...${NC}"
        pip install huggingface_hub
        huggingface-cli download Wan-AI/Wan2.1-T2V-14B --local-dir . --include "*.safetensors"
    fi
    echo -e "${GREEN}✓ WAN 2.1 T2V downloaded${NC}"
}

download_wan_i2v() {
    echo -e "${GREEN}Downloading WAN 2.1 Image-to-Video model...${NC}"
    cd "$MODELS_DIR/wan"
    huggingface-cli download Wan-AI/Wan2.1-I2V-14B --local-dir . --include "*.safetensors"
    echo -e "${GREEN}✓ WAN 2.1 I2V downloaded${NC}"
}

download_cogvideo() {
    echo -e "${GREEN}Downloading CogVideoX-5B model...${NC}"
    cd "$MODELS_DIR/cogvideo"
    huggingface-cli download THUDM/CogVideoX-5b --local-dir . --include "*.safetensors"
    echo -e "${GREEN}✓ CogVideoX-5B downloaded${NC}"
}

download_mochi() {
    echo -e "${GREEN}Downloading Mochi 1 Preview model...${NC}"
    cd "$MODELS_DIR/mochi"
    huggingface-cli download genmo/mochi-1-preview --local-dir . --include "*.safetensors"
    echo -e "${GREEN}✓ Mochi 1 downloaded${NC}"
}

case $model_choice in
    1)
        download_wan_t2v
        ;;
    2)
        download_wan_i2v
        ;;
    3)
        download_cogvideo
        ;;
    4)
        download_mochi
        ;;
    5)
        echo -e "${YELLOW}Skipping model downloads. You can download later using:${NC}"
        echo "  huggingface-cli download <model-name> --local-dir <path>"
        ;;
    all|ALL)
        download_wan_t2v
        download_wan_i2v
        download_cogvideo
        download_mochi
        ;;
    *)
        echo -e "${YELLOW}Invalid choice. Skipping downloads.${NC}"
        ;;
esac

# ============================================
# PART 4: Install API Gateway
# ============================================

echo ""
echo -e "${GREEN}=== Part 4: Installing API Gateway ===${NC}"
echo ""

mkdir -p ~/ai-automation/api-gateway
cd ~/ai-automation/api-gateway

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install flask flask-cors requests python-dotenv aiohttp

# Create API Gateway server
cat > api_gateway.py << 'APIEOF'
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import requests
import os
import json
import time
from datetime import datetime
import logging

app = Flask(__name__)
CORS(app)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Output directory
OUTPUT_DIR = "/tmp/video_outputs"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load API keys from environment
API_KEYS = {
    "kling": os.getenv("KLING_API_KEY", ""),
    "veo": os.getenv("VEO_API_KEY", ""),
    "sora": os.getenv("OPENAI_API_KEY", ""),
    "fal": os.getenv("FAL_API_KEY", ""),
    "replicate": os.getenv("REPLICATE_API_TOKEN", ""),
}

# ============== KLING 2.5 TURBO PRO ==============
@app.route('/kling/text-to-video', methods=['POST'])
def kling_text_to_video():
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 5)
        aspect_ratio = data.get('aspect_ratio', '16:9')
        
        if not API_KEYS['kling']:
            return jsonify({"error": "Kling API key not configured"}), 400
        
        headers = {
            "Authorization": f"Bearer {API_KEYS['kling']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "kling-v2.5-turbo-pro",
            "prompt": prompt,
            "duration": duration,
            "aspect_ratio": aspect_ratio
        }
        
        response = requests.post(
            "https://api.klingai.com/v1/videos/text2video",
            headers=headers,
            json=payload,
            timeout=300
        )
        
        return jsonify(response.json()), response.status_code
        
    except Exception as e:
        logger.error(f"Kling error: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/kling/image-to-video', methods=['POST'])
def kling_image_to_video():
    try:
        data = request.json
        image_url = data.get('image_url', '')
        prompt = data.get('prompt', '')
        duration = data.get('duration', 5)
        
        if not API_KEYS['kling']:
            return jsonify({"error": "Kling API key not configured"}), 400
        
        headers = {
            "Authorization": f"Bearer {API_KEYS['kling']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "kling-v2.5-turbo-pro",
            "image_url": image_url,
            "prompt": prompt,
            "duration": duration
        }
        
        response = requests.post(
            "https://api.klingai.com/v1/videos/image2video",
            headers=headers,
            json=payload,
            timeout=300
        )
        
        return jsonify(response.json()), response.status_code
        
    except Exception as e:
        logger.error(f"Kling I2V error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== GOOGLE VEO 3.1 ==============
@app.route('/veo/generate', methods=['POST'])
def veo_generate():
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 8)
        
        if not API_KEYS['veo']:
            return jsonify({"error": "Veo API key not configured"}), 400
        
        payload = {
            "instances": [{"prompt": prompt}],
            "parameters": {
                "aspectRatio": data.get('aspect_ratio', '16:9'),
                "durationSeconds": duration
            }
        }
        
        response = requests.post(
            f"https://generativelanguage.googleapis.com/v1beta/models/veo-3.1:generateVideo?key={API_KEYS['veo']}",
            json=payload,
            timeout=300
        )
        
        return jsonify(response.json()), response.status_code
        
    except Exception as e:
        logger.error(f"Veo error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== OPENAI SORA 2 ==============
@app.route('/sora/generate', methods=['POST'])
def sora_generate():
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 10)
        
        if not API_KEYS['sora']:
            return jsonify({"error": "OpenAI API key not configured"}), 400
        
        headers = {
            "Authorization": f"Bearer {API_KEYS['sora']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "sora-2",
            "prompt": prompt,
            "duration": duration,
            "resolution": data.get('resolution', '1080p')
        }
        
        response = requests.post(
            "https://api.openai.com/v1/videos/generations",
            headers=headers,
            json=payload,
            timeout=600
        )
        
        return jsonify(response.json()), response.status_code
        
    except Exception as e:
        logger.error(f"Sora error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== FAL.AI (Seedance, Nano Banana) ==============
@app.route('/fal/<model>', methods=['POST'])
def fal_generate(model):
    try:
        data = request.json
        
        if not API_KEYS['fal']:
            return jsonify({"error": "Fal.ai API key not configured"}), 400
        
        headers = {
            "Authorization": f"Key {API_KEYS['fal']}",
            "Content-Type": "application/json"
        }
        
        # Map model names to fal.ai endpoints
        model_map = {
            "seedance": "fal-ai/seedance-1.5-pro",
            "seedance-1.5-pro": "fal-ai/seedance-1.5-pro",
            "nano-banana": "fal-ai/nano-banana-pro",
            "nano-banana-pro": "fal-ai/nano-banana-pro"
        }
        
        endpoint = model_map.get(model, f"fal-ai/{model}")
        
        response = requests.post(
            f"https://fal.run/{endpoint}",
            headers=headers,
            json=data,
            timeout=300
        )
        
        return jsonify(response.json()), response.status_code
        
    except Exception as e:
        logger.error(f"Fal.ai error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== UNIFIED ENDPOINT ==============
@app.route('/generate', methods=['POST'])
def unified_generate():
    """Unified video generation with automatic model selection"""
    try:
        data = request.json
        model = data.get('model', 'auto')
        quality = data.get('quality', 'high')
        budget = data.get('budget', 0.20)
        
        # Auto model selection
        if model == 'auto':
            if quality == 'ultra' and budget >= 0.50:
                model = 'sora'
            elif quality == 'high' and budget >= 0.20:
                model = 'kling'
            elif quality == 'high' and budget >= 0.10:
                model = 'veo'
            elif quality == 'medium':
                model = 'seedance'
            else:
                return jsonify({
                    "status": "use_local",
                    "message": "Use local ComfyUI at http://localhost:8188",
                    "recommended_model": "WAN 2.1"
                })
        
        # Route to appropriate endpoint
        if model in ['kling', 'kling-2.5']:
            return kling_text_to_video()
        elif model in ['veo', 'veo-3.1']:
            return veo_generate()
        elif model in ['sora', 'sora-2']:
            return sora_generate()
        elif model in ['seedance', 'seedance-1.5']:
            return fal_generate('seedance-1.5-pro')
        else:
            return jsonify({"error": f"Unknown model: {model}"}), 400
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ============== STATUS ENDPOINTS ==============
@app.route('/health', methods=['GET'])
def health():
    configured = [k for k, v in API_KEYS.items() if v]
    return jsonify({
        "status": "ok",
        "configured_apis": configured,
        "local_services": {
            "comfyui": "http://localhost:8188",
            "audiocraft": "http://localhost:8189"
        }
    })

@app.route('/models', methods=['GET'])
def list_models():
    return jsonify({
        "local": ["wan-2.1", "cogvideox-5b", "mochi-1", "svd", "animatediff"],
        "api": {
            "kling-2.5-turbo-pro": {"configured": bool(API_KEYS['kling'])},
            "veo-3.1": {"configured": bool(API_KEYS['veo'])},
            "sora-2": {"configured": bool(API_KEYS['sora'])},
            "seedance-1.5-pro": {"configured": bool(API_KEYS['fal'])},
            "nano-banana-pro": {"configured": bool(API_KEYS['fal'])}
        }
    })

@app.route('/pricing', methods=['GET'])
def pricing():
    return jsonify({
        "local": {"cost": "Free", "unlimited": True},
        "kling-2.5": {"5s": "$0.10", "10s": "$0.20"},
        "veo-3.1": {"8s": "$0.10", "16s": "$0.20"},
        "sora-2": {"10s": "$0.50", "20s": "$1.00"},
        "seedance-1.5": {"5s": "$0.08", "10s": "$0.15"}
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8190, debug=False)
APIEOF

# Create environment template
cat > .env.template << 'ENVEOF'
# API Keys Configuration
# Get your API keys from the respective providers and add them here

# Kling AI - https://klingai.com/
KLING_API_KEY=

# Google Veo - https://ai.google.dev/
VEO_API_KEY=

# OpenAI Sora - https://platform.openai.com/
OPENAI_API_KEY=

# Fal.ai (Seedance, Nano Banana) - https://fal.ai/
FAL_API_KEY=

# Replicate - https://replicate.com/
REPLICATE_API_TOKEN=
ENVEOF

# Copy template if .env doesn't exist
if [ ! -f .env ]; then
    cp .env.template .env
fi

echo -e "${GREEN}✓ API Gateway installed${NC}"

# Create systemd service
echo -e "${GREEN}Creating API Gateway service...${NC}"
sudo tee /etc/systemd/system/api-gateway.service << EOF
[Unit]
Description=AI Video API Gateway
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/ai-automation/api-gateway
EnvironmentFile=$HOME/ai-automation/api-gateway/.env
ExecStart=$HOME/ai-automation/api-gateway/venv/bin/python api_gateway.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable api-gateway

echo -e "${GREEN}✓ API Gateway service created${NC}"

# ============================================
# PART 5: Create API Keys Configuration File
# ============================================

echo ""
echo -e "${GREEN}=== Part 5: API Keys Configuration ===${NC}"
echo ""

# Create ComfyUI API keys config
cat > "$COMFYUI_DIR/api_keys.json" << 'KEYSEOF'
{
    "kling": {
        "api_key": "",
        "note": "Get from https://klingai.com/"
    },
    "fal": {
        "api_key": "",
        "note": "Get from https://fal.ai/"
    },
    "replicate": {
        "api_token": "",
        "note": "Get from https://replicate.com/"
    },
    "openai": {
        "api_key": "",
        "note": "Get from https://platform.openai.com/"
    },
    "google": {
        "api_key": "",
        "note": "Get from https://ai.google.dev/"
    }
}
KEYSEOF

echo -e "${GREEN}✓ API keys configuration created${NC}"

# ============================================
# PART 6: Restart Services
# ============================================

echo ""
echo -e "${GREEN}=== Part 6: Starting Services ===${NC}"
echo ""

# Restart ComfyUI to load new nodes
sudo systemctl restart comfyui

# Start API Gateway
sudo systemctl start api-gateway

# Wait for services
sleep 5

# Check services
echo ""
echo "Checking services..."

if sudo systemctl is-active --quiet comfyui; then
    echo -e "${GREEN}✓ ComfyUI is running${NC}"
else
    echo -e "${RED}✗ ComfyUI failed to start${NC}"
fi

if sudo systemctl is-active --quiet api-gateway; then
    echo -e "${GREEN}✓ API Gateway is running${NC}"
else
    echo -e "${RED}✗ API Gateway failed to start${NC}"
fi

# ============================================
# COMPLETE
# ============================================

echo ""
echo "================================================"
echo -e "${GREEN}Hybrid Video System Installation Complete!${NC}"
echo "================================================"
echo ""
echo "Services:"
echo "  • ComfyUI: http://localhost:8188"
echo "  • API Gateway: http://localhost:8190"
echo "  • AudioCraft: http://localhost:8189"
echo "  • N8N: http://localhost:5678"
echo ""
echo "Self-Hosted Models (Free, Unlimited):"
echo "  • WAN 2.1 - Best open-source video model"
echo "  • CogVideoX-5B - High quality text-to-video"
echo "  • Mochi 1 - Alternative option"
echo "  • SVD - Image-to-video"
echo "  • AnimateDiff - Text-to-video animation"
echo ""
echo "API Models (Premium Quality):"
echo "  • Kling 2.5 Turbo Pro"
echo "  • Veo 3.1"
echo "  • Sora 2"
echo "  • Seedance 1.5 Pro"
echo "  • Nano Banana Pro"
echo ""
echo -e "${YELLOW}IMPORTANT: Configure your API keys:${NC}"
echo "  1. Edit ~/ai-automation/api-gateway/.env"
echo "  2. Add your API keys from each provider"
echo "  3. Restart: sudo systemctl restart api-gateway"
echo ""
echo "Documentation:"
echo "  • HYBRID_AI_VIDEO_SYSTEM.md - Complete guide"
echo "  • example_workflows.md - N8N workflow examples"
echo ""
echo "Test the API Gateway:"
echo "  curl http://localhost:8190/health"
echo "  curl http://localhost:8190/models"
echo ""