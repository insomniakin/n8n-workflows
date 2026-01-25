#!/bin/bash

# AI Automation System - N8N Installation Script
# For Ubuntu Linux

set -e

echo "================================================"
echo "AI Automation System - N8N Installation"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please run install_prerequisites.sh first${NC}"
    exit 1
fi

# Create directory structure
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p ~/ai-automation/n8n/{n8n_data,workflows}
cd ~/ai-automation/n8n

# Create docker-compose.yml
echo -e "${GREEN}Creating Docker Compose configuration...${NC}"
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
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://localhost:5678/
      - GENERIC_TIMEZONE=America/New_York
      - N8N_METRICS=true
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
    networks:
      - ai-automation

networks:
  ai-automation:
    driver: bridge
EOF

# Start N8N
echo -e "${GREEN}Starting N8N...${NC}"
docker compose up -d

# Wait for N8N to start
echo -e "${YELLOW}Waiting for N8N to start...${NC}"
sleep 10

# Check if N8N is running
if docker ps | grep -q n8n; then
    echo -e "${GREEN}N8N is running!${NC}"
    echo ""
    echo "================================================"
    echo -e "${GREEN}N8N Installation Completed!${NC}"
    echo "================================================"
    echo ""
    echo "Access N8N at: http://localhost:5678"
    echo "Username: admin"
    echo "Password: changeme123"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Change the default password after first login!${NC}"
    echo ""
    echo "To view logs: docker compose logs -f n8n"
    echo "To stop N8N: docker compose down"
    echo "To restart N8N: docker compose restart"
    echo ""
else
    echo -e "${RED}N8N failed to start. Check logs with: docker compose logs n8n${NC}"
    exit 1
fi