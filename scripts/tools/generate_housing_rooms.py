"""
Script to build and process all 24 isometric room templates for 'The Housing Update'.
Produces:
1. 100% transparent backgrounds outside the isometric cutaway walls and floor (no white canvas, no exterior clutter).
2. Authentic 16-bit pixel art styling matching the character avatars (512x512 quantized grid upscaled with Nearest Neighbor to 2048x2048).
3. Thematic architectural color grading and mood lighting for all 24 property rooms (zero 2D photo pastes).
4. Optimized .import files for Godot lossy WebP compression.
"""

import os
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance

BRAIN_DIR = r"C:\Users\ACER PREDATOR\.gemini\antigravity\brain\9b9cf3a4-7eb3-4ba0-b76b-7dbeeb740e47"
ROOMS_DIR = r"assets\isometric\rooms"

os.makedirs(ROOMS_DIR, exist_ok=True)

# 10 base AI generated rooms mapping
GENERATED_ROOMS = {
    "room_capsule": os.path.join(BRAIN_DIR, "room_capsule_1791645229193.jpg"),
    "room_tenement": os.path.join(BRAIN_DIR, "room_tenement_1791645243340.jpg"),
    "room_studio": os.path.join(BRAIN_DIR, "room_studio_1791645258810.jpg"),
    "room_condo": os.path.join(BRAIN_DIR, "room_condo_1791645273676.jpg"),
    "room_cottage": os.path.join(BRAIN_DIR, "room_cottage_1791645290299.jpg"),
    "room_suburban_split": os.path.join(BRAIN_DIR, "room_suburban_split_1791645306577.jpg"),
    "room_townhouse": os.path.join(BRAIN_DIR, "room_townhouse_1791645323986.jpg"),
    "room_eco_timber": os.path.join(BRAIN_DIR, "room_eco_timber_1791645340532.jpg"),
    "room_house": os.path.join(BRAIN_DIR, "room_house_1791645355974.jpg"),
    "room_cabin": os.path.join(BRAIN_DIR, "room_cabin_1791645376132.jpg"),
}

# Exact diorama cutaway boundary polygons in 1024x1024 space
BASE_POLYGONS = {
    "room_capsule": [(512, 44), (952, 290), (952, 696), (512, 951), (70, 696), (70, 290)],
    "room_tenement": [(511, 47), (926, 260), (926, 767), (511, 982), (98, 767), (98, 260)],
    "room_studio": [(511, 41), (964, 230), (964, 796), (511, 982), (59, 796), (59, 230)],
    "room_condo": [(511, 98), (939, 320), (939, 680), (507, 936), (85, 680), (85, 320)],
    "room_cottage": [(512, 45), (934, 280), (934, 735), (512, 990), (88, 735), (88, 280)],
    "room_suburban_split": [(510, 45), (977, 301), (977, 705), (510, 970), (46, 705), (46, 301)],
    "room_townhouse": [(511, 72), (917, 280), (917, 760), (512, 974), (106, 760), (106, 280)],
    "room_eco_timber": [(511, 74), (942, 303), (942, 748), (500, 965), (81, 748), (81, 303)],
    "room_house": [(500, 95), (960, 335), (960, 670), (500, 940), (42, 670), (42, 335)],
    "room_cabin": [(626, 23), (954, 385), (932, 410), (932, 745), (511, 981), (91, 745), (91, 410), (71, 380), (250, 195)],
}

