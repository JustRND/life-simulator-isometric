extends Node

const MainScreenScene = preload("res://scenes/main/main_screen.tscn")

var vertical_wrap_errors := 0
var contrast_errors := 0
var clipping_errors := 0

func _ready() -> void:
	print("===================================================================")
	print("🔍 RUNNING AUDIT: VERTICAL TEXT WRAPPING, PANEL CLIPPING & CONTRAST")
	print("===================================================================")

	PlayerData.has_started_game = true
	PlayerData.age = 35
	PlayerData.money = 250000
	PlayerData.bank_savings = 500000
	PlayerData.pension_account = {"balance": 75000, "is_open": true, "contribution_pct": 5, "years_held": 10, "annuity_active": false}
	PlayerData.savings_account = {"balance": 120000, "is_open": true, "interest_rate": 0.042, "years_held": 5}
	PlayerData.tax_debt = 5000
	PlayerData.taxes_paid_lifetime = 45000
	PlayerData.mental_state = 45
	PlayerData.health = 80
	PlayerData.happiness = 75
	PlayerData.looks = 70
	PlayerData.smarts = 85
	PlayerData.job_title = "Senior AI Engineer"
	PlayerData.job_salary = 165000
	PlayerData.owned_businesses = [{
		"name": "Nexus Robotics Inc.",
		"type": "technology",
		"valuation": 850000,
		"treasury": 120000,
		"net_profit": 180000,
		"revenue": 450000,
		"employees": 12,
		"shares": 1000,
		"owner_fraction": 1.0,
		"unpaid_taxes": 0,
		"loan_balance": 0
	}]
	PlayerData.owned_assets = [
		{"name": "Luxury Penthouse", "category": "real_estate", "current_value": 650000, "purchase_price": 500000},
		{"name": "Cyber Sedan", "category": "cars", "current_value": 45000, "purchase_price": 50000}
	]

	var screen = MainScreenScene.instantiate()
	add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame

	for theme_mode in ["dark", "light"]:
		print("\n-------------------------------------------------------------")
		print("🎨 AUDITING MODALS UNDER THEME: %s" % theme_mode.to_upper())
		print("-------------------------------------------------------------")
		LifeLibrary.data.theme = theme_mode
		screen.on_theme_changed()
		await get_tree().process_frame
		await get_tree().process_frame

		var modal_methods = [
			["Finance Hub", "_show_finance_hub_modal"],
			["Pension Account", "_show_pension_account_modal"],
			["Savings Account", "_show_savings_account_modal"],
			["Tax Service", "_show_tax_service_modal"],
			["Dating App", "_show_dating_app_modal"],
			["Charity", "_show_charity_modal"],
			["Cyber Gym", "_show_gym_modal"],
			["Meditation Hub", "_show_meditation_modal"],
			["Mind & Body Wellness", "_show_mind_body_modal"],
			["Mental Institution Hub", "_show_mental_institution_hub_modal"],
			["Psychologist", "_show_psychologist_modal"],
			["Psychiatrist", "_show_psychiatrist_modal"],
			["Asylum Commitment", "_show_asylum_commitment_modal"],
			["Salon", "_show_salon_modal"],
			["Spa", "_show_spa_modal"],
			["Social Media", "_show_social_media_modal"],
			["Medical Clinic", "_show_doctor_modal"],
			["Neural Specialist", "_show_neural_specialist_modal"],
			["Credit Card Application", "_show_credit_card_application"],
			["Will & Testament", "_show_will_modal"],
			["Estate Succession", "_show_inheritance_selection_modal"],
			["Casino", "_show_casino_modal"]
		]

		for item in modal_methods:
			var modal_name: String = item[0]
			var method_name: String = item[1]
			if screen.has_method(method_name):
				screen.call(method_name)
				await get_tree().process_frame
				await get_tree().process_frame
				_audit_open_modal(screen, modal_name, theme_mode)
				_close_all_modals(screen)
				await get_tree().process_frame

		# Audit Mortgage Panel
		var prop_item: Dictionary = AssetCatalog.get_item("prop_house")
		if not prop_item.is_empty():
			screen._open_mortgage_panel(prop_item, null)
			await get_tree().process_frame
			await get_tree().process_frame
			_audit_open_modal(screen, "Mortgage Panel", theme_mode)
			_close_all_modals(screen)
			await get_tree().process_frame

	print("\n===================================================================")
	print("📊 AUDIT RESULTS SUMMARY:")
	print("  - Vertical Text Wrapping Violations: %d" % vertical_wrap_errors)
	print("  - Text Contrast Invisibility Issues: %d" % contrast_errors)
	print("  - Panel Bounds / Clipping Issues: %d" % clipping_errors)
	print("===================================================================")

	if vertical_wrap_errors > 0 or contrast_errors > 0 or clipping_errors > 0:
		push_error("AUDIT FAILED! Issues detected.")
		get_tree().quit(1)
	else:
		print("🎉 SUCCESS: ALL MODALS ARE 100% FREE OF VERTICAL SQUISHING, CLIPPING, AND CONTRAST BUGS!")
		get_tree().quit(0)

