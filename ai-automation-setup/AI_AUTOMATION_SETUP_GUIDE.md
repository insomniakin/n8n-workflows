# Complete AI Automation System Setup Guide for Ubuntu

## Overview
This guide will help you set up a complete AI automation system on Ubuntu Linux using N8N for workflow automation, ComfyUI for AI generation, and various AI models for creating images, videos, and audio content - all running locally on your hardware.

## Your Hardware Specifications
- **CPU**: Intel i9 processor
- **Primary GPU**: RTX 3090 (24GB VRAM)
- **Secondary GPU**: RTX 490 (to be configured)
- **OS**: Ubuntu Linux

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     N8N Workflow Engine                      │
│              (Orchestration & Automation Layer)              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        ComfyUI API                           │
│              (AI Model Execution Interface)                  │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Stable     │    │   Stable     │    │  AudioCraft  │
│  Diffusion   │    │    Video     │    │  MusicGen    │
│  (Images)    │    │  Diffusion   │    │   (Audio)    │
└──────────────┘    └──────────────┘    └──────────────┘
```

## Part 1: System Prerequisites

### 1.1 Update Your System
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.2 Install Essential Tools
```bash
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    python3-pip \
    python3-venv
```

### 1.3 Install NVIDIA Drivers (Critical for GPU Support)

Check current driver:
```bash
nvidia-smi
```

If not installed or outdated:
```bash
# Add NVIDIA PPA
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update

# Install recommended driver (usually 535 or newer)
sudo ubuntu-drivers autoinstall

# Or install specific version
sudo apt install nvidia-driver-535

# Reboot
sudo reboot
```

After reboot, verify:
```bash
nvidia-smi
```

You should see your RTX 3090 listed.

### 1.4 Install CUDA Toolkit
```bash
# Download CUDA 12.x (check latest version)
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update
sudo apt install cuda-toolkit-12-3

# Add to PATH
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Verify
nvcc --version
```

## Part 2: Docker Installation

### 2.1 Install Docker
```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker compose version
```

### 2.2 Install NVIDIA Container Toolkit (Essential for GPU in Docker)
```bash
# Add NVIDIA Container Toolkit repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install
sudo apt update
sudo apt install -y nvidia-container-toolkit

# Configure Docker to use NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Test GPU access in Docker
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

## Part 3: N8N Installation

### 3.1 Create N8N Directory Structure
```bash
mkdir -p ~/ai-automation/n8n
cd ~/ai-automation/n8n
```

### 3.2 Create Docker Compose File for N8N
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=changeme123
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://localhost:5678/
      - GENERIC_TIMEZONE=America/New_York
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
    networks:
      - ai-automation

networks:
  ai-automation:
    driver: bridge
EOF
```

### 3.3 Start N8N
```bash
docker compose up -d

# Check logs
docker compose logs -f n8n
```

### 3.4 Access N8N
Open your browser and go to: `http://localhost:5678`
- Username: `admin`
- Password: `changeme123` (change this!)

## Part 4: ComfyUI Installation (AI Model Interface)

### 4.1 Create ComfyUI Directory
```bash
mkdir -p ~/ai-automation/comfyui
cd ~/ai-automation/comfyui
```

### 4.2 Clone ComfyUI
```bash
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
```

### 4.3 Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### 4.4 Install PyTorch with CUDA Support
```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

### 4.5 Install ComfyUI Requirements
```bash
pip install -r requirements.txt
```

### 4.6 Install Additional Dependencies
```bash
pip install aiohttp
```

### 4.7 Create ComfyUI Startup Script
```bash
cat > start_comfyui.sh << 'EOF'
#!/bin/bash
cd ~/ai-automation/comfyui/ComfyUI
source venv/bin/activate
python main.py --listen 0.0.0.0 --port 8188
EOF

chmod +x start_comfyui.sh
```

### 4.8 Create Systemd Service for ComfyUI (Optional but Recommended)
```bash
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

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable comfyui
sudo systemctl start comfyui

# Check status
sudo systemctl status comfyui
```

## Part 5: AI Models Installation

### 5.1 Create Models Directory Structure
```bash
mkdir -p ~/ai-automation/comfyui/ComfyUI/models/{checkpoints,vae,loras,controlnet,upscale_models,embeddings}
```

### 5.2 Download Stable Diffusion Models

#### SDXL (Recommended for high-quality images)
```bash
cd ~/ai-automation/comfyui/ComfyUI/models/checkpoints

# Download SDXL Base
wget https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors

# Download SDXL Refiner (optional, for enhanced quality)
wget https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
```

#### Realistic Vision (Alternative for photorealistic images)
```bash
# Download from Civitai or Hugging Face
wget https://civitai.com/api/download/models/130072 -O realistic_vision_v5.safetensors
```

### 5.3 Download VAE Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models/vae

# SDXL VAE
wget https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors
```

### 5.4 Install Stable Video Diffusion

```bash
cd ~/ai-automation/comfyui/ComfyUI/models/checkpoints

# Download SVD model
wget https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt/resolve/main/svd_xt.safetensors
```

### 5.5 Install ComfyUI Custom Nodes for Video

