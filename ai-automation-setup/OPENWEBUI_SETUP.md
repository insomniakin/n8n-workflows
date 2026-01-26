# Open WebUI + Ollama Setup Guide

## 🎯 Overview

This guide sets up **Open WebUI** (formerly Ollama WebUI) - a beautiful, feature-rich web interface for interacting with local AI models through Ollama.

## 🔴 Common Issue: Models Not Showing in Dropdown

**Symptoms:**
- Model dropdown is empty
- "No models available" message
- Can't see the list of installed models

**Root Causes & Fixes:**

### Cause 1: Ollama Not Running
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# If not running, start it
ollama serve

# Or restart the service
sudo systemctl restart ollama
```

### Cause 2: Wrong OLLAMA_BASE_URL
The most common issue! Open WebUI needs to know where Ollama is.

**For Docker installations:**
```env
OLLAMA_BASE_URL=http://host.docker.internal:11434
```

**For native installations:**
```env
OLLAMA_BASE_URL=http://localhost:11434
```

### Cause 3: No Models Downloaded
```bash
# Check installed models
ollama list

# If empty, pull a model
ollama pull llama3.2
ollama pull mistral
```

### Cause 4: Network/Firewall Issues
```bash
# Ensure Ollama listens on all interfaces
export OLLAMA_HOST=0.0.0.0:11434
export OLLAMA_ORIGINS=*

# Restart Ollama
sudo systemctl restart ollama
```

---

## 🚀 Quick Installation

### One-Command Install
```bash
chmod +x install_openwebui.sh
./install_openwebui.sh
```

### Manual Installation

#### Step 1: Install Ollama
```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

#### Step 2: Configure Ollama for Network Access
```bash
# Create override config
sudo mkdir -p /etc/systemd/system/ollama.service.d/
sudo tee /etc/systemd/system/ollama.service.d/override.conf << 'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
EOF

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

#### Step 3: Pull Models
```bash
# Pull default model
ollama pull llama3.2

# Optional: Pull additional models
ollama pull mistral      # Fast, good quality
ollama pull codellama    # Code generation
ollama pull llava        # Vision (can see images)
ollama pull phi3         # Small, fast
```

#### Step 4: Install Open WebUI with Docker
```bash
mkdir -p ~/ai-automation/openwebui
cd ~/ai-automation/openwebui

# Create docker-compose.yml (see below)
docker compose up -d
```

---

## 📋 Docker Compose Configuration

### Recommended docker-compose.yml
```yaml
version: '3.8'

services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    environment:
      # ========================================
      # CRITICAL: Ollama Connection Settings
      # ========================================
      - OLLAMA_BASE_URL=http://host.docker.internal:11434
      - OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api
      
      # Enable Ollama API
      - ENABLE_OLLAMA_API=true
      
      # ========================================
      # Model Configuration (FIX FOR EMPTY LIST)
      # ========================================
      - DEFAULT_MODELS=llama3.2:latest
      - ENABLE_MODEL_FILTER=false
      - MODEL_FILTER_LIST=
      
      # Auto-refresh models every 30 seconds
      - AUTOMATIC_MODEL_REFRESH=true
      - MODEL_REFRESH_INTERVAL=30
      
      # ========================================
      # Authentication
      # ========================================
      - WEBUI_AUTH=false
      - ENABLE_SIGNUP=true
      
      # ========================================
      # Features
      # ========================================
      - ENABLE_RAG_WEB_SEARCH=true
      - ENABLE_IMAGE_GENERATION=false
      - CHUNK_SIZE=1500
      - CHUNK_OVERLAP=100
      
    volumes:
      - ./data:/app/backend/data
    extra_hosts:
      - "host.docker.internal:host-gateway"
    networks:
      - ai-automation

networks:
  ai-automation:
    driver: bridge
```

---

## 🔧 Environment Variables Reference

### Essential Variables (Must Set)
| Variable | Value | Description |
|----------|-------|-------------|
| `OLLAMA_BASE_URL` | `http://host.docker.internal:11434` | Ollama server URL (Docker) |
| `ENABLE_OLLAMA_API` | `true` | Enable Ollama integration |
| `AUTOMATIC_MODEL_REFRESH` | `true` | Auto-refresh model list |

### Model Configuration
| Variable | Value | Description |
|----------|-------|-------------|
| `DEFAULT_MODELS` | `llama3.2:latest` | Default model to select |
| `ENABLE_MODEL_FILTER` | `false` | Don't filter models |
| `MODEL_FILTER_LIST` | `` | Empty = show all models |
| `MODEL_REFRESH_INTERVAL` | `30` | Refresh every 30 seconds |

### Authentication
| Variable | Value | Description |
|----------|-------|-------------|
| `WEBUI_AUTH` | `false` | Disable auth for local use |
| `ENABLE_SIGNUP` | `true` | Allow new users |

---

## 🔍 Troubleshooting

### Problem: Empty Model Dropdown

**Step 1: Verify Ollama is running**
```bash
curl http://localhost:11434/api/tags
```

Expected output:
```json
{"models":[{"name":"llama3.2:latest",...}]}
```

