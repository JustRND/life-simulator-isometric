extends Control

## TestTextInputPopup
## Rigorously tests the universal pop-up text input panel, typing indicator/caret,
## mobile keyboard support, theme contrast, responsive top placement, and multi-action support.

func _ready() -> void:
	print("===================================================================")
	print("🧪 RUNNING POP-UP TEXT INPUT PANEL & MOBILE KEYBOARD TEST SUITE")
	print("===================================================================")

	# Ensure MobileKeyboardService / MobileKeyboardManager is ready
	if MobileKeyboardManager == null:
		var kb_mgr = preload("res://scripts/ui/mobile_keyboard_manager.gd").new()
		add_child(kb_mgr)

	await get_tree().process_frame
	await get_tree().process_frame

	# -------------------------------------------------------------
	# Test 1: Upper Safe-Zone Placement & Keyboard Clearance
	# -------------------------------------------------------------
	print("\n--- Test 1: Pop-up Placement & Mobile Keyboard Clearance ---")
	var p1 := MobileKeyboardManager.show_input_popup({
		"title": "Enter Character Name",
		"subtitle": "Choose a unique identity for your character.",
		"initial_value": "Alex Vance",
		"placeholder": "Enter character name..."
	})
	assert(p1 != null, "Pop-up overlay must be created")
	assert(MobileKeyboardManager.is_popup_open(), "is_popup_open() must return true")

	var card1: PanelContainer = p1.find_child("PopupCard", true, false) as PanelContainer
	assert(card1 != null, "PopupCard must exist")
	assert(card1.offset_top >= 110.0, "PopupCard top offset must be >= 110px to sit in upper safe zone above keyboard")
	assert(card1.anchor_top == 0.0, "PopupCard anchor_top must be 0.0 (top-anchored, not vertically centered)")

	print("  ✓ PopupCard is top-anchored at offset_top = %d (safe from bottom 55%% virtual keyboard)" % int(card1.offset_top))
	MobileKeyboardManager.close_active_popup()
	assert(not MobileKeyboardManager.is_popup_open(), "close_active_popup() must close active popup")
	print("✔ Test 1 passed: Upper safe-zone positioning verified!")

	# -------------------------------------------------------------
	# Test 2: Blinking Text / Typing Indicator (Caret) Placement & Padding
	# -------------------------------------------------------------
	print("\n--- Test 2: Typing Indicator (Caret) Visibility, Blink & Padding ---")
	var p2 := MobileKeyboardManager.show_input_popup({
		"title": "Bank Transfer Amount",
		"subtitle": "Enter whole dollars to transfer.",
		"placeholder": "Enter whole dollars...",
		"keyboard_type": LineEdit.KEYBOARD_TYPE_NUMBER
	})
	var input_box2: LineEdit = p2.find_child("PopupInputBox", true, false) as LineEdit
	assert(input_box2 != null, "PopupInputBox LineEdit must exist")
	assert(input_box2.caret_blink, "caret_blink must be true for visible typing indicator")
	assert(input_box2.caret_blink_interval > 0.0, "caret_blink_interval must be positive")
	assert(input_box2.caret_force_displayed, "caret_force_displayed must be true to keep typing indicator visible")
	assert(input_box2.virtual_keyboard_enabled, "virtual_keyboard_enabled must be true for mobile support")

	var normal_sb: StyleBoxFlat = input_box2.get_theme_stylebox("normal") as StyleBoxFlat
	assert(normal_sb != null, "Input box must have StyleBoxFlat")
	assert(normal_sb.content_margin_left >= 16.0, "content_margin_left must be >= 16px to prevent caret border clipping")
	assert(normal_sb.content_margin_right >= 16.0, "content_margin_right must be >= 16px")
	assert(normal_sb.content_margin_top >= 8.0, "content_margin_top must be >= 8px")
	assert(normal_sb.content_margin_bottom >= 8.0, "content_margin_bottom must be >= 8px")

	var caret_col: Color = input_box2.get_theme_color("caret_color")
	assert(caret_col.a > 0.5, "caret_color must have full alpha opacity")
	print("  ✓ Caret blink = %s, interval = %.1fs, force_displayed = %s, left padding = %dpx" % [
		input_box2.caret_blink, input_box2.caret_blink_interval, input_box2.caret_force_displayed, int(normal_sb.content_margin_left)
	])
	MobileKeyboardManager.close_active_popup()
	print("✔ Test 2 passed: Typing indicator (caret) is properly configured and never clipped!")

	# -------------------------------------------------------------
	# Test 3: Universal Target Control Binding & Signal Emission
	# -------------------------------------------------------------
	print("\n--- Test 3: Universal Target Control Binding & Signal Emission ---")
	var target_le := LineEdit.new()
	target_le.name = "CustomAmountField"
	target_le.placeholder_text = "Enter dollars..."
	target_le.text = "500"
	add_child(target_le)

	MobileKeyboardManager.attach_to_input(target_le, "Custom Amount Prompt")

	var state := {
		"changed": false,
		"submitted": false,
		"text": ""
	}

	target_le.text_changed.connect(func(new_val: String):
		state["changed"] = true
		state["text"] = new_val
	)
	target_le.text_submitted.connect(func(_sub_val: String):
		state["submitted"] = true
	)

	# Tapping or calling open_keyboard on target input
	MobileKeyboardManager.open_keyboard(target_le)
	assert(MobileKeyboardManager.is_popup_open(), "Calling open_keyboard must open popup")

	var p3 := MobileKeyboardManager._active_popup_control
	var input_box3: LineEdit = p3.find_child("PopupInputBox", true, false) as LineEdit
	assert(input_box3.text == "500", "Popup input must inherit initial value from target")

	var title_lbl3: Label = p3.find_child("PopupTitle", true, false) as Label
	assert(title_lbl3.text == "CUSTOM AMOUNT PROMPT", "Popup title must inherit prompt title")

	# Simulate typing new value and confirming
	input_box3.text = "12500"
	var confirm_btn: Button = p3.find_child("PopupConfirmButton", true, false) as Button
	assert(confirm_btn != null, "Confirm button must exist")
	confirm_btn.emit_signal("pressed")

	assert(not MobileKeyboardManager.is_popup_open(), "Popup must close upon confirmation")
	assert(target_le.text == "12500", "Target LineEdit text must be updated to 12500")
	assert(state["changed"], "target_le.text_changed signal must be emitted")
	assert(state["submitted"], "target_le.text_submitted signal must be emitted")
	assert(state["text"] == "12500", "Received text must match confirmed value")

	print("  ✓ Target LineEdit updated from '500' to '%s', signals emitted cleanly." % target_le.text)
	target_le.queue_free()
	print("✔ Test 3 passed: Universal input binding, updates, and signal cascades verified!")

	# -------------------------------------------------------------
	# Test 4: Custom Multi-Action Buttons (Treasury Dual-Action Support)
	# -------------------------------------------------------------
	print("\n--- Test 4: Custom Multi-Action Buttons (Treasury Dual Actions) ---")
	var custom_res := {
		"dividend": 0,
		"capital": 0
	}

	var act_div := {
		"label": "💰 Withdraw Dividend",
		"color": Color("#10b981"),
		"callback": func(val_str: String):
			custom_res["dividend"] = int(val_str)
	}
	var act_inj := {
		"label": "💵 Inject Capital",
		"color": Color("#0284c7"),
		"callback": func(val_str: String):
			custom_res["capital"] = int(val_str)
	}

	var p4 := MobileKeyboardManager.show_input_popup({
		"title": "CORPORATE TREASURY TRANSFER",
		"subtitle": "Treasury: $5,000,000 • Personal Funds: $250,000",
		"placeholder": "Enter whole dollars...",
		"keyboard_type": LineEdit.KEYBOARD_TYPE_NUMBER,
		"custom_actions": [act_div, act_inj]
	})

	var btn_row4: HBoxContainer = p4.find_child("PopupActionButtons", true, false) as HBoxContainer
	assert(btn_row4 != null, "PopupActionButtons container must exist")
	assert(btn_row4.get_child_count() == 3, "Must contain Withdraw, Inject, and Cancel buttons")

	var input_box4: LineEdit = p4.find_child("PopupInputBox", true, false) as LineEdit
	input_box4.text = "75000"

	# Click "💰 Withdraw Dividend"
	var div_btn: Button = btn_row4.get_child(0) as Button
	assert(div_btn.text == "💰 Withdraw Dividend", "First button must be Withdraw Dividend")
	div_btn.emit_signal("pressed")

	assert(not MobileKeyboardManager.is_popup_open(), "Popup must close after custom action")
	assert(custom_res["dividend"] == 75000, "Withdraw dividend callback must receive 75000")
	assert(custom_res["capital"] == 0, "Inject capital must not be triggered")
	print("  ✓ Custom action executed with value %d and popup closed cleanly." % custom_res["dividend"])
	print("✔ Test 4 passed: Multi-action buttons (Treasury dual-action) verified!")

	# -------------------------------------------------------------
	# Test 5: Light & Dark Theme Contrast & Readability
	# -------------------------------------------------------------
	print("\n--- Test 5: Theme Styling & Contrast (Dark & Light) ---")
	for theme_mode in ["dark", "light"]:
		if LifeLibrary != null and LifeLibrary.data != null:
			LifeLibrary.data.theme = theme_mode

		var pt := MobileKeyboardManager.show_input_popup({
			"title": "Theme Verification Modal",
			"subtitle": "Checking high contrast and no vertical squishing",
			"placeholder": "Test contrast..."
		})

		var card: PanelContainer = pt.find_child("PopupCard", true, false) as PanelContainer
		var title_lbl: Label = pt.find_child("PopupTitle", true, false) as Label
		var sub_lbl: Label = pt.find_child("PopupSubtitle", true, false) as Label
		var input_box: LineEdit = pt.find_child("PopupInputBox", true, false) as LineEdit

		var card_sb: StyleBoxFlat = card.get_theme_stylebox("panel") as StyleBoxFlat
		var card_bg: Color = card_sb.bg_color

		var t_col: Color = title_lbl.get_theme_color("font_color")
		var s_col: Color = sub_lbl.get_theme_color("font_color")
		var in_col: Color = input_box.get_theme_color("font_color")

		var lum_bg := card_bg.get_luminance()
		var lum_t := t_col.get_luminance()
		var lum_s := s_col.get_luminance()
		var lum_in := in_col.get_luminance()

		# Contrast difference check: Ensure text does NOT blend with card background
		assert(abs(lum_t - lum_bg) >= 0.25, "Title must have clear contrast with card bg in %s mode" % theme_mode)
		assert(abs(lum_s - lum_bg) >= 0.20, "Subtitle must have clear contrast with card bg in %s mode" % theme_mode)
		assert(abs(lum_in - lum_bg) >= 0.25, "Input text must have clear contrast in %s mode" % theme_mode)

		print("  ✓ [%s mode] Card bg lum=%.2f, Title lum=%.2f (diff=%.2f), Input text lum=%.2f" % [
			theme_mode, lum_bg, lum_t, abs(lum_t - lum_bg), lum_in
		])
		MobileKeyboardManager.close_active_popup()

	# Restore dark theme
	if LifeLibrary != null and LifeLibrary.data != null:
		LifeLibrary.data.theme = "dark"
	print("✔ Test 5 passed: Both Dark and Light themes have high contrast and zero blending!")

	# -------------------------------------------------------------
	# Test 6: Zero Vertical Text Squishing & Proper Dimensions
	# -------------------------------------------------------------
	print("\n--- Test 6: Zero Vertical Text Squishing Audit ---")
	var p6 := MobileKeyboardManager.show_input_popup({
		"title": "Vertical Squishing Audit",
		"subtitle": "Ensure all action buttons and labels expand horizontally without vertical text",
		"placeholder": "Sample text..."
	})

	await get_tree().process_frame

	var labels := p6.find_children("", "Label", true, false)
	for l in labels:
		var lbl := l as Label
		if not lbl.is_visible_in_tree() or lbl.text.is_empty():
			continue
		assert(lbl.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART or lbl.autowrap_mode == TextServer.AUTOWRAP_WORD,
			"Label '%s' must have AUTOWRAP_WORD_SMART to prevent letter squishing" % lbl.text)

	var buttons := p6.find_children("", "Button", true, false)
	for b in buttons:
		var btn := b as Button
		if not btn.is_visible_in_tree() or btn.text.is_empty():
			continue
		assert(btn.custom_minimum_size.y >= 50.0, "Button '%s' must have min height >= 50px" % btn.text)
		assert(btn.size_flags_horizontal == Control.SIZE_EXPAND_FILL or btn.size.x > btn.size.y,
			"Button '%s' must expand horizontally to prevent vertical text" % btn.text)

	print("  ✓ Checked %d labels and %d buttons for vertical squishing violations: 0 found." % [labels.size(), buttons.size()])
	MobileKeyboardManager.close_active_popup()
	print("✔ Test 6 passed: Zero vertical text squishing verified!")

	# -------------------------------------------------------------
	# Test 7: Enter Key / Text Submitted and Backdrop Dismissal
	# -------------------------------------------------------------
	print("\n--- Test 7: Enter Key Submission & Backdrop Dismissal ---")
	var test7_state := {
		"submitted": "",
		"cancelled": false
	}
	var p7 := MobileKeyboardManager.show_input_popup({
		"title": "Enter Key Test",
		"on_confirm": func(v: String):
			test7_state["submitted"] = v
	})
	var input_box7: LineEdit = p7.find_child("PopupInputBox", true, false) as LineEdit
	input_box7.text = "Hello Antigravity"
	input_box7.emit_signal("text_submitted", "Hello Antigravity")

	assert(not MobileKeyboardManager.is_popup_open(), "Enter key must confirm and close popup")
	assert(test7_state["submitted"] == "Hello Antigravity", "on_confirm callback must receive submitted text")
	print("  ✓ Enter key submission confirmed value: '%s'" % test7_state["submitted"])

	# Test backdrop click dismissal
	var p7_cancel := MobileKeyboardManager.show_input_popup({
		"title": "Backdrop Dismissal Test",
		"on_cancel": func():
			test7_state["cancelled"] = true
	})
	var backdrop7: ColorRect = p7_cancel.find_child("PopupBackdrop", true, false) as ColorRect
	assert(backdrop7 != null, "PopupBackdrop must exist")

	var click_event := InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = true
	backdrop7.emit_signal("gui_input", click_event)

	assert(not MobileKeyboardManager.is_popup_open(), "Backdrop click must dismiss popup")
	assert(test7_state["cancelled"], "on_cancel callback must be called on backdrop dismissal")
	print("  ✓ Backdrop click dismissed popup cleanly.")
	print("✔ Test 7 passed: Enter key submission and backdrop dismissal verified!")

	print("\n===================================================================")
	print("🎉 ALL POP-UP TEXT INPUT & MOBILE KEYBOARD TESTS PASSED! 🎉")
	print("===================================================================")
	get_tree().quit(0)
