extends RefCounted

const Row = preload("res://scripts/ui/reference_row.gd")
const COLORS = ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color", "default_color", "font_placeholder_color"]
var body_font: Font = preload("res://assets/fonts/app_font.tres")
var bold_font: Font = preload("res://assets/fonts/app_font_bold.tres")
var title_font: Font = preload("res://assets/fonts/app_font_bold.tres")
var custom_style = preload("res://scripts/ui/ui_style.gd").new()

func _init() -> void:
	pass

func handles(node: Node, root: Node) -> bool:
	var ancestor := node
	while ancestor != root and ancestor != null:
		if ancestor.has_meta("theme_exempt") or ancestor.name == "DeathScreenOverlay" or ancestor.name == "AfterlifeMinigame" or "Death" in str(ancestor.name) or "Afterlife" in str(ancestor.name) or ancestor.name == "NewGamePanel" or (str(ancestor.name).ends_with("Overlay") and ancestor.name != "SettingsOverlay") or str(ancestor.name).ends_with("Modal"):
			return false
		if ancestor.has_meta("reference_panel") or ancestor.name in ["ActivitiesPanel", "AssetsPanel", "BankPanel", "RelationshipsPanel", "CharacterPanel", "InfantPanel", "SettingsOverlay"]:
			return true
		ancestor = ancestor.get_parent()
	return false

func surface(light: bool, state: String = "normal") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#ffffff") if light else Color("#151e2b")
	if state in ["hover", "pressed", "hover_pressed"]:
		style.bg_color = Color("#e2edf6") if light else Color("#263a50")
	style.border_color = Color("#9aaaba") if light else Color("#45576b")
	style.border_width_bottom = 2
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	if state == "focus":
		style.bg_color.a = 0
		style.set_border_width_all(3)
		style.border_color = Color("#127bb7") if light else Color("#8cd5ff")
	return style

