# Example N8N Workflows for AI Automation

This document provides example workflows you can create in N8N to automate AI content generation.

## Workflow 1: Text-to-Image Generation

### Description
Generate images from text prompts using Stable Diffusion XL.

### N8N Workflow Structure
```
[Webhook/Manual Trigger] 
    → [Set Variables] 
    → [HTTP Request to ComfyUI] 
    → [Wait for Completion] 
    → [Download Image] 
    → [Save to Storage]
```

### ComfyUI API Payload Example
```json
{
  "prompt": {
    "3": {
      "inputs": {
        "seed": 42,
        "steps": 20,
        "cfg": 8,
        "sampler_name": "euler",
        "scheduler": "normal",
        "denoise": 1,
        "model": ["4", 0],
        "positive": ["6", 0],
        "negative": ["7", 0],
        "latent_image": ["5", 0]
      },
      "class_type": "KSampler"
    },
    "4": {
      "inputs": {
        "ckpt_name": "sd_xl_base_1.0.safetensors"
      },
      "class_type": "CheckpointLoaderSimple"
    },
    "5": {
      "inputs": {
        "width": 1024,
        "height": 1024,
        "batch_size": 1
      },
      "class_type": "EmptyLatentImage"
    },
    "6": {
      "inputs": {
        "text": "{{$json.prompt}}",
        "clip": ["4", 1]
      },
      "class_type": "CLIPTextEncode"
    },
    "7": {
      "inputs": {
        "text": "ugly, blurry, low quality, distorted",
        "clip": ["4", 1]
      },
      "class_type": "CLIPTextEncode"
    },
    "8": {
      "inputs": {
        "samples": ["3", 0],
        "vae": ["4", 2]
      },
      "class_type": "VAEDecode"
    },
    "9": {
      "inputs": {
        "filename_prefix": "ComfyUI",
        "images": ["8", 0]
      },
      "class_type": "SaveImage"
    }
  }
}
```

### N8N HTTP Request Node Configuration
- **Method**: POST
- **URL**: `http://localhost:8188/prompt`
- **Headers**: 
  - `Content-Type`: `application/json`
- **Body**: Use the JSON above with `{{$json.prompt}}` for dynamic prompts

---

## Workflow 2: Image-to-Video Generation

### Description
Convert static images into short videos using Stable Video Diffusion.

### N8N Workflow Structure
```
[Webhook/Manual Trigger] 
    → [Read Image File] 
    → [HTTP Request to ComfyUI] 
    → [Poll for Status] 
    → [Download Video] 
    → [Save to Storage]
```

### Steps
1. **Upload Image**: Provide image URL or file path
2. **Call ComfyUI**: Send image to SVD model
3. **Wait**: Poll for completion (videos take 2-5 minutes)
4. **Download**: Get generated video file
5. **Store**: Save to desired location

---

## Workflow 3: Text-to-Music Generation

### Description
Generate music from text descriptions using AudioCraft.

### N8N Workflow Structure
```
[Webhook/Manual Trigger] 
    → [Set Variables] 
    → [HTTP Request to AudioCraft] 
    → [Download Audio] 
    → [Save to Storage]
```

### N8N HTTP Request Node Configuration
- **Method**: POST
- **URL**: `http://localhost:8189/generate`
- **Headers**: 
  - `Content-Type`: `application/json`
- **Body**:
```json
{
  "prompt": "{{$json.music_prompt}}",
  "duration": 30
}
```

### Example Prompts
- "upbeat electronic dance music with heavy bass"
- "calm piano melody for meditation"
- "epic orchestral soundtrack with drums"
- "lo-fi hip hop beats for studying"
- "rock guitar solo with distortion"

---

## Workflow 4: Batch Image Generation

### Description
Generate multiple images from a list of prompts.

### N8N Workflow Structure
```
[Schedule/Webhook] 
    → [Read Prompts from File/Database] 
    → [Split in Batches] 
    → [Loop: Generate Each Image] 
    → [Collect Results] 
    → [Send Notification]
```

### Use Cases
- Generate product images for e-commerce
- Create social media content
- Generate variations of a concept
- Batch process design ideas

---

## Workflow 5: Complete Content Pipeline

### Description
End-to-end content creation: Generate image, convert to video, add music.

### N8N Workflow Structure
```
[Trigger] 
    → [Generate Image (ComfyUI)] 
    → [Image-to-Video (ComfyUI)] 
    → [Generate Music (AudioCraft)] 
    → [Combine Video + Audio (FFmpeg)] 
    → [Upload to Storage] 
    → [Send Notification]
```

### Steps
1. **Generate Image**: Create base image from text prompt
2. **Animate Image**: Convert to video using SVD
3. **Generate Music**: Create matching soundtrack
4. **Combine**: Merge video and audio using FFmpeg
5. **Deliver**: Upload to cloud storage or social media

