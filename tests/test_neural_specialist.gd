extends Node

const NeuralCatalog = preload("res://scripts/economy/neural_catalog.gd")

func _ready() -> void:
	print("\n=======================================================")
	print("🧠 TESTING NEURAL SPECIALIST SYSTEM & AI BRAIN CHIPS")
	print("=======================================================\n")

	test_neural_catalog()
	test_player_data_installation_and_maintenance()
	test_save_load()
	test_main_screen_scene()

	print("\n=======================================================")
	print("🎉 ALL NEURAL SPECIALIST TESTS PASSED WITH 100% SUCCESS!")
	print("=======================================================\n")
	get_tree().quit(0)

func test_neural_catalog() -> void:
	print("--- 1. Testing NeuralCatalog Data Integrity ---")
	var all_mods := NeuralCatalog.get_all_modifications()
	assert(all_mods.size() >= 10, "Expected at least 10 neural modifications in catalog, got %d" % all_mods.size())

	for m in all_mods:
		var mid: String = str(m.get("id", ""))
		var mname: String = str(m.get("name", ""))
		var price: int = int(m.get("price", 0))
		var maint: int = int(m.get("annual_maintenance", 0))
		var slot: String = str(m.get("slot", ""))

		assert(mid != "", "Modification has empty id")
		assert(mname != "", "Modification has empty name: %s" % mid)
		assert(price >= 1000000, "Modification %s price should be in millions (got %d)" % [mid, price])
		assert(maint >= 10000, "Modification %s should have realistic annual maintenance (got %d)" % [mid, maint])
		assert(slot in NeuralCatalog.SLOTS, "Modification %s has invalid slot: %s" % [mid, slot])
		assert(NeuralCatalog.get_modification(mid).get("id", "") == mid, "Lookup failed for %s" % mid)

	print("  ✓ NeuralCatalog verified: %d modifications loaded with millions pricing and annual maintenance." % all_mods.size())

func test_player_data_installation_and_maintenance() -> void:
	print("--- 2. Testing PlayerData Neural Mechanics ---")
	PlayerData.reset_player()
	PlayerData.age = 25
	PlayerData.bank_savings = 50000000 # 50 Million

	# 1. Underage check
	PlayerData.age = 15
	var under_res := PlayerData.install_neural_implant("cortex_neurolink_mk1")
	assert(not under_res["success"], "Minor under 18 should not be allowed to install neural implants")
	PlayerData.age = 25

	# 2. Install Mk.I Cortex Coprocessor
	var prev_smarts := PlayerData.smarts
	var inst_res := PlayerData.install_neural_implant("cortex_neurolink_mk1")
	assert(inst_res["success"], "Failed to install cortex_neurolink_mk1: %s" % str(inst_res))
	assert(PlayerData.has_neural_implant("cortex_neurolink_mk1"), "PlayerData should have cortex_neurolink_mk1")
	assert(PlayerData.neural_implants.size() == 1, "Expected 1 implant, got %d" % PlayerData.neural_implants.size())
	assert(PlayerData.smarts > prev_smarts, "Smarts should increase after installing chip")

	# 3. Upgrade / replace slot
	var old_savings := PlayerData.bank_savings
	var upg_res := PlayerData.install_neural_implant("cortex_omnimind_quantum")
	assert(upg_res["success"], "Failed to upgrade to cortex_omnimind_quantum")
	assert(not PlayerData.has_neural_implant("cortex_neurolink_mk1"), "Old chip should be removed")
	assert(PlayerData.has_neural_implant("cortex_omnimind_quantum"), "New chip should be installed")
	assert(PlayerData.neural_implants.size() == 1, "Slot should be replaced, still 1 implant")
	assert(PlayerData.smarts == 100, "OmniMind Quantum should set smarts to 100")
	assert(upg_res["salvage_refund"] > 0, "Salvage refund should be granted for replaced chip")

	# 4. Install additional slot (Memory)
	var mem_res := PlayerData.install_neural_implant("memory_eidetic_matrix")
	assert(mem_res["success"], "Failed to install memory_eidetic_matrix")
	assert(PlayerData.neural_implants.size() == 2, "Expected 2 implants in distinct slots")

	# 5. Maintenance calculation
	var total_maint := PlayerData.get_total_neural_maintenance()
	assert(total_maint > 0, "Total maintenance should be > 0")

	# 6. Yearly processing with sufficient funds
	var logs := PlayerData.process_yearly_neural_implants()
	assert(logs.size() >= 1, "Expected maintenance log")
	assert(PlayerData.neural_implants[0]["is_active"] == true, "Implants should remain active")

	# 7. Yearly processing when broke
	PlayerData.bank_savings = 0
	PlayerData.money = 0
	var broke_logs := PlayerData.process_yearly_neural_implants()
	assert(broke_logs.size() >= 1, "Expected failure log")
	assert(PlayerData.neural_implants[0]["is_active"] == false, "Implants should deactivate into offline mode when unpaid")

	# 8. Servicing offline implants
	PlayerData.bank_savings = 10000000
	var serv_res := PlayerData.service_all_neural_implants()
	assert(serv_res["success"], "Service should succeed when funds are replenished")
	assert(PlayerData.neural_implants[0]["is_active"] == true, "Implants should be reactivated after servicing")

	print("  ✓ PlayerData installation, upgrading, maintenance, and servicing verified.")

