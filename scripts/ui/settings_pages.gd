extends Node

# Local identity is separate from life saves, so resetting a life keeps the UID.
# Online identities must be assigned/verified by the future authentication service.
const PROFILE_PATH := "user://local_profile.cfg"
const TERMS := """TERMS & CONDITIONS
Prototype draft • LIFE.EXE

ABOUT THIS GAME
LIFE.EXE is a fictional life simulation provided for personal entertainment. Its stories and outcomes are not real-world advice.

PROTOTYPE FEATURES
Features, balance and content may change during development. Google sign-in, email accounts and shop purchases are previews only. No online account is created and no payment is processed in this build.

YOUR PROGRESS
Progress is saved on this device. Cloud backup and cross-device recovery are not available. Clearing app data may permanently remove your progress and local profile ID.

FAIR USE
Use the game lawfully. Do not use future online features to impersonate others, abuse other players or interfere with the service. Game content remains subject to its owners' rights and applicable licenses.

YOUR RIGHTS
Nothing in these draft terms removes rights that cannot be excluded under applicable consumer law.

BEFORE PUBLIC RELEASE
These terms are a draft, not final release terms. Publisher identity, contact details, eligibility rules and any purchase, refund and online service terms must be finalized before launch."""
const PRIVACY := """PRIVACY POLICY
Prototype draft • LIFE.EXE

LOCAL GAME DATA
This prototype stores your character, choices, statistics, relationships and progress in a local save file to resume your game. A randomly generated local profile UID is stored separately to identify this installation's profile. It is not a hardware or advertising identifier.

ACCOUNT PREVIEW
Google and email sign-in are not connected. Email and password fields are used only to preview the form. They are not sent to a server or saved to disk, and are cleared after a successful preview or when you leave the account page. Please use sample details only.

PURCHASE PREVIEW
Shop offers are mockups. This build's shop does not request payment details or process transactions. These account and shop screens do not transmit your data to Google or a payment provider.

RETENTION & LOCAL CONTROL
Local progress remains until it is reset or app data is cleared. Reset Life Progress clears the life save; it does not remove your local UID. Clearing the app's storage removes both, subject to your device's backup settings. There is no cloud account to delete in this preview.

BEFORE PUBLIC RELEASE
This draft must be reviewed against the final app and any third-party services. Publisher and privacy contact details, retention rules, a public policy URL, and disclosures for any future authentication, analytics, advertising or billing services must be added before launch. Online accounts will need an account and data deletion option."""

var local_uid := ""
var profile_persisted := false
var page: PanelContainer
var body: VBoxContainer
var title: Label
var status: Label
var email: LineEdit
var password: LineEdit
var confirm_password: LineEdit
var signup := false
var source_button: Button
var settings: Control

func install(overlay: Control) -> void:
	settings = overlay
	_load_identity()
	var card := overlay.get_node("SettingsCard") as Control
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.offset_left = 0
	card.offset_top = 0.0
	card.offset_right = 0
	card.offset_bottom = 0
	var margin := card.get_node("SettingsMargin")
	var content := margin.get_node("SettingsContent") as VBoxContainer
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 24)
	margin.add_child(column)

	var header := content.get_node_or_null("SettingsHeader")
	if header != null:
		header.reparent(column)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	content.reparent(scroll)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var account := _button("ACCOUNT / LOGIN", content, _open_account)
	content.move_child(account, 2 if header != null else 3)
	var terms := _button("Terms & Conditions", content, func(): _open_document("Terms & Conditions", TERMS))
	content.move_child(terms, 3 if header != null else 4)
	var privacy := _button("Privacy Policy", content, func(): _open_document("Privacy Policy", PRIVACY))
	content.move_child(privacy, 4 if header != null else 5)
	var uid_label := _label("UID: " + local_uid, 22)
	uid_label.name = "UIDLabel"
	uid_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(uid_label)
	var local_prof_lbl := _label("Local profile • " + ("Saved on this device" if profile_persisted else "ID could not be saved; storage unavailable"), 20)
	local_prof_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(local_prof_lbl)
	_build_page()

func _load_identity() -> void:
	var config := ConfigFile.new()
	if config.load(PROFILE_PATH) == OK:
		var saved := str(config.get_value("profile", "uid", ""))
		if saved.length() == 32 and saved.is_valid_hex_number():
			local_uid = saved
			profile_persisted = true
			return
	local_uid = Crypto.new().generate_random_bytes(16).hex_encode().to_upper()
	config.set_value("profile", "uid", local_uid)
	profile_persisted = config.save(PROFILE_PATH) == OK

func _build_page() -> void:
	page = PanelContainer.new()
	page.name = "SettingsDetailPage"
	get_parent().add_child(page)
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.offset_left = 0
	page.offset_top = 0.0
	page.offset_right = 0
	page.offset_bottom = 0
	page.z_index = 91
	var is_light: bool = LifeLibrary.data.theme == "light"
	page.add_theme_stylebox_override("panel", _style(Color("#edf3fa") if is_light else Color(0.055, 0.085, 0.17, 0.98), Color("#0284c7") if is_light else Color("#244872"), 36))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 24)
	page.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	title = _label("ACCOUNT", 40)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close := _button("✕", header, _close_page)
	close.custom_minimum_size = Vector2(80, 60)
	close.add_theme_font_size_override("font_size", 28)
	close.tooltip_text = "Back to Settings"
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 24)
	scroll.add_child(body)
	page.hide()
	preload("res://scripts/ui/panel_pull_up.gd").watch(page)

