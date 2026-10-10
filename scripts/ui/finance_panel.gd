extends Node

var main: Control
var overlay: Control
var learning_overlay: Control
var trade_dialog_overlay: Control
var selected_tab := "Exchange"
var message := ""


func _money(value: float) -> String:
	# Labels keep canonical USD text; the shared localization layer converts it.
	return GameLocale.money(value, "USD")


func install(screen: Control) -> void:
	main = screen
	var list := main.get_node("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	var jobs := list.get_node("JobsActItem")
	var freelance := list.get_node_or_null("FreelanceActItem")
	var market_button: Button = jobs.duplicate(0)
	market_button.name = "FinanceMarketItem"
	market_button.text = "📈  Finance Market"
	list.add_child(market_button)
	var target_index: int = (freelance.get_index() + 1) if freelance != null else (jobs.get_index() + 1)
	list.move_child(market_button, target_index)
	market_button.pressed.connect(open)
	var learning: Button = jobs.duplicate(0)
	learning.name = "LearningItem"
	learning.text = "📚  Learning & Smarts"
	list.add_child(learning)
	list.move_child(learning, list.get_node("EducationActItem").get_index() + 1)
	learning.pressed.connect(open_learning)
	FinanceMarket.ensure.call_deferred(PlayerData)


func label(parent: Node, text: String, size: int = 24, color: Color = Color.TRANSPARENT) -> Label:
	var node := Label.new()
	node.set_meta("reference_part", true)
	node.text = text
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", size)
	var is_light: bool = LifeLibrary.data.theme == "light"
	if color != Color.TRANSPARENT:
		node.add_theme_color_override("font_color", color)
	else:
		node.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#e2e8f0"))
	parent.add_child(node)
	return node


## Creates a tactile, game-like button with a visible border, rounded corners, and shadow backdrop.
func create_market_button(parent: Node, text: String, color: Color, action: Callable, disabled: bool = false, min_height: int = 56) -> Button:
	var btn := Button.new()
	btn.set_meta("reference_part", true)
	btn.set_meta("market_button", true)
	btn.text = text
	btn.disabled = disabled
	btn.custom_minimum_size.y = min_height
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	btn.add_theme_font_size_override("font_size", 22)
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var is_light: bool = LifeLibrary.data.theme == "light"
	var normal_sb := StyleBoxFlat.new()
	normal_sb.bg_color = color.darkened(0.15) if is_light else color.darkened(0.35)
	normal_sb.border_color = color.lightened(0.2)
	normal_sb.set_border_width_all(2)
	normal_sb.set_corner_radius_all(10)
	normal_sb.shadow_color = Color(0, 0, 0, 0.28)
	normal_sb.shadow_size = 4
	normal_sb.shadow_offset = Vector2(0, 3)
	normal_sb.content_margin_left = 18
	normal_sb.content_margin_right = 18
	normal_sb.content_margin_top = 10
	normal_sb.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", normal_sb)
	
	var hover_sb := normal_sb.duplicate() as StyleBoxFlat
	hover_sb.bg_color = color.lightened(0.1) if is_light else color.darkened(0.15)
	hover_sb.border_color = Color.WHITE
	hover_sb.shadow_size = 6
	btn.add_theme_stylebox_override("hover", hover_sb)
	
	var pressed_sb := normal_sb.duplicate() as StyleBoxFlat
	pressed_sb.bg_color = color.darkened(0.35) if is_light else color.darkened(0.55)
	pressed_sb.shadow_size = 1
	pressed_sb.shadow_offset = Vector2(0, 1)
	btn.add_theme_stylebox_override("pressed", pressed_sb)
	
	var disabled_sb := normal_sb.duplicate() as StyleBoxFlat
	disabled_sb.bg_color = Color("#94a3b8" if is_light else "#334155")
	disabled_sb.border_color = Color("#cbd5e1" if is_light else "#475569")
	disabled_sb.shadow_size = 0
	btn.add_theme_stylebox_override("disabled", disabled_sb)
	
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", Color("#e2e8f0" if is_light else "#64748b"))
	
	if not disabled and action.is_valid():
		btn.pressed.connect(action)
	parent.add_child(btn)
	return btn


func button(parent: Node, text: String, action: Callable, disabled: bool = false) -> Button:
	return create_market_button(parent, text, Color("#0891b2"), action, disabled)


func open() -> void:
	FinanceMarket.ensure(PlayerData)
	var modal: Dictionary = main._refresh_cyber_modal(overlay, "FINANCE MARKET", "Prices update when you age up. NPC trading and business results move the market. Trading fee: 1%.", Color("#06b6d4"))
	overlay = modal.overlay
	var list: VBoxContainer = modal.list
	list.set_meta("panel_spacing", 28)
	list.add_theme_constant_override("separation", 28)
	
	# Top Financial Status Card
	var is_light: bool = LifeLibrary.data.theme == "light"
	var stat_card := PanelContainer.new()
	stat_card.set_meta("reference_part", true)
	var sc_style := StyleBoxFlat.new()
	sc_style.bg_color = Color("#f1f5f9") if is_light else Color("#111827")
	sc_style.border_color = Color("#0284c7")
	sc_style.set_border_width_all(2)
	sc_style.set_corner_radius_all(10)
	sc_style.shadow_color = Color(0, 0, 0, 0.15)
	sc_style.shadow_size = 4
	sc_style.shadow_offset = Vector2(0, 2)
	stat_card.add_theme_stylebox_override("panel", sc_style)
	list.add_child(stat_card)
	
	var sc_margin := MarginContainer.new()
	sc_margin.add_theme_constant_override("margin_left", 16)
	sc_margin.add_theme_constant_override("margin_right", 16)
	sc_margin.add_theme_constant_override("margin_top", 12)
	sc_margin.add_theme_constant_override("margin_bottom", 12)
	stat_card.add_child(sc_margin)
	
	var sc_vbox := VBoxContainer.new()
	sc_vbox.add_theme_constant_override("separation", 4)
	sc_margin.add_child(sc_vbox)
	
	var port_val := FinanceMarket.portfolio_value(PlayerData)
	label(sc_vbox, "💵 Available Funds: %s   •   📊 Stock Portfolio: %s" % [_money(PlayerData.get_available_funds()), _money(port_val)], 24, Color("#0284c7") if is_light else Color("#38bdf8"))
	
	if PlayerData.age < 18 or PlayerData.is_in_prison or PlayerData.is_dead:
		label(sc_vbox, "⚠️ Trading and acquisitions require age 18 and freedom from prison.", 20, Color("#ef4444"))
	
	# Navigation Tabs with tactile button styling
	var tabs := HBoxContainer.new()
	tabs.name = "MarketTabs"
	tabs.add_theme_constant_override("separation", 10)
	list.add_child(tabs)
	for tab in ["Exchange", "Portfolio", "My Businesses"]:
		var is_active: bool = (tab == selected_tab)
		var tab_color := Color("#0284c7") if is_active else Color("#475569" if is_light else "#1e293b")
		var tab_btn := create_market_button(tabs, tab, tab_color, func(): selected_tab = tab; message = ""; open(), false, 52)
		tab_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_btn.add_theme_font_size_override("font_size", 22)
		if is_active:
			tab_btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			tab_btn.add_theme_color_override("font_color", Color("#cbd5e1" if is_light else "#94a3b8"))

	if not message.is_empty():
		var msg_p := PanelContainer.new()
		msg_p.set_meta("reference_part", true)
		var ms := StyleBoxFlat.new()
		ms.bg_color = Color("#064e3b" if is_light else "#062e24")
		ms.border_color = Color("#10b981")
		ms.set_border_width_all(1)
		ms.set_corner_radius_all(8)
		msg_p.add_theme_stylebox_override("panel", ms)
		list.add_child(msg_p)
		var mm := MarginContainer.new()
		mm.add_theme_constant_override("margin_left", 14)
		mm.add_theme_constant_override("margin_right", 14)
		mm.add_theme_constant_override("margin_top", 10)
		mm.add_theme_constant_override("margin_bottom", 10)
		msg_p.add_child(mm)
		label(mm, "🔔 " + message, 22, Color("#34d399"))

	match selected_tab:
		"Exchange": _exchange(list)
		"Portfolio": _portfolio(list)
		"My Businesses": _businesses(list)


func _perform(result: String) -> void:
	message = result
	main.rebuild_life_feed()
	main.update_ui()
	SaveManager.save_game()
	open()


func _exchange(list: VBoxContainer) -> void:
	var listings_label := label(list, "8 active listings • 24 company archetypes • NPC-owned businesses can close and reopen.", 21)
	listings_label.name = "ActiveListings"
	label(list, "Acquisitions need no license. Price includes a 25% control premium; shares you already own reduce the cost. Delisting returns 80% of share value; bankruptcy returns zero.", 19, Color("#64748b"))
	
	var is_light: bool = LifeLibrary.data.theme == "light"
	for c in FinanceMarket.active(PlayerData):
		var card := PanelContainer.new()
		card.set_meta("reference_part", true)
		var c_style := StyleBoxFlat.new()
		c_style.bg_color = Color("#ffffff") if is_light else Color("#111827")
		c_style.border_color = Color("#cbd5e1") if is_light else Color("#334155")
		c_style.set_border_width_all(2)
		c_style.set_corner_radius_all(12)
		c_style.shadow_color = Color(0, 0, 0, 0.18)
		c_style.shadow_size = 6
		c_style.shadow_offset = Vector2(0, 3)
		card.add_theme_stylebox_override("panel", c_style)
		list.add_child(card)
		
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 18)
		cm.add_theme_constant_override("margin_right", 18)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)
		
		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)
		
		# 1. Company Header Row with Name & Price Trend Badge
		var header_row := HBoxContainer.new()
		header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_child(header_row)
		
		var name_lbl := label(header_row, "🏛️ " + str(c.name), 28, Color("#0369a1") if is_light else Color("#38bdf8"))
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var change := (float(c.price) / maxf(0.01, float(c.previous)) - 1.0) * 100.0
		var price_box := PanelContainer.new()
		price_box.set_meta("reference_part", true)
		var pb_style := StyleBoxFlat.new()
		var is_up := change >= 0.0
		pb_style.bg_color = Color("#dcfce7" if is_light else "#064e3b") if is_up else Color("#fee2e2" if is_light else "#7f1d1d")
		pb_style.border_color = Color("#10b981") if is_up else Color("#ef4444")
		pb_style.set_border_width_all(1)
		pb_style.set_corner_radius_all(8)
		pb_style.content_margin_left = 12
		pb_style.content_margin_right = 12
		pb_style.content_margin_top = 4
		pb_style.content_margin_bottom = 4
		price_box.add_theme_stylebox_override("panel", pb_style)
		header_row.add_child(price_box)
		
		var trend_sign := "▲ +" if is_up else "▼ "
		var trend_lbl := Label.new()
		trend_lbl.text = "%s (%s%.1f%%)" % [_money(c.price), trend_sign, absf(change)]
		trend_lbl.add_theme_font_size_override("font_size", 21)
		trend_lbl.add_theme_color_override("font_color", Color("#15803d" if is_light else "#34d399") if is_up else Color("#b91c1c" if is_light else "#fca5a5"))
		price_box.add_child(trend_lbl)
		
		# 2. Company Details
		label(cv, "Owner: %s  •  Floating Shares: %d" % [c.owner, int(c.available)], 21, Color("#64748b"))
		label(cv, "Market Activity: %d buys ---- %d sells" % [int(c.npc_buys), int(c.npc_sells)], 20, Color("#64748b"))
		
		if not str(c.business_uid).is_empty():
			label(cv, "👑 Your public company • 80% controlling stake", 22, Color("#eab308"))
			continue
		
		# 3. Holding Status (if player owns shares)
		var holdings: Dictionary = PlayerData.finance_market.get("holdings", {})
		var owned_qty := 0
		if holdings.has(c.uid):
			owned_qty = int(holdings[c.uid].get("quantity", 0))
		if owned_qty > 0:
			var hold_val := owned_qty * float(c.price)
			label(cv, "💼 Portfolio: You own %d shares (Worth: %s)" % [owned_qty, _money(hold_val)], 22, Color("#10b981"))
		
		# 4. Action Buttons with Rounded Corners, Borders, and Shadow Backdrops
		var btn_row := HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 12)
		cv.add_child(btn_row)
		
		# Buy Shares Button (Emerald green, opens custom shares modal)
		var target_c = c
		var buy_btn := create_market_button(btn_row, "📈 Buy Shares", Color("#059669"), func():
			_open_trade_modal(target_c, true)
		, PlayerData.age < 18 or PlayerData.is_in_prison or PlayerData.is_dead)
		buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Sell Shares Button (Rose/Crimson, opens custom shares modal)
		var sell_btn := create_market_button(btn_row, "📉 Sell Shares", Color("#e11d48"), func():
			_open_trade_modal(target_c, false)
		, owned_qty <= 0 or PlayerData.age < 18 or PlayerData.is_in_prison or PlayerData.is_dead)
		sell_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Acquire Business Button (Prestige Indigo)
		var acq_price: float = FinanceMarket.acquisition_price(PlayerData, c)
		var acq_btn := create_market_button(cv, "🏢 Acquire Business • %s" % _money(acq_price), Color("#4f46e5"), func():
			main.get_node("OptionsMenu").confirm("ACQUIRE BUSINESS", "Acquire %s for %s from bank balance? No license is required." % [target_c.name, _money(acq_price)], func():
				_perform(FinanceMarket.acquire(PlayerData, target_c.uid))
			)
		, PlayerData.age < 18 or PlayerData.is_in_prison or PlayerData.is_dead)
		acq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for news in PlayerData.finance_market.get("news", []):
		label(list, "📰 " + str(news), 20, Color("#64748b"))


