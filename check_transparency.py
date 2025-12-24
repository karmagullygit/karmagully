from PIL import Image

FRAME_PATH = "assets/images/poster_frame.png"

img = Image.open(FRAME_PATH).convert("RGBA")
extrema = img.getextrema()
alpha_extrema = extrema[3]

print(f"Alpha Channel Extrema: {alpha_extrema}")

if alpha_extrema[0] < 255:
    print("✅ The frame has transparent pixels.")
    # Find the bounding box of the transparent area
    # We invert the alpha channel to find the "hole"
    alpha = img.split()[3]
    # Find the bounding box of non-transparent pixels (the frame)
    bbox = alpha.getbbox()
    print(f"Frame BBox: {bbox}")
    
    # To find the hole, we can look for fully transparent pixels
    # This is a bit more complex, but let's just see if it has transparency first.
else:
    print("❌ The frame is fully opaque.")