func button_surface(light: bool, state: String = "normal") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#ffffff") if light else Color("#151e2b")
	style.border_color = Color("#9aaaba") if light else Color("#45576b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	if state == "normal" or state in ["hover", "hover_pressed"]:
		style.shadow_color = Color(0, 0, 0, 0.15 if light else 0.35)
		style.shadow_size = 4
		style.shadow_offset = Vector2(0, 3)
	elif state == "pressed":
		style.bg_color = Color("#cbdceb") if light else Color("#1a2938")
		style.shadow_color = Color(0, 0, 0, 0.12 if light else 0.25)
		style.shadow_size = 1
		style.shadow_offset = Vector2(0, 1)
	elif state == "disabled":
		style.shadow_size = 0
		style.shadow_offset = Vector2.ZERO
		style.bg_color = Color("#e2e8f0") if light else Color("#1e293b")
		style.border_color = Color("#cbd5e1") if light else Color("#334155")
	elif state == "focus":
		style.bg_color = Color.TRANSPARENT
		style.set_border_width_all(0)
		style.border_color = Color.TRANSPARENT
		style.shadow_size = 0
		style.shadow_offset = Vector2.ZERO
	return style

func apply(node: Control, light: bool) -> void:
	if node.has_meta("theme_exempt"):
		return
	var cur: Node = node
	while cur != null:
		if cur.has_meta("theme_exempt") or "Death" in str(cur.name) or "Afterlife" in str(cur.name):
			return
		cur = cur.get_parent()
	if node.has_meta("reference_part") or node.has_meta("market_button"):
		custom_style.apply_custom(node, light)
		return
	if node is Label and not node.has_meta("reference_header_title"):
		var p = node.get_parent()
		if p != null and (p.name == "ActList" or p.has_meta("reference_menu")):
			var text: String = node.text.strip_edges()
			if text.length() > 2 and text.length() < 90 and not "\n" in text and not ":" in text and text == text.to_upper() and text != text.to_lower():
				node.set_meta("reference_section", true)
	if node.name == "ActList" and not node.has_meta("reference_categories"):
		node.set_meta("reference_categories", true)
		for entry in [["EducationActItem", "CAREER & EDUCATION"], ["DoctorItem", "HEALTH & LIFESTYLE"], ["ShoppingActItem", "PERSONAL LIFE"]]:
			var before := node.get_node_or_null(entry[0])
			if before != null:
				var bar := Label.new()
				bar.text = entry[1]
				bar.set_meta("reference_section", true)
				node.add_child(bar)
				node.move_child(bar, before.get_index())
	var ink := Color("#174666") if light else Color("#e0eaf5")
	node.add_theme_font_override("font", body_font)
	node.add_theme_font_override("normal_font", body_font)
	node.add_theme_font_override("bold_font", bold_font)
	for key in COLORS:
		node.add_theme_color_override(key, (Color("#606773") if light else Color("#a7b4c5")) if key == "font_disabled_color" else ink)
	if node is Label or node is RichTextLabel:
		if node is Label and node.get_parent() is VBoxContainer:
			node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		node.add_theme_font_size_override("font_size", maxi(26, node.get_theme_font_size("font_size")))
		node.add_theme_font_size_override("normal_font_size", 28)
		# Give nested information cards the same title/body hierarchy as menu rows.
		if node is Label and node.get_index() == 0 and node.get_parent() is BoxContainer and not node.has_meta("reference_section"):
			var owner_box := node.get_parent()
			var inside_card := owner_box.get_parent() is MarginContainer and owner_box.get_parent().get_parent() is PanelContainer
			if inside_card or owner_box is HBoxContainer:
				node.add_theme_font_override("font", title_font)
				node.add_theme_font_size_override("font_size", 36)
				node.add_theme_color_override("font_color", Color("#075b91") if light else Color("#a9dcff"))
				node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if (node is RichTextLabel or node is Label) and (node.name == "EventDescription" or (node.get_parent() != null and node.get_parent().name == "EventContent")):
			var inset := StyleBoxEmpty.new()
			inset.content_margin_left = 32
			inset.content_margin_right = 32
			inset.content_margin_top = 18
			inset.content_margin_bottom = 18
			node.add_theme_stylebox_override("normal", inset)
		elif node is Label and node.get_parent() is VBoxContainer and not node.has_meta("reference_section"):
			var inset := StyleBoxEmpty.new()
			inset.content_margin_left = 28
			inset.content_margin_right = 28
			inset.content_margin_top = 8
			inset.content_margin_bottom = 8
			node.add_theme_stylebox_override("normal", inset)
	if node is PanelContainer or node is Panel:
		var style := surface(light)
		style.set_content_margin_all(0)
		node.add_theme_stylebox_override("panel", style)
		if node.name == "EventPanel":
			style.set_corner_radius_all(24)
			node.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	if node is VBoxContainer:
		# Lists also contain explanatory text and tab bars, not just menu rows.
		# Keep a real gap so button shadows cannot cover the following label.
		node.add_theme_constant_override("separation", maxi(20, int(node.get_meta("panel_spacing", node.get_theme_constant("separation")))))
	elif node is HBoxContainer:
		node.add_theme_constant_override("separation", maxi(16, node.get_theme_constant("separation")))
	elif node is GridContainer:
		node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		node.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		node.add_theme_constant_override("h_separation", maxi(12, node.get_theme_constant("h_separation")))
		node.add_theme_constant_override("v_separation", maxi(10, node.get_theme_constant("v_separation")))
	if node is MarginContainer:
		var parent_name := str(node.get_parent().name) if node.get_parent() != null else ""
		if parent_name in ["MotherCard", "FatherCard", "PartnerCard"] or parent_name.begins_with("ChildCard_"):
			node.add_theme_constant_override("margin_left", 48)
			node.add_theme_constant_override("margin_right", 32)
			node.add_theme_constant_override("margin_top", 20)
			node.add_theme_constant_override("margin_bottom", 20)
		elif str(node.name) in ["ActMargin", "RelMargin", "AssetsMargin", "BankMargin", "InfantMargin", "CharacterMargin", "SettingsMargin", "ConfirmMargin"] or node.has_meta("reference_edge"):
			node.add_theme_constant_override("margin_left", 24)
			node.add_theme_constant_override("margin_right", 24)
			node.add_theme_constant_override("margin_top", 16)
			node.add_theme_constant_override("margin_bottom", 20)
		elif "Card" in parent_name:
			node.add_theme_constant_override("margin_left", 32)
			node.add_theme_constant_override("margin_right", 32)
			node.add_theme_constant_override("margin_top", 20)
			node.add_theme_constant_override("margin_bottom", 20)
	if node is LineEdit or node is TextEdit:
		for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus", "read_only"]:
			node.add_theme_stylebox_override(state, surface(light, state))
		node.add_theme_font_size_override("font_size", 30)
		node.add_theme_color_override("caret_color", ink)
		node.add_theme_color_override("selection_color", Color("#3c7096"))
		node.add_theme_color_override("font_selected_color", Color.WHITE)
	elif node is Button:
		node.focus_mode = Control.FOCUS_NONE
		var is_bank_standout: bool = (node.name == "BankButton" and node.get_parent() != null and node.get_parent().name == "AssetsContent")
		if is_bank_standout:
			_style_banking_standout_button(node, light)
		else:
			for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus", "read_only"]:
				node.add_theme_stylebox_override(state, button_surface(light, state))
		if node.text in ["✕", "×", "X", "✖"]:
			_style_header(node)
		elif (node.get_parent() != null and (node.get_parent().name in ["ActList", "AssetsContent", "SettingsList", "SettingsContent"] or node.has_meta("use_reference_row") or node.name == "BankButton")) and not node is OptionButton and not node is CheckButton and not node is CheckBox and node.text.length() > 2:
			var row: Node = node.get_node_or_null("ReferenceRow")
			if not node.has_meta("reference_row") or row == null:
				node.set_meta("reference_row", true)
				var presenter := Row.new()
				presenter.name = "ReferenceRow"
				node.add_child(presenter)
				presenter.setup(node)
				row = presenter
			elif row != null and row.has_method("setup"):
				row.setup(node)
			elif row != null and row.has_method("_sync"):
				row._sync()
			for key in COLORS:
				node.add_theme_color_override(key, Color.TRANSPARENT)
			for key in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_disabled_color", "icon_focus_color"]:
				node.add_theme_color_override(key, Color.TRANSPARENT)
			node.add_theme_font_size_override("font_size", 1)
			node.expand_icon = true
			node.add_theme_constant_override("icon_max_width", 1)
		else:
			node.add_theme_font_size_override("font_size", 22)
			node.custom_minimum_size.y = maxf(node.custom_minimum_size.y, 48)
	if node.has_meta("reference_section"):
		node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		node.custom_minimum_size.y = 52
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		node.add_theme_font_override("font", bold_font)
		node.add_theme_font_size_override("font_size", 26)
		var bar := StyleBoxFlat.new()
		bar.content_margin_left = 16
		bar.content_margin_right = 16
		bar.content_margin_top = 8
		bar.content_margin_bottom = 8
		bar.set_corner_radius_all(6)
		if light:
			bar.bg_color = Color("#0f172a") # Crisp dark navy banner for high contrast in light mode
			node.add_theme_color_override("font_color", Color.WHITE)
		else:
			bar.bg_color = Color("#263342") # Sleek slate banner in dark mode
			node.add_theme_color_override("font_color", Color.WHITE)
		node.add_theme_stylebox_override("normal", bar)
	if node.has_meta("reference_header_title"):
		node.add_theme_font_override("font", bold_font)
		node.add_theme_font_size_override("font_size", 34)
		node.add_theme_color_override("font_color", Color("#0f172a") if light else Color.WHITE)
		node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if node is Button and node.get_parent().has_meta("reference_header") and not node.text in ["✕", "×", "X", "✖"]:
		# Secondary navigation, such as Back to Assets, belongs to the header.
		node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var nav_ink: Color = Color("#0f172a") if light else Color.WHITE
		for key in COLORS:
			node.add_theme_color_override(key, nav_ink)
		for state in ["normal", "hover", "pressed"]:
			var nav_style := surface(light, state)
			if light:
				nav_style.bg_color = Color("#edf3fa") if state == "normal" else Color("#dbeafe")
				nav_style.border_color = Color("#94a3b8")
			else:
				nav_style.bg_color = Color("#080c12") if state == "normal" else Color("#263a50")
			nav_style.border_width_bottom = 0
			node.add_theme_stylebox_override(state, nav_style)

func _style_header(close: Button) -> void:
	var header := close.get_parent()
	if not header is HBoxContainer:
		return
	if not header.name.ends_with("HeaderRow") and not header.name.ends_with("Header"):
		return
	var light: bool = LifeLibrary.data.get("theme", "dark") == "light"
	close.custom_minimum_size = Vector2(56, 56)
	close.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close.add_theme_font_size_override("font_size", 26)
	for key in COLORS:
		close.add_theme_color_override(key, Color("#0f172a") if light else Color.WHITE)
	close.add_theme_color_override("font_hover_color", Color("#f43f5e"))
	close.add_theme_color_override("font_pressed_color", Color("#dc2626"))
	for state in ["normal", "hover", "pressed", "focus"]:
		var circle := StyleBoxFlat.new()
		if light:
			circle.bg_color = Color("#dbeafe") if state != "normal" else Color("#ffffff")
			circle.border_color = Color("#64748b")
		else:
			circle.bg_color = Color("#28333f") if state != "normal" else Color("#080c12")
			circle.border_color = Color.WHITE
		circle.set_corner_radius_all(28)
		circle.set_border_width_all(2)
		close.add_theme_stylebox_override(state, circle)
	if header.has_meta("reference_header"):
		header.queue_redraw()
		for child in header.get_children():
			if child is Label and child.has_meta("reference_header_title"):
				child.add_theme_color_override("font_color", Color("#0f172a") if light else Color.WHITE)
		return
	header.set_meta("reference_header", true)
	header.custom_minimum_size.y = 72
	header.add_theme_constant_override("separation", 16)
	header.draw.connect(func():
		var is_lt: bool = LifeLibrary.data.get("theme", "dark") == "light"
		header.draw_rect(Rect2(Vector2.ZERO, header.size), Color("#edf3fa") if is_lt else Color("#080c12"))
	)
	header.resized.connect(header.queue_redraw)
	header.move_child(close, 0)
	var gutter := Control.new()
	gutter.custom_minimum_size.x = 8
	header.add_child(gutter)
	header.move_child(gutter, 0)
	for child in header.get_children():
		if child is Label:
			child.set_meta("reference_header_title", true)
			child.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			child.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			child.add_theme_font_size_override("font_size", 32)
			child.add_theme_color_override("font_color", Color("#0f172a") if light else Color.WHITE)
			apply(child, light)
	var balance := Control.new()
	balance.custom_minimum_size.x = 56
	header.add_child(balance)


func _style_banking_standout_button(btn: Button, light: bool) -> void:
	btn.set_meta("bank_standout", true)
	btn.set_meta("colored_button", true)
	btn.custom_minimum_size.y = 74.0

	var n_sb := StyleBoxFlat.new()
	n_sb.set_corner_radius_all(14)
	n_sb.set_border_width_all(2)
	n_sb.content_margin_left = 20
	n_sb.content_margin_right = 20
	n_sb.content_margin_top = 10
	n_sb.content_margin_bottom = 10

	if light:
		n_sb.bg_color = Color("#ecfdf5") # Crisp vibrant emerald-mint surface
		n_sb.border_color = Color("#059669") # Rich emerald border
		n_sb.shadow_color = Color(0.02, 0.4, 0.25, 0.2)
		n_sb.shadow_size = 4
		n_sb.shadow_offset = Vector2(0, 2)
	else:
		n_sb.bg_color = Color("#0c3430") # Deep rich emerald-teal card
		n_sb.border_color = Color("#10b981") # Glowing vibrant emerald border
		n_sb.shadow_color = Color(0.06, 0.72, 0.5, 0.35) # Emerald luminous glow
		n_sb.shadow_size = 8
		n_sb.shadow_offset = Vector2(0, 3)

	var h_sb := n_sb.duplicate() as StyleBoxFlat
	if light:
		h_sb.bg_color = Color("#d1fae5")
		h_sb.border_color = Color("#047857")
		h_sb.shadow_size = 6
	else:
		h_sb.bg_color = Color("#134540")
		h_sb.border_color = Color("#34d399")
		h_sb.shadow_size = 10

	var p_sb := n_sb.duplicate() as StyleBoxFlat
	if light:
		p_sb.bg_color = Color("#a7f3d0")
		p_sb.border_color = Color("#065f46")
		p_sb.shadow_size = 1
	else:
		p_sb.bg_color = Color("#072320")
		p_sb.border_color = Color("#059669")
		p_sb.shadow_size = 2

	for state in ["normal", "focus"]:
		btn.add_theme_stylebox_override(state, n_sb)
	btn.add_theme_stylebox_override("hover", h_sb)
	btn.add_theme_stylebox_override("pressed", p_sb)
	btn.add_theme_stylebox_override("disabled", n_sb)

