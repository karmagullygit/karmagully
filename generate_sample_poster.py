import requests
import json
import base64
import os
from PIL import Image
from io import BytesIO

# Configuration
API_KEY = "AIzaSyCK5bwqpT7IFxYS-XZJjyAe-W5qUc5DXXM"
FRAME_PATH = "assets/images/poster_frame.png"
OUTPUT_PATH = "sample_poster_output.png"
PROMPT = "Epic anime character portrait, vibrant colors, high quality, detailed background, 4k"

def generate_and_composite():
    print("🚀 Starting Poster Generation Process...")

    # 1. Generate Image using Gemini 2.0 Flash Exp (Free Tier)
    print("🎨 Generating anime art with Gemini 2.0 Flash Exp...")
    # Note: Using generateContent endpoint which is often free for experimental models
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key={API_KEY}"
    
    payload = {
        "contents": [{
            "parts": [{"text": "Generate an image of " + PROMPT}]
        }]
    }

    try:
        response = requests.post(url, json=payload, headers={'Content-Type': 'application/json'})
        
        if response.status_code != 200:
            print(f"❌ API Error: {response.status_code} - {response.text}")
            return

        data = response.json()
        # Check for inline image data in the response
        try:
            parts = data['candidates'][0]['content']['parts']
            image_data = None
            for part in parts:
                if 'inlineData' in part:
                    image_data = part['inlineData']['data']
                    break
            
            if not image_data:
                print("❌ No image data found in response. The model might have returned text instead.")
                print(f"Response snippet: {str(data)[:200]}...")
                return

            anime_image_data = base64.b64decode(image_data)
            anime_image = Image.open(BytesIO(anime_image_data))
            print("✅ Anime image generated successfully.")
            
        except (KeyError, IndexError) as e:
            print(f"❌ Error parsing response: {e}")
            print(f"Full response: {data}")
            return

    except Exception as e:
        print(f"❌ Error during generation: {e}")
        return

    # 2. Load Frame
    print(f"🖼️ Loading frame from {FRAME_PATH}...")
    if not os.path.exists(FRAME_PATH):
        print(f"❌ Frame file not found at {FRAME_PATH}")
        return
    
    try:
        frame_image = Image.open(FRAME_PATH).convert("RGBA")
    except Exception as e:
        print(f"❌ Error loading frame: {e}")
        return

    # 3. Resize Anime Image
    # Logic matches Dart: 85% of frame size
    target_width = int(frame_image.width * 0.85)
    target_height = int(frame_image.height * 0.85)
    
    print(f"📏 Resizing anime image to fit {target_width}x{target_height}...")
    
    # Resize maintaining aspect ratio to fit within target box
    anime_image.thumbnail((target_width, target_height), Image.Resampling.LANCZOS)
    
    # 4. Composite
    print("✨ Compositing image...")
    # Calculate center position
    x_offset = (frame_image.width - anime_image.width) // 2
    y_offset = (frame_image.height - anime_image.height) // 2
    
    # Create a copy of frame to paste onto
    final_poster = frame_image.copy()
    final_poster.paste(anime_image, (x_offset, y_offset))

    # 5. Save
    final_poster.save(OUTPUT_PATH)
    print(f"✅ Success! Poster saved to: {os.path.abspath(OUTPUT_PATH)}")

if __name__ == "__main__":
    try:
        generate_and_composite()
    except ImportError:
        print("❌ Missing dependencies. Please run: pip install requests pillow")
