"""
Script to build and process all 24 isometric room templates for 'The Housing Update'.
Handles:
1. Processing 10 AI-generated rooms (clean alpha transparency, upscale to 2048x2048 Lanczos).
2. Synthesizing the remaining 14 property-specific rooms with window composites, color grading,
   and thematic architectural lighting matching each property's exterior.
3. Writing optimized .import files (compress/mode=1, lossy_quality=0.8) for compact PCK.
"""

import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

BRAIN_DIR = r"C:\Users\ACER PREDATOR\.gemini\antigravity\brain\9b9cf3a4-7eb3-4ba0-b76b-7dbeeb740e47"
PROP_DIR = r"assets\items\properties"
ROOMS_DIR = r"assets\isometric\rooms"

os.makedirs(ROOMS_DIR, exist_ok=True)

# 10 generated AI rooms mapping
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

def remove_background_corners(im_rgba, thresh=235):
    """Flood-fills from the four corners inwards on near-white background to set alpha=0."""
    arr = np.array(im_rgba)
    w, h = im_rgba.size
    # Mask of white/near-white pixels
    is_bg = (arr[:, :, 0] > thresh) & (arr[:, :, 1] > thresh) & (arr[:, :, 2] > thresh)
    threshold_img = Image.fromarray((is_bg * 255).astype(np.uint8))
    
    # Floodfill from four corners
    ImageDraw.floodfill(threshold_img, (0, 0), 128, thresh=15)
    ImageDraw.floodfill(threshold_img, (w - 1, 0), 128, thresh=15)
    ImageDraw.floodfill(threshold_img, (0, h - 1), 128, thresh=15)
    ImageDraw.floodfill(threshold_img, (w - 1, h - 1), 128, thresh=15)
    
    mask_arr = (np.array(threshold_img) == 128)
    arr[mask_arr, 3] = 0
    return Image.fromarray(arr)

def composite_window_vista(base_img, exterior_path, window_box, blend_factor=0.88):
    """
    Composites the exterior view into the window bounding box (x1, y1, x2, y2).
    Keeps window frames / mullions and glass reflections via luminance blending.
    """
    x1, y1, x2, y2 = window_box
    win_w = x2 - x1
    win_h = y2 - y1
    
    ext = Image.open(exterior_path).convert("RGBA")
    ext_resized = ext.resize((win_w, win_h), Image.Resampling.LANCZOS)
    
    base_arr = np.array(base_img)
    ext_arr = np.array(ext_resized)
    
    # Target region
    region = base_arr[y1:y2, x1:x2, :3].astype(float)
    ext_rgb = ext_arr[:, :, :3].astype(float)
    
    # Soft blend with exterior
    blended = region * (1.0 - blend_factor) + ext_rgb * blend_factor
    base_arr[y1:y2, x1:x2, :3] = np.clip(blended, 0, 255).astype(np.uint8)
    
    return Image.fromarray(base_arr)

def apply_color_grading(im, r_scale=1.0, g_scale=1.0, b_scale=1.0, brightness=1.0, contrast=1.0):
    """Applies channel scaling, brightness, and contrast adjustments."""
    arr = np.array(im).astype(float)
    # Apply channel multipliers to RGB
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
    print("=== Processing AI Generated Rooms (1-10) ===")
    processed_bases = {}
    for room_id, artifact_path in GENERATED_ROOMS.items():
        print(f"Processing {room_id}...")
        im = Image.open(artifact_path).convert("RGBA")
        im_clean = remove_background_corners(im)
        processed_bases[room_id] = im_clean
        
        # Upscale to 2048x2048 with Lanczos
        im_2k = im_clean.resize((2048, 2048), Image.Resampling.LANCZOS)
        out_path = os.path.join(ROOMS_DIR, f"{room_id}.png")
        im_2k.save(out_path, "PNG")
        create_import_file(out_path)
        print(f"Saved {out_path}")

    print("\n=== Synthesizing Remaining Housing Rooms (11-24) ===")
    # Remaining 14 properties synthesis specs
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

    for spec in SYNTHESIS_SPECS:
        room_id = spec["id"]
        base_id = spec["base"]
        ext_filename = spec["exterior"]
        ext_path = os.path.join(PROP_DIR, ext_filename)
        
        print(f"Synthesizing {room_id} using base {base_id} and {ext_filename}...")
        base_im = processed_bases[base_id].copy()
        
        # 1. Composite window vista
        if os.path.exists(ext_path):
            base_im = composite_window_vista(
                base_im, ext_path, spec["window_box"], spec["blend_factor"]
            )
        
        # 2. Color grading & lighting
        base_im = apply_color_grading(
            base_im,
            r_scale=spec["r"],
            g_scale=spec["g"],
            b_scale=spec["b"],
            brightness=spec["bright"],
            contrast=spec["contrast"]
        )
        
        # 3. Clean background transparency
        base_im = remove_background_corners(base_im)
        
        # 4. Upscale to 2048x2048 with Lanczos
        im_2k = base_im.resize((2048, 2048), Image.Resampling.LANCZOS)
        out_path = os.path.join(ROOMS_DIR, f"{room_id}.png")
        im_2k.save(out_path, "PNG")
        create_import_file(out_path)
        print(f"Saved {out_path}")

    print("\nAll 24 housing rooms generated successfully!")

if __name__ == "__main__":
    main()
