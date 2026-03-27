import os
import sys
import subprocess

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Pillow is not installed. Attempting to install...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image, ImageDraw, ImageFont

def create_placeholder(filename, size, color, text):
    img = Image.new('RGB', size, color=color)
    d = ImageDraw.Draw(img)
    # try loading default font
    try:
        font = ImageFont.load_default()
    except:
        font = None
    
    # Calculate text bounding box
    if font:
        # Pillow >= 8.0.0
        if hasattr(font, "getbbox"):
            bbox = font.getbbox(text)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
        else:
            text_width, text_height = d.textsize(text, font=font)
    else:
        text_width, text_height = (0, 0)
        
    position = ((size[0]-text_width)/2, (size[1]-text_height)/2)
    d.text(position, text, fill=(255, 255, 255), font=font)
    img.save(filename)
    print(f"Created {filename}")

if __name__ == "__main__":
    assets_dir = os.path.join(os.path.dirname(__file__), "assets")
    if not os.path.exists(assets_dir):
        os.makedirs(assets_dir)
        
    assets = [
        # Players (48x48)
        ("player1.png", (48, 48), "darkblue", "P1"),
        ("player2.png", (48, 48), "darkred", "P2"),
        # Elements (32x32)
        ("element_fire.png", (32, 32), "red", "Fire"),
        ("element_water.png", (32, 32), "blue", "Water"),
        ("element_ice.png", (32, 32), "cyan", "Ice"),
        # Tiles (64x64)
        ("tile_floor.png", (64, 64), "gray", "Floor"),
        ("tile_wall.png", (64, 64), "black", "Wall"),
        ("tile_river.png", (64, 64), "darkblue", "River"),
        ("tile_river_frozen.png", (64, 64), "teal", "IceRv"),
        ("tile_plant.png", (64, 64), "green", "Plant"),
        ("tile_plant_burned.png", (64, 64), "brown", "Ash"),
        # Other
        ("treasure.png", (64, 64), "gold", "WIN")
    ]
    
    for filename, size, color, text in assets:
        create_placeholder(os.path.join(assets_dir, filename), size, color, text)
        
    print("All required placeholder assets have been generated in the /assets directory!")
