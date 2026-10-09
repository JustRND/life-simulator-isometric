extends MarginContainer
## Keeps the original button's text, signals, accessibility and disabled state.
const DETAILS = {
	"Life.exe Shop": ["🛒", "Discover new ways to play"],
	"Create A New Life": ["🌟", "Begin a new story"],
	"Save Life": ["💾", "Save your progress on this device"],
	"Load Life": ["👥", "Continue a previously saved life"],
	"Account Login": ["🌐", "Manage your account"],
	"T&C": ["📄", "Read the terms and conditions"],
	"Privacy Protection": ["🔐", "Learn how your data is handled"],
	"Achievements": ["🏆", "Explore your milestones"],
	"Custom Cities": ["🏙", "Add your own places to the world"],
	"Custom People": ["👤", "Create people to meet in your life"],
	"Settings": ["⚙", "Sound and language preferences"],
	"Themes": ["◐", "Choose a light or dark appearance"],
	"Education & School": ["🎓", "Study and develop your potential"],
	"Careers & Jobs": ["💼", "Find work and build your career"],
	"Finance Market": ["📈", "Trade stocks and manage businesses"],
	"Learning & Smarts": ["📚", "Keep your mind active"],
	"Freelance Marketplace": ["💻", "Earn money with flexible work"],
	"Licensing & Certifications": ["📜", "Train and earn new qualifications"],
	"Business & Enterprises": ["🏢", "Build and manage your businesses"],
	"Doctor & Healthcare": ["🩺", "Look after your health"],
	"BANKING": ["🏦", "Checking, savings and loans"],
	"First National Pixel Bank": ["🏦", "Checking, savings and loans"],
	"Bank & Loans": ["🏦", "Checking, savings and loans"],
}
var target: Button
var heading: Label
var description: Label
var symbol: Label
var art: TextureRect
var arrow: Label
var previous := ""

func setup(btn: Button) -> void:
	target = btn
	set_process(false)
	if heading == null:
		_build_ui()
	_connect_target()
	_sync()


func _ready() -> void:
	set_process(false)
	if target == null and get_parent() is Button:
		target = get_parent() as Button
	if heading == null:
		_build_ui()
	_connect_target()
	_sync()


func _connect_target() -> void:
	if target == null:
		return
	if not target.draw.is_connected(_on_target_state_changed):
		target.draw.connect(_on_target_state_changed)
	if not target.resized.is_connected(_on_target_state_changed):
		target.resized.connect(_on_target_state_changed)
	if not target.toggled.is_connected(_on_target_toggled):
		target.toggled.connect(_on_target_toggled)
	if not visibility_changed.is_connected(_on_visibility_changed):
		visibility_changed.connect(_on_visibility_changed)
	var locale = Engine.get_singleton("GameLocale") if Engine.has_singleton("GameLocale") else null
	if locale == null and has_node("/root/GameLocale"):
		locale = get_node("/root/GameLocale")
	if locale != null and not locale.changed.is_connected(_on_target_state_changed):
		locale.changed.connect(_on_target_state_changed)


func _on_target_state_changed() -> void:
	if is_visible_in_tree():
		_sync()


func _on_target_toggled(_pressed: bool) -> void:
	if is_visible_in_tree():
		_sync()


func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_sync()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		add_theme_constant_override("margin_" + side, 20)
	for side in ["top", "bottom"]:
		add_theme_constant_override("margin_" + side, 12)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	add_child(row)
	art = TextureRect.new()
	art.custom_minimum_size = Vector2(46, 46)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	row.add_child(art)
	symbol = _label(34)
	symbol.custom_minimum_size = Vector2(46, 46)
	symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symbol.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(symbol)
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	words.add_theme_constant_override("separation", 0)
	row.add_child(words)
	heading = _label(26, true)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.add_child(heading)
	description = _label(20)
	description.visible = false
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.add_child(description)
	arrow = _label(26)
	arrow.custom_minimum_size = Vector2(24, 24)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(arrow)
	_ignore_mouse(self)

static var _regular_font: Font = preload("res://assets/fonts/app_font.tres")
static var _bold_font: Font = preload("res://assets/fonts/app_font_bold.tres")

func _label(font_size: int, bold: bool = false) -> Label:
	var result := Label.new()
	result.set_meta("reference_part", true)
	result.set_meta("locale_manual", true)
	var font: Font = _bold_font if bold else _regular_font
	result.add_theme_font_override("font", font)
	result.add_theme_font_size_override("font_size", font_size)
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return result

var _target_silenced := false
var _cached_text := ""
var _cached_pressed := false
var _cached_disabled := false
var _cached_icon: Texture2D = null
var _cached_light := false
var _cached_lang := ""
var _cached_colored := false
var _cached_emoji := ""
var _cached_width := 0.0

