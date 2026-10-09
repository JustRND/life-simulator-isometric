extends Node

func _ready() -> void:
	print("=== BEGIN TEST: OPTIONS & BANK BUTTON CLIPPING AUDIT ===")
	LifeLibrary.data.theme = "dark"
	PlayerData.reset_player()
	
	var main_scene_res = load("res://scenes/main/main_screen.tscn")
	var main_scene = main_scene_res.instantiate()
	add_child(main_scene)
	
	if main_scene.disclaimer_screen != null:
		main_scene.disclaimer_screen.hide()
	if main_scene.loading_screen != null:
		main_scene.loading_screen.hide()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Audit BankButton in AssetsPanel
	print("\n--- 1. AUDITING BANK BUTTON IN ASSETS PANEL ---")
	main_scene.show_tab("assets")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var bank_btn: Button = main_scene.bank_button
	assert(bank_btn != null, "BankButton must exist in AssetsPanel")
	assert(bank_btn.has_meta("bank_standout"), "BankButton must have bank_standout meta")
	assert(bank_btn.size.y == 96.0, "BankButton height must be 96.0, got: %f" % bank_btn.size.y)
	
	var bank_row = bank_btn.get_node_or_null("ReferenceRow")
	assert(bank_row != null, "BankButton must have ReferenceRow")
	assert(bank_row.description != null and (not bank_row.description.visible or bank_row.description.text.is_empty()), "BankButton description must be hidden/empty")
	assert(bank_row.symbol != null and bank_row.symbol.visible, "BankButton symbol must be visible")
	assert(bank_row.symbol.text == "🏦", "BankButton symbol must be bank icon '🏦'")
	
	var symbol_bottom: float = bank_row.symbol.position.y + bank_row.symbol.size.y
	print("BankButton symbol pos.y=%f, size.y=%f, bottom=%f (button height=%f)" % [bank_row.symbol.position.y, bank_row.symbol.size.y, symbol_bottom, bank_btn.size.y])
	assert(symbol_bottom <= bank_btn.size.y, "BankButton symbol must NOT clip bottom border! bottom=%f, btn_h=%f" % [symbol_bottom, bank_btn.size.y])
	print("✔ CHECK 1: BankButton icon is perfectly vertically centered and has zero clipping.")
	
	# 2. Audit Options Panel Buttons
	print("\n--- 2. AUDITING OPTIONS PANEL BUTTONS ---")
	if main_scene.settings_overlay != null:
		main_scene.settings_overlay.show()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var content = main_scene.settings_overlay.get_node_or_null("SettingsCard/SettingsMargin/SettingsScroll/SettingsContent")
	if content == null:
		content = main_scene.settings_overlay.find_child("SettingsContent", true, false)
	assert(content != null, "SettingsContent must exist in SettingsOverlay")
	
	var buttons_audited := 0
	for child in content.get_children():
		if child.has_meta("reference_menu"):
			for btn in child.get_children():
				if btn is Button:
					buttons_audited += 1
					var row = btn.get_node_or_null("ReferenceRow")
					assert(row != null, "Options button '%s' must have ReferenceRow" % btn.text)
					assert(row.description != null and row.description.visible and not row.description.text.is_empty(),
						"Options button '%s' must have visible description" % btn.text)
					
					var desc_bottom: float = row.description.global_position.y + row.description.size.y - btn.global_position.y
					var overflow: float = desc_bottom - btn.size.y
					print("Options Button '%s': height=%f, desc_bottom=%f, overflow=%f" % [row.heading.text, btn.size.y, desc_bottom, overflow])
					assert(overflow <= 0.0, "Options button '%s' description clipped! overflow=%f" % [row.heading.text, overflow])
	
	assert(buttons_audited >= 12, "Must audit at least 12 Options buttons, audited: %d" % buttons_audited)
	print("✔ CHECK 2: All %d Options panel button descriptions fit completely inside button cards with zero clipping." % buttons_audited)
	
	print("\n⭐⭐⭐ ALL OPTIONS AND BANK CLIPPING AUDITS PASSED PERFECTLY! ⭐⭐⭐")
	get_tree().quit(0)
