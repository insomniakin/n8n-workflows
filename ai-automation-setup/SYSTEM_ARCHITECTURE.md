# AI Automation System Architecture

## 🏗️ System Overview

This document provides a visual representation of how all components work together in your AI automation system.

## 📊 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                           │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   N8N Web    │  │  ComfyUI Web │  │   Browser    │          │
│  │  Interface   │  │  Interface   │  │   /cURL      │          │
│  │  :5678       │  │  :8188       │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                           │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    N8N Workflow Engine                    │  │
│  │  • Workflow automation                                    │  │
│  │  • API orchestration                                      │  │
│  │  • Scheduling & triggers                                  │  │
│  │  • Data transformation                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EXECUTION LAYER                             │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   ComfyUI    │  │  AudioCraft  │  │   External   │          │
│  │   Server     │  │  API Server  │  │   Services   │          │
│  │   :8188      │  │   :8189      │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┼─────────────┐
                ▼             ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AI MODELS LAYER                           │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │    Stable    │  │    Stable    │  │  AnimateDiff │          │
│  │  Diffusion   │  │    Video     │  │              │          │
│  │     XL       │  │  Diffusion   │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   MusicGen   │  │  Custom LoRA │  │    VAE       │          │
│  │              │  │    Models    │  │   Models     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      HARDWARE LAYER                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Intel i9 Processor                     │  │
│  │  • Workflow orchestration                                 │  │
│  │  • API handling                                           │  │
│  │  • System operations                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    NVIDIA RTX 3090                        │  │
│  │  • 24GB VRAM                                              │  │
│  │  • Primary GPU for AI inference                           │  │
│  │  • CUDA acceleration                                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    NVIDIA RTX 490                         │  │
│  │  • Secondary GPU (optional)                               │  │
│  │  • Parallel processing                                    │  │
│  │  • Load balancing                                         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Diagrams

### Image Generation Workflow

```
User Input (Text Prompt)
        │
        ▼
┌───────────────────┐
│   N8N Workflow    │
│   Receives Input  │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Format Request   │
│  Add Parameters   │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  HTTP POST to     │
│  ComfyUI API      │
│  :8188/prompt     │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│   ComfyUI         │
│   Processes       │
│   Request         │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Load SDXL Model  │
│  to GPU Memory    │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Generate Image   │
│  on RTX 3090      │
│  (10-30 seconds)  │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Save to Output   │
│  Directory        │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Return Image     │
│  URL/Path to N8N  │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  N8N Downloads    │
│  or Processes     │
│  Image            │
└───────────────────┘
        │
        ▼
    Final Output
```

### Video Generation Workflow

```
User Input (Image + Prompt)
        │
        ▼
┌───────────────────┐
│   N8N Workflow    │
│   Receives Input  │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Upload Image to  │
│  ComfyUI          │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  HTTP POST to     │
│  ComfyUI with     │
│  SVD Workflow     │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Load SVD Model   │
│  to GPU Memory    │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Generate Video   │
│  Frames on GPU    │
│  (2-5 minutes)    │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Compile Frames   │
│  into Video       │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Save MP4 File    │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Return Video     │
│  Path to N8N      │
└───────────────────┘
        │
        ▼
    Final Video Output
```

### Music Generation Workflow

```
User Input (Text Description)
        │
        ▼
┌───────────────────┐
│   N8N Workflow    │
│   Receives Input  │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  HTTP POST to     │
│  AudioCraft API   │
│  :8189/generate   │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  AudioCraft       │
│  Processes        │
│  Request          │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Load MusicGen    │
│  Model to GPU     │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Generate Audio   │
│  on GPU           │
│  (30-60 seconds)  │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Save WAV File    │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│  Return Audio     │
│  File to N8N      │
└───────────────────┘
        │
        ▼
    Final Audio Output
```

## 🔌 Component Interactions

### N8N ↔ ComfyUI

```
N8N                          ComfyUI
 │                              │
 │──── POST /prompt ───────────>│
 │     (JSON workflow)          │
 │                              │
 │<──── 200 OK ─────────────────│
 │     (prompt_id)              │
 │                              │
 │──── GET /history/{id} ───────>│
 │     (check status)           │
 │                              │
 │<──── 200 OK ─────────────────│
 │     (status: executing)      │
 │                              │
 │──── GET /history/{id} ───────>│
 │     (check again)            │
 │                              │
 │<──── 200 OK ─────────────────│
 │     (status: complete)       │
 │                              │
 │──── GET /view ───────────────>│
 │     (download image)         │
 │                              │
 │<──── Image Data ─────────────│
 │                              │
```

### N8N ↔ AudioCraft

```
N8N                          AudioCraft
 │                              │
 │──── POST /generate ──────────>│
 │     {                        │
 │       "prompt": "...",       │
 │       "duration": 30         │
 │     }                        │
 │                              │
 │<──── Audio File ─────────────│
 │     (WAV format)             │
 │                              │
```

## 💾 Storage Architecture