func _silence_target() -> void:
	if target == null or _target_silenced:
		return
	_target_silenced = true
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]:
		target.add_theme_color_override(key, Color.TRANSPARENT)
	for key in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_disabled_color", "icon_focus_color"]:
		target.add_theme_color_override(key, Color.TRANSPARENT)
	target.add_theme_font_size_override("font_size", 1)

func _is_colored_target() -> bool:
	if target == null:
		return false
	if target.name.begins_with("EventChoice") or (target.get_parent() != null and target.get_parent().name == "EventChoices") or target.has_meta("event_choice"):
		return true
	if target.has_meta("market_button") or target.has_meta("colored_button") or target.has_meta("bank_standout"):
		return true
	var sb = target.get_theme_stylebox("normal")
	if sb is StyleBoxFlat:
		var bg_col: Color = (sb as StyleBoxFlat).bg_color
		if bg_col.get_luminance() < 0.65 or bg_col.s > 0.35:
			return true
	return false

func _ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)

func _process(_delta: float) -> void:
	# Per-frame polling disabled. ReferenceRow updates on-demand via draw/resized/toggled/visibility signals.
	pass

func _sync() -> void:
	if target == null:
		return
	if not _target_silenced:
		_silence_target()
	var light: bool = LifeLibrary.data.get("theme", "dark") == "light"
	var lang: String = str(LifeLibrary.data.get("language", "en"))
	var text: String = target.text
	var pressed: bool = target.button_pressed
	var disabled: bool = target.disabled
	var icon_res: Texture2D = target.icon
	var emoji_meta: String = str(target.get_meta("action_emoji", ""))
	var cur_w: float = target.size.x

	if (text == _cached_text and pressed == _cached_pressed and disabled == _cached_disabled 
			and icon_res == _cached_icon and light == _cached_light and lang == _cached_lang 
			and emoji_meta == _cached_emoji and abs(cur_w - _cached_width) < 4.0):
		return

	var is_colored: bool = _is_colored_target()
	_cached_text = text
	_cached_pressed = pressed
	_cached_disabled = disabled
	_cached_icon = icon_res
	_cached_light = light
	_cached_lang = lang
	_cached_colored = is_colored
	_cached_emoji = emoji_meta
	_cached_width = cur_w

	var lines := target.text.split("\n", false)
	var first := str(lines[0]) if not lines.is_empty() else ""
	var source: String = str(target.get_meta("locale_source", target.text)).split("\n")[0].strip_edges()
	var glyph: String = preload("res://scripts/ui/action_icons.gd").for_text(source)
	if first.length() > 1 and first.unicode_at(0) > 8000:
		var space := first.find(" ")
		if space > 0 and space < 8:
			glyph = first.substr(0, space)
			first = first.substr(space + 1).strip_edges()
	for title_text in DETAILS:
		if source.ends_with(title_text):
			glyph = DETAILS[title_text][0]
	glyph = str(target.get_meta("action_emoji", glyph))
	heading.text = first
	if description != null:
		description.text = ""
		description.visible = false
	symbol.text = glyph
	art.texture = target.icon
	art.visible = target.icon != null
	symbol.visible = target.icon == null
	arrow.text = "✓" if target.toggle_mode and target.button_pressed else "›"
	var ink: Color
	var secondary: Color
	var accent_ink: Color
	if target.has_meta("bank_standout"):
		ink = Color("#065f46") if light else Color("#ecfdf5")
		accent_ink = Color("#059669") if light else Color("#34d399")
		secondary = accent_ink
		if target.disabled:
			ink = Color(0.2, 0.4, 0.3, 0.6)
			accent_ink = ink
			secondary = ink
	elif is_colored:
		ink = Color.WHITE
		accent_ink = Color.WHITE
		secondary = Color("#f1f5f9")
		if target.disabled:
			ink = Color(1, 1, 1, 0.5)
			accent_ink = ink
			secondary = ink
	else:
		ink = Color("#0f172a") if light else Color("#a9dcff")
		accent_ink = ink
		secondary = Color("#334155") if light else Color("#c1cddd")
		if target.disabled:
			ink = Color("#64748b") if light else Color("#9da8b8")
			accent_ink = ink
			secondary = ink
	heading.add_theme_color_override("font_color", ink)
	if description != null:
		description.add_theme_color_override("font_color", secondary)
	arrow.add_theme_color_override("font_color", accent_ink)
	symbol.add_theme_color_override("font_color", accent_ink)
	var min_h := 74.0
	target.custom_minimum_size.y = min_h