## Custom Amount of Shares Trade Dialog (Prompt with Text Input, Quick Presets, and Live Cost Calculation)
func _open_trade_modal(c: Dictionary, is_buy: bool) -> void:
	if is_instance_valid(trade_dialog_overlay):
		trade_dialog_overlay.queue_free()
	
	var is_light: bool = LifeLibrary.data.theme == "light"
	var holdings: Dictionary = PlayerData.finance_market.get("holdings", {})
	var owned_qty := 0
	if holdings.has(c.uid):
		owned_qty = int(holdings[c.uid].get("quantity", 0))
	
	var share_price := float(c.get("price", 10.0))
	var player_bank: int = PlayerData.bank_savings
	var max_affordable := 0
	if share_price > 0:
		max_affordable = maxi(0, int(float(player_bank) / (share_price * (1.0 + FinanceMarket.FEE))))
	
	var action_word := "BUY" if is_buy else "SELL"
	var modal: Dictionary = main._create_cyber_modal("%s SHARES" % action_word, "%s • Current Market Price: %s" % [c.name, _money(share_price)], Color("#10b981" if is_buy else "#f43f5e"))
	trade_dialog_overlay = modal.overlay
	var list: VBoxContainer = modal.list
	
	# 1. Info Card
	var info_p := PanelContainer.new()
	info_p.set_meta("reference_part", true)
	var ips := StyleBoxFlat.new()
	ips.bg_color = Color("#f8fafc" if is_light else "#0f172a")
	ips.border_color = Color("#10b981" if is_buy else "#f43f5e")
	ips.set_border_width_all(2)
	ips.set_corner_radius_all(10)
	info_p.add_theme_stylebox_override("panel", ips)
	list.add_child(info_p)
	
	var ipm := MarginContainer.new()
	ipm.add_theme_constant_override("margin_left", 18)
	ipm.add_theme_constant_override("margin_right", 18)
	ipm.add_theme_constant_override("margin_top", 14)
	ipm.add_theme_constant_override("margin_bottom", 14)
	info_p.add_child(ipm)
	
	var ipv := VBoxContainer.new()
	ipv.add_theme_constant_override("separation", 6)
	ipm.add_child(ipv)
	
	if is_buy:
		label(ipv, "🏦 Bank Balance (Stock Buying Power): %s" % _money(player_bank), 24, Color("#0284c7") if is_light else Color("#38bdf8"))
		label(ipv, "⚠️ Shares purchases require bank balance. Cash cannot be used.", 19, Color("#f59e0b"))
		label(ipv, "📊 Maximum Affordable: %d shares  •  Available on Market: %d" % [max_affordable, int(c.available)], 21, Color("#64748b"))
	else:
		var current_val := owned_qty * share_price
		label(ipv, "💼 Portfolio Holding: %d shares" % owned_qty, 24, Color("#f43f5e"))
		label(ipv, "💰 Total Value: %s" % _money(current_val), 21, Color("#64748b"))
	
	# 2. Text Input Section
	label(list, "ENTER DESIRED AMOUNT OF SHARES TO %s:" % action_word, 22, Color("#334155" if is_light else "#cbd5e1"))
	
	var input_container := PanelContainer.new()
	input_container.set_meta("reference_part", true)
	var ics := StyleBoxFlat.new()
	ics.bg_color = Color("#ffffff" if is_light else "#1e293b")
	ics.border_color = Color("#0284c7")
	ics.set_border_width_all(2)
	ics.set_corner_radius_all(8)
	input_container.add_theme_stylebox_override("panel", ics)
	list.add_child(input_container)
	
	var line_edit := LineEdit.new()
	line_edit.name = "ShareQuantityInput"
	line_edit.set_meta("reference_part", true)
	line_edit.text = "10" if is_buy else str(mini(owned_qty, 10))
	line_edit.placeholder_text = "Type share quantity..."
	line_edit.custom_minimum_size.y = 56
	line_edit.add_theme_font_size_override("font_size", 28)
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	var le_empty := StyleBoxEmpty.new()
	le_empty.content_margin_left = 16
	le_empty.content_margin_right = 16
	line_edit.add_theme_stylebox_override("normal", le_empty)
	input_container.add_child(line_edit)

	line_edit.virtual_keyboard_enabled = true
	line_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	MobileKeyboardManager.attach_to_input(line_edit, "Enter share quantity to %s:" % action_word)
	
	# 3. Quick Preset Buttons Row
	var preset_row := HBoxContainer.new()
	preset_row.add_theme_constant_override("separation", 8)
	list.add_child(preset_row)
	
	# 4. Live Calculation Box
	var calc_p := PanelContainer.new()
	calc_p.set_meta("reference_part", true)
	var cps := StyleBoxFlat.new()
	cps.bg_color = Color("#f1f5f9" if is_light else "#0b0f19")
	cps.border_color = Color("#cbd5e1" if is_light else "#334155")
	cps.set_border_width_all(1)
	cps.set_corner_radius_all(8)
	calc_p.add_theme_stylebox_override("panel", cps)
	list.add_child(calc_p)
	
	var cpm := MarginContainer.new()
	cpm.add_theme_constant_override("margin_left", 16)
	cpm.add_theme_constant_override("margin_right", 16)
	cpm.add_theme_constant_override("margin_top", 12)
	cpm.add_theme_constant_override("margin_bottom", 12)
	calc_p.add_child(cpm)
	
	var cpv := VBoxContainer.new()
	cpv.add_theme_constant_override("separation", 6)
	cpm.add_child(cpv)
	
	var calc_summary := label(cpv, "", 22)
	calc_summary.name = "CalcSummary"
	var calc_total := label(cpv, "", 24)
	calc_total.name = "CalcTotal"
	var calc_warning := label(cpv, "", 20)
	calc_warning.name = "CalcWarning"
	
	# 5. Confirm and Cancel Buttons
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 14)
	list.add_child(action_row)
	
	var cancel_btn := create_market_button(action_row, "Cancel", Color("#64748b"), func():
		if is_instance_valid(trade_dialog_overlay):
			trade_dialog_overlay.queue_free()
	, false, 60)
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var confirm_btn := create_market_button(action_row, "Confirm %s" % ("Purchase" if is_buy else "Sale"), Color("#059669" if is_buy else "#e11d48"), Callable(), false, 60)
	confirm_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Update Calculation Logic
	var update_calculation = func():
		var raw_txt: String = line_edit.text.strip_edges()
		# Filter to digits only
		var filtered := ""
		for ch in raw_txt:
			if ch in "0123456789":
				filtered += ch
		if filtered != raw_txt:
			line_edit.text = filtered
			line_edit.caret_column = filtered.length()
		
		var qty := int(filtered) if not filtered.is_empty() else 0
		var gross := int(ceil(share_price * qty)) if is_buy else int(floor(share_price * qty))
		var fee := maxi(1, int(ceil(gross * FinanceMarket.FEE))) if qty > 0 else 0
		var total_cost := gross + fee
		var net_proceeds := maxi(0, gross - fee)
		
		calc_summary.text = "Shares: %d  •  Price: %s  •  Fee (1%%): %s" % [qty, _money(share_price), _money(fee)]
		
		var can_confirm := true
		if is_buy:
			calc_total.text = "💳 Total Required: %s (Including fee)" % _money(total_cost)
			calc_total.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
			if qty <= 0:
				calc_warning.text = "⚠️ Please enter a valid quantity of shares (1 or more)."
				calc_warning.add_theme_color_override("font_color", Color("#eab308"))
				can_confirm = false
			elif total_cost > player_bank:
				calc_warning.text = "⚠️ Insufficient bank balance! You need %s more in your bank account." % _money(total_cost - player_bank)
				calc_warning.add_theme_color_override("font_color", Color("#ef4444"))
				can_confirm = false
			elif qty > int(c.available):
				calc_warning.text = "⚠️ Exceeds floating shares! Only %d available." % int(c.available)
				calc_warning.add_theme_color_override("font_color", Color("#ef4444"))
				can_confirm = false
			else:
				calc_warning.text = "✔ Order valid. Ready to purchase."
				calc_warning.add_theme_color_override("font_color", Color("#10b981"))
		else:
			calc_total.text = "💵 Net Proceeds: %s (After fee deduction)" % _money(net_proceeds)
			calc_total.add_theme_color_override("font_color", Color("#10b981"))
			if qty <= 0:
				calc_warning.text = "⚠️ Please enter a valid quantity of shares (1 or more)."
				calc_warning.add_theme_color_override("font_color", Color("#eab308"))
				can_confirm = false
			elif qty > owned_qty:
				calc_warning.text = "⚠️ Cannot sell more than you own! (%d owned)" % owned_qty
				calc_warning.add_theme_color_override("font_color", Color("#ef4444"))
				can_confirm = false
			else:
				calc_warning.text = "✔ Order valid. Ready to sell."
				calc_warning.add_theme_color_override("font_color", Color("#10b981"))
		
		confirm_btn.disabled = not can_confirm
	
	line_edit.text_changed.connect(func(_new_text): update_calculation.call())
	
	# Populate quick preset buttons
	if is_buy:
		for p_val in [10, 50, 100, 500]:
			var pb := create_market_button(preset_row, "+%d" % p_val, Color("#475569" if is_light else "#334155"), func():
				var current_qty := int(line_edit.text)
				line_edit.text = str(current_qty + p_val)
				update_calculation.call()
			, false, 42)
			pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			pb.add_theme_font_size_override("font_size", 18)
		
		var max_b := create_market_button(preset_row, "MAX", Color("#0284c7"), func():
			var limit_qty := mini(max_affordable, int(c.available))
			line_edit.text = str(maxi(1, limit_qty))
			update_calculation.call()
		, max_affordable <= 0, 42)
		max_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		max_b.add_theme_font_size_override("font_size", 18)
	else:
		for frac in [0.25, 0.50, 0.75]:
			var pct_label := "%d%%" % int(frac * 100)
			var pb := create_market_button(preset_row, pct_label, Color("#475569" if is_light else "#334155"), func():
				var q := maxi(1, int(owned_qty * frac))
				line_edit.text = str(q)
				update_calculation.call()
			, owned_qty <= 0, 42)
			pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			pb.add_theme_font_size_override("font_size", 18)
		
		var all_b := create_market_button(preset_row, "ALL (100%)", Color("#e11d48"), func():
			line_edit.text = str(owned_qty)
			update_calculation.call()
		, owned_qty <= 0, 42)
		all_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		all_b.add_theme_font_size_override("font_size", 18)
	
	confirm_btn.pressed.connect(func():
		var final_qty := int(line_edit.text)
		if final_qty > 0:
			if is_instance_valid(trade_dialog_overlay):
				trade_dialog_overlay.queue_free()
			_perform(FinanceMarket.trade(PlayerData, c.uid, final_qty, is_buy))
	)
	
	update_calculation.call()


