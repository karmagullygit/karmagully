from PIL import Image

FRAME_PATH = "assets/images/poster_frame.png"

def is_white(pixel, threshold=240):
    # Check if pixel is close to white
    return pixel[0] > threshold and pixel[1] > threshold and pixel[2] > threshold

img = Image.open(FRAME_PATH).convert("RGB")
width, height = img.size
pixels = img.load()

print(f"Image Size: {width}x{height}")

# Scan horizontal middle line
mid_y = height // 2
left_x = 0
right_x = width - 1

# Find left edge of white area
for x in range(width):
    if is_white(pixels[x, mid_y]):
        left_x = x
        break

# Find right edge of white area
for x in range(width - 1, -1, -1):
    if is_white(pixels[x, mid_y]):
        right_x = x
        break

# Scan vertical middle line
mid_x = width // 2
top_y = 0
bottom_y = height - 1

# Find top edge of white area
for y in range(height):
    if is_white(pixels[mid_x, y]):
        top_y = y
        break

# Find bottom edge of white area
for y in range(height - 1, -1, -1):
    if is_white(pixels[mid_x, y]):
        bottom_y = y
        break

print(f"Detected White Area:")
print(f"Left: {left_x}")
print(f"Right: {right_x}")
print(f"Top: {top_y}")
print(f"Bottom: {bottom_y}")
print(f"Width: {right_x - left_x}")
print(f"Height: {bottom_y - top_y}")

# Check center pixel to be sure
center_pixel = pixels[mid_x, mid_y]
print(f"Center Pixel Color: {center_pixel}")
