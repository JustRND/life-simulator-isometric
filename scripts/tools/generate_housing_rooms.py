"""
Script to build and process all 24 isometric room templates for 'The Housing Update'.
Produces:
1. 100% transparent backgrounds outside the isometric cutaway walls and floor (no white canvas, no exterior trees).
2. Authentic 16-bit pixel art styling matching the character avatars (512x512 quantized grid upscaled with Nearest Neighbor to 2048x2048).
3. Thematic window vista composites and color grading for all 24 property rooms.
4. Optimized .import files for Godot lossy WebP compression.
"""

import os
from collections import deque
import numpy as np
from PIL import Image, ImageDraw, ImageEnhance

BRAIN_DIR = r"C:\Users\ACER PREDATOR\.gemini\antigravity\brain\9b9cf3a4-7eb3-4ba0-b76b-7dbeeb740e47"
PROP_DIR = r"assets\items\properties"
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

# Diorama cutaway boundary polygons in 1024x1024 space
BASE_POLYGONS = {
    "room_capsule": [(500, 52), (928, 260), (928, 696), (500, 928), (70, 696), (70, 268)],
    "room_tenement": [(512, 60), (926, 258), (926, 764), (512, 982), (98, 764), (98, 258)],
    "room_studio": [(500, 46), (958, 230), (958, 799), (500, 976), (65, 797), (65, 230)],
    "room_condo": [(500, 95), (928, 315), (928, 680), (500, 895), (96, 680), (96, 315)],
    "room_cottage": [(512, 60), (914, 268), (914, 735), (512, 966), (88, 722), (88, 272)],
    "room_suburban_split": [(500, 51), (950, 285), (950, 721), (500, 964), (50, 708), (50, 298)],
    "room_townhouse": [(500, 92), (895, 272), (895, 730), (500, 950), (128, 730), (128, 272)],
    "room_eco_timber": [(500, 80), (915, 289), (915, 760), (500, 976), (105, 795), (105, 290)],
    "room_house": [(500, 114), (946, 335), (946, 665), (500, 917), (54, 665), (54, 335)],
    "room_cabin": [(500, 79), (912, 363), (912, 715), (500, 975), (95, 755), (95, 354)],
}

# Remaining 14 property room specifications
SYNTHESIS_SPECS = [
    {
        "id": "room_historic_brownstone",
        "base": "room_townhouse",
        "exterior": "prop_historic_brownstone.jpg",
        "window_box": (180, 240, 440, 580),
        "blend_factor": 0.82,
        "r": 1.15, "g": 0.90, "b": 0.85, # Rich Victorian mahogany & crimson
        "bright": 0.96, "contrast": 1.10
    },
    {
        "id": "room_modern_villa",
        "base": "room_condo",
        "exterior": "prop_modern_villa.jpg",
        "window_box": (610, 230, 830, 560),
        "blend_factor": 0.90,
        "r": 1.02, "g": 1.05, "b": 1.10, # Clean minimalist white & pool cyan
        "bright": 1.12, "contrast": 1.05
    },
    {
        "id": "room_alpine_chalet",
        "base": "room_cabin",
        "exterior": "prop_alpine_chalet.jpg",
        "window_box": (160, 250, 410, 560),
        "blend_factor": 0.88,
        "r": 0.96, "g": 1.00, "b": 1.14, # Alpine snow & roaring hearth
        "bright": 1.02, "contrast": 1.08
    },
    {
        "id": "room_ranch",
        "base": "room_cabin",
        "exterior": "prop_ranch.jpg",
        "window_box": (160, 250, 410, 560),
        "blend_factor": 0.88,
        "r": 1.18, "g": 1.05, "b": 0.82, # Golden sunset oak & pasture hills
        "bright": 1.04, "contrast": 1.06
    },
    {
        "id": "room_desert_estate",
        "base": "room_suburban_split",
        "exterior": "prop_desert_estate.jpg",
        "window_box": (590, 200, 860, 520),
        "blend_factor": 0.88,
        "r": 1.12, "g": 1.02, "b": 0.92, # Desert stacked stone & pool palms
        "bright": 1.05, "contrast": 1.05
    },
    {
        "id": "room_beachfront",
        "base": "room_eco_timber",
        "exterior": "prop_beachfront.jpg",
        "window_box": (530, 160, 860, 680),
        "blend_factor": 0.92,
        "r": 1.04, "g": 1.08, "b": 1.16, # Sun-bleached shiplap & ocean waves
        "bright": 1.14, "contrast": 1.04
    },
    {
        "id": "room_harbor_duplex",
        "base": "room_condo",
        "exterior": "prop_harbor_duplex.jpg",
        "window_box": (610, 230, 830, 560),
        "blend_factor": 0.90,
        "r": 0.94, "g": 1.02, "b": 1.18, # Marina nautical blue & teak deck
        "bright": 1.05, "contrast": 1.06
    },
    {
        "id": "room_penthouse",
        "base": "room_condo",
        "exterior": "prop_penthouse.jpg",
        "window_box": (610, 230, 830, 560),
        "blend_factor": 0.92,
        "r": 1.08, "g": 1.04, "b": 1.00, # Calacatta marble gold & high-rise night skyline
        "bright": 1.04, "contrast": 1.12
    },
    {
        "id": "room_cyber_mansion",
        "base": "room_condo",
        "exterior": "prop_cyber_mansion.jpg",
        "window_box": (610, 230, 830, 560),
        "blend_factor": 0.88,
        "r": 0.82, "g": 0.94, "b": 1.25, # Matte carbon & vibrant cyber neon cyan
        "bright": 0.88, "contrast": 1.22
    },
    {
        "id": "room_chateau",
        "base": "room_townhouse",
        "exterior": "prop_chateau.jpg",
        "window_box": (180, 240, 440, 580),
        "blend_factor": 0.86,
        "r": 1.18, "g": 1.10, "b": 0.88, # French gilded gold boiserie & vineyards
        "bright": 1.06, "contrast": 1.08
    },
    {
        "id": "room_cliffside_compound",
        "base": "room_suburban_split",
        "exterior": "prop_cliffside_compound.jpg",
        "window_box": (590, 200, 860, 520),
        "blend_factor": 0.90,
        "r": 0.90, "g": 0.95, "b": 1.08, # Basalt dark stone & crashing cliff ocean
        "bright": 0.94, "contrast": 1.18
    },
    {
        "id": "room_private_island",
        "base": "room_eco_timber",
        "exterior": "prop_private_island.jpg",
        "window_box": (530, 160, 860, 680),
        "blend_factor": 0.92,
        "r": 1.08, "g": 1.12, "b": 1.04, # Tropical bamboo pavilion & turquoise lagoon
        "bright": 1.12, "contrast": 1.04
    },
    {
        "id": "room_megatower_apex",
        "base": "room_condo",
        "exterior": "prop_megatower_apex.jpg",
        "window_box": (610, 230, 830, 560),
        "blend_factor": 0.92,
        "r": 1.02, "g": 1.08, "b": 1.18, # Cloud-piercing apex sanctuary & sky horizon
        "bright": 1.10, "contrast": 1.08
    },
    {
        "id": "room_orbital",
        "base": "room_condo",
        "exterior": "prop_orbital.jpg",
        "window_box": (610, 230, 830, 560),
        "blend_factor": 0.95,
        "r": 0.80, "g": 0.92, "b": 1.30, # Deep space cupola & glowing blue Earth curve
        "bright": 0.85, "contrast": 1.25
    }
]

