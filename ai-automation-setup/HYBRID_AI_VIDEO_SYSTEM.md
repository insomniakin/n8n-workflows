# Hybrid AI Video Generation System

## 🎯 Overview

This document extends your AI automation system to include **cutting-edge video generation models** through a hybrid approach:

1. **Self-Hosted (Free, Unlimited)**: Open-source models running locally on your RTX 3090
2. **API-Based (Premium Quality)**: Cloud APIs for state-of-the-art models when needed

## 📊 Model Comparison Matrix

| Model | Type | Quality | Speed | Cost | Self-Hosted |
|-------|------|---------|-------|------|-------------|
| **WAN 2.1** | Open Source | ⭐⭐⭐⭐ | Medium | Free | ✅ Yes |
| **CogVideoX-5B** | Open Source | ⭐⭐⭐⭐ | Medium | Free | ✅ Yes |
| **Mochi 1** | Open Source | ⭐⭐⭐⭐ | Medium | Free | ✅ Yes |
| **Stable Video Diffusion** | Open Source | ⭐⭐⭐ | Fast | Free | ✅ Yes |
| **AnimateDiff** | Open Source | ⭐⭐⭐ | Fast | Free | ✅ Yes |
| **Kling 2.5 Turbo Pro** | API | ⭐⭐⭐⭐⭐ | Fast | $$ | ❌ API Only |
| **Veo 3.1** | API | ⭐⭐⭐⭐⭐ | Fast | $$ | ❌ API Only |
| **Sora 2** | API | ⭐⭐⭐⭐⭐ | Medium | $$$ | ❌ API Only |
| **Seedance 1.5 Pro** | API | ⭐⭐⭐⭐⭐ | Fast | $$ | ❌ API Only |
| **Nano Banana Pro** | API | ⭐⭐⭐⭐ | Fast | $ | ❌ API Only |

## 🏗️ Hybrid Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     N8N WORKFLOW ENGINE                          │
│              (Intelligent Model Router & Orchestrator)           │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  LOCAL MODELS │    │  API GATEWAY  │    │   FALLBACK    │
│  (Self-Hosted)│    │   (Premium)   │    │   HANDLER     │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ • WAN 2.1     │    │ • Kling 2.5   │    │ • Retry Logic │
│ • CogVideoX   │    │ • Veo 3.1     │    │ • Queue Mgmt  │
│ • Mochi 1     │    │ • Sora 2      │    │ • Cost Ctrl   │
│ • SVD         │    │ • Seedance    │    │               │
│ • AnimateDiff │    │ • Nano Banana │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      OUTPUT PROCESSING                           │
│         (Format Conversion, Upscaling, Audio Sync)              │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Part 1: Self-Hosted Models Setup

### 1.1 WAN 2.1 (Best Open-Source Video Model)

WAN 2.1 is currently the **best open-source video generation model** available.

#### Installation
```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes

# Clone WAN 2.1 ComfyUI nodes
git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
cd ComfyUI-WanVideoWrapper
pip install -r requirements.txt
```

#### Download WAN 2.1 Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models

# Create WAN directory
mkdir -p wan

# Download WAN 2.1 models (choose based on VRAM)
# For RTX 3090 (24GB), you can use the full model
cd wan

# Text-to-Video model
wget https://huggingface.co/Wan-AI/Wan2.1-T2V-14B/resolve/main/wan2.1_t2v_14b.safetensors

# Image-to-Video model  
wget https://huggingface.co/Wan-AI/Wan2.1-I2V-14B/resolve/main/wan2.1_i2v_14b.safetensors
```

### 1.2 CogVideoX-5B

#### Installation
```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes

# Clone CogVideo nodes
git clone https://github.com/kijai/ComfyUI-CogVideoXWrapper.git
cd ComfyUI-CogVideoXWrapper
pip install -r requirements.txt
```

#### Download CogVideoX Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models
mkdir -p cogvideo
cd cogvideo

# Download CogVideoX-5B
wget https://huggingface.co/THUDM/CogVideoX-5b/resolve/main/cogvideox_5b.safetensors
```

### 1.3 Mochi 1

#### Installation
```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes

# Clone Mochi nodes
git clone https://github.com/kijai/ComfyUI-MochiWrapper.git
cd ComfyUI-MochiWrapper
pip install -r requirements.txt
```

#### Download Mochi Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models
mkdir -p mochi
cd mochi

