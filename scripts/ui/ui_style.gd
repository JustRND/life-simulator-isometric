class_name UIStyle
extends RefCounted
## Shared tokens for custom controls that retain their own layouts and accents.
const BODY_SIZE := 36
const DETAIL_SIZE := 34
const BUTTON_HEIGHT := 96
const RADIUS := 10
const OPEN_SECONDS := 0.34
const CLOSE_SECONDS := 0.28
var font: Font = preload("res://assets/fonts/app_font.tres")
var bold_font: Font = preload("res://assets/fonts/app_font_bold.tres")

func _init() -> void:
	pass

static func contrast(a: Color, b: Color) -> float:
	var first := a.srgb_to_linear().get_luminance()
	var second := b.srgb_to_linear().get_luminance()
	return (maxf(first, second) + 0.05) / (minf(first, second) + 0.05)

static func readable(color: Color, background: Color) -> Color:
	if color.a < 0.01 or contrast(color, background) >= 4.5:
		return color
	return Color("#0f172a") if background.get_luminance() > 0.70 else Color("#f1f5f9")

func apply_custom(node: Control, light: bool) -> void:
	if node is Label or node is RichTextLabel:
		# Row presenters own their title hierarchy and update their own colors.
		if node.has_meta("locale_manual"):
			return
		if not node.has_theme_font_override("font"):
			node.add_theme_font_override("font", font)
		node.add_theme_font_override("normal_font", font)
		node.add_theme_font_size_override("font_size", maxi(DETAIL_SIZE, node.get_theme_font_size("font_size")))
		var key := "default_color" if node is RichTextLabel else "font_color"
		var color: Color = node.get_theme_color(key)
		var background := Color("#ffffff") if light else Color("#151e2b")
		var ancestor := node.get_parent()
		while ancestor is Control:
			if ancestor is PanelContainer:
				var style = ancestor.get_theme_stylebox("panel")
				if style is StyleBoxFlat and style.bg_color.a > 0.9:
					background = style.bg_color
					break
			ancestor = ancestor.get_parent()
		node.add_theme_color_override(key, readable(color, background))
	elif node is Button:
		apply_button(node)
	elif node is PanelContainer:
		var original = node.get_theme_stylebox("panel")
		if original is StyleBoxFlat:
			var panel: StyleBoxFlat = original.duplicate()
			if panel.bg_color.s < 0.55 or panel.bg_color.get_luminance() > 0.65:
				panel.bg_color = Color("#ffffff") if light else Color("#151e2b")
				panel.border_color = Color("#cbd5e1") if light else Color("#45576b")
			panel.set_corner_radius_all(RADIUS)
			node.add_theme_stylebox_override("panel", panel)

func apply_button(button: Button) -> void:
	if button is OptionButton or button is CheckButton or button is CheckBox:
		return
	var original = button.get_theme_stylebox("normal")
	if not original is StyleBoxFlat:
		return
	button.add_theme_font_override("font", font)

	var in_grid: bool = button.get_parent() is GridContainer or button.get_parent() is HBoxContainer
	var cur_font_size: int = button.get_theme_font_size("font_size")
	if cur_font_size > 0 and cur_font_size < BODY_SIZE:
		button.add_theme_font_size_override("font_size", cur_font_size)
	else:
		button.add_theme_font_size_override("font_size", DETAIL_SIZE if in_grid else BODY_SIZE)

	if in_grid:
		button.custom_minimum_size.y = clampf(button.custom_minimum_size.y, 68, 80)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		button.custom_minimum_size.y = maxf(BUTTON_HEIGHT, button.custom_minimum_size.y)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		if button.has_meta("center_text") or button.alignment == HORIZONTAL_ALIGNMENT_CENTER:
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER

	button.focus_mode = Control.FOCUS_NONE
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := original.duplicate() as StyleBoxFlat
		if button.has_theme_stylebox_override(state):
			var existing = button.get_theme_stylebox(state)
			if existing is StyleBoxFlat:
				style.bg_color = existing.bg_color
				style.border_color = existing.border_color
		style.set_corner_radius_all(RADIUS)
		style.set_border_width_all(2)
		style.content_margin_left = 14 if in_grid else 24
		style.content_margin_right = 14 if in_grid else 24
		style.content_margin_top = 10 if in_grid else 16
		style.content_margin_bottom = 10 if in_grid else 16
		if state == "normal" or state == "hover":
			style.shadow_color = Color(0, 0, 0, 0.25)
			style.shadow_size = 4
			style.shadow_offset = Vector2(0, 3)
		elif state == "pressed":
			style.shadow_color = Color(0, 0, 0, 0.18)
			style.shadow_size = 1
			style.shadow_offset = Vector2(0, 1)
			style.bg_color = style.bg_color.darkened(0.20)
		elif state == "disabled":
			style.shadow_size = 0
			style.shadow_offset = Vector2.ZERO
			if not button.has_meta("quiz_feedback"):
				style.bg_color = Color("#475569")
				style.border_color = Color("#94a3b8")
		elif state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.set_border_width_all(0)
			style.border_color = Color.TRANSPARENT
			style.shadow_size = 0
			style.shadow_offset = Vector2.ZERO

		if state != "focus":
			var key: String = {"normal": "font_color", "hover": "font_hover_color", "pressed": "font_pressed_color", "disabled": "font_disabled_color"}[state]
			if state == "disabled":
				button.add_theme_color_override(key, Color(1, 1, 1, 0.5) if style.bg_color.get_luminance() < 0.70 else Color("#94a3b8"))
			else:
				var font_col: Color = Color.WHITE if style.bg_color.get_luminance() < 0.70 else readable(Color.WHITE, style.bg_color)
				button.add_theme_color_override(key, font_col)
				button.add_theme_color_override("font_hover_color", font_col)
				button.add_theme_color_override("font_focus_color", font_col)
		button.add_theme_stylebox_override(state, style)
	if button.has_meta("quiz_feedback"):
		preload("res://scripts/ui/quiz_button_style.gd").feedback(button, button.get_meta("quiz_feedback"))
