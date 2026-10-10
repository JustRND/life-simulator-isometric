extends Node

func _ready() -> void:
	print("--- Running MobileKeyboardInputTest ---")
	var main = load("res://scenes/main/main_screen.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	assert(main.name_input.has_meta("mobile_kb_attached"))
	var options = main.get_node("OptionsMenu")
	options._cities()
	options._people()
	main._show_bank_transfer(true)
	main._show_bank_transfer(false)
	var business := {"uid": "keyboard-test", "name": "Keyboard Test", "treasury": 50000, "loan_balance": 10000}
	main._show_business_repay_custom_loan(business, "keyboard-test")
	main._show_business_custom_dividend(business, "keyboard-test")
	main._show_business_custom_capital(business, "keyboard-test")
	await get_tree().process_frame
	var count := 0
	for edit in main.find_children("*", "LineEdit", true, false):
		assert(edit.has_meta("mobile_kb_attached"), "Unattached input: " + str(edit.get_path()))
		count += 1
	var field := LineEdit.new()
	field.name = "NameInput"
	add_child(field)
	var observed: Array[String] = []
	field.text_changed.connect(func(value): observed.append(value))
	MobileKeyboardManager._apply_input_text(field, "  jANE   DOE  ")
	assert(field.text == "Jane Doe")
	assert(observed == ["Jane Doe"], "Validation must see the normalized value")
	field.name = "FreeText"
	MobileKeyboardManager._apply_input_text(field, "null")
	assert(field.text == "null", "Ordinary text must not be confused with cancellation")
	field.max_length = 4
	MobileKeyboardManager._apply_input_text(field, "123456")
	assert(field.text == "1234")
	var multiline := TextEdit.new()
	add_child(multiline)
	assert(multiline.has_meta("mobile_kb_attached"))
	MobileKeyboardManager._apply_input_text(multiline, "first\nsecond")
	assert(multiline.text == "first\nsecond")
	print("MOBILE_KEYBOARD_INPUT_TEST_PASSED: %d attached fields" % count)
	get_tree().quit()