# Download Mochi 1 model
wget https://huggingface.co/genmo/mochi-1-preview/resolve/main/mochi_preview.safetensors
```

## 🌐 Part 2: API-Based Models Setup

### 2.1 API Gateway Service

Create a unified API gateway that handles all external video generation APIs:

```bash
mkdir -p ~/ai-automation/api-gateway
cd ~/ai-automation/api-gateway
```

#### Create API Gateway Server
```python
# api_gateway.py
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

# API Configuration (set these as environment variables)
API_KEYS = {
    "kling": os.getenv("KLING_API_KEY", ""),
    "veo": os.getenv("VEO_API_KEY", ""),  # Google API Key
    "sora": os.getenv("OPENAI_API_KEY", ""),
    "seedance": os.getenv("SEEDANCE_API_KEY", ""),
    "fal": os.getenv("FAL_API_KEY", ""),  # For multiple models
    "replicate": os.getenv("REPLICATE_API_TOKEN", ""),
}

# API Endpoints
API_ENDPOINTS = {
    "kling": {
        "base_url": "https://api.klingai.com/v1",
        "text_to_video": "/videos/text2video",
        "image_to_video": "/videos/image2video",
    },
    "veo": {
        "base_url": "https://generativelanguage.googleapis.com/v1beta",
        "generate": "/models/veo-3.1:generateVideo",
    },
    "sora": {
        "base_url": "https://api.openai.com/v1",
        "generate": "/videos/generations",
    },
    "seedance": {
        "base_url": "https://api.fal.ai/fal-ai",
        "generate": "/seedance-1.5-pro",
    },
    "fal": {
        "base_url": "https://api.fal.ai",
    },
    "replicate": {
        "base_url": "https://api.replicate.com/v1",
    }
}