**Step 2: Verify models exist**
```bash
ollama list
```

**Step 3: Check Open WebUI logs**
```bash
docker compose logs -f open-webui
```

Look for errors like:
- "Connection refused" → Ollama not running
- "No models found" → Need to pull models
- "OLLAMA_BASE_URL" errors → Wrong URL configuration

**Step 4: Force refresh**
```bash
# Restart Open WebUI
docker compose restart open-webui

# Or recreate container
docker compose down
docker compose up -d
```

### Problem: "Connection Refused" Error

**Fix 1: Ensure Ollama listens on all interfaces**
```bash
# Check current config
cat /etc/systemd/system/ollama.service.d/override.conf

# Should contain:
# Environment="OLLAMA_HOST=0.0.0.0:11434"
```

**Fix 2: Check Docker networking**
```bash
# Test from inside container
docker exec -it open-webui curl http://host.docker.internal:11434/api/tags
```

**Fix 3: Use host network mode (alternative)**
```yaml
services:
  open-webui:
    network_mode: host
    environment:
      - OLLAMA_BASE_URL=http://localhost:11434
```

### Problem: Models Load Slowly

**Fix: Pre-load models**
```bash
# Keep model in memory
ollama run llama3.2 "Hello" && exit
```

**Fix: Increase keep-alive time**
```bash
export OLLAMA_KEEP_ALIVE=24h
sudo systemctl restart ollama
```

---

## 📊 Service Management

### Start Services
```bash
# Start Ollama
sudo systemctl start ollama

# Start Open WebUI
cd ~/ai-automation/openwebui
docker compose up -d
```

### Stop Services
```bash
# Stop Open WebUI
docker compose down

# Stop Ollama
sudo systemctl stop ollama
```

### View Logs
```bash
# Ollama logs
sudo journalctl -u ollama -f

# Open WebUI logs
docker compose logs -f open-webui
```

### Restart Services
```bash
# Restart both
sudo systemctl restart ollama
docker compose restart open-webui
```

---

## 🎨 Recommended Models

### For General Chat
| Model | Size | Speed | Quality | Use Case |
|-------|------|-------|---------|----------|
| `llama3.2` | 3B | ⚡⚡⚡ | ⭐⭐⭐⭐ | General purpose |
| `llama3.2:70b` | 70B | ⚡ | ⭐⭐⭐⭐⭐ | Best quality |
| `mistral` | 7B | ⚡⚡⚡ | ⭐⭐⭐⭐ | Fast, good quality |
| `phi3` | 3.8B | ⚡⚡⚡⚡ | ⭐⭐⭐ | Very fast |

### For Coding
| Model | Size | Best For |
|-------|------|----------|
| `codellama` | 7B | General coding |
| `codellama:34b` | 34B | Complex code |
| `deepseek-coder` | 6.7B | Code completion |

### For Vision (Image Understanding)
| Model | Size | Capability |
|-------|------|------------|
| `llava` | 7B | See and describe images |
| `llava:34b` | 34B | Better image understanding |

### Download Commands
```bash
# Essential models
ollama pull llama3.2
ollama pull mistral

# Coding
ollama pull codellama

# Vision
ollama pull llava

# List all installed
ollama list
```

---

## 🔗 Integration with N8N

### Add to N8N Workflow
```json
{
  "name": "Chat with Ollama",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "http://localhost:11434/api/generate",
    "method": "POST",
    "body": {
      "model": "llama3.2",
      "prompt": "={{$json.user_message}}",
      "stream": false
    }
  }
}
```

### Chat Completion API
```bash
curl http://localhost:11434/api/chat -d '{
  "model": "llama3.2",
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "stream": false
}'
```

---

## 📁 Directory Structure

```
~/ai-automation/openwebui/
├── docker-compose.yml      # Container configuration
├── data/                   # Persistent data
│   ├── webui.db           # User data, settings
│   ├── uploads/           # Uploaded files
│   └── cache/             # Model cache
└── .env                   # Environment variables (optional)
```

---

## ✅ Verification Checklist

After installation, verify everything works:

- [ ] Ollama running: `curl http://localhost:11434/api/tags`
- [ ] Models installed: `ollama list`
- [ ] Open WebUI accessible: http://localhost:3000
- [ ] Model dropdown populated
- [ ] Can send a message and get response
- [ ] Can switch between models

---

## 🆘 Quick Fixes Summary

| Problem | Quick Fix |
|---------|-----------|
| Empty model list | `ollama pull llama3.2 && docker compose restart` |
| Connection refused | `sudo systemctl restart ollama` |
| Slow model loading | `export OLLAMA_KEEP_ALIVE=24h` |
| Can't access WebUI | `docker compose up -d` |
| Models not refreshing | Set `AUTOMATIC_MODEL_REFRESH=true` |

---

## 📞 Access URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Open WebUI | http://localhost:3000 | Chat interface |
| Ollama API | http://localhost:11434 | API endpoint |
| Model List | http://localhost:11434/api/tags | Check models |

---

**Happy chatting with your local AI! 🤖**