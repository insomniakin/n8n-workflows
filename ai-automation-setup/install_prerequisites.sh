#!/bin/bash

# AI Automation System - Prerequisites Installation Script
# For Ubuntu Linux

set -e

echo "================================================"
echo "AI Automation System - Prerequisites Setup"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run this script as root${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}Step 2: Installing essential tools...${NC}"
sudo apt install -y \
    build-essential \
    git \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    python3-pip \
    python3-venv \
    software-properties-common

echo -e "${GREEN}Step 3: Checking NVIDIA driver...${NC}"
if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}NVIDIA driver is already installed:${NC}"
    nvidia-smi
else
    echo -e "${YELLOW}NVIDIA driver not found. Installing...${NC}"
    sudo add-apt-repository ppa:graphics-drivers/ppa -y
    sudo apt update
    sudo ubuntu-drivers autoinstall
    echo -e "${YELLOW}Please reboot your system after this script completes!${NC}"
fi

echo -e "${GREEN}Step 4: Installing CUDA Toolkit...${NC}"
if command -v nvcc &> /dev/null; then
    echo -e "${GREEN}CUDA is already installed:${NC}"
    nvcc --version
else
    echo -e "${YELLOW}Installing CUDA Toolkit...${NC}"
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt update
    sudo apt install -y cuda-toolkit-12-3
    
    # Add to PATH
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    
    echo -e "${YELLOW}CUDA installed. Please run 'source ~/.bashrc' or restart your terminal${NC}"
fi

echo -e "${GREEN}Step 5: Installing Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker is already installed:${NC}"
    docker --version
else
    # Remove old versions
    sudo apt remove docker docker-engine docker.io containerd runc 2>/dev/null || true
    
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
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    echo -e "${YELLOW}Docker installed. Please log out and log back in for group changes to take effect${NC}"
fi

echo -e "${GREEN}Step 6: Installing NVIDIA Container Toolkit...${NC}"
if dpkg -l | grep -q nvidia-container-toolkit; then
    echo -e "${GREEN}NVIDIA Container Toolkit is already installed${NC}"
else
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    
    # Configure Docker to use NVIDIA runtime
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
fi

echo -e "${GREEN}Step 7: Testing GPU access in Docker...${NC}"
if docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi; then
    echo -e "${GREEN}GPU access in Docker is working!${NC}"
else
    echo -e "${RED}GPU access in Docker failed. Please check your setup.${NC}"
fi

echo ""
echo "================================================"
echo -e "${GREEN}Prerequisites installation completed!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. If NVIDIA driver was installed, reboot your system"
echo "2. If Docker was installed, log out and log back in"
echo "3. Run 'source ~/.bashrc' to update PATH"
echo "4. Run './install_n8n.sh' to install N8N"
echo ""