func test_save_load() -> void:
	print("--- 3. Testing SaveManager Persistence ---")
	var captured := SaveManager.capture_data()
	assert(captured.has("neural_implants"), "capture_data should contain neural_implants")
	assert(captured["neural_implants"].size() == 2, "capture_data should serialize 2 implants")

	# Reset and reload
	PlayerData.reset_player()
	assert(PlayerData.neural_implants.is_empty(), "reset_player should clear neural_implants")

	var dummy_save_path := "user://test_neural_save.json"
	SaveManager.write_data(dummy_save_path, captured)
	var load_success := SaveManager.load_game(dummy_save_path)
	assert(load_success, "load_game should succeed")
	assert(PlayerData.neural_implants.size() == 2, "load_game should restore 2 neural implants")

	if FileAccess.file_exists(dummy_save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(dummy_save_path))

	print("  ✓ SaveManager serialization and restoration verified.")

func test_main_screen_scene() -> void:
	print("--- 4. Testing main_screen Scene and Neural Specialist UI ---")
	var packed: PackedScene = load("res://scenes/main/main_screen.tscn")
	assert(packed != null, "Failed to load scenes/main/main_screen.tscn")
	var instance = packed.instantiate()
	assert(instance != null, "Failed to instantiate main_screen.tscn")

	var act_list := instance.get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	assert(act_list != null, "ActList node should exist")

	var btn: Button = act_list.get_node_or_null("NeuralSpecialistItem") as Button
	assert(btn != null, "NeuralSpecialistItem button should exist in ActList")
	assert(btn.text.contains("Neural Specialist"), "Button text should contain 'Neural Specialist', got: %s" % btn.text)

	# Verify position under HEALTH & LIFESTYLE (after DoctorItem and before ShoppingActItem)
	var doc_idx := act_list.get_node("DoctorItem").get_index()
	var neural_idx := btn.get_index()
	var shop_idx := act_list.get_node("ShoppingActItem").get_index()
	assert(neural_idx > doc_idx, "NeuralSpecialistItem should be after DoctorItem")
	assert(neural_idx < shop_idx, "NeuralSpecialistItem should be before ShoppingActItem (under HEALTH & LIFESTYLE)")

	# Verify signal connection
	var connections := btn.pressed.get_connections()
	var connected_to_handler := false
	for c in connections:
		if c["callable"].get_method() == "_on_neural_specialist_item_pressed":
			connected_to_handler = true
			break
	assert(connected_to_handler, "NeuralSpecialistItem should be connected to _on_neural_specialist_item_pressed")

	# Test invoking modal builder with installed hardware in both dark and light modes
	for theme_mode in ["dark", "light"]:
		LifeLibrary.data.theme = theme_mode
		instance._show_neural_specialist_modal("all")
		assert(instance.neural_specialist_modal_overlay != null, "Modal overlay should be created")
		assert(instance.neural_specialist_modal_overlay.visible == true, "Modal overlay should be visible")

		# Test category filter switching
		for cat in ["ai_chips", "cognitive", "sensory", "bio_reg", "interface"]:
			instance._show_neural_specialist_modal(cat)
			assert(instance.neural_specialist_modal_overlay != null, "Modal overlay should update cleanly for cat %s" % cat)

	# Test with an offline implant
	PlayerData.neural_implants[0]["is_active"] = false
	instance._show_neural_specialist_modal("all")
	assert(instance.neural_specialist_modal_overlay != null, "Modal overlay should render offline state cleanly")

	instance.free()
	print("  ✓ main_screen.tscn hierarchy, button placement, and modal generation verified.")