func _portfolio(list: VBoxContainer) -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	
	# Wrap graph in a dedicated card with margins to prevent clipping against tab buttons
	var chart_card := PanelContainer.new()
	chart_card.set_meta("reference_part", true)
	var chart_cs := StyleBoxFlat.new()
	chart_cs.bg_color = Color("#ffffff" if is_light else "#111827")
	chart_cs.border_color = Color("#cbd5e1" if is_light else "#334155")
	chart_cs.set_border_width_all(2)
	chart_cs.set_corner_radius_all(12)
	chart_cs.shadow_color = Color(0, 0, 0, 0.15)
	chart_cs.shadow_size = 4
	chart_cs.shadow_offset = Vector2(0, 2)
	chart_card.add_theme_stylebox_override("panel", chart_cs)
	list.add_child(chart_card)
	
	var chart_cm := MarginContainer.new()
	chart_cm.add_theme_constant_override("margin_left", 18)
	chart_cm.add_theme_constant_override("margin_right", 18)
	chart_cm.add_theme_constant_override("margin_top", 16)
	chart_cm.add_theme_constant_override("margin_bottom", 16)
	chart_card.add_child(chart_cm)
	
	var chart_cv := VBoxContainer.new()
	chart_cv.add_theme_constant_override("separation", 10)
	chart_cm.add_child(chart_cv)
	
	label(chart_cv, "📊 Blue: portfolio value • Gold: net cash invested", 21, Color("#0284c7" if is_light else "#38bdf8"))
	var chart := preload("res://scripts/ui/portfolio_chart.gd").new()
	chart.history = PlayerData.finance_market.get("history", [])
	chart_cv.add_child(chart)
	
	var realized: int = int(PlayerData.finance_market.get("realized", 0))
	var pnl_color := Color("#15803d" if is_light else "#34d399") if realized >= 0 else Color("#b91c1c" if is_light else "#f87171")
	label(list, "Cumulative Realized Profit / Loss: %s" % _money(realized), 24, pnl_color)
	
	var holdings: Dictionary = PlayerData.finance_market.get("holdings", {})
	if holdings.is_empty():
		var empty_card := PanelContainer.new()
		empty_card.set_meta("reference_part", true)
		var es := StyleBoxFlat.new()
		es.bg_color = Color("#f8fafc" if is_light else "#111827")
		es.border_color = Color("#cbd5e1" if is_light else "#334155")
		es.set_border_width_all(1)
		es.set_corner_radius_all(10)
		empty_card.add_theme_stylebox_override("panel", es)
		list.add_child(empty_card)
		var em := MarginContainer.new()
		em.add_theme_constant_override("margin_left", 20)
		em.add_theme_constant_override("margin_right", 20)
		em.add_theme_constant_override("margin_top", 18)
		em.add_theme_constant_override("margin_bottom", 18)
		empty_card.add_child(em)
		label(em, "No shares owned currently. Switch to the 'Exchange' tab to browse and purchase shares.", 22, Color("#64748b"))
		return
	
	for uid in holdings:
		var position: Dictionary = holdings[uid]
		var company: Dictionary = FinanceMarket.issuer(PlayerData, uid)
		if company.is_empty():
			company = {
				"uid": uid,
				"name": str(position.get("name", "Asset " + uid)),
				"price": float(position.get("price", 10.0)),
				"active": false,
				"available": 0
			}
		
		var card := PanelContainer.new()
		card.set_meta("reference_part", true)
		var cs := StyleBoxFlat.new()
		cs.bg_color = Color("#ffffff" if is_light else "#111827")
		cs.border_color = Color("#cbd5e1" if is_light else "#334155")
		cs.set_border_width_all(2)
		cs.set_corner_radius_all(12)
		cs.shadow_color = Color(0, 0, 0, 0.15)
		cs.shadow_size = 4
		cs.shadow_offset = Vector2(0, 2)
		card.add_theme_stylebox_override("panel", cs)
		list.add_child(card)
		
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 18)
		cm.add_theme_constant_override("margin_right", 18)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)
		
		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)
		
		var value := int(position.quantity) * float(company.price)
		var cost := int(position.cost)
		var diff := value - cost
		var is_profit := diff >= 0
		var is_active: bool = bool(company.get("active", true))
		
		var title_row := HBoxContainer.new()
		title_row.add_theme_constant_override("separation", 16)
		cv.add_child(title_row)
		var hname := label(title_row, "🏛️ %s" % company.name, 26, Color("#0369a1" if is_light else "#38bdf8"))
		hname.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if not is_active:
			var off_badge := label(title_row, "[Off-Market]", 20, Color("#f59e0b" if is_light else "#fbbf24"))
			off_badge.size_flags_horizontal = Control.SIZE_SHRINK_END
			off_badge.autowrap_mode = TextServer.AUTOWRAP_OFF
		
		# Give the amount its own full-width line; company names must not squeeze
		# currency values into a one-character-wide column on smaller screens.
		var pnl_lbl := label(cv, "%s%s" % ["+" if is_profit else "", _money(diff)], 24, Color("#15803d" if is_light else "#34d399") if is_profit else Color("#b91c1c" if is_light else "#f87171"))
		pnl_lbl.name = "PortfolioProfitLoss"
		pnl_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
		pnl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		pnl_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		label(cv, "Holding: %d shares  •  Current Value: %s  •  Cost Basis: %s" % [position.quantity, _money(value), _money(cost)], 21, Color("#64748b"))
		
		if not is_active:
			label(cv, "📌 Off-Market: This company rotated off active listings. You can still liquidate your shares anytime.", 19, Color("#94a3b8" if is_light else "#64748b"))
		
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		cv.add_child(row)
		
		var target_c = company
		var sell_custom_btn := create_market_button(row, "📉 Sell Custom Amount", Color("#e11d48"), func():
			_open_trade_modal(target_c, false)
		)
		sell_custom_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var sell_all_btn := create_market_button(row, "⚡ Sell All", Color("#b91c1c"), func():
			_perform(FinanceMarket.trade(PlayerData, uid, int(position.quantity), false))
		)
		sell_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _businesses(list: VBoxContainer) -> void:
	label(list, "IPO: exceed $1,000,000 cumulative after-tax net profit, pay outstanding business taxes, and maintain a non-negative treasury. Float 20%; retain 80%. Underwriting fee: 5%.", 20, Color("#64748b"))
	
	var is_light: bool = LifeLibrary.data.theme == "light"
	if PlayerData.owned_businesses.is_empty():
		var empty_card := PanelContainer.new()
		empty_card.set_meta("reference_part", true)
		var es := StyleBoxFlat.new()
		es.bg_color = Color("#f8fafc" if is_light else "#111827")
		es.border_color = Color("#cbd5e1" if is_light else "#334155")
		es.set_border_width_all(1)
		es.set_corner_radius_all(10)
		empty_card.add_theme_stylebox_override("panel", es)
		list.add_child(empty_card)
		var em := MarginContainer.new()
		em.add_theme_constant_override("margin_left", 20)
		em.add_theme_constant_override("margin_right", 20)
		em.add_theme_constant_override("margin_top", 18)
		em.add_theme_constant_override("margin_bottom", 18)
		empty_card.add_child(em)
		label(em, "No businesses owned. Acquire an active NPC business from the Exchange tab or incorporate one.", 22, Color("#64748b"))
		return
	
	for business in PlayerData.owned_businesses:
		var card := PanelContainer.new()
		card.set_meta("reference_part", true)
		var cs := StyleBoxFlat.new()
		cs.bg_color = Color("#ffffff" if is_light else "#111827")
		cs.border_color = Color("#cbd5e1" if is_light else "#334155")
		cs.set_border_width_all(2)
		cs.set_corner_radius_all(12)
		cs.shadow_color = Color(0, 0, 0, 0.15)
		cs.shadow_size = 4
		card.add_theme_stylebox_override("panel", cs)
		list.add_child(card)
		
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 18)
		cm.add_theme_constant_override("margin_right", 18)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)
		
		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)
		
		label(cv, "🏢 " + str(business.name), 28, Color("#4f46e5" if is_light else "#818cf8"))
		label(cv, "Net profit to date: %s  •  Valuation: %s  •  Ownership: %d%%" % [
			_money(int(business.get("cumulative_net_profit", 0))),
			_money(int(business.get("valuation", 0))),
			int(float(business.get("owner_fraction", 1.0)) * 100)
		], 21, Color("#64748b"))
		
		var btn_row := HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 10)
		cv.add_child(btn_row)
		
		create_market_button(btn_row, "Request IPO", Color("#7c3aed"), func():
			main.get_node("OptionsMenu").confirm("Request IPO", "Sell 20% of this company to the public market? Proceeds enter the business treasury.", func():
				_perform(FinanceMarket.request_ipo(PlayerData, business))
			)
		, business.has("listing_uid")).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		create_market_button(btn_row, "Manage Business", Color("#0284c7"), func():
			main._show_business_modal("financials", business.uid)
		).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		create_market_button(cv, "Resell Business", Color("#e11d48"), func():
			main.get_node("OptionsMenu").confirm("Resell Business", "Sell your ownership stake? Proceeds deduct debt and unpaid taxes.", func():
				var result: Dictionary = BusinessManager.liquidate_business(business.uid)
				_perform(str(result.message))
			)
		).size_flags_horizontal = Control.SIZE_EXPAND_FILL


func open_learning(notice: String = "") -> void:
	var view: Dictionary = main._refresh_cyber_modal(learning_overlay, "LEARNING & SMARTS", "Each activity is available once per year. Any activity protects smarts from annual decay. Gains taper above 85 smarts.", Color("#38bdf8"))
	learning_overlay = view.overlay
	label(view.list, "Smarts: %d • Funds: %s" % [PlayerData.smarts, _money(PlayerData.get_available_funds())], 24)
	if not notice.is_empty():
		label(view.list, notice, 22, Color("#10b981"))
	for activity in BalanceRules.LEARNING:
		var used: bool = int(PlayerData.learning_activities.get(activity.id, -1)) == PlayerData.age
		var title: String = "%s\nCost: %s • Age %d+" % [
			activity.name,
			_money(activity.cost),
			activity.age
		]
		create_market_button(view.list, title, Color("#0284c7"), func():
			var result: String = BalanceRules.learn(PlayerData, activity.id)
			main.rebuild_life_feed()
			main.update_ui()
			SaveManager.save_game()
			open_learning(result)
		, used or PlayerData.age < int(activity.age) or PlayerData.get_available_funds() < int(activity.cost) or PlayerData.is_in_prison or PlayerData.is_dead, 64)
