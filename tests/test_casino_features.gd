extends Node

func _ready() -> void:
	print("=== BEGIN CASINO FEATURE VERIFICATION ===")
	
	PlayerData.reset_player()
	PlayerData.first_name = "Lucky"
	PlayerData.age = 25
	PlayerData.money = 25 # Exactly like the user's screenshot!
	
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
	
	PlayerData.money = 25
	PlayerData.bank_savings = 0
	PlayerData.age = 25
	
	# 1. Open Casino Modal
	main._show_casino_modal()
	assert(main.casino_modal_overlay != null, "Casino overlay must be valid")
	assert(main.casino_modal_overlay.visible == true, "Casino overlay must be visible")
	
	# Verify subtitle does NOT contain arbitrary 0/1 limit
	var subtitle_text: String = main.casino_subtitle_lbl.text if main.casino_subtitle_lbl != null else ""
	print("Casino Subtitle: %s" % subtitle_text)
	assert(not "Plays left: 0/1" in subtitle_text, "Subtitle must not show 0/1 limit")
	assert(not "(Limit Reached)" in subtitle_text, "Subtitle must not show Limit Reached")
	assert("Cash: $25" in subtitle_text, "Subtitle must show accurate cash ($25)")
	print("✔ CHECK 1: Casino header displays cleanly with cash and no arbitrary lockout counter.")
	
	# 2. Check Button States with $25 Cash
	assert(main.casino_scratch_btn != null, "Scratch button must exist")
	assert(main.casino_scratch_btn.disabled == false, "Player with $25 CAN afford $25 scratchcard")
	assert(not "(Limit Reached)" in main.casino_scratch_btn.text, "Scratch button must not say Limit Reached")
	print("✔ CHECK 2: Scratchcard button is ENABLED and playable with $25 cash.")
	
	assert(main.casino_slots_btn != null, "Slots button must exist")
	assert(main.casino_slots_btn.disabled == true, "Slots costs $50, so player with $25 cannot spin yet")
	assert("Insufficient Funds" in main.casino_slots_btn.text, "Slots button clearly indicates insufficient funds")
	print("✔ CHECK 3: Slots button properly displays Insufficient Funds for $50 spin.")
	
	# 3. Check Dice Wager Options
	assert(main.casino_dice_bet_btns.size() >= 4, "Dice bet options should include low bets ($10, $25, etc.)")
	var bet_values: Array[int] = []
	for b in main.casino_dice_bet_btns:
		bet_values.append(int(b.get_meta("bet_amount", 0)))
	assert(10 in bet_values and 25 in bet_values, "Accessible bet amounts ($10, $25) must be available")
	assert(main.current_dice_bet_amount <= 25, "Default bet amount should be accessible ($25 or lower)")
	
	# Prediction buttons should be enabled for current affordable wager
	for btn_roll in main.casino_dice_roll_btns:
		assert(btn_roll.disabled == false, "Prediction roll button must be enabled when wager <= cash")
	print("✔ CHECK 4: Low accessible dice bets ($10, $25) available and prediction buttons enabled.")
	
	# 4. Play Scratchcard
	var initial_overlay = main.casino_modal_overlay
	main.casino_scratch_btn.emit_signal("pressed")
	await get_tree().process_frame
	
	# Verify modal overlay was NOT destroyed and recreated
	assert(main.casino_modal_overlay == initial_overlay, "Modal must update in-place without destroying and recreating overlay")
	# Verify result text is displayed
	var scratch_result: String = main.casino_scratch_result_lbl.text
	print("Scratchcard result: %s" % scratch_result)
	assert("WINNER" in scratch_result or "No match" in scratch_result, "Scratchcard result must be displayed and persist")
	print("✔ CHECK 5: Scratchcard played, result displayed and persisted in place.")
	
	# 5. Play with Wealthier Funds & Slots
	PlayerData.money = 500
	main._sync_casino_ui()
	assert(main.casino_slots_btn.disabled == false, "With $500, Slots button must be enabled")
	
	main.casino_slots_btn.emit_signal("pressed")
	await get_tree().process_frame
	
	var slots_display: String = main.casino_slots_display_lbl.text
	var slots_result: String = main.casino_slots_result_lbl.text
	print("Slots display: %s, result: %s" % [slots_display, slots_result])
	assert(slots_display != "[ 🎰 | 🎰 | 🎰 ]", "Slots display must show rolled reels")
	assert(slots_result != "", "Slots result text must be visible")
	print("✔ CHECK 6: Slots spin executed and reel results clearly displayed in place.")
	
	# 6. Play Dice Roll Multiple Times
	main.current_dice_bet_amount = 50
	main._sync_casino_ui()
	main._play_dice_roll("under")
	await get_tree().process_frame
	
	var dice_display: String = main.casino_dice_display_lbl.text
	var dice_result: String = main.casino_dice_result_lbl.text
	print("Dice display: %s, result: %s" % [dice_display, dice_result])
	assert("🎲 [" in dice_display, "Dice display must show rolled dice values")
	assert("WINNER" in dice_result or "LOST" in dice_result, "Dice result must show outcome")
	
	# Play again immediately (unlimited plays)
	main._play_dice_roll("seven")
	await get_tree().process_frame
	assert(main.casino_scratch_btn.disabled == false, "Player can continue playing; no lockout")
	assert(main.casino_slots_btn.disabled == false, "Player can continue playing slots; no lockout")
	print("✔ CHECK 7: Multiple plays work consecutively without any lockout or limit reached.")
	
	print("=== ALL CASINO FEATURE VERIFICATIONS PASSED SUCCESSFULLY ===")
	get_tree().quit(0)