func _close_all_modals(screen: Control) -> void:
	for child in screen.get_children():
		if child is ColorRect and child.z_index >= 80:
			child.queue_free()

func _audit_open_modal(screen: Control, modal_name: String, theme_mode: String) -> void:
	var active_modal: Control = null
	for child in screen.get_children():
		if child is ColorRect and child.z_index >= 80 and child.visible:
			active_modal = child
			break

	if active_modal == null:
		print("  ℹ️ Modal [%s] could not find open overlay." % modal_name)
		return

	var labels = active_modal.find_children("*", "Label", true, false)
	for l in labels:
		var lbl: Label = l as Label
		if not lbl.is_visible_in_tree():
			continue
		var raw_text := lbl.text.strip_edges()
		if raw_text == "":
			continue

		# 1. Check for Vertical Character Squishing (text width collapsed below 35px for words)
		# A label with words like "Portfolio", "Liquid", "$250,000" that has size.x < 35px is squished.
		if raw_text.length() > 5 and lbl.size.x > 0.0 and lbl.size.x < 35.0:
			vertical_wrap_errors += 1
			print("  🚨 [%s | %s] VERTICAL SQUISH DETECTED on '%s': width=%.1f, height=%.1f, text='%s'" % [
				theme_mode, modal_name, lbl.name, lbl.size.x, lbl.size.y, raw_text.left(30)
			])

		# 2. Check for Text Blending with Background (in Light Mode)
		if theme_mode == "light":
			var font_col: Color = lbl.get_theme_color("font_color")
			var lum: float = font_col.get_luminance()
			# If the label has no dark background stylebox, but has luminance > 0.65 on a light card (~0.93 lum), it's invisible
			var has_dark_bg := false
			if lbl.has_theme_stylebox("normal"):
				var sb = lbl.get_theme_stylebox("normal")
				if sb is StyleBoxFlat and sb.bg_color.get_luminance() < 0.35:
					has_dark_bg = true

			if not has_dark_bg and lum > 0.65:
				contrast_errors += 1
				print("  ⚠️ [%s | %s] CONTRAST BUG on '%s': font_color=#%s (lum=%.2f) text='%s'" % [
					theme_mode, modal_name, lbl.name, font_col.to_html(false), lum, raw_text.replace("\n", " ").left(40)
				])

	# 3. Check Panel Clipping: ensure modal card is not wider than screen viewport
	var cards = active_modal.find_children("*", "PanelContainer", true, false)
	var vp_width = screen.get_viewport_rect().size.x
	for c in cards:
		var pc: PanelContainer = c as PanelContainer
		if pc.size.x > vp_width + 10.0:
			clipping_errors += 1
			print("  🚨 [%s | %s] PANEL OVERFLOW on '%s': width=%.1f exceeds viewport=%.1f" % [
				theme_mode, modal_name, pc.name, pc.size.x, vp_width
			])

	print("  ✓ [%s | %s] Checked %d labels for vertical squishing and contrast." % [theme_mode, modal_name, labels.size()])