# ============== KLING 2.5 TURBO PRO ==============
@app.route('/kling/text-to-video', methods=['POST'])
def kling_text_to_video():
    """Generate video from text using Kling 2.5 Turbo Pro"""
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 5)
        aspect_ratio = data.get('aspect_ratio', '16:9')
        
        headers = {
            "Authorization": f"Bearer {API_KEYS['kling']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "kling-v2.5-turbo-pro",
            "prompt": prompt,
            "duration": duration,
            "aspect_ratio": aspect_ratio,
            "mode": "pro"
        }
        
        response = requests.post(
            f"{API_ENDPOINTS['kling']['base_url']}{API_ENDPOINTS['kling']['text_to_video']}",
            headers=headers,
            json=payload
        )
        
        if response.status_code == 200:
            result = response.json()
            return jsonify(result)
        else:
            return jsonify({"error": response.text}), response.status_code
            
    except Exception as e:
        logger.error(f"Kling error: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/kling/image-to-video', methods=['POST'])
def kling_image_to_video():
    """Generate video from image using Kling 2.5 Turbo Pro"""
    try:
        data = request.json
        image_url = data.get('image_url', '')
        prompt = data.get('prompt', '')
        duration = data.get('duration', 5)
        
        headers = {
            "Authorization": f"Bearer {API_KEYS['kling']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "kling-v2.5-turbo-pro",
            "image_url": image_url,
            "prompt": prompt,
            "duration": duration,
            "mode": "pro"
        }
        
        response = requests.post(
            f"{API_ENDPOINTS['kling']['base_url']}{API_ENDPOINTS['kling']['image_to_video']}",
            headers=headers,
            json=payload
        )
        
        return jsonify(response.json())
        
    except Exception as e:
        logger.error(f"Kling I2V error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== GOOGLE VEO 3.1 ==============
@app.route('/veo/generate', methods=['POST'])
def veo_generate():
    """Generate video using Google Veo 3.1"""
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 8)
        aspect_ratio = data.get('aspect_ratio', '16:9')
        
        headers = {
            "Content-Type": "application/json"
        }
        
        payload = {
            "instances": [{
                "prompt": prompt
            }],
            "parameters": {
                "aspectRatio": aspect_ratio,
                "durationSeconds": duration,
                "personGeneration": "allow_adult"
            }
        }
        
        url = f"{API_ENDPOINTS['veo']['base_url']}{API_ENDPOINTS['veo']['generate']}?key={API_KEYS['veo']}"
        
        response = requests.post(url, headers=headers, json=payload)
        
        return jsonify(response.json())
        
    except Exception as e:
        logger.error(f"Veo error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== OPENAI SORA 2 ==============
@app.route('/sora/generate', methods=['POST'])
def sora_generate():
    """Generate video using OpenAI Sora 2"""
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 10)
        resolution = data.get('resolution', '1080p')
        
        headers = {
            "Authorization": f"Bearer {API_KEYS['sora']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "sora-2",
            "prompt": prompt,
            "duration": duration,
            "resolution": resolution
        }
        
        response = requests.post(
            f"{API_ENDPOINTS['sora']['base_url']}{API_ENDPOINTS['sora']['generate']}",
            headers=headers,
            json=payload
        )
        
        return jsonify(response.json())
        
    except Exception as e:
        logger.error(f"Sora error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== BYTEDANCE SEEDANCE 1.5 PRO ==============
@app.route('/seedance/generate', methods=['POST'])
def seedance_generate():
    """Generate video using Seedance 1.5 Pro"""
    try:
        data = request.json
        prompt = data.get('prompt', '')
        duration = data.get('duration', 5)
        
        headers = {
            "Authorization": f"Key {API_KEYS['fal']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "prompt": prompt,
            "duration": duration,
            "seed": data.get('seed', None)
        }
        
        response = requests.post(
            f"{API_ENDPOINTS['fal']['base_url']}/fal-ai/seedance-1.5-pro",
            headers=headers,
            json=payload
        )
        
        return jsonify(response.json())
        
    except Exception as e:
        logger.error(f"Seedance error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== NANO BANANA PRO ==============
@app.route('/nano-banana/generate', methods=['POST'])
def nano_banana_generate():
    """Generate/edit image using Nano Banana Pro"""
    try:
        data = request.json
        prompt = data.get('prompt', '')
        image_url = data.get('image_url', None)
        
        headers = {
            "Authorization": f"Key {API_KEYS['fal']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "prompt": prompt,
        }
        
        if image_url:
            payload["image_url"] = image_url
        
        response = requests.post(
            f"{API_ENDPOINTS['fal']['base_url']}/fal-ai/nano-banana-pro",
            headers=headers,
            json=payload
        )
        
        return jsonify(response.json())
        
    except Exception as e:
        logger.error(f"Nano Banana error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== UNIFIED GENERATION ENDPOINT ==============
@app.route('/generate', methods=['POST'])
def unified_generate():
    """
    Unified video generation endpoint with automatic model selection
    
    Parameters:
    - prompt: Text description
    - model: Model to use (auto, kling, veo, sora, seedance, local)
    - quality: low, medium, high, ultra
    - duration: Video duration in seconds
    - budget: max cost in USD (for auto selection)
    """
    try:
        data = request.json
        prompt = data.get('prompt', '')
        model = data.get('model', 'auto')
        quality = data.get('quality', 'high')
        duration = data.get('duration', 5)
        budget = data.get('budget', 1.0)
        
        # Auto model selection based on quality and budget
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
                model = 'local'  # Fall back to local models
        
        # Route to appropriate endpoint
        if model == 'kling':
            return kling_text_to_video()
        elif model == 'veo':
            return veo_generate()
        elif model == 'sora':
            return sora_generate()
        elif model == 'seedance':
            return seedance_generate()
        elif model == 'local':
            # Route to local ComfyUI
            return jsonify({
                "status": "redirect",
                "endpoint": "http://localhost:8188",
                "message": "Use local ComfyUI for this request"
            })
        else:
            return jsonify({"error": f"Unknown model: {model}"}), 400
            
    except Exception as e:
        logger.error(f"Unified generate error: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============== STATUS & HEALTH ==============
@app.route('/health', methods=['GET'])
def health():
    """Check API gateway health and configured services"""
    configured_services = []
    for service, key in API_KEYS.items():
        if key:
            configured_services.append(service)
    
    return jsonify({
        "status": "ok",
        "configured_services": configured_services,
        "local_comfyui": "http://localhost:8188",
        "local_audiocraft": "http://localhost:8189"
    })

@app.route('/models', methods=['GET'])
def list_models():
    """List all available models"""
    return jsonify({
        "local_models": {
            "wan_2.1": {"type": "text-to-video, image-to-video", "vram": "24GB", "quality": "high"},
            "cogvideox_5b": {"type": "text-to-video", "vram": "16GB", "quality": "high"},
            "mochi_1": {"type": "text-to-video", "vram": "16GB", "quality": "high"},
            "svd": {"type": "image-to-video", "vram": "8GB", "quality": "medium"},
            "animatediff": {"type": "text-to-video", "vram": "8GB", "quality": "medium"}
        },
        "api_models": {
            "kling_2.5_turbo_pro": {"type": "text-to-video, image-to-video", "cost": "$0.10-0.30/video"},
            "veo_3.1": {"type": "text-to-video", "cost": "$0.05-0.20/video"},
            "sora_2": {"type": "text-to-video", "cost": "$0.20-1.00/video"},
            "seedance_1.5_pro": {"type": "text-to-video", "cost": "$0.05-0.15/video"},
            "nano_banana_pro": {"type": "image-generation", "cost": "$0.01-0.05/image"}
        }
    })

@app.route('/pricing', methods=['GET'])
def pricing():
    """Get current pricing estimates"""
    return jsonify({
        "local": {
            "cost_per_video": "$0.00",
            "electricity_estimate": "$0.01-0.05/video",
            "unlimited": True
        },
        "api": {
            "kling_2.5_turbo_pro": {
                "text_to_video_5s": "$0.10",
                "text_to_video_10s": "$0.20",
                "image_to_video_5s": "$0.15"
            },
            "veo_3.1": {
                "text_to_video_8s": "$0.10",
                "text_to_video_16s": "$0.20"
            },
            "sora_2": {
                "text_to_video_10s": "$0.50",
                "text_to_video_20s": "$1.00"
            },
            "seedance_1.5_pro": {
                "text_to_video_5s": "$0.08",
                "text_to_video_10s": "$0.15"
            }
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8190, debug=False)
```

### 2.2 Create Installation Script for API Gateway

```bash
cat > ~/ai-automation/api-gateway/install.sh << 'EOF'
#!/bin/bash

echo "Installing API Gateway..."

cd ~/ai-automation/api-gateway

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install flask flask-cors requests python-dotenv

# Create environment file template
cat > .env.template << 'ENVEOF'
# API Keys Configuration
# Get your API keys from the respective providers

# Kling AI - https://klingai.com/
KLING_API_KEY=your_kling_api_key_here

# Google Veo - https://ai.google.dev/
VEO_API_KEY=your_google_api_key_here

# OpenAI Sora - https://platform.openai.com/
OPENAI_API_KEY=your_openai_api_key_here

# Fal.ai (for Seedance, Nano Banana) - https://fal.ai/
FAL_API_KEY=your_fal_api_key_here

# Replicate - https://replicate.com/
REPLICATE_API_TOKEN=your_replicate_token_here
ENVEOF

# Copy template to actual env file
cp .env.template .env

echo "API Gateway installed!"
echo "Please edit ~/ai-automation/api-gateway/.env with your API keys"
EOF

chmod +x ~/ai-automation/api-gateway/install.sh
```

### 2.3 Create Systemd Service for API Gateway

```bash
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
```

## 🔗 Part 3: ComfyUI Native API Nodes

ComfyUI now has **native partner nodes** for many of these APIs. Install them:

### 3.1 Install ComfyUI API Nodes

```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes

# Official Kling API Node
git clone https://github.com/KlingTeam/ComfyUI-KLingAI-API.git

# Fal.ai Integration (Seedance, Nano Banana, etc.)
git clone https://github.com/badayvedat/ComfyUI-fal-API.git

# Replicate Integration
git clone https://github.com/replicate/comfyui-replicate.git

# Install dependencies
cd ComfyUI-KLingAI-API && pip install -r requirements.txt && cd ..
cd ComfyUI-fal-API && pip install -r requirements.txt && cd ..

# Restart ComfyUI
sudo systemctl restart comfyui
```

### 3.2 Configure API Keys in ComfyUI

Create a configuration file:
```bash
cat > ~/ai-automation/comfyui/ComfyUI/api_keys.json << 'EOF'
{
    "kling": {
        "api_key": "YOUR_KLING_API_KEY"
    },
    "fal": {
        "api_key": "YOUR_FAL_API_KEY"
    },
    "replicate": {
        "api_token": "YOUR_REPLICATE_TOKEN"
    },
    "openai": {
        "api_key": "YOUR_OPENAI_API_KEY"
    },
    "google": {
        "api_key": "YOUR_GOOGLE_API_KEY"
    }
}
EOF
```

## 📋 Part 4: N8N Workflow Integration

### 4.1 Unified Video Generation Workflow

Create this workflow in N8N to intelligently route video generation requests:

```json
{
  "name": "Hybrid Video Generation",
  "nodes": [
    {
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "generate-video",
        "method": "POST"
      }
    },
    {
      "name": "Model Router",
      "type": "n8n-nodes-base.switch",
      "parameters": {
        "rules": [
          {
            "value": "={{$json.quality}}",
            "operation": "equals",
            "value2": "ultra"
          },
          {
            "value": "={{$json.quality}}",
            "operation": "equals",
            "value2": "high"
          },
          {
            "value": "={{$json.quality}}",
            "operation": "equals",
            "value2": "local"
          }
        ]
      }
    },
    {
      "name": "Sora 2 (Ultra)",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://localhost:8190/sora/generate",
        "method": "POST",
        "body": {
          "prompt": "={{$json.prompt}}",
          "duration": "={{$json.duration}}"
        }
      }
    },
    {
      "name": "Kling 2.5 (High)",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://localhost:8190/kling/text-to-video",
        "method": "POST",
        "body": {
          "prompt": "={{$json.prompt}}",
          "duration": "={{$json.duration}}"
        }
      }
    },
    {
      "name": "Local ComfyUI",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://localhost:8188/prompt",
        "method": "POST",
        "body": "={{JSON.stringify($json.comfyui_workflow)}}"
      }
    }
  ]
}
```

### 4.2 Cost-Optimized Batch Processing

```json
{
  "name": "Cost-Optimized Video Batch",
  "description": "Process videos using cheapest available option first, fallback to premium",
  "nodes": [
    {
      "name": "Input Queue",
      "type": "n8n-nodes-base.webhook"
    },
    {
      "name": "Try Local First",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://localhost:8188/prompt"
      }
    },
    {
      "name": "Check Quality",
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "boolean": [
            {
              "value1": "={{$json.quality_score}}",
              "operation": "larger",
              "value2": 0.8
            }
          ]
        }
      }
    },
    {
      "name": "Upgrade to API",
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "url": "http://localhost:8190/kling/text-to-video"
      }
    }
  ]
}
```

## 💰 Part 5: API Pricing & Cost Management

### 5.1 Current Pricing (2025)

| Model | 5s Video | 10s Video | Image-to-Video |
|-------|----------|-----------|----------------|
| **Kling 2.5 Turbo Pro** | $0.10 | $0.20 | $0.15 |
| **Veo 3.1** | $0.08 | $0.15 | $0.12 |
| **Sora 2** | $0.25 | $0.50 | $0.40 |
| **Seedance 1.5 Pro** | $0.08 | $0.15 | $0.10 |
| **Local (WAN 2.1)** | $0.00 | $0.00 | $0.00 |

### 5.2 Cost Optimization Strategy

```
Priority Order for Cost Optimization:
1. Local Models (Free) - WAN 2.1, CogVideoX, Mochi
2. Seedance 1.5 Pro ($0.08/5s) - Best value API
3. Veo 3.1 ($0.08/5s) - Google quality
4. Kling 2.5 Turbo Pro ($0.10/5s) - Best overall
5. Sora 2 ($0.25/5s) - Premium quality
```

### 5.3 Budget Tracking in N8N

Add a budget tracking node to your workflows:

```javascript
// Budget Tracker Function
const monthlyBudget = 100; // $100/month
const currentSpend = $json.current_spend || 0;
const videoCost = $json.estimated_cost || 0.10;