```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes

# ComfyUI-VideoHelperSuite
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
cd ComfyUI-VideoHelperSuite
pip install -r requirements.txt
cd ..

# ComfyUI-AnimateDiff-Evolved
git clone https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git
cd ComfyUI-AnimateDiff-Evolved
pip install -r requirements.txt
cd ..

# Restart ComfyUI
sudo systemctl restart comfyui
```

### 5.6 Download AnimateDiff Models
```bash
mkdir -p ~/ai-automation/comfyui/ComfyUI/custom_nodes/ComfyUI-AnimateDiff-Evolved/models

cd ~/ai-automation/comfyui/ComfyUI/custom_nodes/ComfyUI-AnimateDiff-Evolved/models

# Download AnimateDiff motion module
wget https://huggingface.co/guoyww/animatediff/resolve/main/mm_sd_v15_v2.ckpt
```

## Part 6: Audio Generation Setup

### 6.1 Install AudioCraft
```bash
cd ~/ai-automation
git clone https://github.com/facebookresearch/audiocraft.git
cd audiocraft

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install
pip install -e .
```

### 6.2 Create AudioCraft API Server
```bash
cat > audiocraft_server.py << 'EOF'
from flask import Flask, request, jsonify, send_file
from audiocraft.models import MusicGen
import torch
import torchaudio
import os
from datetime import datetime

app = Flask(__name__)

# Load model
model = MusicGen.get_pretrained('facebook/musicgen-medium')
model.set_generation_params(duration=30)

@app.route('/generate', methods=['POST'])
def generate_music():
    data = request.json
    prompt = data.get('prompt', 'upbeat electronic music')
    duration = data.get('duration', 30)
    
    model.set_generation_params(duration=duration)
    
    # Generate
    wav = model.generate([prompt])
    
    # Save
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = f"/tmp/music_{timestamp}.wav"
    torchaudio.save(output_path, wav[0].cpu(), model.sample_rate)
    
    return send_file(output_path, mimetype='audio/wav')

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8189)
EOF
```

### 6.3 Install Flask
```bash
pip install flask
```

### 6.4 Create AudioCraft Service
```bash
sudo tee /etc/systemd/system/audiocraft.service << EOF
[Unit]
Description=AudioCraft API Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/ai-automation/audiocraft
ExecStart=$HOME/ai-automation/audiocraft/venv/bin/python audiocraft_server.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable audiocraft
sudo systemctl start audiocraft
```

## Part 7: N8N Workflow Integration

### 7.1 Install N8N Community Nodes

In N8N web interface:
1. Go to Settings → Community Nodes
2. Install: `n8n-nodes-comfyui` (if available)

### 7.2 Create HTTP Request Nodes in N8N

For ComfyUI integration, you'll use HTTP Request nodes:

**Example: Text-to-Image Workflow**
```json
{
  "method": "POST",
  "url": "http://localhost:8188/prompt",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "prompt": {
      "3": {
        "inputs": {
          "seed": 42,
          "steps": 20,
          "cfg": 8,
          "sampler_name": "euler",
          "scheduler": "normal",
          "denoise": 1,
          "model": ["4", 0],
          "positive": ["6", 0],
          "negative": ["7", 0],
          "latent_image": ["5", 0]
        },
        "class_type": "KSampler"
      },
      "4": {
        "inputs": {
          "ckpt_name": "sd_xl_base_1.0.safetensors"
        },
        "class_type": "CheckpointLoaderSimple"
      },
      "5": {
        "inputs": {
          "width": 1024,
          "height": 1024,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage"
      },
      "6": {
        "inputs": {
          "text": "beautiful landscape, mountains, sunset",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode"
      },
      "7": {
        "inputs": {
          "text": "ugly, blurry, low quality",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode"
      },
      "8": {
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        },
        "class_type": "VAEDecode"
      },
      "9": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage"
      }
    }
  }
}
```

## Part 8: GPU Configuration & Optimization

### 8.1 Monitor GPU Usage
```bash
# Install monitoring tools
sudo apt install nvtop

# Run monitoring
nvtop
```

### 8.2 Configure Multi-GPU Setup (RTX 3090 + RTX 490)

**Note**: The RTX 490 doesn't exist yet. If you meant RTX 4090, here's how to configure it:

```bash
# Check both GPUs
nvidia-smi

# Set CUDA_VISIBLE_DEVICES for specific GPU
# In ComfyUI startup script:
export CUDA_VISIBLE_DEVICES=0  # Use first GPU (RTX 3090)
# or
export CUDA_VISIBLE_DEVICES=1  # Use second GPU
# or
export CUDA_VISIBLE_DEVICES=0,1  # Use both GPUs
```

### 8.3 Optimize GPU Memory
```bash
# Add to ComfyUI startup script
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
```

## Part 9: Complete Workflow Examples

### 9.1 Image Generation Workflow (N8N)

1. **Trigger**: Webhook or Schedule
2. **HTTP Request**: Call ComfyUI API with prompt
3. **Wait**: Poll for completion
4. **Download**: Get generated image
5. **Store**: Save to local storage or cloud

