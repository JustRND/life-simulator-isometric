extends Node

func _ready() -> void:
	print("=== BEGIN MENTAL STATE UPDATE (ALPHA v0.1.1) COMPREHENSIVE VERIFICATION ===")

	# ---------------------------------------------------------
	# 1. PlayerData & Equilibrium Drift Logic Checks
	# ---------------------------------------------------------
	PlayerData.reset_player()
	PlayerData.first_name = "Alex"
	PlayerData.age = 25
	PlayerData.health = 90
	PlayerData.smarts = 90
	PlayerData.happiness = 90
	PlayerData.looks = 10  # Severe low looks
	PlayerData.money = 100000
	PlayerData.mental_state = 80

	var low_looks_shift = PlayerData.calculate_mental_state_drift()
	print("Annual shift with looks=10, others=90, mental=80: %d" % low_looks_shift)
	assert(low_looks_shift < 0, "Low looks must cause negative mental state drift when mental_state is 80")

	# Balanced high stats with lower mental state (mental_state = 40)
	PlayerData.looks = 85
	PlayerData.health = 85
	PlayerData.smarts = 85
	PlayerData.happiness = 85
	PlayerData.mental_state = 40
	var high_stats_shift = PlayerData.calculate_mental_state_drift()
	print("Annual shift with all stats=85, mental=40: %d" % high_stats_shift)
	assert(high_stats_shift > 5, "High balanced stats must provide positive recovery drift towards 85")

	# Clamping in apply_effects
	PlayerData.mental_state = 80
	PlayerData.apply_effects({"mental_state": 50})
	assert(PlayerData.mental_state == 100, "Mental state must be clamped to 100")
	PlayerData.apply_effects({"mental_state": -150})
	assert(PlayerData.mental_state == 0, "Mental state must be clamped to 0")
	PlayerData.mental_state = 75
	print("✔ CHECK 1: PlayerData mental state drift calculation and clamping verified.")

	# ---------------------------------------------------------
	# 2. Event Repetition & Cooldown Checks
	# ---------------------------------------------------------
	EventManager.load_events()
	assert(EventManager.events.size() == 57, "Must have exactly 57 events loaded, found %d" % EventManager.events.size())

	var scratch_event: Dictionary = {}
	var repeatable_event: Dictionary = {}
	for ev in EventManager.events:
		if ev.get("id") == "lottery_scratch_miracle":
			scratch_event = ev
		elif ev.get("id") == "crypto_windfall":
			repeatable_event = ev

	assert(not scratch_event.is_empty(), "lottery_scratch_miracle must exist")
	assert(not repeatable_event.is_empty(), "crypto_windfall must exist")
	assert(bool(scratch_event.get("repeatable", true)) == false, "lottery_scratch_miracle must not be repeatable")
	assert(int(repeatable_event.get("cooldown_years", 0)) > 0, "crypto_windfall must have cooldown_years > 0")

	# Non-repeatable event repeat check
	var passes_scratch_before = EventManager._passes_repeat_check(scratch_event, [], 20, {})
	assert(passes_scratch_before == true, "Non-repeatable event not in history must pass")
	var passes_scratch_after = EventManager._passes_repeat_check(scratch_event, ["lottery_scratch_miracle"], 25, {})
	assert(passes_scratch_after == false, "Non-repeatable event in history must NOT pass")

	# Repeatable event cooldown check
	var history_log: Dictionary = {"crypto_windfall": 20}
	var passes_soon = EventManager._passes_repeat_check(repeatable_event, ["crypto_windfall"], 22, history_log)
	assert(passes_soon == false, "Repeatable event during cooldown period must NOT pass")
	var passes_later = EventManager._passes_repeat_check(repeatable_event, ["crypto_windfall"], 34, history_log)
	assert(passes_later == true, "Repeatable event after cooldown period must pass")
	print("✔ CHECK 2: Event repetition rules and cooldown intervals verified.")

	# ---------------------------------------------------------
	# 3. UI & HUD Layout Checks (GridContainer icon-name-bar)
	# ---------------------------------------------------------
	var main_res := load("res://scenes/main/main_screen.tscn") as PackedScene
	assert(main_res != null, "main_screen.tscn must load")
	var main = main_res.instantiate()
	add_child(main)

	if main.disclaimer_screen != null:
		main.disclaimer_screen.hide()
	if main.loading_screen != null:
		main.loading_screen.hide()

	await get_tree().process_frame
	await get_tree().process_frame

	PlayerData.reset_player()
	PlayerData.first_name = "Alex"
	PlayerData.age = 25
	PlayerData.money = 50000
	PlayerData.is_in_mental_institution = false
	PlayerData.mental_institution_years_left = 0

	var stats_container = main.get_node_or_null("SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer")
	assert(stats_container != null, "StatsContainer must exist")
	assert(stats_container is GridContainer, "StatsContainer must be a GridContainer")
	var grid: GridContainer = stats_container as GridContainer
	assert(grid.columns == 2, "StatsContainer must have 2 columns (labels left, bars right)")

	var mental_label: Label = stats_container.get_node_or_null("MentalStateLabel")
	var mental_bar: ProgressBar = stats_container.get_node_or_null("MentalStateBar")
	assert(mental_label != null, "MentalStateLabel must exist")
	assert(mental_bar != null, "MentalStateBar must exist")
	assert(mental_bar.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "MentalStateBar must expand fill horizontally")

	# Check theme color of mental state bar
	var bar_fill: StyleBox = mental_bar.get_theme_stylebox("fill")
	assert(bar_fill is StyleBoxFlat, "MentalStateBar fill must be StyleBoxFlat")
	var bar_flat: StyleBoxFlat = bar_fill as StyleBoxFlat
	assert(bar_flat.bg_color.b > 0.8, "MentalStateBar must use the purple aesthetic palette")
	print("✔ CHECK 3: Stats HUD horizontal layout and Mental State status bar verified.")

	# ---------------------------------------------------------
	# 4. Activities Panel: Mental Institution Entry Point
	# ---------------------------------------------------------
	var mental_item = main.get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList/MentalInstitutionItem")
	assert(mental_item != null, "MentalInstitutionItem button must exist in ActivitiesPanel")

	# Test Underage gate
	PlayerData.age = 10
	main._on_mental_institution_item_pressed()
	assert(main.mental_institution_modal_overlay == null or not is_instance_valid(main.mental_institution_modal_overlay), "Underage player cannot access Mental Institution")

	# Test Valid Age access
	PlayerData.age = 25
	PlayerData.money = 50000
	main._on_mental_institution_item_pressed()
	assert(main.mental_institution_modal_overlay != null and is_instance_valid(main.mental_institution_modal_overlay), "Mental Institution modal must open")
	print("✔ CHECK 4: Mental Institution button and underage gating verified.")

	# ---------------------------------------------------------
	# 5. Psychologist Consultations
	# ---------------------------------------------------------
	PlayerData.mental_state = 40
	PlayerData.happiness = 40
	PlayerData.money = 20000
	var prev_funds = PlayerData.get_available_funds()

	# Open Psychologist panel
	main._show_psychologist_modal()
	assert(main.mental_institution_modal_overlay != null and is_instance_valid(main.mental_institution_modal_overlay), "Psychologist modal must open")

	var psych_list = _find_modal_list(main.mental_institution_modal_overlay)
	assert(psych_list != null, "List must exist in modal")

	# Child 0: return_btn, Child 1: info_lbl, Child 2: $450 session, Child 3: $1200 CBT
	var cbt_btn = psych_list.get_child(3) as Button
	assert(cbt_btn != null and cbt_btn.text.contains("1,200"), "CBT button ($1,200) must be present")
	cbt_btn.emit_signal("pressed")

	assert(PlayerData.get_available_funds() == prev_funds - 1200, "Money deducted properly for therapy")
	assert(PlayerData.mental_state == 58, "Mental state boosted by therapy (+18)")
	assert(PlayerData.happiness == 50, "Happiness boosted by therapy (+10)")
	print("✔ CHECK 5: Psychologist consultation purchase and stat boosts verified.")

	# ---------------------------------------------------------
	# 6. Psychiatrist Clinical Prescriptions
	# ---------------------------------------------------------
	PlayerData.mental_state = 50
	prev_funds = PlayerData.get_available_funds()

	# Open Psychiatrist panel
	main._show_psychiatrist_modal()
	assert(main.mental_institution_modal_overlay != null and is_instance_valid(main.mental_institution_modal_overlay), "Psychiatrist modal must open")

	var med_list = _find_modal_list(main.mental_institution_modal_overlay)
	assert(med_list != null, "Med list must exist in modal")
	# Child 0: return_btn, Child 1: info_lbl, Child 2: $850, Child 3: $2,200 SSRI
	var ssri_btn = med_list.get_child(3) as Button
	assert(ssri_btn != null and ssri_btn.text.contains("2,200"), "SSRI button ($2,200) must be present")
	ssri_btn.emit_signal("pressed")

	assert(PlayerData.get_available_funds() == prev_funds - 2200, "Money deducted properly for psychiatry")
	assert(PlayerData.mental_state == 74, "Mental state boosted by psychiatry (+24)")
	print("✔ CHECK 6: Psychiatrist prescription purchase and stat boosts verified.")

	# ---------------------------------------------------------
	# 7. Asylum Inpatient Commitment & 2-Year Lockout
	# ---------------------------------------------------------
	PlayerData.mental_state = 20
	PlayerData.money = 50000
	PlayerData.bank_savings = 0
	prev_funds = PlayerData.get_available_funds()

	# Show disclaimer modal
	main._show_asylum_commitment_modal()
	assert(main.mental_institution_modal_overlay != null and is_instance_valid(main.mental_institution_modal_overlay), "Asylum modal must open")

	var asylum_list = _find_modal_list(main.mental_institution_modal_overlay)
	assert(asylum_list != null, "Asylum list must exist in modal")
	# Child 0: notice_card, Child 1: confirm_btn
	var confirm_btn = asylum_list.get_child(1) as Button
	assert(confirm_btn != null and confirm_btn.text.contains("CONFIRM VOLUNTARY ADMISSION"), "Confirm button must be present")
	confirm_btn.emit_signal("pressed")

	assert(PlayerData.is_in_mental_institution == true, "Player is marked as inpatient")
	assert(PlayerData.mental_institution_years_left == 2, "Player committed for 2 years")

	# Check Lockouts: Activities and Assets must be blocked
	main.activities_panel.hide()
	main._on_activities_button_pressed()
	assert(main.activities_panel.visible == false, "Activities panel must remain closed while in asylum")

	main.assets_panel.hide()
	main._on_assets_button_pressed()
	assert(main.assets_panel.visible == false, "Assets panel must remain closed while in asylum")

	# Check Event suppression: trigger_event must not set current_event
	main.current_event = null
	main.event_overlay.hide()
	main.trigger_event()
	assert(main.current_event == null, "No events should ever trigger while in asylum")
	assert(main.event_overlay.visible == false, "Event overlay must not be shown while in asylum")

	# Year 1 Age Up
	var year1_mental_before = PlayerData.mental_state
	var year1_money_before = PlayerData.money
	main.age_up()
	assert(PlayerData.is_in_mental_institution == true, "Still in asylum after 1 year")
	assert(PlayerData.mental_institution_years_left == 1, "1 year left after first age up")
	assert(PlayerData.mental_state == year1_mental_before + 25, "Mental state restored by +25 in asylum")
	assert(PlayerData.money == year1_money_before - 15000, "Annual asylum fee $15,000 deducted")
	assert(main.event_overlay.visible == false, "Event overlay remained hidden during age up in asylum")

	# Year 2 Age Up (Discharge)
	main.age_up()
	assert(PlayerData.is_in_mental_institution == false, "Discharged after 2 years")
	assert(PlayerData.mental_institution_years_left == 0, "0 years left after discharge")

	# Check access restored
	main._on_activities_button_pressed()
	assert(main.activities_panel.visible == true, "Activities panel accessible again after discharge")
	print("✔ CHECK 7: Asylum admission, 2-year lockout, fee deductions, event suppression, and discharge verified.")

	# ---------------------------------------------------------
	# 8. Save & Load Persistence
	# ---------------------------------------------------------
	PlayerData.mental_state = 68
	PlayerData.is_in_mental_institution = true
	PlayerData.mental_institution_years_left = 1
	PlayerData.mental_institution_annual_cost = 15000
	PlayerData.record_event("burnout_wellness_retreat", 28)
	SaveManager.save_game()

	PlayerData.reset_player()
	assert(PlayerData.mental_state == 80, "Reset restores default mental state")
	assert(PlayerData.is_in_mental_institution == false, "Reset clears asylum flag")
	assert(PlayerData.event_history_log.is_empty(), "Reset clears event history log")

	SaveManager.load_game()
	assert(PlayerData.mental_state == 68, "Loaded mental state is 68")
	assert(PlayerData.is_in_mental_institution == true, "Loaded asylum flag is true")
	assert(PlayerData.mental_institution_years_left == 1, "Loaded years left is 1")
	assert(PlayerData.event_history_log.has("burnout_wellness_retreat"), "Loaded event history log has recorded event")
	print("✔ CHECK 8: Save and load persistence of mental state and asylum data verified.")

	print("\n⭐⭐⭐ ALL MENTAL STATE UPDATE (ALPHA v0.1.1) CHECKS PASSED! ⭐⭐⭐\n")
	get_tree().quit(0)


func _find_modal_list(overlay: Control) -> VBoxContainer:
	if overlay == null or not is_instance_valid(overlay):
		return null
	for child in overlay.find_children("*", "VBoxContainer", true, false):
		if child.has_meta("reference_menu"):
			return child as VBoxContainer
	return null