if (currentSpend + videoCost > monthlyBudget) {
  return {
    action: "use_local",
    reason: "Budget exceeded",
    remaining: monthlyBudget - currentSpend
  };
}

return {
  action: "proceed",
  new_spend: currentSpend + videoCost,
  remaining: monthlyBudget - currentSpend - videoCost
};
```

## 🔑 Part 6: Getting API Keys

### 6.1 Kling AI
1. Visit: https://klingai.com/
2. Sign up for an account
3. Navigate to API section
4. Generate API key
5. Pricing: Pay-as-you-go

### 6.2 Google Veo 3.1
1. Visit: https://ai.google.dev/
2. Create a Google Cloud project
3. Enable Generative AI API
4. Create API credentials
5. Pricing: Pay-as-you-go via Google Cloud

### 6.3 OpenAI Sora 2
1. Visit: https://platform.openai.com/
2. Sign up/login to OpenAI
3. Navigate to API keys
4. Create new secret key
5. Pricing: Requires ChatGPT Plus or API credits

### 6.4 Fal.ai (Seedance, Nano Banana)
1. Visit: https://fal.ai/
2. Create account
3. Go to Dashboard → API Keys
4. Generate new key
5. Pricing: Pay-as-you-go, very competitive

### 6.5 Replicate
1. Visit: https://replicate.com/
2. Sign up with GitHub
3. Go to Account Settings
4. Copy API token
5. Pricing: Pay-per-second of compute

## 📊 Part 7: Model Selection Guide

### When to Use Each Model

| Use Case | Recommended Model | Reason |
|----------|------------------|--------|
| **Bulk content creation** | WAN 2.1 (Local) | Free, unlimited |
| **Social media clips** | Seedance 1.5 Pro | Fast, cheap, good quality |
| **Professional marketing** | Kling 2.5 Turbo Pro | Best quality/price ratio |
| **Cinematic quality** | Sora 2 | Highest quality |
| **Quick prototypes** | Local SVD | Instant, free |
| **Image animation** | Kling I2V or Local SVD | Depends on quality needs |
| **Music videos** | Veo 3.1 + AudioCraft | Native audio support |

### Quality vs Cost Matrix

```
Quality ↑
    │
    │  ★ Sora 2 ($$$)
    │
    │  ★ Kling 2.5 Pro ($$)  ★ Veo 3.1 ($$)
    │
    │  ★ WAN 2.1 (Free)  ★ Seedance ($)
    │
    │  ★ CogVideoX (Free)  ★ Mochi (Free)
    │
    │  ★ SVD (Free)  ★ AnimateDiff (Free)
    │
    └────────────────────────────────────→ Cost