# Remaining 14 property room specifications with architectural lighting and color grading
SYNTHESIS_SPECS = [
    {
        "id": "room_historic_brownstone",
        "base": "room_townhouse",
        "r": 1.15, "g": 0.90, "b": 0.85, # Rich Victorian mahogany & crimson
        "bright": 0.96, "contrast": 1.10
    },
    {
        "id": "room_modern_villa",
        "base": "room_condo",
        "r": 1.02, "g": 1.05, "b": 1.10, # Clean minimalist white & pool cyan
        "bright": 1.12, "contrast": 1.05
    },
    {
        "id": "room_alpine_chalet",
        "base": "room_cabin",
        "r": 0.96, "g": 1.00, "b": 1.14, # Alpine snow & roaring hearth
        "bright": 1.02, "contrast": 1.08
    },
    {
        "id": "room_ranch",
        "base": "room_cabin",
        "r": 1.18, "g": 1.05, "b": 0.82, # Golden sunset oak & pasture hills
        "bright": 1.04, "contrast": 1.06
    },
    {
        "id": "room_desert_estate",
        "base": "room_suburban_split",
        "r": 1.12, "g": 1.02, "b": 0.92, # Desert stacked stone & pool palms
        "bright": 1.05, "contrast": 1.05
    },
    {
        "id": "room_beachfront",
        "base": "room_eco_timber",
        "r": 1.04, "g": 1.08, "b": 1.16, # Sun-bleached shiplap & ocean breeze
        "bright": 1.14, "contrast": 1.04
    },
    {
        "id": "room_harbor_duplex",
        "base": "room_condo",
        "r": 0.94, "g": 1.02, "b": 1.18, # Marina nautical blue & teak deck
        "bright": 1.05, "contrast": 1.06
    },
    {
        "id": "room_penthouse",
        "base": "room_condo",
        "r": 1.08, "g": 1.04, "b": 1.00, # Calacatta marble gold & high-rise night skyline
        "bright": 1.04, "contrast": 1.12
    },
    {
        "id": "room_cyber_mansion",
        "base": "room_condo",
        "r": 0.82, "g": 0.94, "b": 1.25, # Matte carbon & vibrant cyber neon cyan
        "bright": 0.88, "contrast": 1.22
    },
    {
        "id": "room_chateau",
        "base": "room_townhouse",
        "r": 1.18, "g": 1.10, "b": 0.88, # French gilded gold boiserie & vineyards
        "bright": 1.06, "contrast": 1.08
    },
    {
        "id": "room_cliffside_compound",
        "base": "room_suburban_split",
        "r": 0.90, "g": 0.95, "b": 1.08, # Basalt dark stone & crashing cliff ocean
        "bright": 0.94, "contrast": 1.18
    },
    {
        "id": "room_private_island",
        "base": "room_eco_timber",
        "r": 1.08, "g": 1.12, "b": 1.04, # Tropical bamboo pavilion & turquoise lagoon
        "bright": 1.12, "contrast": 1.04
    },
    {
        "id": "room_megatower_apex",
        "base": "room_condo",
        "r": 1.02, "g": 1.08, "b": 1.18, # Cloud-piercing apex sanctuary & sky horizon
        "bright": 1.10, "contrast": 1.08
    },
    {
        "id": "room_orbital",
        "base": "room_condo",
        "r": 0.80, "g": 0.92, "b": 1.30, # Deep space cupola & glowing blue Earth curve
        "bright": 0.85, "contrast": 1.25
    }
]

def make_diorama_transparent(im_rgb, poly):
    """
    Renders everything outside the room walls and floor 100% transparent.
    Uses precise diorama cutaway polygon masking to eliminate background canvas,
    drop shadows, and exterior clutter while keeping 100% of interior geometry.
    """
    w, h = im_rgb.size
    poly_mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(poly_mask)
    draw.polygon(poly, fill=255)
    
    res = im_rgb.copy()
    res.putalpha(poly_mask)
    return res

def pixelate_and_scale(im_rgba, target_size=(2048, 2048), pixel_grid=512, colors=128):
    """
    Reworks the room texture to match the pixel-art character avatars:
    1. Downscales to a uniform 512x512 pixel grid.
    2. Quantizes color palette (128 colors) for authentic 16-bit pixel cluster aesthetic.
    3. Upscales to 2048x2048 using Nearest-Neighbor to guarantee sharp 4x4 pixel blocks.
    """
    im_small = im_rgba.resize((pixel_grid, pixel_grid), Image.Resampling.BILINEAR)
    a_small = im_small.split()[3]
    
    rgb_quant = im_small.convert('RGB').quantize(colors=colors, method=Image.Quantize.MEDIANCUT).convert('RGB')
    rgb_quant.putalpha(a_small)
    
    return rgb_quant.resize(target_size, Image.Resampling.NEAREST)

