extends Node

const STYLES = ["panel", "normal", "hover", "pressed", "disabled", "focus", "background", "read_only"]
const BUTTON_COLORS = ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]
const INPUT_COLORS = ["font_color", "font_placeholder_color", "font_selected_color", "font_uneditable_color"]
var reference_theme = preload("res://scripts/ui/reference_theme.gd").new()
var stats_hud = preload("res://scripts/ui/stats_hud.gd").new()
var modern_navigation = preload("res://scripts/ui/modern_navigation.gd").new()


func _ready() -> void:
	get_tree().node_added.connect(func(node):
		if node is Control:
			_apply_node.call_deferred(node)
	)
	apply_theme.call_deferred()


func apply_theme() -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	var bg_col := Color("#f4f6fa") if is_light else Color(0.043, 0.075, 0.165, 1.0)
	RenderingServer.set_default_clear_color(bg_col)
	var parent := get_parent()
	if parent != null:
		walk(parent)


func apply_subtree(node: Node) -> void:
	if is_instance_valid(node):
		walk(node)


func walk(node: Node) -> void:
	_apply_node(node)
	for child in node.get_children():
		walk(child)


static func get_light_mode_color(original_color: Color) -> Color:
	# If already dark enough (luminance <= 0.18 and alpha >= 0.7), it already has high contrast
	if original_color.get_luminance() <= 0.18 and original_color.a >= 0.7:
		return original_color
	
	var s := original_color.s
	var h := original_color.h
	var lum := original_color.get_luminance()
	
	# If neutral / near-white / gray
	if s < 0.20 or lum > 0.80:
		if lum > 0.70:
			var c := Color("#0f172a") # Deep dark slate
			c.a = original_color.a
			return c
		else:
			var c := Color("#334155") # Slate-700
			c.a = original_color.a
			return c
	
	# Hue-based mapping to rich dark counterparts for maximum contrast on light backgrounds
	# Cyan / Sky blue (h: ~0.48 - 0.58)
	if h >= 0.48 and h <= 0.58:
		var c := Color("#0369a1")
		c.a = original_color.a
		return c
	# Blue (h: ~0.58 - 0.68)
	elif h > 0.58 and h <= 0.68:
		var c := Color("#1d4ed8")
		c.a = original_color.a
		return c
	# Purple / Violet (h: ~0.68 - 0.82)
	elif h > 0.68 and h <= 0.82:
		var c := Color("#6b21a8")
		c.a = original_color.a
		return c
	# Green / Emerald (h: ~0.22 - 0.45)
	elif h >= 0.22 and h < 0.45:
		var c := Color("#166534")
		c.a = original_color.a
		return c
	# Yellow / Amber / Orange (h: ~0.08 - 0.22)
	elif h >= 0.08 and h < 0.22:
		var c := Color("#b45309")
		c.a = original_color.a
		return c
	# Red / Rose / Pink (h < 0.08 or h > 0.82)
	else:
		var c := Color("#b91c1c")
		c.a = original_color.a
		return c


static func is_exempt(node: Node) -> bool:
	var cur: Node = node
	while cur != null:
		if cur.has_meta("theme_exempt"):
			return true
		var cname: String = str(cur.name)
		if cname == "DeathScreenOverlay" or cname == "death_screen_overlay" or cname == "AfterlifeMinigame" or cname.begins_with("DeathScreen") or cname.begins_with("Afterlife") or "Death" in cname or "Afterlife" in cname:
			return true
		cur = cur.get_parent()
	return false


