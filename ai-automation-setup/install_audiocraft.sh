#!/bin/bash

# AI Automation System - AudioCraft Installation Script
# For music and audio generation

set -e

echo "================================================"
echo "AI Automation System - AudioCraft Installation"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create directory
echo -e "${GREEN}Creating AudioCraft directory...${NC}"
mkdir -p ~/ai-automation/audiocraft
cd ~/ai-automation/audiocraft

# Clone AudioCraft
echo -e "${GREEN}Cloning AudioCraft repository...${NC}"
if [ -d "audiocraft" ]; then
    echo -e "${YELLOW}AudioCraft directory already exists. Pulling latest changes...${NC}"
    cd audiocraft
    git pull
    cd ..
else
    git clone https://github.com/facebookresearch/audiocraft.git
fi

cd audiocraft

# Create virtual environment
echo -e "${GREEN}Creating Python virtual environment...${NC}"
python3 -m venv venv
source venv/bin/activate

# Install AudioCraft
echo -e "${GREEN}Installing AudioCraft...${NC}"
pip install --upgrade pip
pip install -e .

# Install Flask for API server
pip install flask flask-cors

# Create API server
echo -e "${GREEN}Creating AudioCraft API server...${NC}"
cat > audiocraft_server.py << 'EOF'
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from audiocraft.models import MusicGen
import torch
import torchaudio
import os
from datetime import datetime
import logging

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Output directory
OUTPUT_DIR = "/tmp/audiocraft_outputs"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load model
logger.info("Loading MusicGen model...")
model = MusicGen.get_pretrained('facebook/musicgen-medium')
logger.info("Model loaded successfully")

@app.route('/generate', methods=['POST'])
def generate_music():
    try:
        data = request.json
        prompt = data.get('prompt', 'upbeat electronic music')
        duration = data.get('duration', 30)
        
        logger.info(f"Generating music: prompt='{prompt}', duration={duration}s")
        
        # Set generation parameters
        model.set_generation_params(duration=duration)
        
        # Generate
        wav = model.generate([prompt])
        
        # Save
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"music_{timestamp}.wav"
        output_path = os.path.join(OUTPUT_DIR, filename)
        torchaudio.save(output_path, wav[0].cpu(), model.sample_rate)
        
        logger.info(f"Music generated: {output_path}")
        
        return send_file(output_path, mimetype='audio/wav', as_attachment=True, download_name=filename)
    
    except Exception as e:
        logger.error(f"Error generating music: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/generate_batch', methods=['POST'])
def generate_batch():
    try:
        data = request.json
        prompts = data.get('prompts', [])
        duration = data.get('duration', 30)
        
        if not prompts:
            return jsonify({"error": "No prompts provided"}), 400
        
        logger.info(f"Generating batch: {len(prompts)} prompts, duration={duration}s")
        
        # Set generation parameters
        model.set_generation_params(duration=duration)
        
        # Generate
        wav = model.generate(prompts)
        
        # Save all files
        files = []
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for i, audio in enumerate(wav):
            filename = f"music_{timestamp}_{i}.wav"
            output_path = os.path.join(OUTPUT_DIR, filename)
            torchaudio.save(output_path, audio.cpu(), model.sample_rate)
            files.append(filename)
        
        logger.info(f"Batch generated: {len(files)} files")
        
        return jsonify({
            "files": files,
            "message": f"Generated {len(files)} audio files"
        })
    
    except Exception as e:
        logger.error(f"Error generating batch: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/download/<filename>', methods=['GET'])
def download_file(filename):
    try:
        output_path = os.path.join(OUTPUT_DIR, filename)
        if os.path.exists(output_path):
            return send_file(output_path, mimetype='audio/wav', as_attachment=True)
        else:
            return jsonify({"error": "File not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "ok",
        "model": "musicgen-medium",
        "cuda_available": torch.cuda.is_available(),
        "gpu": torch.cuda.get_device_name(0) if torch.cuda.is_available() else "None"
    })

@app.route('/models', methods=['GET'])
def list_models():
    return jsonify({
        "available_models": [
            "facebook/musicgen-small",
            "facebook/musicgen-medium",
            "facebook/musicgen-large"
        ],
        "current_model": "facebook/musicgen-medium"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8189, debug=False)
EOF

# Create systemd service
echo -e "${GREEN}Creating systemd service...${NC}"
sudo tee /etc/systemd/system/audiocraft.service << EOF
[Unit]
Description=AudioCraft API Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/ai-automation/audiocraft/audiocraft
ExecStart=$HOME/ai-automation/audiocraft/audiocraft/venv/bin/python audiocraft_server.py
Restart=on-failure
RestartSec=10
Environment="PATH=$HOME/ai-automation/audiocraft/audiocraft/venv/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Environment="LD_LIBRARY_PATH=/usr/local/cuda/lib64"

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
echo -e "${GREEN}Starting AudioCraft service...${NC}"
sudo systemctl enable audiocraft
sudo systemctl start audiocraft

# Wait for service to start
echo -e "${YELLOW}Waiting for AudioCraft to start (this may take a minute)...${NC}"
sleep 30

# Check service status
if sudo systemctl is-active --quiet audiocraft; then
    echo -e "${GREEN}AudioCraft is running!${NC}"
    echo ""
    echo "================================================"
    echo -e "${GREEN}AudioCraft Installation Completed!${NC}"
    echo "================================================"
    echo ""
    echo "API Endpoint: http://localhost:8189"
    echo ""
    echo "Available endpoints:"
    echo "  POST /generate - Generate single audio"
    echo "  POST /generate_batch - Generate multiple audio files"
    echo "  GET /health - Check service health"
    echo "  GET /models - List available models"
    echo ""
    echo "Example usage:"
    echo "  curl -X POST http://localhost:8189/generate \&quot;
    echo "    -H 'Content-Type: application/json' \&quot;
    echo "    -d '{&quot;prompt&quot;: &quot;upbeat electronic music&quot;, &quot;duration&quot;: 10}' \&quot;
    echo "    --output music.wav"
    echo ""
    echo "Service commands:"
    echo "  Check status: sudo systemctl status audiocraft"
    echo "  View logs: sudo journalctl -u audiocraft -f"
    echo "  Restart: sudo systemctl restart audiocraft"
    echo "  Stop: sudo systemctl stop audiocraft"
    echo ""
else
    echo -e "${RED}AudioCraft failed to start. Check logs with: sudo journalctl -u audiocraft -n 50${NC}"
    exit 1
fi