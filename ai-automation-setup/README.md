# AI Automation System for Ubuntu

A complete local AI automation system for generating images, videos, and music using N8N, ComfyUI, and AudioCraft.

## 🎯 What This System Does

This system allows you to:
- ✅ Generate high-quality images from text descriptions
- ✅ Convert images into videos
- ✅ Create videos from text prompts
- ✅ Generate music and audio from descriptions
- ✅ Automate entire content creation workflows
- ✅ Run everything locally on your hardware (no cloud costs!)
- ✅ Create unlimited content with no restrictions

## 🖥️ System Requirements

### Minimum Requirements
- **OS**: Ubuntu 20.04 or newer
- **CPU**: Intel i5 or AMD Ryzen 5 (8+ cores recommended)
- **RAM**: 16 GB (32 GB recommended)
- **GPU**: NVIDIA GPU with 8GB+ VRAM (RTX 3060 or better)
- **Storage**: 100 GB free space (SSD recommended)
- **Internet**: For initial setup and model downloads

### Your Hardware
- ✅ Intel i9 processor
- ✅ RTX 3090 (24GB VRAM) - Excellent!
- ✅ RTX 490 (secondary GPU) - Can be configured for parallel processing

## 🚀 Quick Start

### Option 1: Automated Installation (Recommended)

```bash
# Make the script executable
chmod +x install_all.sh

# Run the complete installation
./install_all.sh
```

This will install everything automatically. Total time: 1-2 hours.

### Option 2: Manual Step-by-Step Installation

```bash
# Step 1: Install prerequisites
chmod +x install_prerequisites.sh
./install_prerequisites.sh

# Step 2: Install N8N
chmod +x install_n8n.sh
./install_n8n.sh

# Step 3: Install ComfyUI
chmod +x install_comfyui.sh
./install_comfyui.sh

# Step 4: Download AI models
chmod +x download_models.sh
./download_models.sh

# Step 5: Install AudioCraft
chmod +x install_audiocraft.sh
./install_audiocraft.sh
```

## 📦 What Gets Installed

### 1. N8N Workflow Automation
- **Purpose**: Orchestrate and automate AI workflows
- **Access**: http://localhost:5678
- **Default Login**: admin / changeme123

### 2. ComfyUI
- **Purpose**: Generate images and videos
- **Access**: http://localhost:8188
- **Models**: SDXL, Stable Video Diffusion, AnimateDiff

### 3. AudioCraft
- **Purpose**: Generate music and audio
- **Access**: http://localhost:8189 (API)
- **Model**: MusicGen Medium

### 4. AI Models
- Stable Diffusion XL (6.9 GB) - High-quality images
- Stable Video Diffusion (9.8 GB) - Image-to-video
- AnimateDiff (1.7 GB) - Text-to-video
- MusicGen (1.5 GB) - Music generation

## 🎨 Usage Examples

### Generate an Image
1. Open ComfyUI: http://localhost:8188
2. Enter your prompt: "beautiful mountain landscape at sunset"
3. Click "Queue Prompt"
4. Wait 10-30 seconds
5. Download your image!

### Generate Music
```bash
curl -X POST http://localhost:8189/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "upbeat electronic music", "duration": 30}' \
  --output music.wav
```

### Create a Video from Image
1. Upload image to ComfyUI
2. Load SVD workflow
3. Generate video (2-5 minutes)
4. Download MP4 file

### Automate with N8N
1. Open N8N: http://localhost:5678
2. Create new workflow
3. Add HTTP Request nodes to call ComfyUI/AudioCraft
4. Set up triggers (schedule, webhook, etc.)
5. Activate workflow

## 📚 Documentation

- **Complete Setup Guide**: [AI_AUTOMATION_SETUP_GUIDE.md](AI_AUTOMATION_SETUP_GUIDE.md)
- **Example Workflows**: [example_workflows.md](example_workflows.md)
- **Troubleshooting**: See setup guide Part 11

## 🔧 Service Management

### N8N
```bash
cd ~/ai-automation/n8n

# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f n8n

# Restart
docker compose restart
```

### ComfyUI
```bash
# Start
sudo systemctl start comfyui

# Stop
sudo systemctl stop comfyui

# Restart
sudo systemctl restart comfyui

# View logs
sudo journalctl -u comfyui -f

# Check status
sudo systemctl status comfyui
```

### AudioCraft
```bash
# Start
sudo systemctl start audiocraft

# Stop
sudo systemctl stop audiocraft

# Restart
sudo systemctl restart audiocraft

# View logs
sudo journalctl -u audiocraft -f

# Check status
sudo systemctl status audiocraft
```

## 🎯 Common Use Cases

### 1. Content Creation for Social Media
- Generate images for posts
- Create short videos
- Add background music
- Automate posting schedule

### 2. Product Visualization
- Generate product images
- Create 360° views
- Visualize in different settings
- Generate marketing materials

### 3. Video Production
- Create animated sequences
- Generate scene backgrounds
- Add AI-generated music
- Automate video editing

### 4. Art and Design
- Generate concept art
- Create variations
- Explore different styles
- Build art collections

