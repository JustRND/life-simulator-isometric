@tool
extends SceneTree

func _init() -> void:
	print("--- CLASSIFYING ALL TEENAGE PORTRAITS ---")
	
	var results: Array[Dictionary] = []
	for g in ["female", "male"]:
		var max_i := 32 if g == "female" else 64
		for i in range(max_i):
			var p := "res://assets/portraits/teens/%s/teen_%d.png" % [g, i]
			var im := Image.load_from_file(ProjectSettings.globalize_path(p))
			if not im:
				continue
				
			# Sample skin pixels in the face region (y from 45 to 80, x from 45 to 83)
			var total_r := 0.0
			var total_g := 0.0
			var total_b := 0.0
			var sample_count := 0
			
			for y in range(45, 80):
				for x in range(45, 83):
					var c := im.get_pixel(x, y)
					if c.a < 0.5:
						continue
					# Skin pixel heuristic in RGB: R > B and R > 0.15 and not pure black/white
					# Exclude very dark pixels (eyes, eyebrows, dark glasses) where (r+g+b)/3 < 0.18
					var lum := (c.r * 0.299 + c.g * 0.587 + c.b * 0.114)
					if lum > 0.18 and c.r >= c.b:
						total_r += c.r
						total_g += c.g
						total_b += c.b
						sample_count += 1
			
			var avg_lum := 0.5
			var tone := "medium"
			if sample_count > 0:
				var avg_r := total_r / sample_count
				var avg_g := total_g / sample_count
				var avg_b := total_b / sample_count
				avg_lum = avg_r * 0.299 + avg_g * 0.587 + avg_b * 0.114
				
				# Categorize tone based on luminance:
				# deep / dark: lum < 0.46
				# medium / warm / olive: 0.46 <= lum < 0.70
				# light / fair: lum >= 0.70
				if avg_lum < 0.48:
					tone = "dark"
				elif avg_lum < 0.70:
					tone = "medium"
				else:
					tone = "light"
			
			results.append({
				"id": "teen_%s_%d" % [g, i],
				"path": p,
				"gender": g.to_upper(),
				"index": i,
				"age_category": "teenager",
				"skin_tone": tone,
				"avg_luminance": snapped(avg_lum, 0.01)
			})

	var tone_counts := {"dark": 0, "medium": 0, "light": 0}
	for r in results:
		tone_counts[r.skin_tone] += 1
	print("Summary of teen portrait classification: ", tone_counts)
	print("Female distribution: ", results.filter(func(r): return r.gender == "FEMALE").map(func(r): return r.skin_tone))
	print("Male distribution: ", results.filter(func(r): return r.gender == "MALE").map(func(r): return r.skin_tone))
	quit()