### FFmpeg Command (in Execute Command node)
```bash
ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac -shortest output.mp4
```

---

## Workflow 6: AI Art Gallery Automation

### Description
Automatically generate and organize AI art collections.

### N8N Workflow Structure
```
[Schedule: Daily] 
    → [Generate Theme/Prompt] 
    → [Generate Multiple Images] 
    → [Upscale Images] 
    → [Add Watermark] 
    → [Organize in Folders] 
    → [Update Gallery Website]
```

---

## Workflow 7: Social Media Content Creator

### Description
Generate and post AI content to social media platforms.

### N8N Workflow Structure
```
[Schedule: Multiple times daily] 
    → [Generate Image] 
    → [Generate Caption (GPT)] 
    → [Resize for Platform] 
    → [Post to Social Media] 
    → [Track Engagement]
```

### Supported Platforms
- Twitter/X
- Instagram
- Facebook
- LinkedIn
- Pinterest

---

## Workflow 8: Video Thumbnail Generator

### Description
Automatically create eye-catching thumbnails for videos.

### N8N Workflow Structure
```
[Webhook: New Video Upload] 
    → [Extract Video Frame] 
    → [Enhance with AI] 
    → [Add Text Overlay] 
    → [Generate Variations] 
    → [Save Thumbnails]
```

---

## Workflow 9: Product Visualization

### Description
Generate product images in different settings and styles.

### N8N Workflow Structure
```
[Manual Trigger] 
    → [Input: Product Description] 
    → [Generate Multiple Angles] 
    → [Generate Different Backgrounds] 
    → [Generate Lifestyle Shots] 
    → [Organize by Category]
```

### Example Prompts
- "professional product photo, white background, studio lighting"
- "product in modern living room, natural lighting"
- "product in outdoor setting, golden hour"
- "product close-up, macro photography"

---

## Workflow 10: Music Video Creator

### Description
Create complete music videos with AI-generated visuals.

### N8N Workflow Structure
```
[Manual Trigger] 
    → [Generate Music] 
    → [Analyze Music (tempo, mood)] 
    → [Generate Scene Prompts] 
    → [Generate Images for Each Scene] 
    → [Create Video Transitions] 
    → [Sync with Music] 
    → [Export Final Video]
```

---

## Advanced Tips

### 1. Error Handling
Always add error handling nodes:
- **If Node**: Check for errors
- **Stop and Error**: Handle failures gracefully
- **Retry**: Automatically retry failed requests

### 2. Rate Limiting
Implement delays between requests:
- **Wait Node**: Add delays (1-5 seconds)
- **Queue**: Process requests sequentially
- **Batch Processing**: Group requests

### 3. Monitoring
Track your workflows:
- **Set Variables**: Log important data
- **HTTP Request**: Send to monitoring service
- **Email**: Get notifications on completion/errors

### 4. Optimization
Improve performance:
- **Cache Results**: Store frequently used outputs
- **Parallel Processing**: Run independent tasks simultaneously
- **Conditional Logic**: Skip unnecessary steps

### 5. Quality Control
Ensure output quality:
- **Image Analysis**: Check generated images
- **Retry Logic**: Regenerate if quality is low
- **Human Review**: Add approval steps for critical content

---

## Testing Your Workflows

### 1. Start Simple
Begin with basic workflows and gradually add complexity.

### 2. Test Each Node
Execute nodes individually to verify they work correctly.

### 3. Use Test Data
Create sample inputs for testing without consuming resources.

### 4. Monitor Resources
Watch GPU usage, memory, and disk space during execution.

### 5. Log Everything
Enable detailed logging to troubleshoot issues.

---

## Common Issues and Solutions

### Issue: ComfyUI Request Timeout
**Solution**: Increase timeout in HTTP Request node to 300+ seconds

### Issue: Out of GPU Memory
**Solution**: 
- Reduce image resolution
- Lower batch size
- Enable model offloading

### Issue: Slow Generation
**Solution**:
- Use faster samplers (euler, dpm++)
- Reduce steps (15-20 is usually enough)
- Use smaller models

### Issue: Poor Quality Output
**Solution**:
- Improve prompts (be specific and detailed)
- Increase steps (25-30)
- Use better models
- Add negative prompts

---

## Resources

### ComfyUI Workflows
- https://comfyworkflows.com/
- https://openart.ai/workflows

### Prompt Engineering
- https://prompthero.com/
- https://lexica.art/

### N8N Community
- https://community.n8n.io/
- https://n8n.io/workflows/

### Model Resources
- https://civitai.com/
- https://huggingface.co/models

---

## Next Steps

1. **Import Example Workflows**: Download pre-made workflows from N8N community
2. **Customize Prompts**: Adapt examples to your specific needs
3. **Create Templates**: Save successful workflows as templates
4. **Automate Everything**: Connect workflows to external triggers
5. **Share Your Work**: Contribute workflows back to the community

Happy Automating! 🚀