```

## 🚀 Part 8: Quick Start Commands

### Start All Services
```bash
# Start local services
sudo systemctl start comfyui audiocraft api-gateway
cd ~/ai-automation/n8n && docker compose up -d

# Verify all services
curl http://localhost:8188  # ComfyUI
curl http://localhost:8189/health  # AudioCraft
curl http://localhost:8190/health  # API Gateway
curl http://localhost:5678  # N8N
```

### Test Video Generation
```bash
# Test local generation (free)
curl -X POST http://localhost:8188/prompt \
  -H "Content-Type: application/json" \
  -d @wan_workflow.json

# Test Kling API
curl -X POST http://localhost:8190/kling/text-to-video \
  -H "Content-Type: application/json" \
  -d '{"prompt": "A cat playing piano", "duration": 5}'

# Test unified endpoint with auto-selection
curl -X POST http://localhost:8190/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Ocean waves at sunset", "quality": "high", "budget": 0.20}'
```

## 📁 Directory Structure

```
~/ai-automation/
├── n8n/                          # N8N workflow automation
├── comfyui/
│   └── ComfyUI/
│       ├── models/
│       │   ├── checkpoints/      # SDXL, etc.
│       │   ├── wan/              # WAN 2.1 models
│       │   ├── cogvideo/         # CogVideoX models
│       │   └── mochi/            # Mochi models
│       └── custom_nodes/
│           ├── ComfyUI-WanVideoWrapper/
│           ├── ComfyUI-CogVideoXWrapper/
│           ├── ComfyUI-MochiWrapper/
│           ├── ComfyUI-KLingAI-API/
│           └── ComfyUI-fal-API/
├── audiocraft/                   # Music generation
└── api-gateway/                  # Unified API gateway
    ├── api_gateway.py
    ├── .env                      # API keys
    └── venv/
```

## ✅ Summary

Your hybrid system now includes:

### Self-Hosted (Free, Unlimited)
- ✅ WAN 2.1 - Best open-source video model
- ✅ CogVideoX-5B - High quality text-to-video
- ✅ Mochi 1 - Alternative open-source option
- ✅ Stable Video Diffusion - Image-to-video
- ✅ AnimateDiff - Text-to-video animation
- ✅ AudioCraft/MusicGen - Music generation

### API-Based (Premium Quality)
- ✅ Kling 2.5 Turbo Pro - Best quality/price
- ✅ Veo 3.1 - Google's latest
- ✅ Sora 2 - OpenAI's premium
- ✅ Seedance 1.5 Pro - ByteDance's offering
- ✅ Nano Banana Pro - Image generation/editing

### Integration
- ✅ Unified API Gateway
- ✅ N8N workflow automation
- ✅ ComfyUI native nodes
- ✅ Cost optimization
- ✅ Automatic model selection

This gives you the **best of both worlds**: unlimited free generation for bulk work, and premium API access for when you need the absolute best quality!