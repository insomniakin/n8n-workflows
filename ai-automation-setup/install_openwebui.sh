#!/bin/bash

# ============================================
# Open WebUI + Ollama Installation Script
# For AI Automation System
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}   Open WebUI + Ollama Installation${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Create directory structure
INSTALL_DIR="$HOME/ai-automation/openwebui"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# ============================================
# PART 1: Install Ollama
# ============================================
echo -e "${YELLOW}[1/5] Installing Ollama...${NC}"

if command -v ollama &> /dev/null; then
    echo -e "${GREEN}   Ollama is already installed${NC}"
    ollama --version
else
    echo "   Downloading and installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
    echo -e "${GREEN}   Ollama installed successfully${NC}"
fi

# ============================================
# PART 2: Configure Ollama Service
# ============================================
echo -e "${YELLOW}[2/5] Configuring Ollama service...${NC}"

# Create systemd service override for network access
sudo mkdir -p /etc/systemd/system/ollama.service.d/

sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null << 'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
EOF

# Reload and restart Ollama
sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama

echo -e "${GREEN}   Ollama service configured${NC}"

# Wait for Ollama to start
echo "   Waiting for Ollama to start..."
sleep 5

# Verify Ollama is running
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}   Ollama is running on port 11434${NC}"
else
    echo -e "${RED}   Warning: Ollama may not be running yet${NC}"
fi

# ============================================
# PART 3: Download Default Models
# ============================================
echo -e "${YELLOW}[3/5] Downloading AI models...${NC}"

echo "   Pulling llama3.2 (default model)..."
ollama pull llama3.2

echo ""
echo -e "${BLUE}   Would you like to download additional models?${NC}"
echo "   1) mistral (7B - fast, good quality)"
echo "   2) codellama (code generation)"
echo "   3) llava (vision model - can see images)"
echo "   4) phi3 (small, fast)"
echo "   5) Skip additional models"
echo ""
read -p "   Enter choice (1-5): " model_choice

case $model_choice in
    1)
        ollama pull mistral
        ;;
    2)
        ollama pull codellama
        ;;
    3)
        ollama pull llava
        ;;
    4)
        ollama pull phi3
        ;;
    *)
        echo "   Skipping additional models"
        ;;
esac

echo -e "${GREEN}   Models downloaded successfully${NC}"

# List installed models
echo ""
echo -e "${BLUE}   Installed models:${NC}"
ollama list

# ============================================
# PART 4: Install Open WebUI
# ============================================
echo -e "${YELLOW}[4/5] Installing Open WebUI...${NC}"

# Create docker-compose file for Open WebUI
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    environment:
      # Ollama Configuration - CRITICAL FOR MODEL LIST
      - OLLAMA_BASE_URL=http://host.docker.internal:11434
      - OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api
      
      # Enable Ollama API
      - ENABLE_OLLAMA_API=true
      
      # Model Configuration
      - DEFAULT_MODELS=llama3.2:latest
      - ENABLE_MODEL_FILTER=false
      - MODEL_FILTER_LIST=
      
      # Auto-refresh models (FIX FOR MODEL LIST NOT SHOWING)
      - AUTOMATIC_MODEL_REFRESH=true
      - MODEL_REFRESH_INTERVAL=30
      
      # Authentication (disable for local use)
      - WEBUI_AUTH=false
      - ENABLE_SIGNUP=true
      
      # Performance
      - ENABLE_RAG_WEB_SEARCH=true
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
EOF

# Start Open WebUI
echo "   Starting Open WebUI container..."
docker compose up -d

echo -e "${GREEN}   Open WebUI installed successfully${NC}"

# ============================================
# PART 5: Verify Installation
# ============================================
echo -e "${YELLOW}[5/5] Verifying installation...${NC}"

# Wait for services to start
echo "   Waiting for services to initialize..."
sleep 10

# Check Ollama
echo ""
echo -n "   Ollama API: "
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Running${NC}"
    MODELS=$(curl -s http://localhost:11434/api/tags | grep -o '"name":"[^"]*"' | wc -l)
    echo -e "   ${BLUE}Found $MODELS model(s)${NC}"
else
    echo -e "${RED}✗ Not responding${NC}"
fi

# Check Open WebUI
echo -n "   Open WebUI: "
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⏳ Starting up (may take 30-60 seconds)${NC}"
fi

# ============================================
# COMPLETION
# ============================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}   Installation Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo "   Open WebUI:  http://localhost:3000"
echo "   Ollama API:  http://localhost:11434"
echo ""
echo -e "${BLUE}Quick Commands:${NC}"
echo "   List models:     ollama list"
echo "   Pull new model:  ollama pull <model-name>"
echo "   Chat in CLI:     ollama run llama3.2"
echo "   View logs:       docker compose logs -f open-webui"
echo "   Restart:         docker compose restart"
echo ""
echo -e "${YELLOW}If models don't appear in the dropdown:${NC}"
echo "   1. Wait 30 seconds for auto-refresh"
echo "   2. Click the refresh button in Open WebUI"
echo "   3. Check: curl http://localhost:11434/api/tags"
echo "   4. Restart: docker compose restart"
echo ""
echo -e "${GREEN}Enjoy your AI assistant!${NC}"