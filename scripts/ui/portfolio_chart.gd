extends Control

var history: Array = []


func _ready() -> void:
	custom_minimum_size.y = 270
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	GameLocale.changed.connect(queue_redraw)


func _draw() -> void:
	var light: bool = LifeLibrary.data.theme == "light"
	draw_style_box(_background(light), Rect2(Vector2.ZERO, size))
	var rect := Rect2(24, 24, maxf(1, size.x - 48), maxf(1, size.y - 68))
	for i in range(5):
		var y := rect.position.y + rect.size.y * i / 4.0
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Color("#526477"), 1)
	if history.is_empty():
		return
	var upper := 1.0
	var lower := 0.0
	for point in history:
		upper = maxf(upper, maxf(float(point.value), float(point.invested)))
		lower = minf(lower, minf(float(point.value), float(point.invested)))
	for key in ["value", "invested"]:
		var points := PackedVector2Array()
		for i in history.size():
			points.append(Vector2(rect.position.x + rect.size.x * i / maxf(1, history.size() - 1), rect.end.y - rect.size.y * (float(history[i][key]) - lower) / (upper - lower)))
		var color := Color("#0891b2") if key == "value" else Color("#d99b25")
		if points.size() > 1:
			draw_polyline(points, color, 3, true)
		else:
			draw_circle(points[0], 4, color)
	var font := ThemeDB.fallback_font
	var ink := Color("#17394a") if light else Color("#dce9f5")
	draw_string(font, Vector2(24, size.y - 16), "%s %d → %d  |  %s %s" % [GameLocale.translate("Age"), int(history[0].age), int(history[-1].age), GameLocale.translate("Scale"), GameLocale.money(upper)], HORIZONTAL_ALIGNMENT_LEFT, size.x - 48, 23, ink)


func _background(light: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#edf3fa") if light else Color("#12213b")
	style.border_color = Color("#cbd5e1" if light else "#334155")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style
