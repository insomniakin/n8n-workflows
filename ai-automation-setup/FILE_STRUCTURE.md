# AI Automation System - File Structure

This document describes all the files in your AI automation system setup.

## 📁 Directory Structure

```
workspace/
├── Installation Scripts
│   ├── install_all.sh                    # Complete automated installation
│   ├── install_prerequisites.sh          # System prerequisites (NVIDIA, CUDA, Docker)
│   ├── install_n8n.sh                    # N8N workflow automation
│   ├── install_comfyui.sh                # ComfyUI for image/video generation
│   ├── download_models.sh                # Download AI models
│   └── install_audiocraft.sh             # AudioCraft for music generation
│
├── Documentation
│   ├── README.md                         # Main documentation and quick start
│   ├── AI_AUTOMATION_SETUP_GUIDE.md      # Complete setup guide (detailed)
│   ├── example_workflows.md              # N8N workflow examples
│   ├── QUICK_REFERENCE.md                # Quick command reference
│   ├── FILE_STRUCTURE.md                 # This file
│   └── todo.md                           # Project task list
│
└── User Uploaded Files
    ├── Self-hosted AI Automation.pdf
    ├── Self-hosted AI Automation.html
    ├── Branch · Self-hosted AI Automation.html
    ├── Branch · ddSelf-hosted AI Automation.html
    └── 52.html
```

## 📄 File Descriptions

### Installation Scripts

#### `install_all.sh` ⭐ START HERE
**Purpose**: Complete automated installation of all components  
**What it does**:
- Installs system prerequisites
- Sets up N8N
- Installs ComfyUI
- Downloads AI models
- Installs AudioCraft
- Configures all services

**Usage**:
```bash
chmod +x install_all.sh
./install_all.sh
```

**Time**: 1-2 hours  
**Disk Space**: ~50 GB

---

#### `install_prerequisites.sh`
**Purpose**: Install system-level dependencies  
**What it installs**:
- NVIDIA drivers
- CUDA toolkit
- Docker and Docker Compose
- NVIDIA Container Toolkit
- Essential system tools

**Usage**:
```bash
chmod +x install_prerequisites.sh
./install_prerequisites.sh
```

**Note**: May require system reboot after installation

---

#### `install_n8n.sh`
**Purpose**: Install N8N workflow automation platform  
**What it does**:
- Creates directory structure
- Sets up Docker Compose configuration
- Starts N8N container
- Configures basic authentication

**Access**: http://localhost:5678  
**Default Login**: admin / changeme123

---

#### `install_comfyui.sh`
**Purpose**: Install ComfyUI for AI image/video generation  
**What it does**:
- Clones ComfyUI repository
- Creates Python virtual environment
- Installs PyTorch with CUDA support
- Sets up systemd service
- Creates startup scripts

**Access**: http://localhost:8188

---

#### `download_models.sh`
**Purpose**: Download essential AI models  
**What it downloads**:
- Stable Diffusion XL Base (6.9 GB)
- SDXL VAE (335 MB)
- Stable Video Diffusion (9.8 GB)
- AnimateDiff Motion Module (1.7 GB)
- ComfyUI Manager
- Video Helper Suite
- AnimateDiff Evolved

**Total Size**: ~20-30 GB

---

#### `install_audiocraft.sh`
**Purpose**: Install AudioCraft for music generation  
**What it does**:
- Clones AudioCraft repository
- Creates Python virtual environment
- Installs dependencies
- Sets up Flask API server
- Creates systemd service

**Access**: http://localhost:8189 (API)

---

### Documentation Files

#### `README.md` ⭐ READ FIRST
**Purpose**: Main documentation and quick start guide  
**Contents**:
- System overview
- Quick start instructions
- Usage examples
- Service management
- Common use cases
- Troubleshooting
- Community resources

**Best for**: Getting started and understanding the system

---

#### `AI_AUTOMATION_SETUP_GUIDE.md`
**Purpose**: Complete detailed setup guide  
**Contents**:
- System architecture
- Step-by-step installation instructions
- Configuration details
- GPU optimization
- Advanced configuration
- Performance tuning
- Maintenance procedures

**Best for**: Detailed technical reference and troubleshooting

---

