#!/bin/bash

# AI Automation System - Complete Installation Script
# Installs all components in the correct order

set -e

echo "================================================"
echo "AI Automation System - Complete Installation"
echo "================================================"
echo ""
echo "This script will install:"
echo "  1. System prerequisites (NVIDIA drivers, CUDA, Docker)"
echo "  2. N8N workflow automation"
echo "  3. ComfyUI for image/video generation"
echo "  4. AI models (SDXL, SVD, AnimateDiff)"
echo "  5. AudioCraft for music generation"
echo ""
echo "Total installation time: 1-2 hours"
echo "Total disk space required: ~50 GB"
echo ""

read -p "Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Make all scripts executable
chmod +x install_prerequisites.sh
chmod +x install_n8n.sh
chmod +x install_comfyui.sh
chmod +x download_models.sh
chmod +x install_audiocraft.sh

# Step 1: Prerequisites
echo ""
echo "================================================"
echo "Step 1/5: Installing Prerequisites"
echo "================================================"
./install_prerequisites.sh

# Check if reboot is needed
if ! command -v nvidia-smi &> /dev/null; then
    echo ""
    echo "================================================"
    echo "REBOOT REQUIRED"
    echo "================================================"
    echo "NVIDIA driver was installed. Please reboot your system and run this script again."
    exit 0
fi

# Step 2: N8N
echo ""
echo "================================================"
echo "Step 2/5: Installing N8N"
echo "================================================"
./install_n8n.sh

# Step 3: ComfyUI
echo ""
echo "================================================"
echo "Step 3/5: Installing ComfyUI"
echo "================================================"
./install_comfyui.sh

# Step 4: Download Models
echo ""
echo "================================================"
echo "Step 4/5: Downloading AI Models"
echo "================================================"
./download_models.sh

# Step 5: AudioCraft
echo ""
echo "================================================"
echo "Step 5/5: Installing AudioCraft"
echo "================================================"
./install_audiocraft.sh

# Final summary
echo ""
echo "================================================"
echo "INSTALLATION COMPLETED SUCCESSFULLY!"
echo "================================================"
echo ""
echo "Your AI Automation System is ready!"
echo ""
echo "Access your services:"
echo "  • N8N: http://localhost:5678"
echo "    Username: admin"
echo "    Password: changeme123"
echo ""
echo "  • ComfyUI: http://localhost:8188"
echo ""
echo "  • AudioCraft API: http://localhost:8189"
echo ""
echo "Service management:"
echo "  • N8N: cd ~/ai-automation/n8n && docker compose [up|down|restart]"
echo "  • ComfyUI: sudo systemctl [start|stop|restart|status] comfyui"
echo "  • AudioCraft: sudo systemctl [start|stop|restart|status] audiocraft"
echo ""
echo "Next steps:"
echo "  1. Change N8N default password"
echo "  2. Explore ComfyUI workflows"
echo "  3. Create your first automation in N8N"
echo "  4. Check the documentation: AI_AUTOMATION_SETUP_GUIDE.md"
echo ""
echo "For help and troubleshooting, see the setup guide."
echo ""