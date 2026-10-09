"""
Character Frame Extraction & Alignment Tool
Extracts and generates 20 game-ready isometric character frames:
- 4-phase walk cycles: walk_se (0..3), walk_sw (0..3), walk_ne (0..3), walk_nw (0..3)
- Grounded idle poses: idle_se, idle_sw, idle_ne, idle_nw
Aligns all frames to a 240x480 canvas with feet baseline at y=460.
"""

import os
from PIL import Image
import numpy as np

def generate_frames():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.abspath(os.path.join(script_dir, "..", ".."))
    
    char_sheet_path = os.path.join(project_dir, "assets", "isometric", "characters", "character_spritesheet.png")
    out_dir = os.path.join(project_dir, "assets", "isometric", "characters", "processed")
    os.makedirs(out_dir, exist_ok=True)
    
    img = Image.open(char_sheet_path).convert('RGB')
    arr = np.array(img, dtype=float)
    
    diff = (arr[:, :, 0] + arr[:, :, 2]) * 0.5 - arr[:, :, 1]
    is_magenta_bg = (diff > 50) & (arr[:, :, 0] > 110) & (arr[:, :, 2] > 110) & (arr[:, :, 1] < 100)
    is_outline_fringe = (diff > 20) & (arr[:, :, 0] < 120) & (arr[:, :, 2] < 120)

    clean_arr = arr.copy()
    clean_arr[is_outline_fringe, 0] = np.minimum(clean_arr[is_outline_fringe, 0], clean_arr[is_outline_fringe, 1] + 15)
    clean_arr[is_outline_fringe, 2] = np.minimum(clean_arr[is_outline_fringe, 2], clean_arr[is_outline_fringe, 1] + 15)

    alpha = np.where(is_magenta_bg, 0, 255).astype(np.uint8)
    rgba = np.dstack((clean_arr.astype(np.uint8), alpha))
    full_img = Image.fromarray(rgba, 'RGBA')

    crops = {
        'top_0': (25, 20, 240, 475),
        'top_1': (285, 20, 485, 475),
        'top_2': (535, 20, 755, 475),
        'top_3': (810, 20, 980, 475),
        'bottom_0': (35, 530, 235, 975),
        'bottom_1': (300, 530, 475, 975),
        'bottom_2': (540, 530, 750, 975),
        'bottom_3': (815, 530, 980, 975)
    }

    cropped_frames = {}
    for name, box in crops.items():
        cropped = full_img.crop(box)
        bbox = cropped.getbbox()
        if bbox:
            cropped = cropped.crop(bbox)
        cropped_frames[name] = cropped

    # Synthesize Stride 2 & Pass 2 for SE walk
    im_0 = cropped_frames['top_0']
    im_1 = cropped_frames['top_1']
    im_2 = cropped_frames['top_2']
    im_3 = cropped_frames['top_3']

    arr_0 = np.array(im_0)
    arr_1 = np.array(im_1)
    arr_2 = np.array(im_2)

    belt_y = 250
    torso_2 = arr_2[:belt_y, :]
    ys_t, xs_t = np.where(torso_2[:, :, 3] > 0)
    mid_x_t2 = (np.min(xs_t) + np.max(xs_t)) / 2

    legs_0 = arr_0[belt_y:, :]
    legs_flipped = np.fliplr(legs_0)
    ys_l, xs_l = np.where(legs_flipped[:, :, 3] > 0)
    mid_x_l = (np.min(xs_l) + np.max(xs_l)) / 2
    shift_x = int(round(mid_x_t2 - mid_x_l)) + 8

    canvas_stride2 = np.zeros((im_2.size[1], max(im_2.size[0], im_0.size[0] + abs(shift_x) + 20), 4), dtype=np.uint8)
    canvas_stride2[:belt_y, :torso_2.shape[1]] = torso_2
    leg_start_x = max(0, shift_x)
    canvas_stride2[belt_y:belt_y+legs_flipped.shape[0], leg_start_x:leg_start_x+legs_flipped.shape[1]] = legs_flipped

    # Remove any border artifacts
    im_stride2 = Image.fromarray(canvas_stride2, 'RGBA').crop(Image.fromarray(canvas_stride2, 'RGBA').getbbox())

    torso_1 = arr_1[:belt_y, :]
    legs_1 = arr_1[belt_y:, :]
    legs_1_flipped = np.fliplr(legs_1)
    canvas_pass2 = np.zeros((im_1.size[1], im_1.size[0] + 40, 4), dtype=np.uint8)
    canvas_pass2[:belt_y, :torso_1.shape[1]] = torso_1
    canvas_pass2[belt_y:belt_y+legs_1_flipped.shape[0], 12:12+legs_1_flipped.shape[1]] = legs_1_flipped
    im_pass2 = Image.fromarray(canvas_pass2, 'RGBA').crop(Image.fromarray(canvas_pass2, 'RGBA').getbbox())

    canvas_w = 240
    canvas_h = 480
    baseline_y = 460
    center_x = 120

    def align(im):
        bbox = im.getbbox()
        cr = im.crop(bbox)
        w, h = cr.size
        paste_y = baseline_y - h
        paste_x = center_x - (w // 2)
        can = Image.new('RGBA', (canvas_w, canvas_h), (0, 0, 0, 0))
        can.paste(cr, (paste_x, paste_y), cr)
        return can

    # Save SE and SW frames
    se_frames = [
        ('walk_se_0', im_0),
        ('walk_se_1', im_1),
        ('walk_se_2', im_stride2),
        ('walk_se_3', im_pass2),
        ('idle_se', im_3)
    ]

    for name, im in se_frames:
        aligned = align(im)
        aligned.save(os.path.join(out_dir, f'{name}.png'))
        sw_name = name.replace('_se', '_sw')
        aligned.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(out_dir, f'{sw_name}.png'))

    # Save NE and NW frames
    ne_frames = [
        ('walk_ne_0', cropped_frames['bottom_0']),
        ('walk_ne_1', cropped_frames['bottom_1']),
        ('walk_ne_2', cropped_frames['bottom_2']),
        ('walk_ne_3', cropped_frames['bottom_1']),
        ('idle_ne', cropped_frames['bottom_3'])
    ]

    for name, im in ne_frames:
        aligned = align(im)
        aligned.save(os.path.join(out_dir, f'{name}.png'))
        nw_name = name.replace('_ne', '_nw')
        aligned.transpose(Image.FLIP_LEFT_RIGHT).save(os.path.join(out_dir, f'{nw_name}.png'))

    print("Successfully generated all 20 character frames.")

if __name__ == '__main__':
    generate_frames()