```
~/ai-automation/
│
├── n8n/
│   ├── n8n_data/                    # N8N persistent data
│   │   ├── database.sqlite          # Workflow database
│   │   └── .n8n/                    # Configuration
│   └── workflows/                   # Exported workflows
│
├── comfyui/
│   └── ComfyUI/
│       ├── models/                  # AI Models (~50 GB)
│       │   ├── checkpoints/         # Main models
│       │   ├── vae/                 # VAE models
│       │   ├── loras/               # LoRA models
│       │   └── controlnet/          # ControlNet models
│       ├── output/                  # Generated content
│       │   ├── images/              # Generated images
│       │   └── videos/              # Generated videos
│       └── custom_nodes/            # Extensions
│
└── audiocraft/
    └── audiocraft/
        └── /tmp/audiocraft_outputs/ # Generated audio
```

## 🔐 Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Localhost (127.0.0.1)                   │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Port 5678  │  │   Port 8188  │  │   Port 8189  │      │
│  │     N8N      │  │   ComfyUI    │  │  AudioCraft  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │            Docker Network: ai-automation           │     │
│  │                                                     │     │
│  │  ┌──────────────────────────────────────────┐     │     │
│  │  │         N8N Container                    │     │     │
│  │  │  • Internal: 5678                        │     │     │
│  │  │  • External: 5678                        │     │     │
│  │  └──────────────────────────────────────────┘     │     │
│  └────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Processing Pipeline

### Complete Content Creation Pipeline

```
1. Input Stage
   ├── Text Prompt
   ├── Reference Images
   └── Audio Description

2. Processing Stage
   ├── Image Generation (ComfyUI + SDXL)
   │   └── 10-30 seconds on RTX 3090
   │
   ├── Image Enhancement (Optional)
   │   ├── Upscaling
   │   └── Style Transfer
   │
   ├── Video Generation (ComfyUI + SVD)
   │   └── 2-5 minutes on RTX 3090
   │
   └── Audio Generation (AudioCraft)
       └── 30-60 seconds on RTX 3090

3. Post-Processing Stage
   ├── Video + Audio Merging (FFmpeg)
   ├── Format Conversion
   └── Quality Enhancement

4. Output Stage
   ├── Local Storage
   ├── Cloud Upload (Optional)
   └── Social Media Posting (Optional)
```

## 🔄 Resource Management

### GPU Memory Allocation

```
RTX 3090 (24GB VRAM)
├── System Reserved: ~2GB
├── SDXL Model: ~6GB
├── SVD Model: ~10GB
├── MusicGen Model: ~3GB
└── Working Memory: ~3GB

Strategies:
• Load models on-demand
• Unload unused models
• Use model offloading
• Enable attention optimization
```

### CPU Usage

```
Intel i9 Processor
├── N8N Workflow Engine: 1-2 cores
├── ComfyUI Server: 2-4 cores
├── AudioCraft Server: 2-4 cores
├── System Operations: 2-4 cores
└── Available for Processing: Remaining cores
```

## 🚀 Scaling Considerations

### Horizontal Scaling (Multiple Machines)

```
Machine 1 (Orchestration)
└── N8N Workflow Engine

Machine 2 (Image Generation)
└── ComfyUI + SDXL

Machine 3 (Video Generation)
└── ComfyUI + SVD

Machine 4 (Audio Generation)
└── AudioCraft
```

### Vertical Scaling (Single Machine)

```
Current Setup
├── Single RTX 3090
└── All services on one machine

Upgraded Setup
├── RTX 3090 (Primary - Images)
├── RTX 490 (Secondary - Videos)
└── Distributed processing
```

## 📊 Performance Metrics

### Typical Generation Times

| Task | Resolution/Duration | Time | GPU Usage |
|------|-------------------|------|-----------|
| Image (SDXL) | 1024x1024 | 10-30s | 100% |
| Video (SVD) | 4 seconds | 2-5 min | 100% |
| Music | 30 seconds | 30-60s | 100% |
| Batch (10 images) | 1024x1024 | 2-5 min | 100% |

### Resource Requirements

| Component | RAM | VRAM | Disk |
|-----------|-----|------|------|
| N8N | 512MB | 0 | 1GB |
| ComfyUI | 4GB | 0 | 2GB |
| SDXL Model | 8GB | 6GB | 7GB |
| SVD Model | 12GB | 10GB | 10GB |
| AudioCraft | 4GB | 3GB | 2GB |

## 🔍 Monitoring Points

```
System Health Monitoring
├── GPU Temperature
├── GPU Memory Usage
├── CPU Usage
├── RAM Usage
├── Disk Space
├── Network Traffic
└── Service Status

Application Monitoring
├── N8N Workflow Execution
├── ComfyUI Queue Length
├── AudioCraft API Response Time
├── Generation Success Rate
└── Error Logs
```

## 🎓 Learning Path

```
Beginner
├── Understand system architecture
├── Learn basic N8N workflows
├── Generate simple images
└── Create basic automations

Intermediate
├── Create complex workflows
├── Optimize GPU usage
├── Batch processing
└── Custom model integration

Advanced
├── Multi-GPU setup
├── Custom node development
├── API integration
├── Production deployment
└── Performance optimization
```

---

**This architecture is designed to be modular, scalable, and optimized for your hardware!**