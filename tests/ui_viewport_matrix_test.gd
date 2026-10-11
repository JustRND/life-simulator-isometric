extends Node

const MainScreen = preload("res://scenes/main/main_screen.tscn")
const VIEWPORTS := [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(960, 540),
	Vector2i(540, 960),
	Vector2i(1080, 1920),
]

var findings: Array[String] = []


func _ready() -> void:
	LifeLibrary.profile_path = "user://ui_viewport_matrix_profile.json"
	var main = MainScreen.instantiate()
	add_child(main)
	await get_tree().process_frame
	main.new_game_panel.hide()
	main.loading_screen.hide()
	main.disclaimer_screen.hide()
	PlayerData.age = 30

	for viewport_size in VIEWPORTS:
		get_window().size = viewport_size
		await get_tree().process_frame
		await get_tree().process_frame
		for tab in ["timeline", "activities", "assets", "bank", "relationships", "character", "infant", "settings"]:
			main.show_tab(tab)
			await get_tree().process_frame
			_audit_primary_surface(main, tab, viewport_size)

	if FileAccess.file_exists(LifeLibrary.profile_path):
		DirAccess.remove_absolute(LifeLibrary.profile_path)
	assert(findings.is_empty(), "Viewport layout findings:\n" + "\n".join(findings))
	print("UI_VIEWPORT_MATRIX_TEST_PASSED: %d viewports" % VIEWPORTS.size())
	get_tree().quit(0)


func _audit_primary_surface(main: Node, tab: String, viewport_size: Vector2i) -> void:
	var surface: Control = main.settings_overlay if tab == "settings" else main.get(tab + "_panel") as Control
	if tab == "timeline":
		surface = main.get_node("SafeArea") as Control
	if surface == null or not surface.is_visible_in_tree():
		findings.append("%s: missing visible surface at %s" % [tab, viewport_size])
		return
	# Canvas stretch may render the project in a logical viewport that differs
	# from the native window size. Control rectangles use this rendered space.
	var visible_rect := get_viewport().get_visible_rect()
	for node in surface.find_children("*", "Control", true, false):
		var control := node as Control
		if not control.is_visible_in_tree() or control is ScrollBar:
			continue
		var rect := control.get_global_rect()
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			continue
		# Descendants may legitimately extend below a scroll viewport, but no
		# actionable text should leave the horizontal viewport bounds.
		if control is Button or control is LineEdit or control is TextEdit:
			if rect.position.x < -2.0 or rect.end.x > visible_rect.end.x + 2.0:
				findings.append("%s: %s horizontal overflow at %s" % [tab, control.name, viewport_size])