func _clear_body() -> void:
	_clear_credentials()
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	email = null
	password = null
	confirm_password = null
	(body.get_parent() as ScrollContainer).scroll_vertical = 0

func _show_page(heading: String) -> void:
	if not page.visible:
		source_button = get_viewport().gui_get_focus_owner() as Button
	title.text = heading
	page.show()
	page.find_children("*", "Button", true, false)[0].grab_focus()

func _close_page() -> void:
	_clear_credentials()
	preload("res://scripts/ui/panel_close.gd").dismiss(page, false, func():
		if is_instance_valid(source_button):
			source_button.grab_focus()
	)

func _input(event: InputEvent) -> void:
	if page != null and page.visible and event.is_action_pressed("ui_cancel"):
		_close_page()
		get_viewport().set_input_as_handled()

func _open_document(heading: String, text: String) -> void:
	_clear_body()
	body.add_child(_label(text, 28))
	_show_page(heading)

func _open_account() -> void:
	_clear_body()
	body.add_child(_label("YOUR LIFE. YOUR SAVE.", 34))
	body.add_child(_label("Playing with a local profile. Online accounts are coming later; use sample details in this preview.", 26))
	_button("Continue with Google", body, func(): status.text = "Google sign-in is a preview. No account was connected.")
	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 18)
	body.add_child(modes)
	var login := _button("Email login", modes, func(): signup = false; _open_account())
	login.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var create := _button("Sign up", modes, func(): signup = true; _open_account())
	create.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(_label("CREATE A LIFE.EXE ACCOUNT" if signup else "EMAIL LOGIN", 28))
	email = _field("Email", false)
	password = _field("Password (8+ characters)", true)
	if signup:
		confirm_password = _field("Confirm password", true)
	_button("Preview sign up" if signup else "Preview login", body, _submit_email)
	_button("Save progress locally", body, _save_local)
	body.add_child(_label("Local saves stay on this device. Cloud sync and recovery are not available yet.", 24))
	status = _label("UID: " + local_uid, 24)
	status.name = "AccountStatus"
	body.add_child(status)
	_show_page("ACCOUNT")

func _field(caption: String, secret: bool) -> LineEdit:
	body.add_child(_label(caption, 24))
	var input := LineEdit.new()
	input.placeholder_text = caption
	input.secret = secret
	input.max_length = 254 if not secret else 128
	input.custom_minimum_size.y = 78
	input.add_theme_font_size_override("font_size", 28)
	var is_light: bool = LifeLibrary.data.theme == "light"
	input.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f1f5ff"))
	input.add_theme_color_override("placeholder_color", Color("#64748b"))
	input.add_theme_stylebox_override("normal", _style(Color("#edf3fa") if is_light else Color("#12213b"), Color("#0284c7") if is_light else Color("#40647e"), 16))
	body.add_child(input)
	MobileKeyboardManager.attach_to_input(input, caption)
	return input

func _submit_email() -> void:
	var address := email.text.strip_edges()
	var pattern := RegEx.new()
	pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
	if pattern.search(address) == null:
		status.text = "Enter a valid sample email address."
		return
	if password.text.length() < 8:
		status.text = "Use at least 8 characters for the sample password."
		return
	if signup and password.text != confirm_password.text:
		status.text = "The sample passwords do not match."
		return
	_clear_credentials()
	status.text = "Preview complete. No account was created or signed in. Your details were cleared."

func _clear_credentials() -> void:
	for field in [email, password, confirm_password]:
		if is_instance_valid(field):
			field.clear()

func _save_local() -> void:
	_clear_credentials()
	if not PlayerData.has_started_game:
		status.text = "Your local profile is ready. Start a life before saving progress."
		return
	_close_page()
	get_parent().get_node("OptionsMenu")._save_life()

func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var is_light: bool = LifeLibrary.data.theme == "light"
	label.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#aee4f5"))
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _style(fill: Color, border: Color, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style

func _button(text: String, parent: Node, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 82
	button.add_theme_font_size_override("font_size", 28)
	var is_light: bool = LifeLibrary.data.theme == "light"
	var normal_sb := _style(Color("#edf3fa") if is_light else Color("#12213b"), Color("#0284c7") if is_light else Color("#40647e"), 16)
	normal_sb.shadow_color = Color(0, 0, 0, 0.22)
	normal_sb.shadow_size = 4
	normal_sb.shadow_offset = Vector2(0, 3)

	var hover_sb := _style(Color("#bfdbfe") if is_light else Color("#1d3353"), Color("#0369a1") if is_light else Color("#64e6ff"), 16)
	hover_sb.shadow_color = Color(0, 0, 0, 0.28)
	hover_sb.shadow_size = 6
	hover_sb.shadow_offset = Vector2(0, 3)
	hover_sb.border_color = Color("#0284c7") if is_light else Color.WHITE

	var pressed_sb := _style(Color("#93c5fd") if is_light else Color("#0d1729"), Color("#000000") if is_light else Color("#64e6ff"), 16)
	pressed_sb.shadow_color = Color(0, 0, 0, 0.18)
	pressed_sb.shadow_size = 1
	pressed_sb.shadow_offset = Vector2(0, 1)

	button.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#64e6ff"))
	button.add_theme_color_override("font_hover_color", Color("#0284c7") if is_light else Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#000000") if is_light else Color("#ffffff"))
	button.add_theme_stylebox_override("normal", normal_sb)
	button.add_theme_stylebox_override("hover", hover_sb)
	button.add_theme_stylebox_override("pressed", pressed_sb)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	parent.add_child(button)
	button.pressed.connect(action)
	return button