func _apply_node(node: Node) -> void:
	if not is_instance_valid(node) or not node is Control:
		return
	if is_exempt(node):
		return
	var root := get_parent()
	if root != null and not root.is_ancestor_of(node) and node != root:
		return

	var is_light: bool = LifeLibrary.data.theme == "light"
	if modern_navigation.handles(node):
		modern_navigation.apply(node, is_light)
		return
	if stats_hud.handles(node):
		stats_hud.apply(node, is_light)
		return
	if reference_theme.handles(node, root):
		reference_theme.apply(node, is_light)
		return
	if node.has_meta("reference_part") or node.has_meta("market_button") or node.has_meta("event_choice"):
		return

	# 1. Capture dark originals if not yet recorded
	if not node.has_meta("dark_theme_originals"):
		var original := {"styles": {}, "colors": {}}
		for key in STYLES:
			if node.has_theme_stylebox(key):
				var style = node.get_theme_stylebox(key)
				if style is StyleBoxFlat:
					original.styles[key] = style.duplicate()

		if node is Button:
			for key in BUTTON_COLORS:
				if node.has_theme_color_override(key):
					original.colors[key] = node.get_theme_color(key)
		elif node is Label:
			if node.has_theme_color_override("font_color"):
				original.colors["font_color"] = node.get_theme_color("font_color")
		elif node is RichTextLabel:
			if node.has_theme_color_override("default_color"):
				original.colors["default_color"] = node.get_theme_color("default_color")
		elif node is LineEdit or node is TextEdit:
			for key in INPUT_COLORS:
				if node.has_theme_color_override(key):
					original.colors[key] = node.get_theme_color(key)
		elif node is ProgressBar:
			if node.has_theme_color_override("font_color"):
				original.colors["font_color"] = node.get_theme_color("font_color")

		if node is ColorRect and node.material == null and node.color.a >= 0.95:
			original.rect_color = node.color
		node.set_meta("dark_theme_originals", original)

	var originals: Dictionary = node.get_meta("dark_theme_originals")

	# 2. Apply Styles
	for key in originals.styles:
		var style: StyleBoxFlat = originals.styles[key].duplicate()
		if is_light:
			if style.bg_color.get_luminance() < 0.45:
				var alpha := style.bg_color.a
				if key == "hover":
					style.bg_color = Color("#bfdbfe") if node is Button else Color("#d5e3f2")
					style.border_color = Color("#0284c7")
				elif key == "pressed":
					style.bg_color = Color("#93c5fd") if node is Button else Color("#c7d8ea")
					style.border_color = Color("#0369a1")
				elif key == "disabled":
					style.bg_color = Color("#e2e8f0")
					style.border_color = Color("#94a3b8")
				else:
					style.bg_color = Color("#edf3fa") if key in ["panel", "normal", "background", "read_only"] else Color("#d5e3f2")
					style.border_color = style.border_color.darkened(0.40)
				style.bg_color.a = alpha
			else:
				if style.border_color.get_luminance() > 0.60:
					style.border_color = style.border_color.darkened(0.40)
		node.add_theme_stylebox_override(key, style)

	# 3. Apply Colors
	if is_light:
		if node is Button:
			node.focus_mode = Control.FOCUS_NONE
			var base_col: Color = originals.colors.get("font_color", node.get_theme_color("font_color"))
			var light_col := get_light_mode_color(base_col)
			node.add_theme_color_override("font_color", light_col)
			node.add_theme_color_override("font_hover_color", light_col)
			node.add_theme_color_override("font_pressed_color", Color("#000000"))
			node.add_theme_color_override("font_focus_color", light_col)
			node.add_theme_color_override("font_disabled_color", Color("#64748b"))
		elif node is Label:
			var base_col: Color = originals.colors.get("font_color", Color("#ffffff"))
			node.add_theme_color_override("font_color", get_light_mode_color(base_col))
		elif node is RichTextLabel:
			node.add_theme_color_override("default_color", Color("#0f172a"))
		elif node is LineEdit or node is TextEdit:
			node.add_theme_color_override("font_color", Color("#0f172a"))
			node.add_theme_color_override("font_placeholder_color", Color("#64748b"))
			node.add_theme_color_override("font_selected_color", Color("#ffffff"))
			node.add_theme_color_override("font_uneditable_color", Color("#64748b"))
		elif node is ProgressBar:
			node.add_theme_color_override("font_color", Color("#0f172a"))
	else:
		# Restore Dark Mode colors
		if node is Button:
			node.focus_mode = Control.FOCUS_NONE
			for key in BUTTON_COLORS:
				if originals.colors.has(key):
					node.add_theme_color_override(key, originals.colors[key])
				elif node.has_theme_color_override(key):
					node.remove_theme_color_override(key)
			if node.has_theme_color_override("font_color"):
				var dark_col: Color = node.get_theme_color("font_color")
				node.add_theme_color_override("font_hover_color", dark_col)
				node.add_theme_color_override("font_focus_color", dark_col)
		elif node is Label:
			if originals.colors.has("font_color"):
				node.add_theme_color_override("font_color", originals.colors["font_color"])
			elif node.has_theme_color_override("font_color"):
				node.remove_theme_color_override("font_color")
		elif node is RichTextLabel:
			if originals.colors.has("default_color"):
				node.add_theme_color_override("default_color", originals.colors["default_color"])
			elif node.has_theme_color_override("default_color"):
				node.remove_theme_color_override("default_color")
		elif node is LineEdit or node is TextEdit:
			for key in INPUT_COLORS:
				if originals.colors.has(key):
					node.add_theme_color_override(key, originals.colors[key])
				elif node.has_theme_color_override(key):
					node.remove_theme_color_override(key)
		elif node is ProgressBar:
			if originals.colors.has("font_color"):
				node.add_theme_color_override("font_color", originals.colors["font_color"])
			elif node.has_theme_color_override("font_color"):
				node.remove_theme_color_override("font_color")

	# 4. ColorRect (solid background / backdrop)
	if originals.has("rect_color"):
		node.color = Color("#f4f6fa") if is_light else originals.rect_color
