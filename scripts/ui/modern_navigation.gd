extends RefCounted

var font: Font = preload("res://assets/fonts/app_font_bold.tres")
static var textures: Dictionary = {}
const STATS = {
	"health": '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 64 64"><path d="M32 54 C30 52 10 36 10 22 C10 14 16 8 24 8 C28.5 8 31 10.5 32 12 C33 10.5 35.5 8 40 8 C48 8 54 14 54 22 C54 36 34 52 32 54 Z" fill="#10b981"/></svg>',
	"happiness": '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 64 64"><circle cx="32" cy="32" r="26" fill="#f59e0b"/><path d="M20 36 Q32 52 44 36" fill="none" stroke="#1c1917" stroke-width="5" stroke-linecap="round"/><circle cx="23" cy="24" r="3.5" fill="#1c1917"/><circle cx="41" cy="24" r="3.5" fill="#1c1917"/></svg>',
	"smarts": '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 64 64"><path d="M32 6 A18 18 0 0 0 17 27 C17 33 21 37 23 41 L41 41 C43 37 47 33 47 27 A18 18 0 0 0 32 6 Z" fill="#0284c7"/><path d="M24 47 H40 M26 53 H38" fill="none" stroke="#0284c7" stroke-width="4.5" stroke-linecap="round"/><path d="M32 18 V28 M27 23 H37" fill="none" stroke="white" stroke-width="3" stroke-linecap="round"/></svg>',
	"looks": '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 64 64"><path d="M32 4 Q32 32 60 32 Q32 32 32 60 Q32 32 4 32 Q32 32 32 4 Z" fill="#db2777"/><circle cx="50" cy="14" r="4.5" fill="#db2777"/><circle cx="14" cy="50" r="3.5" fill="#db2777"/></svg>',
	"mentalstate": '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 64 64"><circle cx="32" cy="18" r="8" fill="#8b5cf6"/><path d="M16 46 C16 34 24 30 32 30 C40 30 48 34 48 46 Z" fill="#8b5cf6"/><circle cx="14" cy="44" r="5" fill="#a78bfa"/><circle cx="50" cy="44" r="5" fill="#a78bfa"/><path d="M22 28 C26 22 38 22 42 28" fill="none" stroke="#c4b5fd" stroke-width="3" stroke-linecap="round"/></svg>'
}

const PATHS = {
	"health": '<path d="M32 53 12 33C-1 19 17 3 32 19 47 3 65 19 52 33Z"/>',
	"happiness": '<circle cx="32" cy="32" r="24"/><path d="M20 38q12 16 24 0"/><circle cx="23" cy="25" r="1.5"/><circle cx="41" cy="25" r="1.5"/>',
	"smarts": '<path d="M22 42c-18-13-9-34 10-34s28 21 10 34l-2 7H24Zm3 15h14M24 49h16M32 20v12m-7-5h14"/>',
	"looks": '<path d="M8 24h19v14H12Zm29 0h19l-4 14H37ZM27 28h10M20 47q12 9 24 0"/>',
	"mentalstate": '<circle cx="32" cy="18" r="8"/><path d="M16 46 C16 34 24 30 32 30 C40 30 48 34 48 46 Z"/><path d="M22 28 C26 22 38 22 42 28"/>',
	"life": '<circle cx="32" cy="22" r="9"/><path d="M14 53v-5c0-10 8-16 18-16s18 6 18 16v5"/>',
	"assets": '<rect x="9" y="16" width="46" height="36" rx="8"/><path d="M13 16V12h35v4M55 29H39v12h16"/><circle cx="44" cy="35" r="1"/>',
	"relationships": '<path d="M32 53 12 33C-1 19 17 3 32 19 47 3 65 19 52 33Z"/>',
	"activities": '<rect x="10" y="10" width="17" height="17" rx="5"/><rect x="37" y="10" width="17" height="17" rx="5"/><rect x="10" y="37" width="17" height="17" rx="5"/><rect x="37" y="37" width="17" height="17" rx="5"/>',
}

func _init() -> void:
	pass

static func icon(kind: String) -> Texture2D:
	if not textures.has(kind):
		var svg: String
		if STATS.has(kind):
			svg = STATS[kind]
		elif kind == "age":
			svg = '<svg xmlns="http://www.w3.org/2000/svg" width="230" height="230" viewBox="0 0 230 230"><defs><linearGradient id="g" x2="1" y2="1"><stop stop-color="#22b8a9"/><stop offset="1" stop-color="#087c85"/></linearGradient></defs><rect x="16" y="16" width="198" height="198" rx="62" fill="url(#g)"/><rect x="17" y="17" width="196" height="196" rx="61" fill="none" stroke="#77e6d8" stroke-opacity=".55" stroke-width="2"/><path d="M115 57v66M82 90h66" fill="none" stroke="white" stroke-width="10" stroke-linecap="round"/><path d="m82 174 10-26 10 26m-16-9h12M125 152c-12-10-24 4-17 17 4 7 13 7 18 2v-10h-9M148 149h-14v25h14m-14-13h11" fill="none" stroke="white" stroke-width="3.5" stroke-linejoin="round" stroke-linecap="round"/></svg>'
		else:
			svg = '<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 64 64"><g fill="none" stroke="white" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round">' + str(PATHS.get(kind, PATHS.life)) + '</g></svg>'
		var image := Image.new()
		image.load_svg_from_string(svg)
		textures[kind] = ImageTexture.create_from_image(image)
	return textures[kind]

func handles(node: Node) -> bool:
	return node.name == "AgeButton" or node.name == "AgeArtwork" or node.name == "ActionBar" or (node is Button and node.get_parent().name == "ActionRow")

func apply(node: Control, light: bool) -> void:
	var ink := Color("#245270") if light else Color("#bed7e8")
	if node.name == "AgeArtwork":
		node.texture = icon("age")
		node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		return
	if node.name == "AgeButton":
		return
	if node.name == "ActionBar":
		var bar := StyleBoxFlat.new()
		bar.bg_color = Color("#f8fafc") if light else Color("#101925")
		bar.border_width_top = 2
		bar.border_color = Color("#d1dce6") if light else Color("#324455")
		node.add_theme_stylebox_override("panel", bar)
		return
	var kinds := {"InfantButton": "life", "AssetsButton": "assets", "RelationshipsButton": "relationships", "ActivitiesButton": "activities"}
	node.icon = icon(kinds.get(str(node.name), "life"))
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	node.add_theme_font_override("font", font)
	node.add_theme_font_size_override("font_size", 25)
	node.add_theme_constant_override("icon_max_width", 64)
	node.add_theme_constant_override("h_separation", 18)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var surface := StyleBoxFlat.new()
		surface.bg_color = Color.TRANSPARENT
		if state in ["hover", "pressed"]:
			surface.bg_color = Color("#e1f2f4") if light else Color("#20394a")
		if state == "focus":
			surface.set_border_width_all(2)
			surface.border_color = Color("#35b8b5")
		surface.set_corner_radius_all(20)
		surface.content_margin_top = 36
		surface.content_margin_bottom = 30
		node.add_theme_stylebox_override(state, surface)
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "icon_normal_color", "icon_hover_color", "icon_pressed_color"]:
		node.add_theme_color_override(key, ink)
