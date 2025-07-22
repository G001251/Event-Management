import io
import base64
import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from diffusers import StableDiffusionPipeline
import torch

# Get Hugging Face token from environment variable
HF_TOKEN = os.getenv("HF_TOKEN")

# Use SD 1.5 instead of SDXL for better memory efficiency
try:
    pipe = StableDiffusionPipeline.from_pretrained(
        "runwayml/stable-diffusion-v1-5",
        torch_dtype=torch.float16,
        use_safetensors=True,
        token=HF_TOKEN
    )

    # Critical memory optimizations
    pipe.enable_attention_slicing()      # Process attention in smaller chunks
    pipe.enable_model_cpu_offload()      # Offload to CPU when not in use
    
    # Optional: Enable VAE slicing for even more memory savings
    # pipe.enable_vae_slicing()
    
    # Only move to GPU if available
    if torch.cuda.is_available():
        print("CUDA available - using GPU acceleration")
        pipe = pipe.to("cuda")
    else:
        print("CUDA not available - using CPU (will be slower)")
        pipe = pipe.to("cpu")
        
    print("Pipeline loaded successfully!")
    
except Exception as e:
    print(f"Error loading pipeline: {e}")
    pipe = None

app = FastAPI(title="EventVista Image Generator")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PromptRequest(BaseModel):
    prompt: str

@app.get("/")
async def root():
    return {"status": "EventVista Image Generator is running", "model": "stable-diffusion-v1-5"}

@app.post("/generate")
async def generate_image(request: PromptRequest):
    if pipe is None:
        raise HTTPException(status_code=500, detail="Model not loaded properly")
    
    try:
        print(f"Generating image for prompt: {request.prompt}")
        
        # Generate image with optimized settings
        with torch.inference_mode():
            image = pipe(
                request.prompt,
                num_inference_steps=30,  # Good balance of quality vs speed
                guidance_scale=7.5,      # Standard guidance scale
                height=512,              # Standard resolution for SD 1.5
                width=512,
                negative_prompt="blurry, low quality, distorted, ugly, bad anatomy"
            ).images[0]
        
        # Convert to base64
        buffer = io.BytesIO()
        image.save(buffer, format='PNG', quality=95)
        image_base64 = base64.b64encode(buffer.getvalue()).decode()
        
        print("Image generated successfully!")
        return {"image": image_base64}
        
    except torch.cuda.OutOfMemoryError:
        # Clear GPU cache and try again
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        raise HTTPException(status_code=500, detail="GPU out of memory. Try reducing the image size or close other applications.")
    
    except Exception as e:
        print(f"Generation error: {e}")
        # Clear GPU cache on any error
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        raise HTTPException(status_code=500, detail=f"Image generation failed: {str(e)}")

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "cuda_available": torch.cuda.is_available(),
        "model_loaded": pipe is not None
    }
