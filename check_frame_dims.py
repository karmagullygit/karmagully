from PIL import Image
import os

FRAME_PATH = "assets/images/poster_frame.png"

if os.path.exists(FRAME_PATH):
    img = Image.open(FRAME_PATH)
    print(f"Frame Dimensions: {img.width}x{img.height}")
    print(f"Aspect Ratio: {img.width/img.height:.2f}")
else:
    print("Frame not found.")
