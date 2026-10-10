extends PanelContainer

signal closed
const OFFERS = [
	["LIFE.EXE PLUS", "A little extra for every life.", "Mock premium membership and bonus customization.", "$4.99", "#64e6ff"],
	["NEON WARDROBE", "Make your next chapter brighter.", "Mock pack of portrait frames and profile accents.", "$1.99", "#bda2ff"],
	["NEW BEGINNINGS", "More room for more stories.", "Mock pack of three additional character save slots.", "$2.99", "#75efb3"],
	["PIXEL COLLECTION", "Small details. Your signature style.", "Mock bundle of alternate UI color themes.", "$0.99", "#ffd481"]
]
var _close: Button
var _status: Label
var _shop_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 90
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel", _style(Color("#090f1d"), Color("#090f1d"), 0))
	_build()
	visible = false
	preload("res://scripts/ui/panel_pull_up.gd").watch(self)

func install_button(row: HBoxContainer) -> void:
	_shop_button = Button.new()
	_shop_button.name = "ShopButton"
	_shop_button.text = "SHOP"
	_shop_button.icon = load("res://assets/ui/shop.svg")
	_shop_button.expand_icon = true
	_shop_button.add_theme_constant_override("icon_max_width", 76)
	_shop_button.add_theme_constant_override("h_separation", 14)
	_shop_button.add_theme_font_size_override("font_size", 30)
	_shop_button.custom_minimum_size = Vector2(230, 104)
	_shop_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_shop_button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_style_button(_shop_button, Color("#64e6ff"))
	row.add_child(_shop_button)
	_shop_button.pressed.connect(open_shop)

func open_shop() -> void:
	_status.text = "Preview shop • Sample prices • No real purchases"
	show()
	_close.grab_focus()

func close_shop() -> void:
	preload("res://scripts/ui/panel_close.gd").dismiss(self, false, func():
		closed.emit()
		if is_instance_valid(_shop_button):
			_shop_button.grab_focus()
	)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled()

func _build() -> void:
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 38)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 26)
	margin.add_child(column)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 22)
	column.add_child(header)
	var icon := TextureRect.new()
	icon.texture = load("res://assets/ui/shop.svg")
	icon.custom_minimum_size = Vector2(108, 108)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	header.add_child(icon)
	var title := _label("LIFE.EXE SHOP", 46, Color("#64e6ff"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(title)
	_close = Button.new()
	_close.name = "CloseShopButton"
	_close.text = "X"
	_close.tooltip_text = "Return to game"
	_close.custom_minimum_size = Vector2(100, 100)
	_style_button(_close, Color("#ff90aa"))
	header.add_child(_close)
	_close.pressed.connect(close_shop)
	column.add_child(_label("YOUR LIFE. YOUR STYLE.", 32, Color("#f1f5ff")))
	column.add_child(_label("Explore extras for your next story.", 29, Color("#a2b5cf")))
	var scroll := ScrollContainer.new()
	scroll.name = "OffersScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var offers := VBoxContainer.new()
	offers.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offers.add_theme_constant_override("separation", 22)
	scroll.add_child(offers)
	for offer in OFFERS:
		var card := PanelContainer.new()
		var accent := Color(offer[4])
		var is_light: bool = LifeLibrary.data.theme == "light"
		var card_bg: Color = Color("#edf3fa") if is_light else Color("#111e34")
		var card_border: Color = accent.darkened(0.35) if (is_light and accent.get_luminance() > 0.40) else accent
		card.add_theme_stylebox_override("panel", _style(card_bg, card_border, 24))
		offers.add_child(card)
		var content := VBoxContainer.new()
		content.add_theme_constant_override("separation", 12)
		card.add_child(content)
		content.add_child(_label(offer[0], 36, accent))
		content.add_child(_label(offer[1], 29, Color("#f1f5ff")))
		content.add_child(_label(offer[2], 27, Color("#a2b5cf")))
		var price := Button.new()
		price.text = "%s  •  PREVIEW" % offer[3]
		price.custom_minimum_size.y = 86
		_style_button(price, accent)
		content.add_child(price)
		price.pressed.connect(_preview_offer.bind(offer[0]))
	_status = _label("Preview shop • Sample prices • No real purchases", 27, Color("#a2b5cf"))
	_status.custom_minimum_size.y = 96
	column.add_child(_status)

func _preview_offer(offer_name: String) -> void:
	_status.text = "%s is a mock offer. Nothing was charged or added." % offer_name

func _label(value: String, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	var is_light: bool = LifeLibrary.data.theme == "light"
	var text_color: Color = tint
	if is_light:
		if tint.get_luminance() > 0.65:
			text_color = Color("#0f172a") if tint.s < 0.2 else Color("#0284c7")
		elif tint.get_luminance() > 0.40:
			text_color = Color("#475569") if tint.s < 0.2 else tint.darkened(0.35)
	label.add_theme_color_override("font_color", text_color)
	return label

func _style(fill: Color, border: Color, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _style_button(button: Button, accent: Color) -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	var dark_accent: Color = accent.darkened(0.35) if (is_light and accent.get_luminance() > 0.40) else accent
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color("#0f172a") if is_light else accent)
	button.add_theme_color_override("font_hover_color", Color("#0284c7") if is_light else Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#000000") if is_light else Color.WHITE)

	var normal_sb := _style(Color("#edf3fa") if is_light else Color("#12213b"), dark_accent, 12)
	normal_sb.shadow_color = Color(0, 0, 0, 0.22)
	normal_sb.shadow_size = 4
	normal_sb.shadow_offset = Vector2(0, 3)

	var hover_sb := _style(Color("#bfdbfe") if is_light else Color("#1d3353"), Color("#0284c7") if is_light else Color.WHITE, 12)
	hover_sb.shadow_color = Color(0, 0, 0, 0.28)
	hover_sb.shadow_size = 6
	hover_sb.shadow_offset = Vector2(0, 3)

	var pressed_sb := _style(Color("#93c5fd") if is_light else Color("#0d1729"), Color("#0369a1") if is_light else accent, 12)
	pressed_sb.shadow_color = Color(0, 0, 0, 0.18)
	pressed_sb.shadow_size = 1
	pressed_sb.shadow_offset = Vector2(0, 1)

	button.add_theme_stylebox_override("normal", normal_sb)
	button.add_theme_stylebox_override("hover", hover_sb)
	button.add_theme_stylebox_override("pressed", pressed_sb)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if button.name != "CloseShopButton":
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