### 5. Music Production
- Generate background music
- Create sound effects
- Produce jingles
- Generate ambient soundscapes

## 🔍 Monitoring and Optimization

### Check GPU Usage
```bash
# Real-time monitoring
watch -n 1 nvidia-smi

# Or use nvtop (more detailed)
sudo apt install nvtop
nvtop
```

### Check Disk Space
```bash
df -h ~/ai-automation
```

### Check Service Status
```bash
# All services
sudo systemctl status comfyui audiocraft
docker ps

# Detailed status
sudo systemctl status comfyui --no-pager -l
```

## 🛠️ Troubleshooting

### ComfyUI Not Starting
```bash
# Check logs
sudo journalctl -u comfyui -n 50

# Verify GPU access
nvidia-smi

# Test CUDA
python3 -c "import torch; print(torch.cuda.is_available())"
```

### Out of GPU Memory
- Reduce image resolution (1024x1024 → 768x768)
- Lower batch size
- Close other GPU applications
- Use model offloading

### N8N Can't Connect to ComfyUI
```bash
# Check if ComfyUI is running
sudo systemctl status comfyui

# Check port
netstat -tulpn | grep 8188

# Test connection
curl http://localhost:8188
```

### Slow Generation
- Use faster samplers (euler, dpm++)
- Reduce steps (15-20)
- Enable xformers optimization
- Use FP16 precision

## 📊 Performance Tips

### For RTX 3090 (24GB VRAM)
- Can handle 1024x1024 images easily
- Can generate 4-second videos
- Can run multiple models simultaneously
- Recommended batch size: 1-4

### Multi-GPU Setup (RTX 3090 + RTX 490)
```bash
# Use specific GPU
export CUDA_VISIBLE_DEVICES=0  # RTX 3090
export CUDA_VISIBLE_DEVICES=1  # RTX 490

# Use both GPUs
export CUDA_VISIBLE_DEVICES=0,1
```

### Optimize Disk I/O
- Use SSD for model storage
- Enable disk caching
- Regular cleanup of output files

## 🔐 Security Considerations

### Change Default Passwords
```bash
# Edit N8N docker-compose.yml
cd ~/ai-automation/n8n
nano docker-compose.yml
# Change N8N_BASIC_AUTH_PASSWORD
docker compose restart
```

### Firewall Configuration
```bash
# If exposing to network
sudo ufw allow 5678  # N8N
sudo ufw allow 8188  # ComfyUI
sudo ufw allow 8189  # AudioCraft
```

### Network Access
By default, services are accessible only from localhost. To access from other devices:
1. Change `listen` addresses in configs
2. Configure firewall
3. Consider using reverse proxy (nginx)

## 📈 Scaling and Advanced Usage

### Add More Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models/checkpoints
# Download models from Civitai or Hugging Face
wget <model_url>
```

### Custom Nodes
```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes
git clone <custom_node_repo>
sudo systemctl restart comfyui
```

### Batch Processing
Create N8N workflows that:
- Process multiple prompts
- Generate variations
- Organize outputs
- Send notifications

## 🌐 Community and Resources

### Official Documentation
- N8N: https://docs.n8n.io/
- ComfyUI: https://github.com/comfyanonymous/ComfyUI
- AudioCraft: https://github.com/facebookresearch/audiocraft

### Communities
- N8N Community: https://community.n8n.io/
- ComfyUI Discord: https://discord.gg/comfyui
- Stable Diffusion Reddit: https://reddit.com/r/StableDiffusion

### Model Resources
- Civitai: https://civitai.com/
- Hugging Face: https://huggingface.co/models
- ComfyUI Workflows: https://comfyworkflows.com/

## 🤝 Contributing

Found a bug or have a suggestion? Please:
1. Check existing issues
2. Create detailed bug reports
3. Share your workflows
4. Help others in the community

## 📝 License

This setup guide is provided as-is. Individual components have their own licenses:
- N8N: Fair-code license
- ComfyUI: GPL-3.0
- AudioCraft: MIT License
- Stable Diffusion: CreativeML Open RAIL-M

## ⚠️ Important Notes

1. **GPU Required**: This system requires an NVIDIA GPU with CUDA support
2. **Disk Space**: Models require significant storage (50-100 GB)
3. **Internet**: Initial setup requires downloading large files
4. **Legal**: Ensure you have rights to use generated content
5. **Ethics**: Use AI responsibly and ethically

## 🎓 Learning Resources

### Beginner
1. Start with ComfyUI web interface
2. Try basic image generation
3. Experiment with different prompts
4. Learn prompt engineering

### Intermediate
1. Create N8N workflows
2. Combine multiple AI models
3. Automate content pipelines
4. Optimize for performance

### Advanced
1. Custom model training
2. API integration
3. Multi-GPU optimization
4. Production deployment

## 📞 Support

Need help?
1. Check the troubleshooting section
2. Review the complete setup guide
3. Search community forums
4. Ask in Discord/Reddit communities

## 🎉 Success Stories

Share what you've created with this system!
- Tag your work on social media
- Share workflows with the community
- Contribute to documentation
- Help others get started

---

**Happy Creating! 🚀**

Built with ❤️ for the AI automation community