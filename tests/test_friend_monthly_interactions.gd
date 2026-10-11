extends Node

const MainScreen = preload("res://scenes/main/main_screen.tscn")

func _ready() -> void:
	print("--- BEGIN TEST: FRIEND MONTHLY INTERACTIONS ---")
	var main = MainScreen.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	main.new_game_panel.hide()
	main.loading_screen.hide()
	main.disclaimer_screen.hide()

	PlayerData.reset_player()
	PlayerData.age = 22
	PlayerData.in_game_month = 5
	PlayerData.in_game_year = 2026

	# 1. Add two friends
	var f1 := {
		"id": "friend_maya_01",
		"name": "Maya Lin",
		"age": 22,
		"gender": "FEMALE",
		"relationship": 50,
		"occupation": "Graphic Designer",
		"personality": "Artistic"
	}
	var f2 := {
		"id": "friend_jake_02",
		"name": "Jake Peralta",
		"age": 23,
		"gender": "MALE",
		"relationship": 50,
		"occupation": "Detective",
		"personality": "Funny"
	}
	assert(PlayerData.add_friend(f1), "Failed to add friend 1")
	assert(PlayerData.add_friend(f2), "Failed to add friend 2")

	# 2. Check initial availability
	assert(PlayerData.can_interact_friend_hangout("friend_maya_01"), "Maya hangout should be available initially")
	assert(PlayerData.can_interact_friend_compliment("friend_maya_01"), "Maya compliment should be available initially")
	assert(PlayerData.can_interact_friend_hangout("friend_jake_02"), "Jake hangout should be available initially")
	assert(PlayerData.can_interact_friend_compliment("friend_jake_02"), "Jake compliment should be available initially")
	print("PASS: Initial availability confirmed")

	# 3. Record hangout with Maya
	PlayerData.record_friend_hangout("friend_maya_01")
	assert(not PlayerData.can_interact_friend_hangout("friend_maya_01"), "Maya hangout should NOT be available after use")
	assert(PlayerData.can_interact_friend_compliment("friend_maya_01"), "Maya compliment should still be available")
	assert(PlayerData.can_interact_friend_hangout("friend_jake_02"), "Jake hangout should still be available (isolated per friend)")
	print("PASS: Hangout rate limit works and isolates per friend")

	# 4. Record compliment with Maya
	PlayerData.record_friend_compliment("friend_maya_01")
	assert(not PlayerData.can_interact_friend_compliment("friend_maya_01"), "Maya compliment should NOT be available after use")
	print("PASS: Compliment rate limit works")

	# 5. Advance month
	PlayerData.in_game_month += 1
	assert(PlayerData.can_interact_friend_hangout("friend_maya_01"), "Maya hangout should reset in next month")
	assert(PlayerData.can_interact_friend_compliment("friend_maya_01"), "Maya compliment should reset in next month")
	print("PASS: Monthly rollover resets friend interactions")

	# 6. Test in MainScreen UI
	main.show_tab("relationships")
	await get_tree().process_frame
	await get_tree().process_frame

	var rel_list = main.get_node("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList")
	var f_card0 = rel_list.get_node_or_null("FriendCard_0")
	assert(f_card0 != null, "FriendCard_0 must exist in relationships panel")

	var buttons: Array = f_card0.find_children("*", "Button", true, false)
	assert(buttons.size() == 4, "FriendCard_0 should have exactly 4 buttons (Hang Out, Compliment, Outing, Unfriend)")

	var hang_btn: Button = null
	var comp_btn: Button = null
	var outing_btn: Button = null
	var unfriend_btn: Button = null

	for b in buttons:
		var btn := b as Button
		if "Hang Out" in btn.text:
			hang_btn = btn
		elif "Compliment" in btn.text:
			comp_btn = btn
		elif "Outing" in btn.text:
			outing_btn = btn
		elif "Unfriend" in btn.text:
			unfriend_btn = btn

	assert(hang_btn != null, "Hang Out button must exist")
	assert(comp_btn != null, "Compliment button must exist")
	assert(outing_btn != null, "Outing button must exist")
	assert(unfriend_btn != null, "Unfriend button must exist")

	# Both should start enabled
	assert(not hang_btn.disabled, "Hang out button should start enabled")
	assert(not comp_btn.disabled, "Compliment button should start enabled")
	assert(not "(Used)" in hang_btn.text, "Hang out should not have (Used) initially")
	assert(not "(Used)" in comp_btn.text, "Compliment should not have (Used) initially")
	print("PASS: UI buttons rendered in active state")

	# Click Hang Out
	var initial_rel: int = int(PlayerData.friends[0].get("relationship", 50))
	hang_btn.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame

	var after_rel: int = int(PlayerData.friends[0].get("relationship", 50))
	assert(after_rel > initial_rel, "Friendship should increase after Hang Out")

	# Find updated card buttons after UI refresh
	var updated_card0 = rel_list.get_node_or_null("FriendCard_0")
	var updated_buttons: Array = updated_card0.find_children("*", "Button", true, false)
	var updated_hang: Button = null
	var updated_comp: Button = null
	for b in updated_buttons:
		var btn := b as Button
		if "Hang Out" in btn.text:
			updated_hang = btn
		elif "Compliment" in btn.text:
			updated_comp = btn

	assert(updated_hang != null and updated_hang.disabled, "Hang Out button must be disabled after use")
	assert("(Used)" in updated_hang.text, "Hang Out button text must contain (Used)")
	assert(updated_comp != null and not updated_comp.disabled, "Compliment button should remain active")

	# Attempt to click Hang Out again (simulate spam attempt)
	var rel_before_spam = after_rel
	updated_hang.emit_signal("pressed")
	await get_tree().process_frame
	var rel_after_spam = int(PlayerData.friends[0].get("relationship", 50))
	assert(rel_after_spam == rel_before_spam, "Spamming Hang Out in same month must not increase friendship!")
	print("PASS: Anti-spam verification passed successfully! Spamming blocked.")

	# Click Compliment from freshly updated card
	var card_before_comp = rel_list.get_node_or_null("FriendCard_0")
	var comp_btn_to_press: Button = null
	for b in card_before_comp.find_children("*", "Button", true, false):
		var btn := b as Button
		if "Compliment" in btn.text:
			comp_btn_to_press = btn
			break
	assert(comp_btn_to_press != null and not comp_btn_to_press.disabled, "Compliment button must exist and be active")
	comp_btn_to_press.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	var rel_after_comp = int(PlayerData.friends[0].get("relationship", 50))
	assert(rel_after_comp > rel_after_spam, "Friendship should increase after Compliment")

	var comp_card0 = rel_list.get_node_or_null("FriendCard_0")
	var comp_buttons: Array = comp_card0.find_children("*", "Button", true, false)
	var comp_hang_btn: Button = null
	var comp_comp_btn: Button = null
	for b in comp_buttons:
		var btn := b as Button
		if "Hang Out" in btn.text:
			comp_hang_btn = btn
		elif "Compliment" in btn.text:
			comp_comp_btn = btn

	assert(comp_hang_btn.disabled and "(Used)" in comp_hang_btn.text, "Hang out still used")
	assert(comp_comp_btn.disabled and "(Used)" in comp_comp_btn.text, "Compliment now used")

	# Advance month and verify buttons reset to active
	PlayerData.in_game_month += 1
	main.update_relationships_panel()
	await get_tree().process_frame

	var reset_card0 = rel_list.get_node_or_null("FriendCard_0")
	var reset_buttons: Array = reset_card0.find_children("*", "Button", true, false)
	var reset_hang: Button = null
	var reset_comp: Button = null
	for b in reset_buttons:
		var btn := b as Button
		if "Hang Out" in btn.text:
			reset_hang = btn
		elif "Compliment" in btn.text:
			reset_comp = btn

	assert(not reset_hang.disabled and not "(Used)" in reset_hang.text, "Hang Out re-enabled next month")
	assert(not reset_comp.disabled and not "(Used)" in reset_comp.text, "Compliment re-enabled next month")
	print("PASS: Next month correctly re-enables both buttons!")

	print("\n--- ALL FRIEND MONTHLY INTERACTION TESTS PASSED ---")
	get_tree().quit(0)
