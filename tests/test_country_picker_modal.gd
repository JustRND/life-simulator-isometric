extends SceneTree

const CreationOptions = preload("res://scripts/core/creation_options.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")
const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")
const CountryPickerModal = preload("res://scripts/ui/country_picker_modal.gd")
const TouchScrollController = preload("res://scripts/ui/touch_scroll_controller.gd")

func _init() -> void:
	print("--- Running Test Country Picker Modal & Flag System ---")
	test_country_and_flag_catalog()
	test_names_and_portraits_for_all_countries()
	test_country_picker_modal_ui()
	print("\n--- ALL COUNTRY PICKER & FLAG TESTS PASSED SUCCESSFULLY! ---")
	quit()

func test_country_and_flag_catalog() -> void:
	print("\n[1] Testing 81 Countries & Flags...")
	var countries: Array = CreationOptions.COUNTRIES
	print("Total countries defined: ", countries.size())
	assert(countries.size() >= 80, "Expected at least 80 countries in CreationOptions.COUNTRIES")
	
	# Verify every country has valid column, row, and atlas texture
	for entry in countries:
		var c_name: String = str(entry[0])
		var col: int = int(entry[1])
		var row: int = int(entry[2])
		assert(not c_name.is_empty(), "Country name cannot be empty")
		assert(col >= 0 and col < 16, "Column must be within 0..15: " + c_name)
		assert(row >= 0 and row < 18, "Row must be within 0..17: " + c_name)
		
		var tex: AtlasTexture = CreationOptions.flag_texture(col, row)
		assert(tex != null, "Flag texture must not be null for " + c_name)
		assert(tex.atlas != null, "Flag atlas must be valid for " + c_name)
		assert(tex.region.size.x > 0 and tex.region.size.y > 0, "Flag region must have non-zero dimensions for " + c_name)
	
	# Test get_flag_for_country lookup
	var indo_flag := CreationOptions.get_flag_for_country("Indonesia")
	assert(indo_flag != null, "Indonesia flag lookup must succeed")
	var usa_flag := CreationOptions.get_flag_for_country("United States")
	assert(usa_flag != null, "United States flag lookup must succeed")
	var norway_flag := CreationOptions.get_flag_for_country("Norway")
	assert(norway_flag != null, "Norway flag lookup must succeed")
	
	print("  PASS: All 81 countries have valid sheet coordinates and slice textures.")

func test_names_and_portraits_for_all_countries() -> void:
	print("\n[2] Testing Name Generation and Portrait Ethnicities for All Countries...")
	for entry in CreationOptions.COUNTRIES:
		var c_name: String = str(entry[0])
		
		# Test name generation (male and female)
		var male_name := NameCatalog.random_name(c_name, false)
		assert(not male_name.is_empty(), "Male name must not be empty for " + c_name)
		var female_name := NameCatalog.random_name(c_name, true)
		assert(not female_name.is_empty(), "Female name must not be empty for " + c_name)
		
		# Test portrait ethnicities
		var ethnicities := PortraitCatalog.get_country_ethnicities(c_name)
		assert(ethnicities.size() > 0, "Ethnicity list must not be empty for " + c_name)
		for eth in ethnicities:
			assert(eth in ["black", "asian", "white", "latino"], "Invalid ethnicity for " + c_name + ": " + eth)
		
		var rand_eth := PortraitCatalog.random_ethnicity_for_country(c_name)
		assert(rand_eth in ethnicities, "Random ethnicity must come from allowed ethnicities for " + c_name)
	
	print("  PASS: NameCatalog and PortraitCatalog fully support all 81 countries safely.")