#### `example_workflows.md`
**Purpose**: N8N workflow examples and templates  
**Contents**:
- 10+ example workflows
- Text-to-image generation
- Image-to-video conversion
- Music generation
- Batch processing
- Complete content pipelines
- Social media automation
- Tips and best practices

**Best for**: Learning how to create automated workflows

---

#### `QUICK_REFERENCE.md`
**Purpose**: Quick command reference  
**Contents**:
- Common commands
- Service management
- Monitoring commands
- Troubleshooting quick fixes
- Emergency commands
- Useful links

**Best for**: Day-to-day operations and quick lookups

---

#### `FILE_STRUCTURE.md`
**Purpose**: This file - describes all files in the system  
**Contents**:
- Directory structure
- File descriptions
- Usage instructions
- Recommended reading order

---

#### `todo.md`
**Purpose**: Project task list and progress tracking  
**Contents**:
- Installation tasks
- Configuration tasks
- Documentation tasks
- Testing tasks

**Status**: All tasks completed ✅

---

## 🚀 Getting Started - Recommended Order

### For Complete Beginners:
1. **Read**: `README.md` - Understand what the system does
2. **Run**: `install_all.sh` - Install everything automatically
3. **Read**: `QUICK_REFERENCE.md` - Learn basic commands
4. **Explore**: `example_workflows.md` - Try example workflows
5. **Reference**: `AI_AUTOMATION_SETUP_GUIDE.md` - When you need details

### For Experienced Users:
1. **Skim**: `README.md` - Quick overview
2. **Run**: Individual installation scripts as needed
3. **Reference**: `QUICK_REFERENCE.md` - For commands
4. **Customize**: `example_workflows.md` - Adapt to your needs
5. **Optimize**: `AI_AUTOMATION_SETUP_GUIDE.md` - Advanced configuration

### For Troubleshooting:
1. **Check**: `QUICK_REFERENCE.md` - Quick fixes section
2. **Review**: `AI_AUTOMATION_SETUP_GUIDE.md` - Part 11: Troubleshooting
3. **Search**: Service logs using commands from quick reference
4. **Ask**: Community forums (links in README)

---

## 📊 File Sizes

| File | Size | Type |
|------|------|------|
| install_all.sh | ~2 KB | Script |
| install_prerequisites.sh | ~4 KB | Script |
| install_n8n.sh | ~2 KB | Script |
| install_comfyui.sh | ~4 KB | Script |
| download_models.sh | ~6 KB | Script |
| install_audiocraft.sh | ~5 KB | Script |
| README.md | ~15 KB | Documentation |
| AI_AUTOMATION_SETUP_GUIDE.md | ~45 KB | Documentation |
| example_workflows.md | ~20 KB | Documentation |
| QUICK_REFERENCE.md | ~10 KB | Documentation |
| FILE_STRUCTURE.md | ~8 KB | Documentation |

**Total Documentation**: ~100 KB  
**Total Scripts**: ~25 KB

---

## 🔄 Update Frequency

| File | Update Frequency | Reason |
|------|-----------------|---------|
| Installation Scripts | Rarely | Only when installation process changes |
| README.md | Occasionally | New features or major changes |
| Setup Guide | Occasionally | New features or troubleshooting tips |
| Example Workflows | Regularly | New workflow ideas and improvements |
| Quick Reference | Occasionally | New commands or shortcuts |

---

## 💡 Tips

1. **Keep scripts executable**: Run `chmod +x *.sh` if needed
2. **Bookmark Quick Reference**: Most useful for daily operations
3. **Update documentation**: Add your own notes and discoveries
4. **Share workflows**: Contribute back to the community
5. **Backup regularly**: Especially N8N workflows and custom nodes

---

## 🆘 If You Get Lost

1. Start with `README.md`
2. Run `install_all.sh` for automated setup
3. Use `QUICK_REFERENCE.md` for common tasks
4. Check `AI_AUTOMATION_SETUP_GUIDE.md` for detailed help
5. Try `example_workflows.md` for inspiration

---

## 📞 Need More Help?

- Check the troubleshooting sections in documentation
- Review service logs using commands from Quick Reference
- Search community forums (links in README)
- Ask in Discord/Reddit communities

---

**Remember**: All documentation is interconnected. Use the file that best matches your current need!