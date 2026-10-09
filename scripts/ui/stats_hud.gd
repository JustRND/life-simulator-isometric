extends RefCounted
## The compact HUD is not a menu: its labels must not become category bars.
var font: Font = preload("res://assets/fonts/app_font_bold.tres")

func _init() -> void:
	pass

func handles(node: Node) -> bool:
	var ancestor := node
	while ancestor != null:
		if ancestor.name == "StatsPanel":
			return true
		ancestor = ancestor.get_parent()
	return false

func apply(node: Control, light: bool) -> void:
	if node.name == "StatsPanel":
		var panel := StyleBoxFlat.new()
		panel.bg_color = Color("#ffffff") if light else Color("#151e2b")
		panel.border_color = Color("#9aaaba") if light else Color("#45576b")
		panel.border_width_top = 2
		node.add_theme_stylebox_override("panel", panel)
		if not node.has_meta("stats_layout"):
			node.set_meta("stats_layout", true)
			node.minimum_size_changed.connect(func(): _layout.call_deferred(node))
			node.resized.connect(func(): _layout.call_deferred(node))
		_layout.call_deferred(node)
	elif node is MarginContainer:
		for side in ["left", "right"]:
			node.add_theme_constant_override("margin_" + side, 16)
		for side in ["top", "bottom"]:
			node.add_theme_constant_override("margin_" + side, 12)
	elif node is VBoxContainer:
		node.add_theme_constant_override("separation", 4)
	elif node is Label:
		node.remove_meta("reference_section")
		var stat_name := str(node.name).trim_suffix("Label")
		if stat_name in ["Health", "Happiness", "Smarts", "Looks"]:
			node.text = stat_name.to_upper()
			var icon_node := node.get_node_or_null(stat_name + "Icon") as TextureRect
			if icon_node == null:
				icon_node = TextureRect.new()
				icon_node.name = stat_name + "Icon"
				node.add_child(icon_node)
			icon_node.texture = preload("res://scripts/ui/modern_navigation.gd").icon(stat_name.to_lower())
			icon_node.material = null
			icon_node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			icon_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_node.size = Vector2(34, 34)
			icon_node.custom_minimum_size = Vector2(34, 34)
			icon_node.position = Vector2(4, 0)
			icon_node.modulate = Color.WHITE
		node.custom_minimum_size.y = 34
		node.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		node.add_theme_font_override("font", font)
		node.add_theme_font_size_override("font_size", 26)
		node.add_theme_color_override("font_color", Color("#075b91") if light else Color("#a9dcff"))
		var spacing := StyleBoxEmpty.new()
		spacing.content_margin_left = 48
		node.add_theme_stylebox_override("normal", spacing)
	elif node is TextureRect:
		var stat_kind := str(node.name).trim_suffix("Icon").to_lower()
		node.texture = preload("res://scripts/ui/modern_navigation.gd").icon(stat_kind)
		node.material = null
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.position = Vector2(4, 0)
		node.size = Vector2(34, 34)
		node.custom_minimum_size = Vector2(34, 34)
		node.modulate = Color.WHITE
	elif node is ProgressBar:
		node.custom_minimum_size.y = 28
		node.add_theme_font_override("font", font)
		node.add_theme_font_size_override("font_size", 22)
		node.add_theme_color_override("font_color", Color.WHITE)
		node.add_theme_color_override("font_outline_color", Color("#111827"))
		node.add_theme_constant_override("outline_size", 4)
		var track := StyleBoxFlat.new()
		track.bg_color = Color("#dce5ed") if light else Color("#27374b")
		track.set_corner_radius_all(4)
		node.add_theme_stylebox_override("background", track)

func _layout(panel: Control) -> void:
	if not is_instance_valid(panel) or not panel.is_inside_tree():
		return
	var feed := panel.get_parent().get_node_or_null("LifeFeedPanel") as Control
	var navigation := panel.get_parent().get_node_or_null("ActionBar") as Control
	if feed == null or navigation == null:
		return
	# Reserve the measured HUD height rather than relying on a fixed timeline end.
	panel.offset_bottom = navigation.offset_top - 16.0
	panel.offset_top = panel.offset_bottom - panel.get_combined_minimum_size().y

	var pull_btn := panel.get_parent().get_node_or_null("TimelinePullUpButton") as Control
	if pull_btn != null:
		pull_btn.offset_bottom = panel.offset_top
		pull_btn.offset_top = pull_btn.offset_bottom - 46.0

	var timeline_panel := panel.get_parent().get_node_or_null("TimelinePanel") as Control
	if timeline_panel != null and not timeline_panel.has_meta("is_animating"):
		timeline_panel.offset_bottom = (pull_btn.offset_top if pull_btn != null else panel.offset_top) - 8.0

	feed.offset_bottom = (pull_btn.offset_top if pull_btn != null else panel.offset_top) - 8.0