def make_diorama_transparent(im_rgb, poly):
    """
    Renders everything outside the room walls and floor 100% transparent.
    Uses:
    1. Precise diorama hexagon clipping (removes outside trees, neighborhood houses, gardens).
    2. Connected border floodfill to eliminate any white background or cast shadows.
    """
    arr = np.array(im_rgb, dtype=np.float32)
    h, w, _ = arr.shape
    
    corner_colors = [arr[0, 0], arr[0, w-1], arr[h-1, 0], arr[h-1, w-1]]
    mean_bg = np.mean(corner_colors, axis=0)
    
    dist = np.linalg.norm(arr - mean_bg, axis=2)
    # Candidate for outside background: near corner background or bright background
    is_candidate = (dist < 85) | (np.min(arr, axis=2) > 185)
    
    visited = np.zeros((h, w), dtype=bool)
    queue = deque()
    for y in range(h):
        for x in [0, w-1]:
            if is_candidate[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))
    for x in range(w):
        for y in [0, h-1]:
            if is_candidate[y, x] and not visited[y, x]:
                visited[y, x] = True
                queue.append((y, x))
                
    while queue:
        y, x = queue.popleft()
        for dy, dx in [(-1,0), (1,0), (0,-1), (0,1)]:
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx]:
                if is_candidate[ny, nx]:
                    visited[ny, nx] = True
                    queue.append((ny, nx))
                    
    poly_mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(poly_mask)
    draw.polygon(poly, fill=255)
    poly_arr = np.array(poly_mask) > 0
    
    alpha = ((~visited) & poly_arr) * 255
    alpha = alpha.astype(np.uint8)
    
    return Image.fromarray(np.dstack([arr.astype(np.uint8), alpha]))

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

def composite_window_vista(base_img, exterior_path, window_box, blend_factor=0.88):
    """Composites the property exterior view into the window bounding box."""
    x1, y1, x2, y2 = window_box
    win_w = x2 - x1
    win_h = y2 - y1
    
    ext = Image.open(exterior_path).convert("RGBA")
    ext_resized = ext.resize((win_w, win_h), Image.Resampling.LANCZOS)
    
    base_arr = np.array(base_img)
    ext_arr = np.array(ext_resized)
    
    region = base_arr[y1:y2, x1:x2, :3].astype(float)
    ext_rgb = ext_arr[:, :, :3].astype(float)
    
    blended = region * (1.0 - blend_factor) + ext_rgb * blend_factor
    base_arr[y1:y2, x1:x2, :3] = np.clip(blended, 0, 255).astype(np.uint8)
    
    return Image.fromarray(base_arr)

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
        ext_filename = spec["exterior"]
        ext_path = os.path.join(PROP_DIR, ext_filename)
        
        print(f"Synthesizing {room_id} (base {base_id})...")
        base_im = raw_bases[base_id].copy()
        
        # 1. Composite exterior window vista
        if os.path.exists(ext_path):
            base_im = composite_window_vista(
                base_im, ext_path, spec["window_box"], spec["blend_factor"]
            )
            
        # 2. Color grading & lighting adjustments
        base_im = apply_color_grading(
            base_im,
            r_scale=spec["r"],
            g_scale=spec["g"],
            b_scale=spec["b"],
            brightness=spec["bright"],
            contrast=spec["contrast"]
        )
        
        # 3. Clean diorama transparency using base room's polygon
        poly = BASE_POLYGONS[base_id]
        im_clean = make_diorama_transparent(base_im, poly)
        
        # 4. Pixel art conversion & 2048x2048 upscale
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
        # Pixelate legacy wood
        wood_pixel = pixelate_and_scale(wood_im)
        wood_pixel.save(wood_path, "PNG")
        create_import_file(wood_path)
        print("Updated room_wood.png")

    print("\nAll 24 housing rooms + starter rooms successfully built in pixel art style with zero background!")

if __name__ == "__main__":
    main()