### 9.2 Image-to-Video Workflow

1. **Input**: Upload or generate image
2. **HTTP Request**: Call ComfyUI with SVD model
3. **Process**: Generate video frames
4. **Compile**: Create video file
5. **Output**: Save or share video

### 9.3 Text-to-Music Workflow

1. **Input**: Music description
2. **HTTP Request**: Call AudioCraft API
3. **Generate**: Create audio
4. **Post-process**: Apply effects (optional)
5. **Output**: Save audio file

## Part 10: Testing & Verification

### 10.1 Test ComfyUI
```bash
# Access ComfyUI web interface
http://localhost:8188

# Try generating an image through the UI
```

### 10.2 Test N8N
```bash
# Access N8N
http://localhost:5678

# Create a simple workflow and execute it
```

### 10.3 Test AudioCraft
```bash
curl -X POST http://localhost:8189/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "upbeat electronic music", "duration": 10}' \
  --output test_music.wav
```

## Part 11: Maintenance & Troubleshooting

### 11.1 Update Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models/checkpoints
# Download new models as needed
```

### 11.2 Check Logs
```bash
# ComfyUI logs
sudo journalctl -u comfyui -f

# N8N logs
docker compose logs -f n8n

# AudioCraft logs
sudo journalctl -u audiocraft -f
```

### 11.3 Restart Services
```bash
# Restart ComfyUI
sudo systemctl restart comfyui

# Restart N8N
cd ~/ai-automation/n8n
docker compose restart

# Restart AudioCraft
sudo systemctl restart audiocraft
```

### 11.4 Common Issues

**Issue**: Out of GPU memory
**Solution**: 
- Reduce batch size
- Use lower resolution
- Enable model offloading
- Close other GPU applications

**Issue**: ComfyUI not starting
**Solution**:
```bash
# Check logs
sudo journalctl -u comfyui -n 50

# Verify Python environment
source ~/ai-automation/comfyui/ComfyUI/venv/bin/activate
python -c "import torch; print(torch.cuda.is_available())"
```

**Issue**: N8N can't connect to ComfyUI
**Solution**:
- Check if ComfyUI is running: `sudo systemctl status comfyui`
- Verify port: `netstat -tulpn | grep 8188`
- Check firewall: `sudo ufw status`

## Part 12: Advanced Configuration

### 12.1 Enable HTTPS for N8N
```bash
# Install nginx
sudo apt install nginx certbot python3-certbot-nginx

# Configure reverse proxy
sudo nano /etc/nginx/sites-available/n8n

# Add SSL certificate
sudo certbot --nginx -d your-domain.com
```

### 12.2 Optimize for Production
```bash
# Increase file descriptors
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf

# Optimize network
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
```

### 12.3 Backup Configuration
```bash
# Create backup script
cat > ~/backup_ai_automation.sh << 'EOF'
#!/bin/bash
BACKUP_DIR=~/ai_automation_backups
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup N8N data
tar -czf $BACKUP_DIR/n8n_$DATE.tar.gz ~/ai-automation/n8n/n8n_data

# Backup workflows
tar -czf $BACKUP_DIR/workflows_$DATE.tar.gz ~/ai-automation/n8n/workflows

# Backup ComfyUI custom nodes
tar -czf $BACKUP_DIR/comfyui_custom_nodes_$DATE.tar.gz ~/ai-automation/comfyui/ComfyUI/custom_nodes

echo "Backup completed: $DATE"
EOF

chmod +x ~/backup_ai_automation.sh
```

## Part 13: Performance Optimization

### 13.1 Model Optimization
```bash
# Use FP16 for faster inference (in ComfyUI)
# Edit startup script to add:
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
export CUDA_LAUNCH_BLOCKING=0
```

### 13.2 Disk I/O Optimization
```bash
# Use SSD for model storage
# Mount SSD to models directory
sudo mkdir -p /mnt/models
sudo mount /dev/sdX /mnt/models
ln -s /mnt/models ~/ai-automation/comfyui/ComfyUI/models
```

## Summary

You now have a complete AI automation system with:
- ✅ N8N for workflow orchestration
- ✅ ComfyUI for image and video generation
- ✅ Stable Diffusion for images
- ✅ Stable Video Diffusion for videos
- ✅ AudioCraft for music/audio generation
- ✅ GPU acceleration configured
- ✅ All services running locally

## Next Steps

1. Explore ComfyUI workflows at: https://comfyworkflows.com/
2. Join N8N community: https://community.n8n.io/
3. Download more models from: https://civitai.com/
4. Experiment with different prompts and settings

## Resources

- ComfyUI: https://github.com/comfyanonymous/ComfyUI
- N8N: https://n8n.io/
- Stable Diffusion: https://stability.ai/
- AudioCraft: https://github.com/facebookresearch/audiocraft
- Hugging Face Models: https://huggingface.co/models

---

**Important Notes:**
- This setup requires significant disk space (100GB+ for models)
- RTX 3090 has 24GB VRAM - sufficient for most tasks
- Always monitor GPU temperature and usage
- Keep your system and models updated
- Join communities for support and latest developments