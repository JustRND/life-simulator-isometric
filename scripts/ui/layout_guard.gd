class_name LayoutGuard
extends Node

## Shared, deliberately conservative layout conventions for dynamic UI.
##
## This helper configures controls at their creation point. It never walks the
## tree to rewrite existing layouts: doing that breaks compact children in an
## HBoxContainer (avatars, badges and close buttons) by making them expand.

const COMPACT_ACTION_MIN_WIDTH := 132.0
const STANDARD_ACTION_MIN_WIDTH := 176.0
const COLLAPSED_WIDTH := 44.0


static func configure_expanding_label(label: Label, wrap: TextServer.AutowrapMode = TextServer.AUTOWRAP_WORD_SMART) -> Label:
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = wrap
	return label


static func configure_compact_label(label: Label, minimum_width: float = 0.0) -> Label:
	label.size_flags_horizontal = Control.SIZE_SHRINK_END
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	if minimum_width > 0.0:
		label.custom_minimum_size.x = maxf(label.custom_minimum_size.x, minimum_width)
	return label


static func configure_action_button(button: Button, minimum_width: float = STANDARD_ACTION_MIN_WIDTH) -> Button:
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.x = maxf(button.custom_minimum_size.x, minimum_width)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


static func configure_compact_grid_action(button: Button, minimum_width: float = 120.0) -> Button:
	configure_action_button(button, minimum_width)
	button.set_meta("compact_grid_action", true)
	button.custom_minimum_size.y = 45.0
	button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	button.add_theme_font_size_override("font_size", 24)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := button.get_theme_stylebox(state)
		if style is StyleBoxFlat:
			var compact_style := (style as StyleBoxFlat).duplicate() as StyleBoxFlat
			compact_style.content_margin_top = 0
			compact_style.content_margin_bottom = 0
			button.add_theme_stylebox_override(state, compact_style)
	return button


static func configure_compact_avatar(avatar: TextureRect, width: float) -> TextureRect:
	avatar.custom_minimum_size.x = width
	avatar.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	avatar.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return avatar


func audit_tree(root: Node) -> void:
	# This diagnostic is intentionally development-only. It observes layout
	# mistakes without mutating any release UI or adding per-frame work.
	if not OS.is_debug_build() or root == null:
		return
	for node in root.find_children("*", "Control", true, false):
		var control := node as Control
		if control == null or not control.is_visible_in_tree() or control.size.x >= COLLAPSED_WIDTH:
			continue
		if control is Button and not (control as Button).text.strip_edges().is_empty():
			push_warning("LayoutGuard: collapsed button '%s' has %.1f px width at %s" % [control.name, control.size.x, control.get_path()])
		elif control is Label and (control as Label).text.strip_edges().length() >= 4:
			push_warning("LayoutGuard: collapsed label '%s' has %.1f px width at %s" % [control.name, control.size.x, control.get_path()])
