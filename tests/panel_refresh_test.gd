extends Node


func press_matching(root: Node, text: String) -> void:
	for button in root.find_children("*", "Button", true, false):
		if text in button.text and not button.disabled:
			button.pressed.emit()
			return
	assert(false, "Missing enabled button: " + text)


func _ready() -> void:
	# Run with APPDATA redirected to work/ so action callbacks cannot save over a life.
	assert("blink-review" in OS.get_user_data_dir(), "Use the isolated blink-review APPDATA directory")
	LifeLibrary.data.language = "en"
	var main = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main)
	await get_tree().create_timer(3.5).timeout
	main.new_game_panel.hide()
	main.loading_screen.hide()
	main.disclaimer_screen.hide()
	PlayerData.age = 30
	PlayerData.has_started_game = true
	PlayerData.finance_market = {}
	PlayerData.money = 1000000
	PlayerData.bank_savings = 1000000
	PlayerData.is_dead = false
	PlayerData.is_in_prison = false
	var business := {"uid": "refresh-test", "id": "coffee_shop", "name": "Refresh Test", "treasury": 100000, "valuation": 500000, "loan_balance": 0}
	PlayerData.owned_businesses = [business]
	for mode in ["dark", "light"]:
		LifeLibrary.data.theme = mode
		main.get_node("ThemeController").apply_theme()
		main._show_business_modal("financials", "refresh-test")
		var overlay: Control = main.business_modal_overlay
		var view: Dictionary = overlay.get_meta("modal_view")
		var surface: Control = view.card.get_parent()
		assert(surface.offset_top > 0.0, "Opening should animate")
		await get_tree().create_timer(0.5).timeout
		view.scroll.scroll_vertical = 180
		await get_tree().process_frame
		var scroll_position: int = view.scroll.scroll_vertical
		assert(scroll_position > 0)
		for repeat in range(3):
			var treasury: int = business.treasury
			press_matching(overlay, "Inject $10,000 Capital")
			assert(int(business.treasury) == treasury + 10000, "Action must still run")
			assert(main.business_modal_overlay == overlay, "Refresh must retain the window")
			assert(is_zero_approx(surface.offset_top), "Action must not replay opening animation")
			await get_tree().process_frame
			await get_tree().process_frame
			assert(view.scroll.scroll_vertical == scroll_position, "Refresh must retain scroll position")
			assert(view.vbox.get_child_count() == 4, "Refresh must not duplicate pinned tabs")
		press_matching(overlay, "Incorporate (7 Sectors)")
		assert(main.business_modal_overlay == overlay)
		assert(is_zero_approx(surface.offset_top))
		press_matching(overlay, "Financials & Loans")
		assert(main.business_modal_overlay == overlay)
		assert(is_zero_approx(surface.offset_top))
		var nested: Dictionary = main._create_cyber_modal("NESTED", "A new dialog should animate", Color.CYAN)
		assert(nested.card.get_parent().offset_top > 0.0)
		assert(is_zero_approx(surface.offset_top))
		nested.overlay.queue_free()
		view.close_button.pressed.emit()
		await get_tree().create_timer(0.5).timeout
		assert(not is_instance_valid(overlay))
	# Finance Market tab buttons must refresh the same surface too.
	var finance = main.get_node("FinancePanel")
	finance.open()
	var market: Control = finance.overlay
	var market_view: Dictionary = market.get_meta("modal_view")
	assert(market_view.card.get_parent().offset_top > 0.0)
	await get_tree().create_timer(0.5).timeout
	for tab in ["Portfolio", "My Businesses", "Exchange", "Exchange"]:
		press_matching(market, tab)
		assert(finance.overlay == market)
		assert(is_zero_approx(market_view.card.get_parent().offset_top))
		await get_tree().process_frame
	press_matching(market, "Buy Shares")
	var trade: Control = finance.trade_dialog_overlay
	var trade_surface: Control = trade.get_meta("modal_view").card.get_parent()
	assert(trade_surface.offset_top > 0.0, "A new trade dialog should animate")
	await get_tree().create_timer(0.5).timeout
	press_matching(trade, "+10")
	assert(is_zero_approx(trade_surface.offset_top), "Quantity input must not replay animation")
	var savings: int = PlayerData.bank_savings
	press_matching(trade, "Confirm Purchase")
	assert(PlayerData.bank_savings < savings, "Purchase must still execute")
	assert(finance.overlay == market)
	assert(is_zero_approx(market_view.card.get_parent().offset_top), "Trade must refresh in place")
	market_view.close_button.pressed.emit()
	await get_tree().create_timer(0.5).timeout
	finance.open()
	assert(finance.overlay.get_meta("modal_view").card.get_parent().offset_top > 0.0)
	finance.open_learning()
	var learning: Control = finance.learning_overlay
	var learning_surface: Control = learning.get_meta("modal_view").card.get_parent()
	var entrance: Tween = learning_surface.get_meta("pull_up_controller")._tween
	finance.open_learning("Refresh during entrance")
	assert(learning_surface.get_meta("pull_up_controller")._tween == entrance, "Rapid refresh must not restart the entrance")
	await get_tree().create_timer(0.5).timeout
	finance.open_learning("Updated activity result")
	assert(finance.learning_overlay == learning)
	assert(is_zero_approx(learning_surface.offset_top))
	print("PANEL_REFRESH_TEST_PASSED")
	get_tree().quit()
