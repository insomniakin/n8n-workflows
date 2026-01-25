# Quick Reference Guide

## 🚀 Installation Commands

```bash
# Complete installation (recommended)
./install_all.sh

# Or step by step:
./install_prerequisites.sh
./install_n8n.sh
./install_comfyui.sh
./download_models.sh
./install_audiocraft.sh
```

## 🌐 Access URLs

| Service | URL | Default Login |
|---------|-----|---------------|
| N8N | http://localhost:5678 | admin / changeme123 |
| ComfyUI | http://localhost:8188 | No login required |
| AudioCraft API | http://localhost:8189 | No login required |

## 🔧 Service Management

### N8N
```bash
cd ~/ai-automation/n8n
docker compose up -d        # Start
docker compose down         # Stop
docker compose restart      # Restart
docker compose logs -f n8n  # View logs
```

### ComfyUI
```bash
sudo systemctl start comfyui    # Start
sudo systemctl stop comfyui     # Stop
sudo systemctl restart comfyui  # Restart
sudo systemctl status comfyui   # Status
sudo journalctl -u comfyui -f   # View logs
```

### AudioCraft
```bash
sudo systemctl start audiocraft    # Start
sudo systemctl stop audiocraft     # Stop
sudo systemctl restart audiocraft  # Restart
sudo systemctl status audiocraft   # Status
sudo journalctl -u audiocraft -f   # View logs
```

## 📊 Monitoring

### GPU Usage
```bash
nvidia-smi                    # Quick check
watch -n 1 nvidia-smi        # Real-time monitoring
nvtop                        # Advanced monitoring (install: sudo apt install nvtop)
```

### Disk Space
```bash
df -h ~/ai-automation        # Check AI automation disk usage
du -sh ~/ai-automation/*     # Size of each component
```

### System Resources
```bash
htop                         # CPU and RAM usage
free -h                      # Memory usage
```

## 🎨 Quick Generation Commands

### Generate Image (via ComfyUI API)
```bash
curl -X POST http://localhost:8188/prompt \
  -H "Content-Type: application/json" \
  -d @prompt.json
```

### Generate Music
```bash
curl -X POST http://localhost:8189/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "upbeat electronic music", "duration": 30}' \
  --output music.wav
```

### Check Service Health
```bash
curl http://localhost:8189/health  # AudioCraft health
curl http://localhost:8188         # ComfyUI health
curl http://localhost:5678         # N8N health
```

## 📁 Important Directories

```bash
~/ai-automation/
├── n8n/
│   ├── n8n_data/          # N8N data and settings
│   └── workflows/         # N8N workflow files
├── comfyui/
│   └── ComfyUI/
│       ├── models/        # AI models
│       ├── output/        # Generated images/videos
│       └── custom_nodes/  # Custom nodes
└── audiocraft/
    └── audiocraft/        # AudioCraft installation
```

## 🔍 Troubleshooting Quick Fixes

### Service Won't Start
```bash
# Check logs
sudo journalctl -u comfyui -n 50
sudo journalctl -u audiocraft -n 50
docker compose logs n8n

# Restart all services
sudo systemctl restart comfyui audiocraft
cd ~/ai-automation/n8n && docker compose restart
```

### Out of GPU Memory
```bash
# Check GPU usage
nvidia-smi

# Kill GPU processes
sudo fuser -v /dev/nvidia*
sudo kill -9 <PID>

# Restart services
sudo systemctl restart comfyui
```

### Disk Space Full
```bash
# Clean ComfyUI outputs
rm -rf ~/ai-automation/comfyui/ComfyUI/output/*

# Clean AudioCraft outputs
rm -rf /tmp/audiocraft_outputs/*

# Clean Docker
docker system prune -a
```

### Can't Access Services
```bash
# Check if services are running
sudo systemctl status comfyui audiocraft
docker ps

# Check ports
netstat -tulpn | grep -E '5678|8188|8189'

# Restart network
sudo systemctl restart networking
```

## 🎯 Common Workflows

### 1. Generate Image
1. Open http://localhost:8188
2. Enter prompt in text box
3. Click "Queue Prompt"
4. Wait for generation
5. Download from output folder

### 2. Create Video from Image
1. Upload image to ComfyUI
2. Load SVD workflow
3. Adjust settings
4. Queue prompt
5. Wait 2-5 minutes
6. Download video

### 3. Generate Music
1. Use curl command or N8N
2. Provide text description
3. Set duration (10-30 seconds)
4. Download WAV file

### 4. Automate with N8N
1. Open http://localhost:5678
2. Create new workflow
3. Add HTTP Request nodes
4. Configure endpoints
5. Set up triggers
6. Activate workflow

## 📦 Model Management

### Download New Models
```bash
cd ~/ai-automation/comfyui/ComfyUI/models/checkpoints
wget <model_url>
```

### List Installed Models
```bash
ls -lh ~/ai-automation/comfyui/ComfyUI/models/checkpoints/
```

### Remove Unused Models
```bash
rm ~/ai-automation/comfyui/ComfyUI/models/checkpoints/<model_name>
```

## 🔄 Updates

### Update ComfyUI
```bash
cd ~/ai-automation/comfyui/ComfyUI
git pull
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart comfyui
```

### Update N8N
```bash
cd ~/ai-automation/n8n
docker compose pull
docker compose up -d
```

### Update Custom Nodes
```bash
cd ~/ai-automation/comfyui/ComfyUI/custom_nodes
for dir in */; do
  cd "$dir"
  git pull
  cd ..
done
sudo systemctl restart comfyui
```

## 💾 Backup

### Backup N8N Data
```bash
tar -czf n8n_backup_$(date +%Y%m%d).tar.gz ~/ai-automation/n8n/n8n_data
```

### Backup Workflows
```bash
tar -czf workflows_backup_$(date +%Y%m%d).tar.gz ~/ai-automation/n8n/workflows
```

### Backup Custom Nodes
```bash
tar -czf custom_nodes_backup_$(date +%Y%m%d).tar.gz ~/ai-automation/comfyui/ComfyUI/custom_nodes
```

## 🔐 Security

### Change N8N Password
```bash
cd ~/ai-automation/n8n
nano docker-compose.yml
# Edit N8N_BASIC_AUTH_PASSWORD
docker compose restart
```

### Enable Firewall
```bash
sudo ufw enable
sudo ufw allow 5678  # N8N
sudo ufw allow 8188  # ComfyUI
sudo ufw allow 8189  # AudioCraft
```

## 📈 Performance Optimization

### Check GPU Temperature
```bash
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader
```

### Monitor GPU Memory
```bash
nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader
```

### Set GPU Power Limit (if needed)
```bash
sudo nvidia-smi -pl 300  # Set to 300W (adjust for your GPU)
```

## 🆘 Emergency Commands

### Stop All Services
```bash
sudo systemctl stop comfyui audiocraft
cd ~/ai-automation/n8n && docker compose down
```

### Kill All GPU Processes
```bash
sudo fuser -k /dev/nvidia*
```

### Free Up Memory
```bash
sudo sync
sudo sysctl -w vm.drop_caches=3
```

### Reboot System
```bash
sudo reboot
```

## 📞 Getting Help

1. Check logs first
2. Review troubleshooting section in setup guide
3. Search community forums
4. Ask in Discord/Reddit communities

## 🔗 Useful Links

- Setup Guide: [AI_AUTOMATION_SETUP_GUIDE.md](AI_AUTOMATION_SETUP_GUIDE.md)
- Example Workflows: [example_workflows.md](example_workflows.md)
- README: [README.md](README.md)

---

**Keep this reference handy for quick access to common commands!**