func test_country_picker_modal_ui() -> void:
	print("\n[3] Testing CountryPickerModal UI, Touch Scrolling, and Gesture-Slop Logic...")
	var canvas := Control.new()
	canvas.custom_minimum_size = Vector2(1080, 1920)
	canvas.size = Vector2(1080, 1920)
	root.add_child(canvas)
	
	var touch_controller = TouchScrollController.new()
	canvas.add_child(touch_controller)
	
	var ob := OptionButton.new()
	for entry in CreationOptions.COUNTRIES:
		ob.add_icon_item(CreationOptions.get_flag_for_country(entry[0]), entry[0])
	canvas.add_child(ob)
	
	# Select Indonesia by default
	var indo_idx := -1
	for i in range(ob.item_count):
		if ob.get_item_text(i) == "Indonesia":
			indo_idx = i
			break
	assert(indo_idx >= 0, "Indonesia must be present in OptionButton items")
	ob.select(indo_idx)
	ob.text = "Indonesia"
	
	# 3A: Open modal
	var overlay = CountryPickerModal.open(canvas, ob)
	assert(overlay != null, "Modal overlay must be created")
	assert(CountryPickerModal.is_open(), "is_open() should return true")
	
	var scroll: ScrollContainer = overlay.find_child("CountryListScroll", true, false)
	assert(scroll != null, "Modal must contain CountryListScroll")
	
	var list_container: VBoxContainer = overlay.find_child("CountryListContainer", true, false)
	assert(list_container != null, "Modal must contain CountryListContainer")
	assert(list_container.get_child_count() == CreationOptions.COUNTRIES.size(), "Should have a button for each country")
	
	# Check Indonesia button has checkmark
	var indo_btn: Button = list_container.get_node_or_null("Country_Indonesia")
	assert(indo_btn != null, "Country_Indonesia button must exist")
	assert("✓" in indo_btn.text, "Active country button should display checkmark: " + indo_btn.text)
	
	# 3B: Test search filter
	var search_input: LineEdit = overlay.find_child("CountrySearchInput", true, false)
	assert(search_input != null, "Modal must contain CountrySearchInput")
	search_input.text = "japan"
	search_input.text_changed.emit("japan")
	
	var japan_btn: Button = list_container.get_node_or_null("Country_Japan")
	assert(japan_btn != null, "Japan button must exist")
	assert(japan_btn.visible, "Japan button should be visible when searching 'japan'")
	assert(not indo_btn.visible, "Indonesia button should be hidden when searching 'japan'")
	
	# Reset search
	search_input.text = ""
	search_input.text_changed.emit("")
	assert(indo_btn.visible, "Indonesia button should be visible after clearing search")
	
	# 3C: Test Gesture-Slop: Dragging >= 16px should NOT select button
	print("  Testing drag gesture (>= 16px)...")
	var prev_selected := ob.selected
	var japan_touch_start = InputEventScreenTouch.new()
	japan_touch_start.position = Vector2(50, 20)
	japan_touch_start.pressed = true
	japan_btn.gui_input.emit(japan_touch_start)
	
	var drag_move = InputEventScreenDrag.new()
	drag_move.position = Vector2(50, 70) # 50px delta >= 16px threshold
	japan_btn.gui_input.emit(drag_move)
	
	var japan_touch_end = InputEventScreenTouch.new()
	japan_touch_end.position = Vector2(50, 70)
	japan_touch_end.pressed = false
	japan_btn.gui_input.emit(japan_touch_end)
	
	assert(ob.selected == prev_selected, "Drag gesture must NOT change selected country!")
	assert(CountryPickerModal.is_open(), "Modal must remain open after drag gesture")
	print("  PASS: Drag gesture correctly ignored for button selection.")
	
	# 3D: Test Hold Duration: Holding > 650ms should NOT select button
	print("  Testing hold duration (> 650ms)...")
	var hold_start = InputEventScreenTouch.new()
	hold_start.position = Vector2(50, 20)
	hold_start.pressed = true
	japan_btn.gui_input.emit(hold_start)
	
	# Wait or simulate 700ms pass
	OS.delay_msec(700)
	var hold_end = InputEventScreenTouch.new()
	hold_end.position = Vector2(50, 20)
	hold_end.pressed = false
	japan_btn.gui_input.emit(hold_end)
	
	assert(ob.selected == prev_selected, "Hold > 650ms must NOT change selected country!")
	assert(CountryPickerModal.is_open(), "Modal must remain open after hold gesture")
	print("  PASS: Hold > 650ms correctly ignored for button selection.")
	
	# 3E: Test Clean Tap (< 16px, <= 650ms): Should select button and close modal
	print("  Testing clean tap (< 16px, <= 650ms)...")
	var tap_start = InputEventScreenTouch.new()
	tap_start.position = Vector2(50, 20)
	tap_start.pressed = true
	japan_btn.gui_input.emit(tap_start)
	
	# Simulate 50ms tap duration, moved only 2px
	OS.delay_msec(50)
	var tap_end = InputEventScreenTouch.new()
	tap_end.position = Vector2(52, 21)
	tap_end.pressed = false
	japan_btn.gui_input.emit(tap_end)
	
	assert(ob.text == "Japan", "Clean tap must select Japan on target OptionButton, got: " + ob.text)
	assert(ob.get_item_text(ob.selected) == "Japan", "OptionButton selected item must be Japan")
	print("  PASS: Clean tap successfully selected Japan and updated OptionButton!")
	
	canvas.queue_free()