def apply_color_grading(im, r_scale=1.0, g_scale=1.0, b_scale=1.0, brightness=1.0, contrast=1.0):
    """Applies channel scaling, brightness, and contrast adjustments."""
    arr = np.array(im).astype(float)
    arr[:, :, 0] *= r_scale
    arr[:, :, 1] *= g_scale
    arr[:, :, 2] *= b_scale
    arr[:, :, :3] = np.clip(arr[:, :, :3], 0, 255)
    
    res = Image.fromarray(arr.astype(np.uint8))
    if brightness != 1.0:
        res = ImageEnhance.Brightness(res).enhance(brightness)
    if contrast != 1.0:
        res = ImageEnhance.Contrast(res).enhance(contrast)
    return res

def create_import_file(png_path):
    """Creates a Godot .import file with Lossy WebP compression."""
    import_path = png_path + ".import"
    rel_path = "res://" + png_path.replace("\\", "/")
    dest_path = "res://.godot/imported/" + os.path.basename(png_path) + ".ctex"
    
    content = f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://{abs(hash(png_path)):012x}"
path="{dest_path}"
metadata={{
"vram_texture": false
}}

[deps]

source_file="{rel_path}"
dest_files=["{dest_path}"]

[params]

compress/mode=1
compress/high_quality=false
compress/lossy_quality=0.8
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""
    with open(import_path, "w", encoding="utf-8") as f:
        f.write(content)

def main():
    print("=== Processing 10 Base AI Isometric Rooms with Pixel Art & Clean Transparency ===")
    raw_bases = {}
    for room_id, artifact_path in GENERATED_ROOMS.items():
        print(f"Loading {room_id}...")
        raw_bases[room_id] = Image.open(artifact_path).convert("RGB")
        
        # 1. Clean transparency outside diorama
        poly = BASE_POLYGONS[room_id]
        im_clean = make_diorama_transparent(raw_bases[room_id], poly)
        
        # 2. Pixel art conversion & 2048x2048 upscale
        im_pixel = pixelate_and_scale(im_clean)
        
        out_path = os.path.join(ROOMS_DIR, f"{room_id}.png")
        im_pixel.save(out_path, "PNG")
        create_import_file(out_path)
        print(f"Saved clean pixel room: {out_path} ({os.path.getsize(out_path) // 1024} KB)")

    print("\n=== Synthesizing Remaining 14 Property Rooms ===")
    for spec in SYNTHESIS_SPECS:
        room_id = spec["id"]
        base_id = spec["base"]
        
        print(f"Synthesizing {room_id} (base {base_id})...")
        base_im = raw_bases[base_id].copy()
        
        # 1. Color grading & architectural mood lighting adjustments
        base_im = apply_color_grading(
            base_im,
            r_scale=spec["r"],
            g_scale=spec["g"],
            b_scale=spec["b"],
            brightness=spec["bright"],
            contrast=spec["contrast"]
        )
        
        # 2. Clean diorama transparency using base room's polygon
        poly = BASE_POLYGONS[base_id]
        im_clean = make_diorama_transparent(base_im, poly)
        
        # 3. Pixel art conversion & 2048x2048 upscale
        im_pixel = pixelate_and_scale(im_clean)
        
        out_path = os.path.join(ROOMS_DIR, f"{room_id}.png")
        im_pixel.save(out_path, "PNG")
        create_import_file(out_path)
        print(f"Saved clean pixel room: {out_path} ({os.path.getsize(out_path) // 1024} KB)")

    # Also ensure starter wood room is pixel-styled and clean
    wood_path = os.path.join(ROOMS_DIR, "room_wood.png")
    if os.path.exists(wood_path):
        print("\n=== Pixelating Legacy room_wood.png ===")
        wood_im = Image.open(wood_path).convert("RGBA")
        wood_pixel = pixelate_and_scale(wood_im)
        wood_pixel.save(wood_path, "PNG")
        create_import_file(wood_path)
        print("Updated room_wood.png")

    print("\nAll 24 housing rooms + starter rooms successfully built in pixel art style with zero background and zero overlays!")

if __name__ == "__main__":
    main()
