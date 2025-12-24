import requests
import json
import os
import random
import time
from PIL import Image
from io import BytesIO
import urllib.parse

# Configuration
API_KEY = "AIzaSyCK5bwqpT7IFxYS-XZJjyAe-W5qUc5DXXM"
FRAME_PATH = "assets/images/poster_frame.png"
OUTPUT_PATH = "pollinations_sample_output.png"
THEME = "Naruto"
STYLE = "Epic Battle"

def generate_sample():
    print("🚀 Starting Hybrid Generation Process...")

    # 1. Generate Prompt with Gemini 1.5 Flash
    print("🧠 Asking Gemini 1.5 Flash for a creative prompt...")
    text_gen_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}"
    
    prompt_text = f"anime poster of {THEME}, {STYLE} style, masterpiece, 8k, vibrant colors"
    
    try:
        payload = {
            "contents": [{
                "parts": [{"text": f'Write a short, descriptive image generation prompt for an anime poster featuring "{THEME}" in "{STYLE}" style. Focus on visual details. Output ONLY the prompt.'}]
            }]
        }
        
        response = requests.post(text_gen_url, json=payload, headers={'Content-Type': 'application/json'})
        
        if response.status_code == 200:
            data = response.json()
            candidates = data.get('candidates', [])
            if candidates:
                generated_text = candidates[0]['content']['parts'][0]['text']
                prompt_text = generated_text.strip()
                print(f"📝 Gemini Generated Prompt: {prompt_text}")
            else:
                print("⚠️ No candidates returned, using default prompt.")
        else:
            print(f"⚠️ Gemini Text Gen failed ({response.status_code}), using default prompt.")
            print(response.text)

    except Exception as e:
        print(f"⚠️ Gemini Error: {e}")

    # 2. Generate Image with Pollinations.ai
    print("🎨 Generating image via Pollinations.ai (Flux model)...")
    encoded_prompt = urllib.parse.quote(prompt_text)
    seed = random.randint(0, 1000000)
    # Using Flux model for high quality
    image_url = f"https://image.pollinations.ai/prompt/{encoded_prompt}?width=768&height=1024&seed={seed}&model=flux"
    
    print(f"🔗 Requesting: {image_url}")
    
    try:
        # Pollinations can take a few seconds
        start_time = time.time()
        img_response = requests.get(image_url, timeout=60)
        duration = time.time() - start_time
        
        if img_response.status_code != 200:
            print(f"❌ Pollinations Error: {img_response.status_code}")
            return

        print(f"✅ Image downloaded in {duration:.2f}s")
        anime_image = Image.open(BytesIO(img_response.content)).convert("RGBA")

    except Exception as e:
        print(f"❌ Image Generation Error: {e}")
        return

    # 3. Composite with Frame
    print(f"🖼️ Loading frame from {FRAME_PATH}...")
    if not os.path.exists(FRAME_PATH):
        print(f"❌ Frame file not found at {FRAME_PATH}")
        # Save raw image just in case
        anime_image.save("raw_anime_output.png")
        print("Saved raw image to raw_anime_output.png instead.")
        return
    
    try:
        frame_image = Image.open(FRAME_PATH).convert("RGBA")
        
        # Resize logic: 100% of frame (Full Bleed)
        target_width = frame_image.width
        target_height = frame_image.height
        
        print(f"📏 Resizing anime image to fit {target_width}x{target_height}...")
        # Use resize instead of thumbnail to force dimensions (maintainAspect: false)
        anime_image = anime_image.resize((target_width, target_height), Image.Resampling.LANCZOS)
        
        # Center
        x_offset = (frame_image.width - anime_image.width) // 2
        y_offset = (frame_image.height - anime_image.height) // 2
        
        # Paste
        final_poster = frame_image.copy()
        final_poster.paste(anime_image, (x_offset, y_offset))
        
        # Save
        final_poster.save(OUTPUT_PATH)
        print(f"✅ Success! Sample poster saved to: {os.path.abspath(OUTPUT_PATH)}")
        
    except Exception as e:
        print(f"❌ Composition Error: {e}")

if __name__ == "__main__":
    generate_sample()
