extends Control
const CreationOptions = preload("res://scripts/core/creation_options.gd")
const NameCatalog = preload("res://scripts/core/name_catalog.gd")
const PortraitCatalog = preload("res://scripts/core/portrait_catalog.gd")
const BirthStoryGenerator = preload("res://scripts/core/birth_story_generator.gd")
const RomanceRules = preload("res://scripts/core/romance_rules.gd")
const RelationshipExtras = preload("res://scripts/core/relationship_extras.gd")
const CareerProgression = preload("res://scripts/economy/career_progression.gd")
const UndergroundProgression = preload("res://scripts/economy/underground_progression.gd")
const UIStyle = preload("res://scripts/ui/ui_style.gd")
const NpcLifeProgress = preload("res://scripts/core/npc_life_progress.gd")
const RoomManager = preload("res://scripts/isometric/room_manager.gd")


var portrait: TextureRect
var panel_pull_up := preload("res://scripts/ui/panel_pull_up.gd").new()
var portrait_key: String = ""
var gender_input: OptionButton
var creation_selected_ethnicity: String = "white"
var creation_selected_track: int = 0
var creation_avatar_rect: TextureRect
var creation_avatar_desc: Label

var current_event = null
var current_event_choices: Array = []
var annual_event_popup_chance: float = 0.45

# Profile Strip Nodes
@onready var avatar_button: Button = $ProfileStrip/ProfileMargin/ProfileRow/AvatarButton
@onready var nationality_flag: TextureRect = $ProfileStrip/ProfileMargin/ProfileRow/NationalityFlag
@onready var name_label: Label = $ProfileStrip/ProfileMargin/ProfileRow/NameAndPhase/NameLabel
@onready var phase_label: Label = $ProfileStrip/ProfileMargin/ProfileRow/NameAndPhase/PhaseLabel
@onready var balance_label: Label = $ProfileStrip/ProfileMargin/ProfileRow/BalanceLabel

# Main Screen / Timeline
@onready var life_feed: RichTextLabel = (
	get_node_or_null("SafeArea/MainColumn/TimelinePanel/TimelineContent/MarginContainer/LifeFeed") as RichTextLabel
	if has_node("SafeArea/MainColumn/TimelinePanel/TimelineContent/MarginContainer/LifeFeed")
	else get_node_or_null("SafeArea/MainColumn/LifeFeedPanel/MarginContainer/LifeFeed") as RichTextLabel
)
@onready var timeline_drawer: PanelContainer = get_node_or_null("SafeArea/MainColumn/TimelinePanel") as PanelContainer
@onready var timeline_pull_up_btn: Button = get_node_or_null("SafeArea/MainColumn/TimelinePullUpButton") as Button
@onready var close_timeline_btn: Button = get_node_or_null("SafeArea/MainColumn/TimelinePanel/TimelineContent/TimelineHeaderRow/CloseTimelineButton") as Button
@onready var isometric_room: Node2D = get_node_or_null("SafeArea/MainColumn/LifeFeedPanel/RoomViewportContainer/RoomSubViewport/IsometricRoom") as Node2D
@onready var health_bar: ProgressBar = $SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer/HealthBar
@onready var happiness_bar: ProgressBar = $SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer/HappinessBar
@onready var smarts_bar: ProgressBar = $SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer/SmartsBar
@onready var looks_bar: ProgressBar = $SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer/LooksBar

var _is_timeline_open: bool = false
var _timeline_drawer_tween: Tween = null


# Loading Screen
@onready var loading_screen: Control = get_node_or_null("LoadingScreen") as Control
@onready var disclaimer_screen: Control = get_node_or_null("DisclaimerScreen") as Control
@onready var loading_progress_label: Label = get_node_or_null("LoadingScreen/CenterContainer/LoadingVBox/LoadingProgressLabel") as Label
@onready var age_button: Button = $SafeArea/MainColumn/AgeButton
@onready var safe_area: Control = $SafeArea
@onready var top_bar: PanelContainer = $TopBar
@onready var profile_strip: PanelContainer = $ProfileStrip

# Dialogs & Overlays
@onready var settings_overlay: ColorRect = $SettingsOverlay
@onready var reset_confirmation_overlay: ColorRect = $ResetConfirmationOverlay
@onready var new_game_panel: PanelContainer = $NewGamePanel
@onready var name_input: LineEdit = $NewGamePanel/CenterContainer/CreationCard/NewGameContent/NameInput
@onready var birthplace_input: OptionButton = $NewGamePanel/CenterContainer/CreationCard/NewGameContent/BirthplaceInput
@onready var validation_label: Label = $NewGamePanel/CenterContainer/CreationCard/NewGameContent/ValidationLabel

# 4 Action Buttons flanking Age Button
@onready var action_bar: PanelContainer = $SafeArea/MainColumn/ActionBar
@onready var infant_button: Button = $SafeArea/MainColumn/ActionBar/ActionRow/InfantButton
@onready var assets_button: Button = $SafeArea/MainColumn/ActionBar/ActionRow/AssetsButton
@onready var relationships_button: Button = $SafeArea/MainColumn/ActionBar/ActionRow/RelationshipsButton
@onready var activities_button: Button = $SafeArea/MainColumn/ActionBar/ActionRow/ActivitiesButton

# Navigation panels
@onready var timeline_panel: Control = $SafeArea
@onready var character_panel: PanelContainer = $CharacterPanel

# Character Profile Nodes
@onready var character_name: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/IdentityCard/Margin/VBox/CharacterName
@onready var character_stage: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/IdentityCard/Margin/VBox/CharacterStage
@onready var character_birthplace: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/IdentityCard/Margin/VBox/CharacterBirthplace
@onready var character_birthday: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/IdentityCard/Margin/VBox/CharacterBirthday
@onready var character_mother: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/FamilyCard/Margin/VBox/CharacterMother
@onready var character_father: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/FamilyCard/Margin/VBox/CharacterFather
@onready var character_story: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/FamilyCard/Margin/VBox/CharacterStory
@onready var character_money: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/FinancesCard/Margin/VBox/CharacterMoney
@onready var character_karma: Label = $CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/FinancesCard/Margin/VBox/CharacterKarma
@onready var character_milestones_list: VBoxContainer = get_node_or_null("CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/MilestonesCard/Margin/VBox/MilestonesList") as VBoxContainer

# Toddler / Infant Panel (Life Overview Panel)
@onready var infant_panel: PanelContainer = $InfantPanel
@onready var current_stage_label: Label = $InfantPanel/InfantMargin/InfantContent/StatusCard/StatusMargin/StatusBox/CurrentStageLabel
@onready var current_job_label: Label = get_node_or_null("InfantPanel/InfantMargin/InfantContent/StatusCard/StatusMargin/StatusBox/CurrentJobLabel") as Label
@onready var current_edu_label: Label = get_node_or_null("InfantPanel/InfantMargin/InfantContent/StatusCard/StatusMargin/StatusBox/CurrentEduLabel") as Label
@onready var grades_label: Label = get_node_or_null("InfantPanel/InfantMargin/InfantContent/StatusCard/StatusMargin/StatusBox/GradesContainer/GradesLabel") as Label
@onready var grades_progress_bar: ProgressBar = get_node_or_null("InfantPanel/InfantMargin/InfantContent/StatusCard/StatusMargin/StatusBox/GradesContainer/GradesProgressBar") as ProgressBar
@onready var history_list: VBoxContainer = $InfantPanel/InfantMargin/InfantContent/HistoryScroll/HistoryList
@onready var filter_all_btn: Button = get_node_or_null("InfantPanel/InfantMargin/InfantContent/HistoryFilterRow/FilterAllButton") as Button
@onready var filter_milestones_btn: Button = get_node_or_null("InfantPanel/InfantMargin/InfantContent/HistoryFilterRow/FilterMilestonesButton") as Button
@onready var filter_unique_btn: Button = get_node_or_null("InfantPanel/InfantMargin/InfantContent/HistoryFilterRow/FilterUniqueButton") as Button

var overview_history_filter: String = "all"

# Activities Modals
var jobs_modal_overlay: Control = null
var job_category_modal_overlay: Control = null
var freelance_modal_overlay: Control = null
var licensing_modal_overlay: Control = null
var license_category_modal_overlay: Control = null
var driving_exam_modal_overlay: Control = null
var business_modal_overlay: Control = null
var business_category_modal_overlay: Control = null
var education_modal_overlay: Control = null
var university_modal_overlay: Control = null
var shopping_modal_overlay: Control = null
var mind_body_modal_overlay: Control = null
var social_media_modal_overlay: Control = null
var pet_adoption_modal_overlay: Control = null
var will_modal_overlay: Control = null
var salon_modal_overlay: Control = null
var spa_modal_overlay: Control = null

# Assets Panel
@onready var assets_panel: PanelContainer = $AssetsPanel
@onready var assets_cash_label: Label = $AssetsPanel/AssetsMargin/AssetsContent/AssetsCashLabel
@onready var bank_button: Button = $AssetsPanel/AssetsMargin/AssetsContent/BankButton
@onready var assets_list: VBoxContainer = $AssetsPanel/AssetsMargin/AssetsContent/AssetsScroll/AssetsList

# Bank Panel
@onready var bank_panel: PanelContainer = $BankPanel
@onready var bank_scroll: ScrollContainer = $BankPanel/BankMargin/BankContent/BankScroll
@onready var bank_list: VBoxContainer = $BankPanel/BankMargin/BankContent/BankScroll/BankList
@onready var bank_checking_label: Label = $BankPanel/BankMargin/BankContent/BankScroll/BankList/BankCard/Margin/VBox/CheckingBalanceLabel
@onready var bank_header_icon: TextureRect = $BankPanel/BankMargin/BankContent/BankScroll/BankList/BankCard/Margin/VBox/BankIconRow/BankHeaderIcon

# Relationships Panel Nodes
@onready var relationships_panel: PanelContainer = $RelationshipsPanel
@onready var mother_card: PanelContainer = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/MotherCard
@onready var mother_icon: TextureRect = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/MotherCard/Margin/HBox/MotherIcon
@onready var mother_name_label: Label = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/MotherCard/Margin/HBox/MotherVBox/MotherNameLabel
@onready var mother_job_label: Label = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/MotherCard/Margin/HBox/MotherVBox/MotherJobLabel
@onready var mother_status_label: Label = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/MotherCard/Margin/HBox/MotherVBox/MotherStatusLabel

@onready var father_card: PanelContainer = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/FatherCard
@onready var father_icon: TextureRect = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/FatherCard/Margin/HBox/FatherIcon
@onready var father_name_label: Label = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/FatherCard/Margin/HBox/FatherVBox/FatherNameLabel
@onready var father_job_label: Label = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/FatherCard/Margin/HBox/FatherVBox/FatherJobLabel
@onready var father_status_label: Label = $RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList/FatherCard/Margin/HBox/FatherVBox/FatherStatusLabel

# Activities Panel
@onready var activities_panel: PanelContainer = $ActivitiesPanel

# Event Dialog Nodes
@onready var event_overlay: Control = get_node_or_null("EventOverlay") as Control
@onready var event_title: Label = _find_event_node("EventTitle") as Label
@onready var event_description: RichTextLabel = _find_event_node("EventDescription") as RichTextLabel
@onready var event_choice_1: Button = _find_event_node("EventChoice1") as Button
@onready var event_choice_2: Button = _find_event_node("EventChoice2") as Button
@onready var event_choice_3: Button = _find_event_node("EventChoice3") as Button
@onready var event_choice_4: Button = _find_event_node("EventChoice4") as Button


func _ready() -> void:
	_configure_ui()
	_connect_runtime_signals()

	var shop := preload("res://scripts/ui/shop_panel.gd").new()
	shop.name = "ShopPanel"
	add_child(shop)
	shop.closed.connect(func(): show_tab("settings"))
	var settings_pages := preload("res://scripts/ui/settings_pages.gd").new()
	settings_pages.name = "SettingsPages"
	add_child(settings_pages)
	settings_pages.install(settings_overlay)
	var options := preload("res://scripts/ui/options_menu.gd").new()
	options.name = "OptionsMenu"
	add_child(options)
	options.install(self, settings_pages)
	var finance_panel := preload("res://scripts/ui/finance_panel.gd").new()
	finance_panel.name = "FinancePanel"
	add_child(finance_panel)
	finance_panel.install(self)
	life_feed.set_meta("locale_manual", true)
	GameLocale.changed.connect(rebuild_life_feed)
	var localization := preload("res://scripts/ui/localization_controller.gd").new()
	localization.name = "LocalizationController"
	add_child(localization)
	var theme_controller := preload("res://scripts/ui/theme_controller.gd").new()
	theme_controller.name = "ThemeController"
	add_child(theme_controller)
	var touch_scroll := preload("res://scripts/ui/touch_scroll_controller.gd").new()
	touch_scroll.name = "TouchScrollController"
	add_child(touch_scroll)
	var mobile_kb := preload("res://scripts/ui/mobile_keyboard_manager.gd").new()
	mobile_kb.name = "MobileKeyboardManager"
	add_child(mobile_kb)
	var pull_up = preload("res://scripts/ui/panel_pull_up.gd")
	pull_up.watch(event_overlay.get_node("EventPanel"), event_overlay)
	pull_up.watch(reset_confirmation_overlay.get_node("ConfirmCard"), reset_confirmation_overlay)
	pull_up.watch(new_game_panel)

	# Smooth high-refresh UI rendering
	Engine.max_fps = 120

	# Configure translucent, sleek scroll indicators on every page and scroll container
	_setup_all_translucent_scrollbars()
	_adjust_safe_area()
	get_viewport().size_changed.connect(_adjust_safe_area)
	if age_button != null:
		age_button.button_down.connect(func(): _trigger_haptic(25))

	var loaded: bool = SaveManager.load_game()
	FinanceMarket.ensure(PlayerData)
	BalanceRules.normalize_salary(PlayerData)
	RomanceRules.normalize(PlayerData)

	if event_overlay != null:
		event_overlay.visible = false

	if settings_overlay != null:
		settings_overlay.visible = false

	if reset_confirmation_overlay != null:
		reset_confirmation_overlay.visible = false

	character_panel.visible = false
	infant_panel.visible = false
	assets_panel.visible = false
	bank_panel.visible = false
	relationships_panel.visible = false
	activities_panel.visible = false
	timeline_panel.visible = true

	# Pre-populate and build panels at startup so they render immediately with all buttons ready on first tap
	update_assets_panel()
	update_bank_panel()
	update_relationships_panel()
	update_character_panel()
	update_infant_panel()
	_configure_button_contrasts()
	if has_node("ThemeController"):
		var tc = get_node("ThemeController")
		for p in [assets_panel, bank_panel, relationships_panel, character_panel, infant_panel, activities_panel]:
			tc.apply_subtree(p)

	if loaded and PlayerData.has_started_game:
		hide_new_game_screen()
		rebuild_life_feed()
		update_ui()
		if action_bar != null:
			action_bar.visible = true
		if age_button != null:
			age_button.visible = true
		if PlayerData.is_dead:
			_show_death_screen(PlayerData.cause_of_death if PlayerData.cause_of_death != "" else "Health Complications")
	else:
		show_new_game_screen()

	if disclaimer_screen != null and loading_screen != null:
		disclaimer_screen.visible = true
		disclaimer_screen.modulate.a = 1.0
		loading_screen.visible = true
		loading_screen.modulate.a = 1.0
		_start_game_initialization_sequence()
	elif loading_screen != null:
		loading_screen.visible = true
		loading_screen.modulate.a = 1.0
		_start_loading_animation()


func on_theme_changed() -> void:
	if has_node("ThemeController"):
		get_node("ThemeController").apply_theme()
	_configure_ui()
	_configure_button_contrasts()
	_update_creation_theme()
	update_ui()
	rebuild_life_feed()
	update_character_panel()
	update_relationships_panel()
	update_assets_panel()
	update_bank_panel()
	update_infant_panel()
	update_history_panel()
	if has_node("ThemeController"):
		var tc = get_node("ThemeController")
		for p in [assets_panel, bank_panel, relationships_panel, character_panel, infant_panel, activities_panel]:
			if p != null and is_instance_valid(p):
				tc.apply_subtree(p)


func _connect_runtime_signals() -> void:
	if avatar_button != null and not avatar_button.pressed.is_connected(_on_avatar_button_pressed):
		avatar_button.pressed.connect(_on_avatar_button_pressed)

	if filter_all_btn != null and not filter_all_btn.pressed.is_connected(_on_filter_all_pressed):
		filter_all_btn.pressed.connect(_on_filter_all_pressed)
	if filter_milestones_btn != null and not filter_milestones_btn.pressed.is_connected(_on_filter_milestones_pressed):
		filter_milestones_btn.pressed.connect(_on_filter_milestones_pressed)
	if filter_unique_btn != null and not filter_unique_btn.pressed.is_connected(_on_filter_unique_pressed):
		filter_unique_btn.pressed.connect(_on_filter_unique_pressed)

	var dating_app_btn := get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList/DatingAppItem") as Button
	if dating_app_btn != null and not dating_app_btn.pressed.is_connected(_on_dating_app_item_pressed):
		dating_app_btn.pressed.connect(_on_dating_app_item_pressed)

	var charity_btn := get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList/CharityActItem") as Button
	if charity_btn != null and not charity_btn.pressed.is_connected(_on_charity_item_pressed):
		charity_btn.pressed.connect(_on_charity_item_pressed)

	if timeline_pull_up_btn != null and not timeline_pull_up_btn.pressed.is_connected(_on_timeline_pull_up_button_pressed):
		timeline_pull_up_btn.pressed.connect(_on_timeline_pull_up_button_pressed)
	if close_timeline_btn != null and not close_timeline_btn.pressed.is_connected(_on_close_timeline_button_pressed):
		close_timeline_btn.pressed.connect(_on_close_timeline_button_pressed)



func _configure_ui() -> void:
	_configure_creation()
	_configure_age_art()
	_configure_action_bar()
	_configure_custom_icons()
	_configure_stat_bars()
	_configure_portrait()
	_configure_button_contrasts()

	var disclaimer_card := get_node_or_null("DisclaimerScreen/CenterContainer/DisclaimerCard") as PanelContainer
	if disclaimer_card != null:
		disclaimer_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#00f0ff")))

	var is_light: bool = LifeLibrary.data.theme == "light"
	var bg_color := Color("#f4f6fa") if is_light else Color(0.043, 0.075, 0.165, 1.0)
	RenderingServer.set_default_clear_color(bg_color)
	var bg_node := get_node_or_null("Background") as ColorRect
	if bg_node != null:
		bg_node.color = bg_color
	var load_bg := get_node_or_null("LoadingScreen/LoadingBackground") as ColorRect
	if load_bg != null:
		load_bg.color = bg_color
	var disc_bg := get_node_or_null("DisclaimerScreen/DisclaimerBackground") as ColorRect
	if disc_bg != null:
		disc_bg.color = bg_color

	if balance_label != null:
		var bal_sb := StyleBoxFlat.new()
		bal_sb.bg_color = Color("#edf3fa") if is_light else Color(0.035, 0.08, 0.16, 0.95)
		bal_sb.border_color = Color("#15803d") if is_light else Color("#10b981")
		bal_sb.border_width_left = 2
		bal_sb.border_width_top = 2
		bal_sb.border_width_right = 2
		bal_sb.border_width_bottom = 2
		bal_sb.corner_radius_top_left = 12
		bal_sb.corner_radius_top_right = 12
		bal_sb.corner_radius_bottom_right = 12
		bal_sb.corner_radius_bottom_left = 12
		bal_sb.content_margin_left = 18
		bal_sb.content_margin_right = 18
		bal_sb.content_margin_top = 8
		bal_sb.content_margin_bottom = 8
		bal_sb.shadow_color = Color(0, 0, 0, 0.12 if is_light else 0.25)
		bal_sb.shadow_size = 8
		balance_label.add_theme_stylebox_override("normal", bal_sb)
		balance_label.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#34d399"))
		balance_label.add_theme_font_size_override("font_size", 20)
		balance_label.custom_minimum_size = Vector2(260, 96)
		balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		balance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		balance_label.mouse_filter = Control.MOUSE_FILTER_STOP
		if not balance_label.has_meta("gui_connected"):
			balance_label.set_meta("gui_connected", true)
			balance_label.gui_input.connect(func(event: InputEvent) -> void:
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					show_tab("bank")
			)

	life_feed.scroll_following = true
	if not life_feed.get_v_scroll_bar().changed.is_connected(_scroll_after_layout):
		life_feed.get_v_scroll_bar().changed.connect(_scroll_after_layout)
	name_label.add_theme_font_size_override("font_size", 40)
	phase_label.add_theme_font_size_override("font_size", 26)
	life_feed.add_theme_font_size_override("normal_font_size", 28)
	life_feed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var life_margin := get_node_or_null("SafeArea/MainColumn/TimelinePanel/TimelineContent/MarginContainer") as MarginContainer
	if life_margin == null:
		life_margin = get_node_or_null("SafeArea/MainColumn/LifeFeedPanel/MarginContainer") as MarginContainer
	if life_margin != null:
		life_margin.add_theme_constant_override("margin_left", 30)
		life_margin.add_theme_constant_override("margin_right", 30)
		life_margin.add_theme_constant_override("margin_top", 24)
		life_margin.add_theme_constant_override("margin_bottom", 24)


	var page := StyleBoxFlat.new()
	page.bg_color = Color("#f8fafc") if is_light else Color(0.055, 0.085, 0.17, 0.98)
	page.border_width_left = 3
	page.border_width_top = 3
	page.border_width_right = 3
	page.border_width_bottom = 3
	page.border_color = Color("#0284c7") if is_light else Color(0.22, 0.65, 0.95, 0.95)
	page.corner_radius_top_left = 12
	page.corner_radius_top_right = 12
	page.corner_radius_bottom_right = 12
	page.corner_radius_bottom_left = 12
	page.shadow_color = Color(0, 0, 0, 0.12 if is_light else 0.7)
	page.shadow_size = 14
	character_panel.add_theme_stylebox_override("panel", page)
	infant_panel.add_theme_stylebox_override("panel", page)
	assets_panel.add_theme_stylebox_override("panel", page)
	bank_panel.add_theme_stylebox_override("panel", page)
	relationships_panel.add_theme_stylebox_override("panel", page)
	activities_panel.add_theme_stylebox_override("panel", page)


func _configure_button_contrasts() -> void:
	var light: bool = LifeLibrary.data.theme == "light"
	var font_col: Color = Color("#0f172a") if light else Color("#f1f5f9")
	var hover_col: Color = Color("#0284c7") if light else Color("#00f0ff")
	var pressed_col: Color = Color("#000000") if light else Color("#ffffff")
	var focus_col: Color = Color("#0284c7") if light else Color("#00f0ff")
	var disabled_col: Color = Color("#64748b") if light else Color("#94a3b8")

	# Enforce clear contrasting text on all activity buttons and cards
	var act_list := get_node_or_null("ActivitiesPanel/ActMargin/ActContent/ActScroll/ActList")
	if act_list != null:
		for child in act_list.get_children():
			if child is Button:
				# If button has ReferenceRow presenter, do not overwrite button font_color with opaque color,
				# keep it transparent so native button text doesn't clash with ReferenceRow presenter.
				if child.has_node("ReferenceRow"):
					for key in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]:
						child.add_theme_color_override(key, Color.TRANSPARENT)
					var r = child.get_node("ReferenceRow")
					if r.has_method("_sync"):
						r._sync()
					continue
				if not child.has_meta("dark_theme_originals"):
					child.set_meta("dark_theme_originals", {
						"styles": {},
						"colors": {
							"font_color": Color("#f1f5f9"),
							"font_hover_color": Color("#00f0ff"),
							"font_pressed_color": Color("#ffffff"),
							"font_focus_color": Color("#00f0ff"),
							"font_disabled_color": Color("#94a3b8")
						}
					})
				child.add_theme_color_override("font_color", font_col)
				child.add_theme_color_override("font_hover_color", hover_col)
				child.add_theme_color_override("font_pressed_color", pressed_col)
				child.add_theme_color_override("font_focus_color", focus_col)
				child.add_theme_color_override("font_disabled_color", disabled_col)

	if bank_button != null:
		if bank_button.has_node("ReferenceRow"):
			for key in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]:
				bank_button.add_theme_color_override(key, Color.TRANSPARENT)
			var r = bank_button.get_node("ReferenceRow")
			if r.has_method("_sync"):
				r._sync()
		else:
			if not bank_button.has_meta("dark_theme_originals"):
				bank_button.set_meta("dark_theme_originals", {
					"styles": {},
					"colors": {
						"font_color": Color("#f1f5f9"),
						"font_hover_color": Color("#00f0ff"),
						"font_pressed_color": Color("#ffffff"),
						"font_focus_color": Color("#00f0ff"),
						"font_disabled_color": Color("#94a3b8")
					}
				})
			bank_button.add_theme_color_override("font_color", font_col)
			bank_button.add_theme_color_override("font_hover_color", hover_col)
			bank_button.add_theme_color_override("font_pressed_color", pressed_col)
			bank_button.add_theme_color_override("font_focus_color", focus_col)
			bank_button.add_theme_color_override("font_disabled_color", disabled_col)

	var back_assets_btn := get_node_or_null("BankPanel/BankMargin/BankContent/BankHeaderRow/BackToAssetsButton") as Button
	if back_assets_btn != null:
		if not back_assets_btn.has_meta("dark_theme_originals"):
			back_assets_btn.set_meta("dark_theme_originals", {
				"styles": {},
				"colors": {
					"font_color": Color("#f1f5f9"),
					"font_hover_color": Color("#00f0ff"),
					"font_pressed_color": Color("#ffffff"),
					"font_focus_color": Color("#00f0ff"),
					"font_disabled_color": Color("#94a3b8")
				}
			})
		back_assets_btn.add_theme_color_override("font_color", font_col)
		back_assets_btn.add_theme_color_override("font_hover_color", hover_col)
		back_assets_btn.add_theme_color_override("font_pressed_color", pressed_col)
		back_assets_btn.add_theme_color_override("font_focus_color", focus_col)
		back_assets_btn.add_theme_color_override("font_disabled_color", disabled_col)


func _configure_action_bar() -> void:
	# Configure MenuButton (Settings Cog) in TopBar with smooth tactile micro-animations
	var menu_btn := get_node_or_null("TopBar/Row/MenuButton") as Button
	if menu_btn != null:
		if ResourceLoader.exists("res://assets/ui/options_menu.svg"):
			menu_btn.icon = load("res://assets/ui/options_menu.svg")
			menu_btn.text = ""
			menu_btn.expand_icon = true
			menu_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			menu_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			menu_btn.custom_minimum_size = Vector2(76, 76)
			menu_btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		menu_btn.pivot_offset = Vector2(38, 38)
		if not menu_btn.mouse_entered.is_connected(_on_menu_btn_hover):
			menu_btn.mouse_entered.connect(_on_menu_btn_hover)
		if not menu_btn.mouse_exited.is_connected(_on_menu_btn_exit):
			menu_btn.mouse_exited.connect(_on_menu_btn_exit)
		if not menu_btn.button_down.is_connected(_on_menu_btn_down):
			menu_btn.button_down.connect(_on_menu_btn_down)
		if not menu_btn.button_up.is_connected(_on_menu_btn_up):
			menu_btn.button_up.connect(_on_menu_btn_up)

	# Modern navigation icons retain the existing tactile interactions
	var icon_configs := [
		[infant_button, "life", "Infant"],
		[assets_button, "assets", "Assets"],
		[relationships_button, "relationships", "Relationships"],
		[activities_button, "activities", "Activities"]
	]

	for item in icon_configs:
		var btn: Button = item[0]
		if btn != null:
			if item[1] != "":
				btn.icon = preload("res://scripts/ui/modern_navigation.gd").icon(item[1])
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				btn.expand_icon = true
				btn.add_theme_constant_override("icon_max_width", 64)
				btn.add_theme_constant_override("h_separation", 8)
				btn.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			btn.pivot_offset = Vector2(75, 105)
			if not btn.mouse_entered.is_connected(_on_action_bar_btn_hover.bind(btn)):
				btn.mouse_entered.connect(_on_action_bar_btn_hover.bind(btn))
			if not btn.mouse_exited.is_connected(_on_action_bar_btn_exit.bind(btn)):
				btn.mouse_exited.connect(_on_action_bar_btn_exit.bind(btn))
			if not btn.button_down.is_connected(_on_action_bar_btn_down.bind(btn)):
				btn.button_down.connect(_on_action_bar_btn_down.bind(btn))
			if not btn.button_up.is_connected(_on_action_bar_btn_up.bind(btn)):
				btn.button_up.connect(_on_action_bar_btn_up.bind(btn))

	# Configure Bank icon on BankButton in AssetsPanel
	if bank_button != null:
		bank_button.icon = null

	if bank_header_icon != null:
		var bank_svg := """<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0f2b48"/>
      <stop offset="60%" stop-color="#091b30"/>
      <stop offset="100%" stop-color="#040c17"/>
    </linearGradient>
    <linearGradient id="rimGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#38bdf8"/>
      <stop offset="50%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#0369a1"/>
    </linearGradient>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#fde047"/>
      <stop offset="50%" stop-color="#eab308"/>
      <stop offset="100%" stop-color="#ca8a04"/>
    </linearGradient>
    <linearGradient id="marbleGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="100%" stop-color="#cbd5e1"/>
    </linearGradient>
    <linearGradient id="roofGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ffffff"/>
      <stop offset="100%" stop-color="#e2e8f0"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="6" stdDeviation="6" flood-color="#000000" flood-opacity="0.45"/>
    </filter>
  </defs>
  <rect x="12" y="12" width="232" height="232" rx="64" fill="url(#bgGrad)"/>
  <rect x="14" y="14" width="228" height="228" rx="62" fill="none" stroke="url(#rimGrad)" stroke-width="4.5"/>
  <rect x="22" y="22" width="212" height="212" rx="54" fill="none" stroke="#38bdf8" stroke-width="1.5" stroke-opacity="0.25"/>
  <g filter="url(#shadow)">
    <path d="M 44 94 L 128 44 L 212 94 Z" fill="url(#roofGrad)"/>
    <rect x="40" y="94" width="176" height="14" rx="4" fill="#f8fafc"/>
    <rect x="44" y="108" width="168" height="6" rx="2" fill="#94a3b8"/>
    <circle cx="128" cy="74" r="13" fill="url(#goldGrad)"/>
    <circle cx="128" cy="74" r="10" fill="none" stroke="#fef08a" stroke-width="1.5"/>
    <path d="M 128 67 V 81 M 125 70 C 125 68 131 68 131 71 C 131 74 125 74 125 77 C 125 80 131 80 131 78" 
          fill="none" stroke="#78350f" stroke-width="1.8" stroke-linecap="round"/>
    <rect x="58" y="114" width="22" height="62" rx="4" fill="url(#marbleGrad)"/>
    <rect x="56" y="114" width="26" height="5" rx="2" fill="#e2e8f0"/>
    <rect x="56" y="171" width="26" height="5" rx="2" fill="#94a3b8"/>
    <rect x="98" y="114" width="22" height="62" rx="4" fill="url(#marbleGrad)"/>
    <rect x="96" y="114" width="26" height="5" rx="2" fill="#e2e8f0"/>
    <rect x="96" y="171" width="26" height="5" rx="2" fill="#94a3b8"/>
    <rect x="136" y="114" width="22" height="62" rx="4" fill="url(#marbleGrad)"/>
    <rect x="134" y="114" width="26" height="5" rx="2" fill="#e2e8f0"/>
    <rect x="134" y="171" width="26" height="5" rx="2" fill="#94a3b8"/>
    <rect x="176" y="114" width="22" height="62" rx="4" fill="url(#marbleGrad)"/>
    <rect x="174" y="114" width="26" height="5" rx="2" fill="#e2e8f0"/>
    <rect x="174" y="171" width="26" height="5" rx="2" fill="#94a3b8"/>
    <rect x="42" y="176" width="172" height="12" rx="3" fill="#f8fafc"/>
    <rect x="34" y="188" width="188" height="14" rx="4" fill="#cbd5e1"/>
    <rect x="34" y="200" width="188" height="3" rx="1.5" fill="#64748b"/>
  </g>
</svg>"""
		var b_img := Image.new()
		if b_img.load_svg_from_string(bank_svg, 1.0) == OK:
			bank_header_icon.texture = ImageTexture.create_from_image(b_img)
		bank_header_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func get_stage_icon_path(age: int) -> String:
	if age == 0:
		return "res://assets/icons/icon_infant.png"
	elif age <= 4:
		return "res://assets/icons/icon_toddler.png"
	elif age <= 12:
		return "res://assets/icons/icon_child.png"
	elif age <= 19:
		return "res://assets/icons/icon_teenager.png"
	elif age <= 64:
		return "res://assets/icons/icon_adult.png"
	else:
		return "res://assets/icons/icon_elder.png"


func _find_event_node(node_name: String) -> Node:
	var paths := [
		"EventOverlay/EventPanel/EventMargin/EventContent/" + node_name,
		"EventOverlay/EventPanel/EventMargin/EventContent/EventChoices/" + node_name,
		"EventOverlay/EventPanel/EventContent/" + node_name,
		"EventOverlay/EventPanel/EventContent/EventChoices/" + node_name,
		"EventOverlay/EventPanel/MarginContainer/EventContent/" + node_name,
		"EventOverlay/EventPanel/MarginContainer/EventContent/EventChoices/" + node_name
	]

	for path in paths:
		var node: Node = get_node_or_null(path)
		if node != null:
			return node

	return null


func _format_number(val: int) -> String:
	var s := str(absi(val))
	var res := ""
	for i in range(s.length()):
		if i > 0 and (s.length() - i) % 3 == 0:
			res += ","
		res += s[i]
	return ("-" if val < 0 else "") + res


func age_up() -> void:
	if PlayerData.is_dead:
		return
	if current_event != null:
		return

	var spent_year_in_prison: bool = PlayerData.is_in_prison
	var prev_age: int = PlayerData.age
	PlayerData.age += 1

	var year_word: String = "year" if PlayerData.age == 1 else "years"
	add_life_event("You turned %d %s old." % [PlayerData.age, year_word], "age")

	# 1. Prison Sentence Countdown
	if PlayerData.is_in_prison:
		PlayerData.prison_sentence_years -= 1
		if PlayerData.prison_sentence_years <= 0:
			PlayerData.is_in_prison = false
			PlayerData.prison_sentence_years = 0
			add_life_event("🎉 RELEASED: You have completed your prison sentence and were released back into society!", "crime")
		else:
			add_life_event("🔒 You served another year behind bars (%d years remaining)." % PlayerData.prison_sentence_years, "crime")
			PlayerData.happiness = maxi(5, PlayerData.happiness - 6)

	# 2. Annual Salary Payout (if employed and not in prison)
	if not PlayerData.is_in_prison and PlayerData.job_title != "" and PlayerData.job_salary > 0:
		PlayerData.receive_salary(PlayerData.job_salary)
		add_life_event("Your annual salary of $%s from %s was deposited into your bank account." % [
			_format_number(PlayerData.job_salary),
			PlayerData.job_company
		], "job")

	# 3. Living Expenses & Taxes (Adults age >= 18)
	if PlayerData.age >= 18:
		# Young adults under 22 living with parents pay $0 if unemployed
		var base_living: int = 0
		if PlayerData.age < 22 and PlayerData.job_title == "":
			base_living = 0
		elif PlayerData.job_salary > 0:
			base_living = 3200 + int(PlayerData.job_salary * 0.16)
		else:
			# Unemployed adult over 22: minimal independent survival costs
			base_living = randi_range(2400, 4800)

		if base_living > 0:
			var total_avail: int = PlayerData.money + PlayerData.bank_savings
			if total_avail >= base_living:
				PlayerData.debit_funds(base_living)
				add_life_event("You paid your annual basic living expenses of $%s (food, rent & bills)." % _format_number(base_living), "finance")
			else:
				var paid: int = total_avail
				var unpaid: int = base_living - paid
				PlayerData.money = 0
				PlayerData.bank_savings = 0
				PlayerData.debt += unpaid
				PlayerData.happiness = maxi(5, PlayerData.happiness - randi_range(2, 5))
				if PlayerData.debt > 15000:
					PlayerData.health = maxi(5, PlayerData.health - 1)
				add_life_event("⚠️ FINANCIAL STRUGGLE: You couldn't afford full living expenses ($%s)! Unpaid $%s added to debt (Total Debt: $%s)." % [
					_format_number(base_living),
					_format_number(unpaid),
					_format_number(PlayerData.get_total_debt())
				], "finance")

		# Taxes: Progressive bracket with $18,000 standard deduction
		var tax_due: int = 0
		if PlayerData.job_salary > 18000:
			var taxable: int = PlayerData.job_salary - 18000
			if taxable <= 42000:
				tax_due = int(taxable * 0.08)
			elif taxable <= 132000:
				tax_due = int(42000 * 0.08 + (taxable - 42000) * 0.14)
			else:
				tax_due = int(42000 * 0.08 + 90000 * 0.14 + (taxable - 132000) * 0.22)

		if tax_due > 0:
			var total_avail_tax: int = PlayerData.money + PlayerData.bank_savings
			if total_avail_tax >= tax_due:
				PlayerData.debit_funds(tax_due)
				add_life_event("You paid your annual income tax of $%s." % _format_number(tax_due), "finance")
			else:
				var paid_tax: int = total_avail_tax
				var unpaid_tax: int = tax_due - paid_tax
				PlayerData.money = 0
				PlayerData.bank_savings = 0
				PlayerData.tax_debt += unpaid_tax
				PlayerData.modify_credit_score(-35)
				add_life_event("⚠️ TAX AUDIT: You couldn't afford your annual income tax of $%s! The unpaid $%s has been added to your debt (Total Debt: $%s)." % [
					_format_number(tax_due),
					_format_number(unpaid_tax),
					_format_number(PlayerData.get_total_debt())
				], "finance")

	# Completed service promotes the current job; higher pay begins next year.
	var promotion := CareerProgression.advance_year(PlayerData, spent_year_in_prison)
	if not promotion.is_empty():
		add_life_event(promotion, "career")
		PlayerData.add_milestone("Promoted to %s at %s." % [PlayerData.job_title, PlayerData.job_company], PlayerData.age, "🎖️")

	# 5. Bank Loan Interest (APR)
	if PlayerData.loan_balance > 0:
		var interest: int = maxi(10, int(PlayerData.loan_balance * PlayerData.loan_interest_rate))
		PlayerData.loan_balance += interest
		add_life_event("Your bank loan accrued $%s in annual interest (Loan Balance: $%s)." % [
			_format_number(interest),
			_format_number(PlayerData.loan_balance)
		], "finance")

	# 5b. Credit Card Interest & Term Settlement
	if PlayerData.has_credit_card and PlayerData.credit_card_balance > 0:
		var cc_interest: int = maxi(5, int(PlayerData.credit_card_balance * PlayerData.credit_card_apr))
		PlayerData.credit_card_balance += cc_interest
		add_life_event("Your %s Credit Card accrued $%s in annual interest (Card Usage: $%s, %d%% APR)." % [
			PlayerData.credit_card_tier,
			_format_number(cc_interest),
			_format_number(PlayerData.credit_card_balance),
			int(PlayerData.credit_card_apr * 100)
		], "finance")

		var min_payment: int = maxi(1, int(ceil(PlayerData.credit_card_balance * 0.10)))
		var available_funds: int = PlayerData.get_available_funds()

		if available_funds < min_payment:
			# Player is unable to pay the minimum usage back to the bank -> Deactivate and convert usage to debt
			var def_res := PlayerData.deactivate_credit_card_on_default()
			var unpaid_debt: int = int(def_res.get("unpaid_usage", 0))
			add_life_event("🚨 CREDIT CARD DEFAULT & DEACTIVATION: You were unable to service the required 10%% minimum term payment ($%s) on your credit card usage. The bank has DEACTIVATED your credit card and transferred all unpaid usage ($%s) into collections as general DEBT! Credit score penalized (-75 pts)." % [
				_format_number(min_payment),
				_format_number(unpaid_debt)
			], "finance")
		else:
			# Player has funds; check if manual payment was made this year
			if PlayerData.credit_card_paid_this_year < min_payment:
				PlayerData.modify_credit_score(-15)
				add_life_event("⚠️ MISSED CREDIT CARD TERM: You missed this year's manual term payment on your credit card usage ($%s owed, 10%% minimum: $%s). Interest was assessed and credit score dropped by 15 points. Pay your balance in Banking to prevent card deactivation!" % [
					_format_number(PlayerData.credit_card_balance),
					_format_number(min_payment)
				], "finance")
			else:
				PlayerData.modify_credit_score(5)
				add_life_event("💳 Credit Standing: Timely credit card manual term payments met. Credit score maintained (+5 pts).", "finance")

		PlayerData.credit_card_paid_this_year = 0

	# 5c. Annual Credit Score Evaluation
	if PlayerData.age >= 18:
		if PlayerData.tax_debt > 0:
			PlayerData.modify_credit_score(-20)
			add_life_event("⚠️ CREDIT SCORE PENALTY: Outstanding unpaid taxes reduced your credit score by 20 points (Current Score: %d)." % PlayerData.credit_score, "finance")
		elif PlayerData.has_credit_card and PlayerData.credit_card_balance > int(PlayerData.credit_card_limit * 0.8):
			PlayerData.modify_credit_score(-10)
			add_life_event("⚠️ CREDIT SCORE IMPACT: High credit card utilization (>80%%) lowered your credit score by 10 points (Current Score: %d)." % PlayerData.credit_score, "finance")
		elif PlayerData.get_total_debt() == 0:
			PlayerData.modify_credit_score(5)

	# 6. Bank Savings Interest (2.5% Annual Return)
	if PlayerData.bank_savings > 0:
		var savings_interest: int = int(PlayerData.bank_savings * 0.025)
		if savings_interest > 0:
			PlayerData.bank_savings += savings_interest
			add_life_event("Your high-yield bank savings account accrued $%s in annual interest (2.5%% APR)." % _format_number(savings_interest), "finance")

	# 7. Gym Membership Annual Auto-Debit
	if PlayerData.has_gym_membership:
		var gym_fee: int = PlayerData.gym_membership_annual_fee
		if PlayerData.bank_savings >= gym_fee:
			PlayerData.bank_savings -= gym_fee
			add_life_event("🏋️ GYM MEMBERSHIP: $%s was auto-debited from your bank account for your annual fitness club membership." % _format_number(gym_fee), "finance")
		elif PlayerData.get_available_funds() >= gym_fee:
			PlayerData.debit_funds(gym_fee)
			add_life_event("🏋️ GYM MEMBERSHIP: $%s was paid from your available funds for your annual fitness club membership." % _format_number(gym_fee), "finance")
		else:
			PlayerData.has_gym_membership = false
			PlayerData.happiness = maxi(5, PlayerData.happiness - 4)
			add_life_event("⚠️ GYM MEMBERSHIP CANCELLED: You lacked sufficient funds ($%s) in your bank account to renew your gym membership. It has been cancelled." % _format_number(gym_fee), "finance")

	# 7b. Owned Assets Upkeep, Depreciation & Equity Appreciation
	var asset_logs := AssetCatalog.process_yearly_assets(PlayerData)
	for log_msg in asset_logs:
		add_life_event(log_msg, "finance")

	# 7c. Asset Disaster Events (Earthquakes, Wildfires, Lawsuits, Syndicate Thefts)
	_check_asset_disaster_event()

	# 7d. Freelance Annual Project Gigs
	_process_yearly_freelance_projects()

	# 7e. Commercial Business Yearly Financial Simulation
	_process_yearly_business_operations()
	FinanceMarket.advance_year(PlayerData)

	# 7f. Social Media Audience Growth & Monetization
	var social_logs := SocialMediaManager.process_yearly_social_media(PlayerData)
	for s_log in social_logs:
		add_life_event(s_log, "lifestyle")

	# 7g. Pet Lifespan, Care & Aging Simulation
	var pet_logs := PetManager.process_yearly_pets(PlayerData)
	for p_log in pet_logs:
		add_life_event(p_log, "relationship")

	# 8. Education Lifecycle Progression (Kindergarten @ 3, Primary @ 6, Middle @ 11, High @ 14, Grad @ 18)
	if PlayerData.age == 3:
		PlayerData.education_level = "Kindergarten"
		PlayerData.grades = 80
		add_life_event("🧸 You enrolled in Kindergarten! Learning letters, colors, and finger painting.", "milestone")
	elif PlayerData.age == 6:
		PlayerData.education_level = "Primary School"
		add_life_event("🎒 You completed Kindergarten and entered Primary School! Learning math, science, and reading.", "milestone")
	elif PlayerData.age == 11:
		PlayerData.education_level = "Middle School"
		add_life_event("🏫 You completed Primary School and advanced to Middle School! Academic subjects and social dynamics intensify.", "milestone")
	elif PlayerData.age == 14 and PlayerData.education_level != "High School Dropout":
		PlayerData.education_level = "High School"
		add_life_event("📘 You entered High School! Your academic marks directly determine future career qualification.", "milestone")
	elif PlayerData.age == 18 and PlayerData.education_level == "High School":
		PlayerData.education_level = "High School Graduate"
		var honors_hs := ""
		if PlayerData.grades >= 90:
			honors_hs = " with High Honors"
		elif PlayerData.grades >= 80:
			honors_hs = " with Honors"
		add_life_event("🎓 You graduated from High School%s with a final academic grade of %d%% (%s)!" % [honors_hs, PlayerData.grades, PlayerData.get_letter_grade()], "milestone")
		PlayerData.add_milestone("Graduated from High School%s (Grade: %d%%)." % [honors_hs, PlayerData.grades], PlayerData.age, "🎓")
	elif PlayerData.education_level == "University Student":
		PlayerData.university_years += 1
		var tuition: int = PlayerData.university_tuition if PlayerData.university_tuition > 0 else 12000
		var uni_title: String = PlayerData.university_name if PlayerData.university_name != "" else "University"
		if PlayerData.has_scholarship:
			add_life_event("Your full-ride scholarship paid for your $%s %s tuition!" % [_format_number(tuition), uni_title], "education")
		else:
			if PlayerData.get_available_funds() >= tuition:
				PlayerData.debit_funds(tuition)
				add_life_event("You paid your $%s %s tuition from your available funds." % [_format_number(tuition), uni_title], "education")
			elif PlayerData.bank_savings >= tuition:
				PlayerData.bank_savings -= tuition
				add_life_event("Your $%s %s tuition was deducted from your bank savings." % [_format_number(tuition), uni_title], "education")
			else:
				PlayerData.loan_balance += tuition
				add_life_event("%s tuition of $%s was funded via a Student Loan (8%% APR)." % [uni_title, _format_number(tuition)], "finance")

		if PlayerData.university_years >= 4:
			PlayerData.education_level = "University Graduate"
			PlayerData.smarts = mini(100, PlayerData.smarts + 12)
			PlayerData.happiness = mini(100, PlayerData.happiness + 15)
			var deg_name: String = PlayerData.university_degree if PlayerData.university_degree != "" else "Bachelor's Degree"
			var maj_name: String = PlayerData.university_major_title if PlayerData.university_major_title != "" else "Specialized Major"
			var gpa: float = clampf((float(PlayerData.grades) / 100.0) * 4.0, 1.0, 4.0)
			var honors := ""
			if gpa >= 3.90:
				honors = "as a summa cum laude"
			elif gpa >= 3.70:
				honors = "as a magna cum laude"
			elif gpa >= 3.50:
				honors = "as a cum laude"

			var completed_degree := {
				"university": uni_title,
				"major": PlayerData.university_major,
				"major_title": maj_name,
				"degree": deg_name,
				"grades": PlayerData.grades,
				"gpa": gpa,
				"honors": honors,
				"year_graduated": PlayerData.age
			}
			PlayerData.degrees.append(completed_degree)
			PlayerData.university_years = 0
			var milestone_text := ""
			if honors != "":
				milestone_text = "You graduated from %s %s with a GPA of %.2f." % [uni_title, honors, gpa]
			else:
				milestone_text = "You graduated from %s with a GPA of %.2f." % [uni_title, gpa]
			add_life_event("🎓 CONGRATULATIONS! %s Degree: %s in %s! Careers in %s are now unlocked." % [milestone_text, deg_name, maj_name, maj_name], "milestone")
			PlayerData.add_milestone(milestone_text, PlayerData.age, "🎓")
		else:
			var m_label: String = " (%s)" % PlayerData.university_major_title if PlayerData.university_major_title != "" else ""
			add_life_event("You finished Year %d of 4 at %s%s (Grades: %d%%)." % [PlayerData.university_years, uni_title, m_label, PlayerData.grades], "education")

	# Grades Degradation & Maintenance System (Forces active educational participation)
	_process_yearly_grades_decay(prev_age)


	# Smarts Degradation & Maintenance System (Forces players to actively use education system)
	_process_yearly_smarts_decay(prev_age)

	# 8. Aging Health Curve & General Sickness
	randomize_stats()

	# 9. Multi-Stage Cancer & Illness Progression
	var cancer: Dictionary = PlayerData.get_illness("cancer")
	if not cancer.is_empty():
		var st: int = int(cancer.get("stage", 1))
		if st == 1:
			PlayerData.health = maxi(0, PlayerData.health - 4)
			cancer["stage"] = 2
			add_life_event("⚠️ MEDICAL ALERT: Your cancer has progressed to Stage 2. Please visit the clinic for chemotherapy treatment.", "health")
		elif st == 2:
			PlayerData.health = maxi(0, PlayerData.health - 8)
			cancer["stage"] = 3
			add_life_event("🚨 CRITICAL ALERT: Your cancer has reached Stage 3. Your immune system is deteriorating rapidly. Seek chemotherapy immediately!", "health")
		else:
			PlayerData.health = maxi(0, PlayerData.health - 15)
			add_life_event("💀 Terminal Stage 3 Cancer continues to severely weaken your body!", "health")

		if PlayerData.health <= 0:
			trigger_death("Untreated Stage 3 Lymphoma Cancer")
			return

	# 7. Random Illness Contraction by Age (Balanced chances)
	if not PlayerData.has_illness("cancer") and PlayerData.age >= 30:
		var cancer_chance: float = 0.004
		if PlayerData.age >= 75:
			cancer_chance = 0.025
		elif PlayerData.age >= 60:
			cancer_chance = 0.015
		elif PlayerData.age >= 45:
			cancer_chance = 0.008

		if randf() < cancer_chance:
			PlayerData.add_illness("cancer", "Lymphoma Cancer", 1)
			add_life_event("⚠️ DIAGNOSIS: You have been diagnosed with Stage 1 Lymphoma Cancer! Consult a medical doctor immediately for chemotherapy.", "health")

	# 8. Random Accidents (Extremely rare freak accidents with survivable damage)
	if randf() < 0.002 and PlayerData.age >= 16:
		if randf() < 0.6:
			var dmg: int = randi_range(12, 20)
			PlayerData.health = maxi(0, PlayerData.health - dmg)
			add_life_event("💥 VEHICLE COLLISION: You were involved in a traffic accident! Fortunately you survived with bruises.", "health")
			if PlayerData.health <= 0:
				trigger_death("Fatal Highway Car Collision")
				return
		else:
			var dmg: int = randi_range(10, 18)
			PlayerData.health = maxi(0, PlayerData.health - dmg)
			add_life_event("⚡ ACCIDENT: You suffered minor injuries in a sudden mishap.", "health")
			if PlayerData.health <= 0:
				trigger_death("Fatal Structural Collapse Accident")
				return

	# 9. Natural Old Age Mortality (Age 85+)
	if PlayerData.age >= 85:
		var nat_chance: float = float(PlayerData.age - 84) * 0.035
		if randf() < nat_chance:
			PlayerData.health = 0
			trigger_death("Old Age & Natural Cardiac Arrest")
			return

	# 10. Check if player health reached 0%
	if PlayerData.health <= 0:
		var fallback_cause: String = "Untreated Stage 3 Lymphoma Cancer" if PlayerData.has_illness("cancer") else ("Severe Physical Exhaustion & Debt-Induced Stress" if PlayerData.debt > 15000 else "Critical Medical Failure & Acute Complications")
		trigger_death(fallback_cause)
		return

	# 11. Relationships Aging, Neglect & Consequences
	_process_relationships_aging()
	if not PlayerData.pregnancy.is_empty():
		var baby_female := randf() < 0.5
		var baby_name := NameCatalog.random_name(PlayerData.birthplace if not PlayerData.birthplace.is_empty() else "United States", baby_female).split(" ")[0]
		var birth := RelationshipExtras.deliver_due_baby(PlayerData, baby_name, "FEMALE" if baby_female else "MALE")
		if not birth.is_empty():
			add_life_event(birth, "family")

	trigger_event()
	update_ui()
	SaveManager.save_game()


func _is_intellectual_career(j_id: String, j_title: String) -> bool:
	if j_id == "" and j_title == "":
		return false
	var j_low := (j_id + " " + j_title).to_lower()
	var intellectual_keywords := [
		"doctor", "surgeon", "physician", "engineer", "scientist", "programmer",
		"developer", "analyst", "lawyer", "attorney", "judge", "teacher",
		"professor", "accountant", "architect", "pharmacist", "pilot", "executive"
	]
	for kw in intellectual_keywords:
		if kw in j_low:
			return true
	return false


func _process_yearly_smarts_decay(prev_age: int) -> void:
	if PlayerData.is_dead:
		return

	# Cosmic buff immunity: Super Smarts locked at 100+
	if PlayerData.has_buff("super_smarts"):
		return

	# Early infancy and toddler development (Ages 0-2): no degradation
	if prev_age < 3:
		return

	var studied_last_year: bool = (PlayerData.last_school_activity_age == prev_age)
	var is_student: bool = PlayerData.education_level in ["Kindergarten", "Primary School", "Middle School", "High School", "University Student"]
	var is_intellectual: bool = _is_intellectual_career(PlayerData.job_id, PlayerData.job_title)

	if is_student:
		if studied_last_year:
			# Maintained via active study in the education system! No decay.
			return
		elif PlayerData.grades >= 80:
			# High academic marks shield student from atrophy
			return
		elif PlayerData.grades >= 60:
			# Mediocre performance with zero study outside class: mild cognitive atrophy
			var decay := randi_range(1, 2)
			PlayerData.smarts = maxi(10, PlayerData.smarts - decay)
			add_life_event("📉 Mental Slump: You did not study outside class at age %d. Your academic sharpness slipped." % prev_age, "education")
		else:
			# Low grades (< 60) and zero study: significant academic deterioration
			var decay := randi_range(2, 4)
			PlayerData.smarts = maxi(5, PlayerData.smarts - decay)
			add_life_event("📉 Academic Neglect: Neglecting your studies and falling behind in school at age %d caused your cognitive sharpness to deteriorate." % prev_age, "education")
	else:
		# Adult / Non-student
		if studied_last_year or is_intellectual:
			# Maintained via library reading, online skill seminar, or intellectually demanding career!
			return
		else:
			# Cognitive atrophy from lack of mental stimulation
			var decay := randi_range(1, 3)
			PlayerData.smarts = maxi(5, PlayerData.smarts - decay)
			add_life_event("📉 Cognitive Decline: Without regular reading, study, or mental challenges at age %d, your cognitive sharpness dulled." % prev_age, "education")


func _process_yearly_grades_decay(prev_age: int) -> void:
	if PlayerData.is_dead:
		return

	# Early infancy and toddler development (Ages 0-2): no grades degradation before schooling begins
	if prev_age < 3:
		return

	var studied_last_year: bool = (PlayerData.last_school_activity_age == prev_age)
	var is_student: bool = PlayerData.education_level in ["Kindergarten", "Primary School", "Middle School", "High School", "University Student"]
	var is_intellectual: bool = _is_intellectual_career(PlayerData.job_id, PlayerData.job_title)

	if is_student:
		if studied_last_year:
			# Maintained or gently boosted based on smarts
			var smarts_bonus: int = int((float(PlayerData.smarts) - 50.0) / 12.0)
			var drift: int = smarts_bonus + randi_range(0, 2)
			PlayerData.grades = clamp(PlayerData.grades + drift, 0, 100)
		else:
			# Neglected schooling: grades degrade noticeably each unmaintained year (8-12 points)
			var drop: int = randi_range(8, 12)
			if PlayerData.smarts >= 80:
				drop = maxi(5, drop - 3)
			PlayerData.grades = maxi(0, PlayerData.grades - drop)
			if PlayerData.grades == 0:
				add_life_event("🚨 ACADEMIC RECORD EXPIRED (0%%): You completely neglected your studies at age %d and your grades dropped to 0%%! You must complete an Academic Refresher Course." % prev_age, "education")
			elif PlayerData.grades < 55:
				add_life_event("📉 Academic Warning: Without active study at age %d, your marks fell by %d%% to %d%% (%s)!" % [prev_age, drop, PlayerData.grades, PlayerData.get_letter_grade()], "education")
			else:
				add_life_event("Academic Neglect: You skipped academic tasks at age %d. Grades dropped by %d%% to %d%% (%s)." % [prev_age, drop, PlayerData.grades, PlayerData.get_letter_grade()], "education")
	else:
		# Non-students / graduates / adults
		if studied_last_year:
			# Maintained via reading, seminars, minigames, or courses
			pass
		elif is_intellectual:
			# Intellectual careers (doctors, engineers, scientists) slow academic decay
			var drop: int = randi_range(1, 3)
			PlayerData.grades = maxi(0, PlayerData.grades - drop)
			if PlayerData.grades == 0:
				add_life_event("⚠️ ACADEMIC RECORD EXPIRED: Your academic qualification has decayed to 0% due to disuse. You must take an Academic Refresher Course to certify credentials.", "education")
		else:
			# Adult without study or mental challenges: grades decay overtime (5-8 points)
			var drop: int = randi_range(5, 8)
			PlayerData.grades = maxi(0, PlayerData.grades - drop)
			if PlayerData.grades == 0:
				add_life_event("⚠️ ACADEMIC RECORD EXPIRED: Your academic qualification has decayed to 0% due to years of disuse! New job applications and university enrollments now require you to take an Academic Refresher Course.", "education")



func randomize_stats() -> void:
	# Aging health curve: Young = stable/positive, Older = progressive deterioration
	var health_flux: int = 0
	if PlayerData.age < 30:
		health_flux = randi_range(-1, 2)
	elif PlayerData.age < 50:
		health_flux = randi_range(-2, 1)
	elif PlayerData.age < 65:
		health_flux = randi_range(-3, 0)
	elif PlayerData.age < 80:
		health_flux = randi_range(-5, -1)
	else:
		health_flux = randi_range(-7, -2)

	# Smarts is excluded from random passive increases: must be earned and maintained via active gameplay
	var random_effects := {
		"health": health_flux,
		"happiness": randi_range(-3, 3),
		"looks": randi_range(-1, 1) if PlayerData.age < 50 else randi_range(-3, -1)
	}

	PlayerData.apply_effects(random_effects)


func _process_parents_aging() -> void:
	# Mother
	if PlayerData.mother_alive:
		var mom_age: int = PlayerData.mother_base_age + PlayerData.age
		if mom_age >= 60:
			var decay: int = randi_range(3, 7) + int((mom_age - 60) / 4.0)
			PlayerData.mother_health = maxi(0, PlayerData.mother_health - decay)

		var mom_dead: bool = PlayerData.mother_health <= 0 or (mom_age >= 75 and randf() < (float(mom_age - 70) * 0.038))
		if mom_dead:
			PlayerData.mother_alive = false
			PlayerData.mother_health = 0
			PlayerData.happiness = maxi(5, PlayerData.happiness - 40) # Significantly drops, but not ZERO
			add_life_event("💔 TRAGEDY: Your mother, %s, has passed away at the age of %d. You are heartbroken and grieving." % [PlayerData.mother_name, mom_age], "relationship")

	# Father
	if PlayerData.father_alive and PlayerData.father_name != "" and PlayerData.father_name != "Unknown":
		var dad_age: int = PlayerData.father_base_age + PlayerData.age
		if dad_age >= 60:
			var decay: int = randi_range(3, 7) + int((dad_age - 60) / 4.0)
			PlayerData.father_health = maxi(0, PlayerData.father_health - decay)

		var dad_dead: bool = PlayerData.father_health <= 0 or (dad_age >= 75 and randf() < (float(dad_age - 70) * 0.038))
		if dad_dead:
			PlayerData.father_alive = false
			PlayerData.father_health = 0
			PlayerData.happiness = maxi(5, PlayerData.happiness - 40) # Significantly drops, but not ZERO
			add_life_event("💔 TRAGEDY: Your father, %s, has passed away at the age of %d. You are heartbroken and grieving." % [PlayerData.father_name, dad_age], "relationship")


func trigger_death(cause: String) -> void:
	PlayerData.health = 0
	PlayerData.is_dead = true
	PlayerData.cause_of_death = cause
	add_life_event("💀 You passed away at age %d. Cause of death: %s." % [PlayerData.age, cause], "death")
	update_ui()
	SaveManager.save_game()
	_show_death_screen(cause)


var _life_feed_empty: bool = true


func add_life_event(text: String, kind: String = "event") -> void:
	var clean_text := PlayerData.sanitize_stat_spoilers(text).strip_edges()
	if clean_text == "":
		return

	if _life_feed_empty:
		life_feed.append_text(_format_life_entry(PlayerData.age, clean_text))
		_life_feed_empty = false
	else:
		life_feed.append_text("\n\n" + _format_life_entry(PlayerData.age, clean_text))

	PlayerData.add_life_log_entry(clean_text, kind)
	_scroll_timeline_to_latest.call_deferred()


func rebuild_life_feed() -> void:
	life_feed.clear()
	_life_feed_empty = true

	for entry in PlayerData.life_log:
		var text_value: String = str(entry.get("text", ""))
		if text_value == "":
			continue

		var formatted_entry := _format_life_entry(int(entry.get("age", 0)), text_value)
		if _life_feed_empty:
			life_feed.append_text(formatted_entry)
			_life_feed_empty = false
		else:
			life_feed.append_text("\n\n" + formatted_entry)

	_scroll_timeline_to_latest.call_deferred()


func _format_life_entry(entry_age: int, text: String) -> String:
	var heading := GameLocale.translate("Age: %d year" if entry_age == 1 else "Age: %d years") % entry_age
	var is_light: bool = LifeLibrary.data.theme == "light"
	var age_color: String = "#0284c7" if is_light else "#38bdf8"
	var body_color: String = "#0f172a" if is_light else "#e2e8f0"
	return "[color=%s][b]%s[/b][/color]\n[color=%s]%s[/color]" % [age_color, heading, body_color, GameLocale.display(text)]


func _scroll_timeline_to_latest() -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	var bar := life_feed.get_v_scroll_bar()
	bar.value = maxf(bar.min_value, bar.max_value - bar.page)


func _scroll_after_layout() -> void:
	_scroll_timeline_to_latest.call_deferred()


func update_ui() -> void:
	PlayerData.enforce_buffs_and_debuffs()
	_update_portrait()
	if isometric_room != null and isometric_room.has_method("set_room") and PlayerData.selected_room_id != "":
		if isometric_room.current_room_id != PlayerData.selected_room_id:
			isometric_room.set_room(PlayerData.selected_room_id)
		if isometric_room.has_method("update_character"):
			isometric_room.update_character()
	name_label.text = PlayerData.first_name
	phase_label.text = "%s %s" % [PlayerData.get_stage_icon(), PlayerData.get_stage_name()]
	var bank_title := "BANK BALANCE" if _format_number(PlayerData.bank_savings).length() <= 7 else "BANK"
	balance_label.text = "💵 $%s CASH\n🏦 $%s %s" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		bank_title
	]
	balance_label.tooltip_text = "Cash (Wallet): $%s\nBank Balance (Savings): $%s\nClick to view Bank & Savings" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings)
	]

	if nationality_flag != null and PlayerData.birthplace != "":
		nationality_flag.texture = CreationOptions.get_flag_for_country(PlayerData.birthplace)

	health_bar.value = PlayerData.health
	happiness_bar.value = PlayerData.happiness
	smarts_bar.value = PlayerData.smarts
	looks_bar.value = PlayerData.looks

	_update_stat_bar_color(health_bar, PlayerData.health, Color("#10b981"), Color("#047857"))
	_update_stat_bar_color(happiness_bar, PlayerData.happiness, Color("#f59e0b"), Color("#b45309"))
	_update_stat_bar_color(smarts_bar, PlayerData.smarts, Color("#0284c7"), Color("#1e3a8a"))
	_update_stat_bar_color(looks_bar, PlayerData.looks, Color("#db2777"), Color("#7e22ce"))

	# Update InfantButton icon with age progression (Strictly stage name, never occupation)
	if infant_button != null:
		infant_button.icon = preload("res://scripts/ui/modern_navigation.gd").icon("life")
		infant_button.text = PlayerData.get_stage_name()

	# Assets Button Dimming & Tooltip Gating for Infants / Toddlers
	if assets_button != null:
		if PlayerData.age < 5:
			assets_button.tooltip_text = "🔒 Assets unlock at age 5 (Childhood)"
			assets_button.modulate = Color(0.65, 0.65, 0.65, 0.8)
		else:
			assets_button.tooltip_text = "Assets & Net Worth"
			assets_button.modulate = Color.WHITE

	# If panels are open, refresh them
	if relationships_panel.visible:
		update_relationships_panel()
	if character_panel.visible:
		update_character_panel()


func _on_age_button_pressed() -> void:
	_trigger_haptic(45)
	age_up()


func _trigger_haptic(duration_ms: int = 40) -> void:
	if not bool(LifeLibrary.data.get("haptics_enabled", true)):
		return
	# 1. Native mobile device vibration (Android / iOS native app)
	if DisplayServer.is_touchscreen_available() or OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		Input.vibrate_handheld(duration_ms)
	# 2. Web browser haptics (iOS Safari / Android Chrome / Samsung Internet)
	if OS.has_feature("web") and OS.has_feature("JavaScript"):
		JavaScriptBridge.eval("""
			try {
				if (navigator.vibrate) {
					navigator.vibrate(%d);
				}
			} catch (e) {}
		""" % duration_ms)


func _adjust_safe_area() -> void:
	var top_m: float = 0.0
	var bottom_m: float = 0.0

	var screen_h: int = DisplayServer.screen_get_size().y
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	if screen_h > 0 and safe.size.y > 0 and safe.size.y < screen_h:
		var scale: float = 1920.0 / float(screen_h)
		top_m = float(safe.position.y) * scale
		bottom_m = float(screen_h - (safe.position.y + safe.size.y)) * scale

	# Extra padding on mobile web to clear dynamic browser address/tab bars
	if OS.has_feature("web") and MobileKeyboardManager.is_mobile():
		bottom_m = maxf(bottom_m, 32.0)
		top_m = maxf(top_m, 16.0)

	if is_instance_valid(safe_area):
		safe_area.offset_top = top_m
		safe_area.offset_bottom = 0.0
	if is_instance_valid(action_bar):
		action_bar.offset_bottom = 0.0
	if is_instance_valid(age_button):
		age_button.offset_bottom = 0.0

	if is_instance_valid(top_bar):
		top_bar.offset_top = top_m
		top_bar.offset_bottom = 112.0 + top_m

	if is_instance_valid(profile_strip):
		profile_strip.offset_top = 112.0 + top_m
		profile_strip.offset_bottom = 260.0 + top_m


func trigger_event() -> void:
	if PlayerData.is_dead:
		return
	if PlayerData.age >= 18 and not PlayerData.is_in_prison and not LifeLibrary.data.people.is_empty() and randf() < 0.25:
		var person: Dictionary = LifeLibrary.data.people.pick_random()
		add_life_event("You met %s from %s and enjoyed a friendly conversation." % [person.name, person.country], "event")
		PlayerData.happiness = mini(100, PlayerData.happiness + 2)

	# Chance-based event popups: Events don't always pop up every year to avoid feeling spammy.
	# Some years are peaceful, uneventful, and let the player focus on gameplay choices.
	if randf() > annual_event_popup_chance:
		current_event = null
		current_event_choices.clear()
		age_button.disabled = false
		return

	var carrier := RelationshipExtras.pregnancy_carrier(PlayerData)
	if not carrier.is_empty() and randf() < 0.08:
		current_event = {"id": "unplanned_pregnancy", "title": "UNEXPECTED PREGNANCY", "unplanned_pregnancy": true,
			"text": "%s unexpectedly pregnant. You had not planned to start a family before marriage, and the news brings anxiety and tension with your parents." % ("You are" if carrier == "player" else PlayerData.get_partner_name() + " is")}
		current_event_choices = [{"text": "Take time to process the news", "description": "Take time to process this momentous life news."}]
		show_event_popup()
		return
	if not PlayerData.is_dead and not PlayerData.is_in_prison and PlayerData.age >= 18 and not PlayerData.has_partner() and randf() < 0.25:
		var candidate := _generate_dating_candidate()
		var venues: Array[String] = ["a coffee date", "a picnic in the park", "a night at the arcade", "a walk through the night market"]
		current_event = {"id": "date_invitation", "title": "A DATE INVITATION", "candidate": candidate,
			"text": "%s asked you out for %s. Do you want to go on a date with %s?" % [candidate.name, venues.pick_random(), candidate.name]}
		current_event_choices = [
			{"text": "Yes, let's go!", "accept_date": true, "description": "Spend an evening getting to know them."},
			{"text": "Politely decline", "accept_date": false, "description": "Politely decline the date invitation."}]
		show_event_popup()
		return

	# High-stakes violent confrontation events specifically for players who own firearms
	if not PlayerData.is_dead and not PlayerData.is_in_prison and PlayerData.has_firearm() and randf() < 0.25:
		var firearm_ev = EventManager.get_firearm_defense_event(PlayerData.age, PlayerData.event_history, PlayerData.get_stats())
		if firearm_ev != null:
			current_event = firearm_ev
			current_event_choices = generate_event_choices(current_event)
			show_event_popup()
			return

	current_event = EventManager.get_random_event(
		PlayerData.age,
		PlayerData.event_history,
		PlayerData.get_stats()
	)

	if current_event == null:
		current_event_choices.clear()
		age_button.disabled = false
		return

	current_event_choices = generate_event_choices(current_event)
	show_event_popup()


func get_event_text(event: Dictionary) -> String:
	var variants: Array = event.get("text_variants", [])

	if not variants.is_empty():
		return str(variants.pick_random())

	return str(event.get("text", event.get("description", "Something happened.")))


func generate_event_choices(event: Dictionary) -> Array:
	var all_choices: Array = event.get("choices", []).duplicate()
	all_choices.shuffle()

	var requested_count: int = int(event.get("choice_count", 3))
	var choice_count: int = min(requested_count, all_choices.size())

	return all_choices.slice(0, choice_count)


func _sanitize_karma_text(text: String) -> String:
	var regex := RegEx.new()
	regex.compile("(?i)(,\\s*)?[+-]?\\d+\\s*Karma(\\s*,)?|(?i)\\bKarma\\s*[+-]?\\d+\\b")
	var cleaned := regex.sub(text, "", true).strip_edges()
	regex.compile(",\\s*,")
	cleaned = regex.sub(cleaned, ", ", true)
	cleaned = cleaned.trim_prefix(",").trim_suffix(",").strip_edges()
	if cleaned == "":
		return "No major stat changes"
	return cleaned


func _format_effects_summary(choice: Dictionary) -> String:
	var effects: Dictionary = BalanceRules.event_effects(choice.get("effects", {}), PlayerData.age)
	if effects == choice.get("effects", {}) and choice.has("description") and str(choice["description"]).strip_edges() != "":
		return _sanitize_karma_text(str(choice["description"]).strip_edges())

	var parts: Array[String] = []
	if effects.has("happiness") and effects["happiness"] != 0:
		var v: int = int(effects["happiness"])
		parts.append(("%+d Happiness" if v > 0 else "%d Happiness") % v)
	if effects.has("health") and effects["health"] != 0:
		var v: int = int(effects["health"])
		parts.append(("%+d Health" if v > 0 else "%d Health") % v)
	if effects.has("smarts") and effects["smarts"] != 0:
		var v: int = int(effects["smarts"])
		parts.append(("%+d Smarts" if v > 0 else "%d Smarts") % v)
	if effects.has("looks") and effects["looks"] != 0:
		var v: int = int(effects["looks"])
		parts.append(("%+d Looks" if v > 0 else "%d Looks") % v)
	if effects.has("money") and effects["money"] != 0:
		var v: int = int(effects["money"])
		parts.append(("+$%d Cash" if v > 0 else "-$%d Cash") % absi(v))

	if parts.is_empty():
		return "No major stat changes"
	return ", ".join(parts)


func show_event_popup() -> void:
	if event_overlay == null or event_description == null:
		push_error("Event popup nodes are missing.")
		current_event = null
		current_event_choices.clear()
		age_button.disabled = false
		return

	var is_light: bool = LifeLibrary.data.theme == "light"
	if event_title != null:
		event_title.text = str(current_event.get("title", "LIFE EVENT"))
		event_title.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#00f0ff"))
		event_title.add_theme_font_size_override("font_size", 42)

	event_description.text = get_event_text(current_event) + "\n\nWhat do you do?"
	event_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_description.add_theme_font_size_override("normal_font_size", 30)
	event_description.add_theme_color_override("default_color", Color("#0f172a") if is_light else Color("#f8fafc"))
	var desc_inset := StyleBoxEmpty.new()
	desc_inset.content_margin_left = 32
	desc_inset.content_margin_right = 32
	desc_inset.content_margin_top = 20
	desc_inset.content_margin_bottom = 20
	event_description.add_theme_stylebox_override("normal", desc_inset)

	event_overlay.visible = true
	age_button.disabled = true

	var buttons: Array[Button] = []
	for button in [event_choice_1, event_choice_2, event_choice_3, event_choice_4]:
		if button != null:
			buttons.append(button)
			button.visible = false
			for font_key in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]:
				button.add_theme_color_override(font_key, Color.TRANSPARENT)
			button.add_theme_font_size_override("font_size", 1)

	var used_choice_icons: Array[String] = []
	var choice_colors := [Color("#0284c7"), Color("#10b981"), Color("#f59e0b"), Color("#8b5cf6")]
	for i in range(min(current_event_choices.size(), buttons.size())):
		var choice: Dictionary = current_event_choices[i]
		var btn: Button = buttons[i]
		var col: Color = choice_colors[i % choice_colors.size()]
		var choice_icon: String = preload("res://scripts/ui/action_icons.gd").for_choice(choice, used_choice_icons)
		used_choice_icons.append(choice_icon)
		btn.set_meta("action_emoji", choice_icon)
		btn.set_meta("reference_part", true)
		btn.set_meta("event_choice", true)
		btn.text = "%s  %s" % [choice_icon, str(choice.get("text", "Choose"))]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.visible = true

		if not btn.has_node("ReferenceRow"):
			btn.set_meta("reference_row", true)
			var presenter := preload("res://scripts/ui/reference_row.gd").new()
			presenter.name = "ReferenceRow"
			btn.add_child(presenter)
			presenter.setup(btn)

		var n_sb := StyleBoxFlat.new()
		n_sb.bg_color = col.darkened(0.18) if is_light else col.darkened(0.42)
		n_sb.border_color = col.lightened(0.2)
		n_sb.set_border_width_all(2)
		n_sb.set_corner_radius_all(12)
		n_sb.shadow_color = Color(0, 0, 0, 0.28)
		n_sb.shadow_size = 4
		n_sb.shadow_offset = Vector2(0, 3)
		n_sb.content_margin_left = 20
		n_sb.content_margin_right = 20
		n_sb.content_margin_top = 12
		n_sb.content_margin_bottom = 12
		btn.add_theme_stylebox_override("normal", n_sb)

		var h_sb := n_sb.duplicate() as StyleBoxFlat
		h_sb.bg_color = col.lightened(0.08) if is_light else col.darkened(0.2)
		h_sb.border_color = Color.WHITE
		h_sb.shadow_size = 6
		btn.add_theme_stylebox_override("hover", h_sb)

		var p_sb := n_sb.duplicate() as StyleBoxFlat
		p_sb.bg_color = col.darkened(0.4) if is_light else col.darkened(0.6)
		p_sb.shadow_size = 1
		p_sb.shadow_offset = Vector2(0, 1)
		btn.add_theme_stylebox_override("pressed", p_sb)

		for font_key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			btn.add_theme_color_override(font_key, Color.TRANSPARENT)
		btn.add_theme_font_size_override("font_size", 1)

		var ref_row = btn.get_node_or_null("ReferenceRow")
		if ref_row != null and ref_row.has_method("_sync"):
			ref_row._sync()

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(event_overlay)


func hide_event_popup() -> void:
	if event_overlay != null:
		preload("res://scripts/ui/panel_close.gd").dismiss(event_overlay, false, Callable(), event_overlay.get_node_or_null("EventPanel"))


func choose_event_option(choice_index: int) -> void:
	if current_event == null:
		return

	if choice_index < 0 or choice_index >= current_event_choices.size():
		return

	var choice: Dictionary = current_event_choices[choice_index]
	var event_id: String = str(current_event.get("id", ""))
	var current_ev_title: String = str(current_event.get("title", ""))

	PlayerData.apply_effects(BalanceRules.event_effects(choice.get("effects", {}), PlayerData.age))

	var result_text: String = str(choice.get("result", ""))
	if current_event.has("unplanned_pregnancy"):
		result_text = RelationshipExtras.begin_unplanned_pregnancy(PlayerData)
	if current_event.has("candidate"):
		result_text = RomanceRules.date_result(PlayerData, current_event.candidate, bool(choice.get("accept_date", false)), randf())
	if result_text != "":
		add_life_event(result_text, "family" if current_event.has("unplanned_pregnancy") else ("relationship" if current_event.has("candidate") else "event"))

	PlayerData.record_event(event_id)

	current_event = null
	current_event_choices.clear()
	hide_event_popup()
	age_button.disabled = false
	update_ui()
	SaveManager.save_game()

	# Unpredictable fatality / accident death check
	if PlayerData.health <= 0:
		var death_cause: String = _get_death_cause_from_event(event_id, current_ev_title, choice)
		trigger_death(death_cause)
		return


func _get_death_cause_from_event(ev_id: String, ev_title: String, _choice: Dictionary) -> String:
	match ev_id:
		"freak_car_crash":
			return "Fatal High-Speed Highway Collision"
		"joyriding_car":
			return "Fatal Joyriding Automobile Accident"
		"sudden_appendicitis":
			return "Ruptured Appendix & Septic Peritonitis"
		"heart_attack_warning":
			return "Acute Myocardial Infarction (Heart Attack)"
		"slip_and_fall":
			return "Fatal Traumatic Brain Injury from Fall"
		"dangerous_street_dare":
			return "Fatal Fall & Traumatic Physical Injuries"
		"office_whistleblower":
			return "Stress-Induced Acute Cardiac Arrest"
		"childhood_bicycle":
			return "Fatal Bicycle Collision & Head Trauma"
		"street_dog_encounter":
			return "Fatal Infection & Animal Attack Injuries"
		"highschool_fight":
			return "Fatal Physical Trauma from Altercation"
		"stray_kitten_rescue":
			return "Fatal Fall from Tree"
		"event_armed_robbery_gunpoint":
			return "Fatal Gunshot Wound During Alleyway Armed Robbery"
		"event_home_invasion_armed":
			return "Fatal Trauma from Hostile Armed Home Invasion"
		"event_intersection_carjacking":
			return "Fatal Trauma in Violent Highway Carjacking"
		"event_stalker_blade_ambush":
			return "Fatal Hemorrhage from Psychopathic Stalker Knife Ambush"
		"event_active_shooter_defense":
			return "Killed in the Line of Action Confronting Active Mass Shooter"

	if PlayerData.has_illness("cancer"):
		return "Untreated Stage 3 Lymphoma Cancer"

	if ev_title != "":
		var clean_title := ev_title.to_lower().capitalize()
		return "Fatal Incident during %s" % clean_title

	return "Critical Health Depletion & Physical Trauma"


func _on_event_choice_1_pressed() -> void:
	choose_event_option(0)


func _on_event_choice_2_pressed() -> void:
	choose_event_option(1)


func _on_event_choice_3_pressed() -> void:
	choose_event_option(2)


func _on_event_choice_4_pressed() -> void:
	choose_event_option(3)


func _on_settings_button_pressed() -> void:
	show_tab("settings")


func _on_room_cycle_button_pressed() -> void:
	var rooms := RoomManager.get_all_room_ids()
	var current_idx := rooms.find(PlayerData.selected_room_id)
	if current_idx == -1:
		current_idx = 0
	var next_idx := (current_idx + 1) % rooms.size()
	var next_room := rooms[next_idx]
	PlayerData.selected_room_id = next_room
	if isometric_room != null and isometric_room.has_method("set_room"):
		isometric_room.set_room(next_room)
	SaveManager.save_game_debounced()


func _on_timeline_pull_up_button_pressed() -> void:
	_toggle_timeline_drawer()


func _on_close_timeline_button_pressed() -> void:
	_close_timeline_drawer()


func _toggle_timeline_drawer() -> void:
	if _is_timeline_open:
		_close_timeline_drawer()
	else:
		_open_timeline_drawer()


func _open_timeline_drawer() -> void:
	if timeline_drawer == null:
		return
	_is_timeline_open = true
	if timeline_pull_up_btn != null:
		timeline_pull_up_btn.icon = preload("res://assets/ui/timeline_pulldown_icon.png")
		timeline_pull_up_btn.tooltip_text = "Hide Timeline"
	
	timeline_drawer.visible = true
	timeline_drawer.set_meta("is_animating", true)
	if _timeline_drawer_tween != null and _timeline_drawer_tween.is_valid():
		_timeline_drawer_tween.kill()
		
	var base_top: float = 264.0
	var base_bottom: float = (timeline_pull_up_btn.offset_top - 8.0) if timeline_pull_up_btn != null else -530.0
	timeline_drawer.modulate.a = 0.0
	timeline_drawer.offset_top = base_top + 140.0
	timeline_drawer.offset_bottom = base_bottom + 140.0
	
	_timeline_drawer_tween = create_tween().set_parallel(true)
	_timeline_drawer_tween.tween_property(timeline_drawer, "offset_top", base_top, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_timeline_drawer_tween.tween_property(timeline_drawer, "offset_bottom", base_bottom, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_timeline_drawer_tween.tween_property(timeline_drawer, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_timeline_drawer_tween.chain().tween_callback(func():
		if is_instance_valid(timeline_drawer):
			timeline_drawer.remove_meta("is_animating")
	)
	
	_scroll_timeline_to_latest.call_deferred()


func _close_timeline_drawer() -> void:
	_is_timeline_open = false
	if timeline_pull_up_btn != null:
		timeline_pull_up_btn.icon = preload("res://assets/ui/timeline_pullup_icon.png")
		timeline_pull_up_btn.tooltip_text = "Show Timeline"
	if timeline_drawer == null:
		return
	timeline_drawer.set_meta("is_animating", true)
	if _timeline_drawer_tween != null and _timeline_drawer_tween.is_valid():
		_timeline_drawer_tween.kill()
		
	var base_top: float = 264.0
	var base_bottom: float = (timeline_pull_up_btn.offset_top - 8.0) if timeline_pull_up_btn != null else -530.0
	_timeline_drawer_tween = create_tween().set_parallel(true)
	_timeline_drawer_tween.tween_property(timeline_drawer, "offset_top", base_top + 120.0, 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_timeline_drawer_tween.tween_property(timeline_drawer, "offset_bottom", base_bottom + 120.0, 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_timeline_drawer_tween.tween_property(timeline_drawer, "modulate:a", 0.0, 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_timeline_drawer_tween.chain().tween_callback(func():
		if is_instance_valid(timeline_drawer) and not _is_timeline_open:
			timeline_drawer.visible = false
			timeline_drawer.offset_top = base_top
			timeline_drawer.offset_bottom = base_bottom
			timeline_drawer.remove_meta("is_animating")
	)



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _is_timeline_open:
		_close_timeline_drawer()
		get_viewport().set_input_as_handled()



func _on_close_settings_button_pressed() -> void:
	panel_pull_up.cancel()
	preload("res://scripts/ui/panel_close.gd").dismiss(settings_overlay, false, func(): show_tab("timeline"), settings_overlay.get_node("SettingsCard"))


func _on_reset_progress_button_pressed() -> void:
	if reset_confirmation_overlay != null:
		reset_confirmation_overlay.visible = true


func _on_cancel_reset_pressed() -> void:
	if reset_confirmation_overlay != null:
		reset_confirmation_overlay.visible = false


func _on_confirm_reset_pressed() -> void:
	if reset_confirmation_overlay != null:
		reset_confirmation_overlay.visible = false
	if settings_overlay != null:
		settings_overlay.visible = false

	SaveManager.delete_save()
	PlayerData.reset_player()

	current_event = null
	current_event_choices.clear()
	hide_event_popup()

	life_feed.clear()
	update_history_panel()
	update_character_panel()
	show_tab("timeline")
	show_new_game_screen()


func show_new_game_screen() -> void:
	if action_bar != null:
		action_bar.visible = false
	if age_button != null:
		age_button.visible = false
	if name_input != null:
		name_input.text = ""

	if birthplace_input != null:
		birthplace_input.select(8)

	if validation_label != null:
		validation_label.text = ""

	_update_creation_theme()
	new_game_panel.visible = true


func hide_new_game_screen() -> void:
	new_game_panel.visible = false
	if action_bar != null:
		action_bar.visible = true
	if age_button != null:
		age_button.visible = true


func _on_start_game_button_pressed() -> void:
	if name_input == null:
		push_error("NameInput could not be found.")
		return

	if birthplace_input == null:
		push_error("BirthplaceInput could not be found.")
		return

	if validation_label == null:
		push_error("ValidationLabel could not be found.")
		return

	var entered_name: String = CreationOptions.normalize_name(name_input.text)
	var selected_country: String = birthplace_input.get_item_text(birthplace_input.selected)

	if entered_name == "":
		validation_label.text = "Please enter your name."
		return

	validation_label.text = ""

	PlayerData.reset_player()

	PlayerData.first_name = entered_name
	LifeLibrary.data.active_slot = ""
	LifeLibrary.persist()
	PlayerData.birthplace = selected_country
	FinanceMarket.ensure(PlayerData)
	PlayerData.gender = "MALE" if gender_input.selected == 0 else "FEMALE"
	PlayerData.ethnicity = creation_selected_ethnicity
	PlayerData.portrait_track = creation_selected_track
	PlayerData.portrait_variant = creation_selected_track
	PlayerData.has_started_game = true

	# Generate rich, unique BitLife-style birth description & family background
	var profile: Dictionary = BirthStoryGenerator.generate_profile(
		entered_name,
		selected_country,
		PlayerData.gender
	)
	PlayerData.birth_story = str(profile.get("story", ""))
	PlayerData.birth_month = str(profile.get("birth_month", "January"))
	PlayerData.birth_day = int(profile.get("birth_day", 1))
	PlayerData.zodiac = str(profile.get("zodiac", "Capricorn"))
	PlayerData.mother_name = str(profile.get("mother_name", ""))
	PlayerData.mother_job = str(profile.get("mother_job", ""))
	PlayerData.mother_base_age = int(profile.get("mother_age", 35))
	PlayerData.mother_education = str(profile.get("mother_education", "High School"))
	PlayerData.mother_condition = str(profile.get("mother_condition", ""))
	PlayerData.mother_health = int(profile.get("mother_health", 80))
	PlayerData.mother_portrait_track = int(profile.get("mother_portrait_track", randi() % 4))
	PlayerData.father_name = str(profile.get("father_name", ""))
	PlayerData.father_job = str(profile.get("father_job", ""))
	PlayerData.father_base_age = int(profile.get("father_age", 37))
	PlayerData.father_education = str(profile.get("father_education", "High School"))
	PlayerData.father_condition = str(profile.get("father_condition", ""))
	PlayerData.father_health = int(profile.get("father_health", 80))
	PlayerData.father_portrait_track = int(profile.get("father_portrait_track", randi() % 4))
	PlayerData.family_wealth = str(profile.get("family_wealth", "middle_class"))
	PlayerData.add_milestone("Born in %s." % PlayerData.birthplace, 0, "🍼")

	hide_new_game_screen()
	show_tab("timeline")
	if action_bar != null:
		action_bar.visible = true
	if age_button != null:
		age_button.visible = true

	life_feed.clear()

	# Add newborn character description to feed
	add_life_event(PlayerData.birth_story, "milestone")

	update_ui()
	update_history_panel()
	update_character_panel()
	update_relationships_panel()
	update_assets_panel()
	update_bank_panel()
	update_infant_panel()
	_configure_button_contrasts()
	if has_node("ThemeController"):
		var tc = get_node("ThemeController")
		for p in [assets_panel, bank_panel, relationships_panel, character_panel, infant_panel, activities_panel]:
			tc.apply_subtree(p)

	SaveManager.save_game()


func show_tab(tab_name: String) -> void:
	if tab_name == "assets" and PlayerData.age < 5:
		if PlayerData.age == 0:
			add_life_event("🍼 Restricted: You are an infant! Infants do not possess financial assets or bank accounts yet. Advance age (+1 Year) to grow up.", "finance")
		else:
			add_life_event("🧸 Restricted: You are %d years old. Financial assets and wealth management unlock at age 5 (Childhood)—advance age to grow up!" % PlayerData.age, "finance")
		return

	var touch_controller = get_node_or_null("TouchScrollController")
	if touch_controller != null and touch_controller.has_method("reset_state"):
		touch_controller.reset_state()

	panel_pull_up.cancel()
	# Keep the main screen underneath the entering panel to avoid an empty flash.
	var animated_tabs := ["infant", "assets", "relationships", "activities", "settings", "character", "bank"]
	timeline_panel.visible = tab_name == "timeline" or tab_name in animated_tabs
	character_panel.visible = tab_name == "character"
	infant_panel.visible = tab_name == "infant"
	assets_panel.visible = tab_name == "assets"
	bank_panel.visible = tab_name == "bank"
	relationships_panel.visible = tab_name == "relationships"
	activities_panel.visible = tab_name == "activities"

	var is_home: bool = (tab_name == "timeline")
	if action_bar != null:
		action_bar.visible = is_home
	if age_button != null:
		age_button.visible = is_home
	if timeline_pull_up_btn != null:
		timeline_pull_up_btn.visible = is_home
	if not is_home and _is_timeline_open:
		_close_timeline_drawer()


	if tab_name == "settings":
		if settings_overlay != null:
			settings_overlay.visible = true
			panel_pull_up.play(settings_overlay.get_node("SettingsCard"))
			if has_node("ThemeController"):
				get_node("ThemeController").apply_subtree(settings_overlay)
		return
	elif settings_overlay != null:
		settings_overlay.visible = false

	if tab_name == "character":
		update_character_panel()
	elif tab_name == "infant":
		update_infant_panel()
	elif tab_name == "assets":
		update_assets_panel()
	elif tab_name == "bank":
		update_bank_panel()
	elif tab_name == "relationships":
		update_relationships_panel()
	elif tab_name == "activities":
		_configure_button_contrasts()

	_apply_translucent_scrollbars_recursive(self)
	var opening_panels := {"infant": infant_panel, "assets": assets_panel, "relationships": relationships_panel, "activities": activities_panel, "character": character_panel, "bank": bank_panel}
	if opening_panels.has(tab_name):
		var target_panel: Control = opening_panels[tab_name]
		target_panel.offset_top = 0.0
		target_panel.offset_bottom = 0.0
		target_panel.offset_left = 0.0
		target_panel.offset_right = 0.0
		for sc in target_panel.find_children("*", "ScrollContainer", true, false):
			(sc as ScrollContainer).scroll_vertical = 0
		if has_node("ThemeController"):
			get_node("ThemeController").apply_subtree(target_panel)
		panel_pull_up.play(target_panel)


# Avatar Button clicked -> opens Character profile panel!
func _on_avatar_button_pressed() -> void:
	show_tab("character")


func _on_settings_nav_button_pressed() -> void:
	show_tab("settings")


# 4 Action button signal handlers
func _on_infant_button_pressed() -> void:
	show_tab("infant")


func _on_assets_button_pressed() -> void:
	if PlayerData.age < 5:
		if PlayerData.age == 0:
			add_life_event("🍼 Restricted: You are an infant! Infants do not possess financial assets or bank accounts yet. Advance age (+1 Year) to grow up.", "finance")
		else:
			add_life_event("🧸 Restricted: You are %d years old. Financial assets and wealth management unlock at age 5 (Childhood)—advance age to grow up!" % PlayerData.age, "finance")
		return
	show_tab("assets")


func _on_relationships_button_pressed() -> void:
	show_tab("relationships")


func _on_activities_button_pressed() -> void:
	show_tab("activities")


# Panel Close & Back handlers
func _on_close_panel_button_pressed() -> void:
	panel_pull_up.cancel()
	for panel in [character_panel, infant_panel, assets_panel, bank_panel, relationships_panel, activities_panel]:
		if panel.visible:
			preload("res://scripts/ui/panel_close.gd").dismiss(panel, false, func(): show_tab("timeline"))
			return


func _on_bank_button_pressed() -> void:
	if PlayerData.age < 13:
		add_life_event("🏦 Banking accounts unlock at age 13 for youth accounts.", "finance")
		return
	show_tab("bank")


func _on_back_to_assets_button_pressed() -> void:
	panel_pull_up.cancel()
	preload("res://scripts/ui/panel_close.gd").dismiss(bank_panel, false, func(): show_tab("assets"))


func _is_life_milestone(entry: Dictionary) -> bool:
	return PlayerData.is_life_milestone(entry)


func _is_routine_event(entry: Dictionary) -> bool:
	var txt := str(entry.get("text", "")).strip_edges().to_lower()
	if txt.is_empty():
		return true
	if txt.begins_with("you turned ") or txt.begins_with("you aged "):
		return true
	if txt.begins_with("you received your annual salary of"):
		return true
	if txt.begins_with("you paid your annual basic living"):
		return true
	if txt.begins_with("you paid your annual income tax"):
		return true
	if "bank loan accrued" in txt:
		return true
	if "bank savings account accrued" in txt:
		return true
	if "you finished year " in txt and "at university" in txt:
		return true
	if "you served another year behind bars" in txt:
		return true
	return false


func _is_unique_life_event(entry: Dictionary) -> bool:
	if _is_routine_event(entry):
		return false
	if _is_life_milestone(entry):
		return false
	return true


func _update_history_filter_buttons() -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	var active_color := Color("#0284c7") if is_light else Color("#00f0ff")
	var normal_color := Color("#475569") if is_light else Color("#94a3b8")
	var active_bg := Color("#bfdbfe") if is_light else Color("#0e2f44")
	var normal_bg := Color("#edf3fa") if is_light else Color("#091122")

	var btns := [
		{"btn": filter_all_btn, "key": "all", "text": "🌟 All Highlights"},
		{"btn": filter_milestones_btn, "key": "milestones", "text": "🏆 Life Milestones"},
		{"btn": filter_unique_btn, "key": "unique", "text": "✨ Unique Events"}
	]

	for item in btns:
		var btn: Button = item["btn"]
		if btn == null:
			continue
		var is_selected: bool = (overview_history_filter == item["key"])
		btn.text = item["text"]
		var style := StyleBoxFlat.new()
		style.bg_color = active_bg if is_selected else normal_bg
		style.border_color = active_color if is_selected else (Color("#cbd5e1") if is_light else Color("#1e3a5f"))
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("focus", style)
		btn.add_theme_color_override("font_color", (Color("#0369a1") if is_light else Color("#ffffff")) if is_selected else normal_color)


var history_display_limit: int = 35
var _card_style_milestone: StyleBoxFlat = null
var _card_style_regular: StyleBoxFlat = null


func _get_card_style(is_milestone: bool) -> StyleBoxFlat:
	if is_milestone:
		if _card_style_milestone == null:
			_card_style_milestone = StyleBoxFlat.new()
			_card_style_milestone.bg_color = Color("#17120a")
			_card_style_milestone.border_color = Color("#f59e0b")
			_card_style_milestone.set_border_width_all(2)
			_card_style_milestone.set_corner_radius_all(8)
		return _card_style_milestone
	else:
		if _card_style_regular == null:
			_card_style_regular = StyleBoxFlat.new()
			_card_style_regular.bg_color = Color("#091122")
			_card_style_regular.border_color = Color("#1e3a5f")
			_card_style_regular.set_border_width_all(2)
			_card_style_regular.set_corner_radius_all(8)
		return _card_style_regular


func _on_filter_all_pressed() -> void:
	overview_history_filter = "all"
	history_display_limit = 35
	_update_history_filter_buttons()
	update_history_panel()


func _on_filter_milestones_pressed() -> void:
	overview_history_filter = "milestones"
	history_display_limit = 35
	_update_history_filter_buttons()
	update_history_panel()


func _on_filter_unique_pressed() -> void:
	overview_history_filter = "unique"
	history_display_limit = 35
	_update_history_filter_buttons()
	update_history_panel()


func update_history_panel() -> void:
	if history_list == null:
		return

	for child in history_list.get_children():
		history_list.remove_child(child)
		child.queue_free()

	var matching_entries: Array[Dictionary] = []
	var last_rendered_text := ""
	var last_rendered_age := -1

	for entry in PlayerData.life_log:
		var is_milestone: bool = _is_life_milestone(entry)
		var is_unique: bool = _is_unique_life_event(entry)

		if overview_history_filter == "milestones" and not is_milestone:
			continue
		elif overview_history_filter == "unique" and not is_unique:
			continue
		elif overview_history_filter == "all" and not (is_milestone or is_unique):
			continue

		var entry_text := str(entry.get("text", "")).strip_edges()
		var entry_age := int(entry.get("age", 0))
		if entry_text == last_rendered_text and entry_age == last_rendered_age:
			continue
		last_rendered_text = entry_text
		last_rendered_age = entry_age
		matching_entries.append(entry)

	var total_count := matching_entries.size()
	var visible_count := mini(total_count, history_display_limit)
	var is_light: bool = LifeLibrary.data.theme == "light"

	for i in range(visible_count):
		var entry: Dictionary = matching_entries[i]
		var is_milestone: bool = _is_life_milestone(entry)

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _get_card_style(is_milestone))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_top", 14)
		margin.add_theme_constant_override("margin_bottom", 14)
		card.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		margin.add_child(vbox)

		var header_hbox := HBoxContainer.new()
		vbox.add_child(header_hbox)

		var badge_lbl := Label.new()
		if is_milestone:
			badge_lbl.text = "🏆 LIFE MILESTONE"
			badge_lbl.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#fbbf24"))
		else:
			badge_lbl.text = "✨ UNIQUE EVENT"
			badge_lbl.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
		badge_lbl.add_theme_font_size_override("font_size", 20)
		badge_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_hbox.add_child(badge_lbl)

		var age_lbl := Label.new()
		age_lbl.text = "AGE %d" % int(entry.get("age", 0))
		age_lbl.add_theme_font_size_override("font_size", 20)
		age_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		header_hbox.add_child(age_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = str(entry.get("text", ""))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_lbl.add_theme_font_size_override("font_size", 22)
		desc_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		vbox.add_child(desc_lbl)

		history_list.add_child(card)

	if total_count > visible_count:
		var remaining := total_count - visible_count
		var load_more_btn := Button.new()
		load_more_btn.text = "▼ Load Older Events (%d remaining)" % remaining
		load_more_btn.custom_minimum_size.y = 54
		load_more_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		load_more_btn.pressed.connect(func():
			history_display_limit += 35
			update_history_panel()
		)
		history_list.add_child(load_more_btn)

	if total_count == 0:
		var empty := Label.new()
		if overview_history_filter == "milestones":
			empty.text = "No life milestones reached yet.\nEnrolling in school, graduating, starting a career, or key achievements will appear here!"
		elif overview_history_filter == "unique":
			empty.text = "No unique life events recorded yet.\nRandom occurrences, critical decisions, and special encounters will appear here!"
		else:
			empty.text = "No life events recorded yet.\nYour milestones, achievements, and unique choices will appear here."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		empty.add_theme_font_size_override("font_size", 24)
		empty.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		history_list.add_child(empty)

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(history_list)


func update_character_panel() -> void:
	PlayerData.sync_milestones_from_log()

	if character_name != null:
		character_name.text = "Name: %s" % PlayerData.first_name
	if character_stage != null:
		character_stage.text = "Stage: %s %s (Age %d)" % [PlayerData.get_stage_icon(), PlayerData.get_stage_name(), PlayerData.age]
	if character_birthplace != null:
		var bp: String = PlayerData.birthplace if PlayerData.birthplace.strip_edges() != "" else "United States"
		character_birthplace.text = "Born in: %s" % bp
	if character_birthday != null:
		character_birthday.text = "Birthday: %s %d • %s" % [PlayerData.birth_month, PlayerData.birth_day, PlayerData.zodiac]

	if character_mother != null:
		if PlayerData.mother_name != "":
			var mom_age: int = PlayerData.mother_base_age + PlayerData.age
			var mom_edu_str := " • Edu: %s" % PlayerData.mother_education if PlayerData.mother_education != "" else ""
			var mom_cond_str := " • Health: %s" % PlayerData.mother_condition if PlayerData.mother_condition != "" else ""
			character_mother.text = "Mother: %s, %s (age %d)%s%s" % [PlayerData.mother_name, PlayerData.mother_job, mom_age, mom_edu_str, mom_cond_str]
		else:
			character_mother.text = "Mother: Unknown"

	if character_father != null:
		if PlayerData.father_name != "" and PlayerData.father_name != "Unknown":
			var dad_age: int = PlayerData.father_base_age + PlayerData.age
			var dad_edu_str := " • Edu: %s" % PlayerData.father_education if PlayerData.father_education != "" else ""
			var dad_cond_str := " • Health: %s" % PlayerData.father_condition if PlayerData.father_condition != "" else ""
			character_father.text = "Father: %s, %s (age %d)%s%s" % [PlayerData.father_name, PlayerData.father_job, dad_age, dad_edu_str, dad_cond_str]
		else:
			character_father.text = "Father: Unknown (Single mother)"

	if character_story != null:
		character_story.text = PlayerData.birth_story if PlayerData.birth_story != "" else "Born into the world."

	if character_money != null:
		var wealth_label := "Middle Class"
		match PlayerData.family_wealth:
			"poor": wealth_label = "Working Poor"
			"wealthy": wealth_label = "Wealthy"
			_: wealth_label = "Middle Class"
		character_money.text = "Cash: $%s • Savings: $%s • Family: %s" % [_format_number(PlayerData.money), _format_number(PlayerData.bank_savings), wealth_label]

	if character_karma != null:
		character_karma.visible = true
		character_karma.text = "🎯 Credit Score: %d (%s)  •  Net Worth: $%s" % [
			PlayerData.credit_score,
			PlayerData.get_credit_rating(),
			_format_number(PlayerData.get_net_worth())
		]
		character_karma.add_theme_color_override("font_color", PlayerData.get_credit_score_color())

	var m_list: VBoxContainer = character_milestones_list if character_milestones_list != null else get_node_or_null("CharacterPanel/CharacterMargin/CharacterContent/CharacterScroll/ProfileCards/MilestonesCard/Margin/VBox/MilestonesList") as VBoxContainer
	if m_list != null:
		for child in m_list.get_children():
			m_list.remove_child(child)
			child.queue_free()

		var is_light: bool = LifeLibrary.data.theme == "light"
		if PlayerData.life_milestones.is_empty():
			var empty_lbl := Label.new()
			empty_lbl.text = "No life milestones achieved yet."
			empty_lbl.add_theme_font_size_override("font_size", 22)
			empty_lbl.add_theme_color_override("font_color", Color("#64748b") if is_light else Color("#94a3b8"))
			m_list.add_child(empty_lbl)
		else:
			for m in PlayerData.life_milestones:
				if m is Dictionary:
					var m_age: int = int(m.get("age", 0))
					var m_icon: String = str(m.get("icon", "🏆"))
					var m_text: String = str(m.get("text", "")).strip_edges()
					if m_text.begins_with(m_icon):
						m_text = m_text.substr(m_icon.length()).strip_edges()
					var item := Label.new()
					item.text = "%s Age %d: %s" % [m_icon, m_age, m_text]
					item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					item.add_theme_font_size_override("font_size", 24)
					item.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f1f5f9"))
					m_list.add_child(item)


func update_infant_panel() -> void:
	var infant_title: Label = get_node_or_null("InfantPanel/InfantMargin/InfantContent/InfantHeaderRow/InfantTitle")
	if infant_title != null:
		infant_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		infant_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		infant_title.text = "%s & LIFE OVERVIEW" % PlayerData.get_stage_name().to_upper()

	# 1. Life Stage: NAME AND AGE
	if current_stage_label != null:
		current_stage_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		current_stage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_str: String = PlayerData.first_name if PlayerData.first_name != "" else "Character"
		current_stage_label.text = "👤 %s  •  %s %s (Age %d)" % [name_str, PlayerData.get_stage_icon(), PlayerData.get_stage_name(), PlayerData.age]

	# 4. CURRENT JOB
	var is_light: bool = LifeLibrary.data.theme == "light"
	if current_job_label != null:
		current_job_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		current_job_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if PlayerData.job_title != "":
			current_job_label.text = "💼 Current Job: %s at %s ($%s/yr)" % [PlayerData.job_title, PlayerData.job_company, _format_number(PlayerData.job_salary)]
			current_job_label.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#34d399"))
		else:
			current_job_label.text = "💼 Current Job: Unemployed"
			current_job_label.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))

	# 5. CURRENT EDUCATION LEVEL
	if current_edu_label != null:
		current_edu_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		current_edu_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		current_edu_label.text = "🎓 Current Education: %s" % PlayerData.get_education_display_string()

	# 6. CURRENT GRADES & GRADES PROGRESS BAR
	if grades_label != null:
		grades_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		grades_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if PlayerData.age < 3:
			grades_label.text = "📊 Academic Readiness: %d%% • Kindergarten begins at Age 3" % PlayerData.grades
			grades_label.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
		else:
			var standing: String = "Honor Roll" if PlayerData.grades >= 85 else ("Satisfactory" if PlayerData.grades >= 70 else ("Passing" if PlayerData.grades >= 55 else ("Failing" if PlayerData.grades > 0 else "EXPIRED (Course Required)")))
			grades_label.text = "📊 Current Marks: %d%% (%s) • %s" % [PlayerData.grades, PlayerData.get_letter_grade(), standing]
			var g_color: Color
			if is_light:
				g_color = Color("#15803d") if PlayerData.grades >= 85 else (Color("#0284c7") if PlayerData.grades >= 70 else (Color("#b45309") if PlayerData.grades >= 55 else Color("#b91c1c")))
			else:
				g_color = Color("#10b981") if PlayerData.grades >= 85 else (Color("#38bdf8") if PlayerData.grades >= 70 else (Color("#fbbf24") if PlayerData.grades >= 55 else Color("#ef4444")))
			grades_label.add_theme_color_override("font_color", g_color)


	if grades_progress_bar != null:
		grades_progress_bar.value = PlayerData.grades
		if PlayerData.grades >= 85:
			_update_stat_bar_color(grades_progress_bar, PlayerData.grades, Color("#10b981"), Color("#059669"))
		elif PlayerData.grades >= 70:
			_update_stat_bar_color(grades_progress_bar, PlayerData.grades, Color("#38bdf8"), Color("#0284c7"))
		elif PlayerData.grades >= 55:
			_update_stat_bar_color(grades_progress_bar, PlayerData.grades, Color("#f59e0b"), Color("#b45309"))
		else:
			_update_stat_bar_color(grades_progress_bar, PlayerData.grades, Color("#ef4444"), Color("#991b1b"))

	_update_history_filter_buttons()
	update_history_panel()


func apply_for_job(job_id: String) -> void:
	if PlayerData.is_dead or PlayerData.is_in_prison or PlayerData.job_id == job_id:
		return
	var job: Dictionary = JobManager.get_job_by_id(job_id)
	if job.is_empty():
		return

	var eval: Dictionary = JobManager.can_apply(job, PlayerData.age, PlayerData.get_stats(), {
		"grades": PlayerData.grades,
		"education_level": PlayerData.education_level,
		"major": PlayerData.university_major,
		"university_name": PlayerData.university_name,
		"degrees": PlayerData.degrees
	})
	if not bool(eval.get("allowed", false)):
		return

	PlayerData.job_id = str(job.get("id", ""))
	PlayerData.job_title = str(job.get("title", ""))
	PlayerData.job_company = str(job.get("workplace", ""))
	PlayerData.job_salary = int(job.get("salary", 0))
	CareerProgression.begin(PlayerData)
	if job.get("category", "") == "underworld_crime":
		UndergroundProgression.join(PlayerData)

	add_life_event("You started working as a %s at %s ($%s/yr)." % [
		PlayerData.job_title,
		PlayerData.job_company,
		_format_number(PlayerData.job_salary)
	], "milestone")
	PlayerData.add_milestone("Started career as %s at %s." % [PlayerData.job_title, PlayerData.job_company], PlayerData.age, "💼")
	update_ui()
	SaveManager.save_game()


func quit_job() -> void:
	if PlayerData.job_title == "":
		return

	var old_title: String = PlayerData.job_title
	PlayerData.job_id = ""
	PlayerData.job_title = ""
	PlayerData.job_company = ""
	PlayerData.job_salary = 0
	PlayerData.career_progress = {}

	add_life_event("You resigned from your position as %s. You are now unemployed." % old_title, "job")
	update_ui()
	SaveManager.save_game()


func update_assets_panel() -> void:
	var total_assets: int = PlayerData.get_total_asset_value()
	var net_worth: int = PlayerData.get_net_worth()
	var total_cash: int = PlayerData.money
	var savings: int = PlayerData.bank_savings
	var debt_val: int = PlayerData.get_total_debt()
	var is_light: bool = LifeLibrary.data.theme == "light"

	if net_worth < 0:
		assets_cash_label.text = "Cash: $%s  •  Bank: $%s  •  Assets: $%s  •  Debt: $%s\nTotal Net Worth: -$%s" % [
			_format_number(total_cash),
			_format_number(savings),
			_format_number(total_assets),
			_format_number(debt_val),
			_format_number(absi(net_worth))
		]
		assets_cash_label.add_theme_color_override("font_color", Color("#dc2626") if is_light else Color("#ef4444"))
	else:
		assets_cash_label.text = "Cash: $%s  •  Bank: $%s  •  Assets: $%s\nTotal Net Worth: $%s" % [
			_format_number(total_cash),
			_format_number(savings),
			_format_number(total_assets),
			_format_number(net_worth)
		]
		assets_cash_label.add_theme_color_override("font_color", Color("#16a34a") if is_light else Color("#22c55e"))

	_render_assets_list()
	_configure_button_contrasts()


func _render_assets_list() -> void:
	if assets_list == null:
		return

	var is_light: bool = LifeLibrary.data.theme == "light"

	for child in assets_list.get_children():
		assets_list.remove_child(child)
		child.queue_free()

	# 1. Commercial Dealerships & Brokerages Hub Card
	var store_card := PanelContainer.new()
	store_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#0284c7") if is_light else Color("#38bdf8")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	store_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 14)
	sm.add_child(sv)

	var stitle := Label.new()
	stitle.text = "🛍️ COMMERCIAL SHOPPING & BROKERAGES"
	stitle.add_theme_font_size_override("font_size", 26)
	stitle.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
	sv.add_child(stitle)

	var sdesc := Label.new()
	sdesc.text = "Vehicle dealerships, real estate brokerages, jewelers, aircraft, and yacht dealers are now located in the dedicated Shopping hub inside Activities!"
	sdesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sdesc.add_theme_font_size_override("font_size", 20)
	sdesc.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
	sv.add_child(sdesc)

	var btn_open_shop := _create_cyber_button("🛍️ Open Commercial Shopping Hub ➔", Color("#0284c7") if is_light else Color("#38bdf8"), func():
		_show_shopping_modal()
	)
	btn_open_shop.custom_minimum_size.y = 60
	btn_open_shop.add_theme_font_size_override("font_size", 24)
	sv.add_child(btn_open_shop)

	assets_list.add_child(store_card)

	# 2. Owned Vehicles Section (Cars, Motorcycles, Bicycles)
	_render_owned_assets_section("🚗 OWNED VEHICLES & RIDES", [AssetCatalog.CATEGORY_CARS, AssetCatalog.CATEGORY_MOTORCYCLES, AssetCatalog.CATEGORY_BICYCLES], Color("#06b6d4"))

	# 3. Owned Aviation Aircraft
	_render_owned_assets_section("✈️ OWNED AIRCRAFT & AVIATION", [AssetCatalog.CATEGORY_AIRCRAFT], Color("#38bdf8"))

	# 4. Owned Marine Vessels
	_render_owned_assets_section("🛥️ OWNED YACHTS & VESSELS", [AssetCatalog.CATEGORY_YACHTS], Color("#2563eb"))

	# 5. Owned Real Estate Section (Properties)
	_render_owned_assets_section("🏠 OWNED REAL ESTATE & PROPERTIES", [AssetCatalog.CATEGORY_PROPERTIES], Color("#10b981"))

	# 6. Owned Luxury Valuables & Fine Instruments
	_render_owned_assets_section("💎 OWNED LUXURY VALUABLES & INSTRUMENTS", [AssetCatalog.CATEGORY_JEWELRY, AssetCatalog.CATEGORY_INSTRUMENTS], Color("#f59e0b"))

	# 7. Owned Firearms & Tactical Defense Arsenal
	_render_owned_assets_section("🎯 OWNED FIREARMS & DEFENSE ARSENAL", [AssetCatalog.CATEGORY_FIREARMS], Color("#ef4444"))

	# 8. Owned Pets & Animal Companions
	_render_owned_pets_section()

	# 9. Owned Commercial Enterprises (Businesses)
	_render_owned_businesses_section()


func _render_owned_assets_section(title_text: String, categories: Array, theme_color: Color) -> void:
	var section_card := PanelContainer.new()
	section_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(theme_color))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	section_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 14)
	sm.add_child(sv)

	var is_light: bool = LifeLibrary.data.theme == "light"
	var matching_items: Array[Dictionary] = []
	for item in PlayerData.owned_assets:
		if str(item.get("category", "")) in categories:
			matching_items.append(item)

	var title_lbl := Label.new()
	title_lbl.text = "%s (%d)" % [title_text, matching_items.size()]
	title_lbl.add_theme_font_size_override("font_size", 24)
	var tc: Color = theme_color.darkened(0.35) if (is_light and theme_color.get_luminance() > 0.35) else theme_color
	title_lbl.add_theme_color_override("font_color", tc)
	sv.add_child(title_lbl)

	if matching_items.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "You do not currently own any assets in this category. Visit the marketplaces above to acquire vehicles or properties!"
		empty_lbl.add_theme_font_size_override("font_size", 20)
		empty_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sv.add_child(empty_lbl)
	else:
		for item in matching_items:
			var item_card := PanelContainer.new()
			var ic_style := StyleBoxFlat.new()
			ic_style.bg_color = Color("#edf3fa") if is_light else Color("#070e1c")
			ic_style.border_color = theme_color.darkened(0.35) if is_light else theme_color.darkened(0.2)
			ic_style.set_border_width_all(2)
			ic_style.set_corner_radius_all(10)
			item_card.add_theme_stylebox_override("panel", ic_style)
			sv.add_child(item_card)

			var im := MarginContainer.new()
			im.add_theme_constant_override("margin_left", 16)
			im.add_theme_constant_override("margin_right", 16)
			im.add_theme_constant_override("margin_top", 14)
			im.add_theme_constant_override("margin_bottom", 14)
			item_card.add_child(im)

			var ih := HBoxContainer.new()
			ih.add_theme_constant_override("separation", 18)
			im.add_child(ih)

			# Pixel art picture preview
			var img_rect := TextureRect.new()
			img_rect.custom_minimum_size = Vector2(130, 130)
			img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var img_path: String = str(item.get("image_path", ""))
			if ResourceLoader.exists(img_path):
				img_rect.texture = load(img_path)
			ih.add_child(img_rect)

			var iv := VBoxContainer.new()
			iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			iv.add_theme_constant_override("separation", 6)
			ih.add_child(iv)

			var name_lbl := Label.new()
			name_lbl.text = str(item.get("name", "Asset"))
			name_lbl.add_theme_font_size_override("font_size", 22)
			name_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
			name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			iv.add_child(name_lbl)

			var cur_val: int = int(item.get("current_value", item.get("purchase_price", 0)))
			var upkeep: int = int(item.get("upkeep", 0))
			var val_lbl := Label.new()
			val_lbl.text = "Resale Value: $%s   •   Upkeep: $%s/yr" % [_format_number(cur_val), _format_number(upkeep)]
			val_lbl.add_theme_font_size_override("font_size", 18)
			val_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#4ade80"))
			val_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			iv.add_child(val_lbl)

			# Action Row: Joyride / Relax and Sell
			var act_row := HBoxContainer.new()
			act_row.add_theme_constant_override("separation", 10)
			iv.add_child(act_row)

			var cat: String = str(item.get("category", ""))
			var is_used: bool = int(item.get("last_used_age", -1)) == PlayerData.age
			var use_text := "Joyride (Used)" if is_used else "🏎️ Joyride"
			if cat == AssetCatalog.CATEGORY_PROPERTIES:
				use_text = "Relax (Used)" if is_used else "🎉 Host Party"

			var instance_id: String = str(item.get("instance_id", ""))
			var btn_use := _create_cyber_button(use_text, Color("#0284c7"), func():
				var res = AssetCatalog.use_asset(PlayerData, instance_id)
				if res["success"]:
					add_life_event(res["message"], "lifestyle")
					update_ui()
					update_assets_panel()
				else:
					add_life_event(res["message"], "lifestyle")
					show_tab("timeline")
			)
			btn_use.custom_minimum_size.y = 48
			btn_use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_use.add_theme_font_size_override("font_size", 18)
			if is_used:
				btn_use.disabled = true
				btn_use.modulate = Color(0.6, 0.6, 0.6, 0.65)
			act_row.add_child(btn_use)

			var btn_sell := _create_cyber_button("💰 Sell ($%s)" % _format_number(cur_val), Color("#f43f5e"), func():
				var res = AssetCatalog.sell_asset(PlayerData, instance_id)
				if res["success"]:
					add_life_event("💰 ASSET SOLD: You sold %s for $%s!" % [item.get("name", "Asset"), _format_number(res["sale_price"])], "finance")
					update_ui()
					update_assets_panel()
			)
			btn_sell.custom_minimum_size.y = 48
			btn_sell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_sell.add_theme_font_size_override("font_size", 18)
			act_row.add_child(btn_sell)

	assets_list.add_child(section_card)


func _render_owned_pets_section() -> void:
	var section_card := PanelContainer.new()
	section_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	section_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 14)
	sm.add_child(sv)

	var is_light: bool = LifeLibrary.data.theme == "light"
	var pets_list: Array = PlayerData.get("pets") if PlayerData.get("pets") is Array else []
	var title_lbl := Label.new()
	title_lbl.text = "🐾 OWNED PETS & COMPANIONS (%d)" % pets_list.size()
	title_lbl.add_theme_font_size_override("font_size", 24)
	title_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#10b981"))
	sv.add_child(title_lbl)

	if pets_list.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "You do not currently care for any pets. Visit Pet Adoption in Activities to welcome a companion to your home!"
		empty_lbl.add_theme_font_size_override("font_size", 20)
		empty_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sv.add_child(empty_lbl)
	else:
		for i in range(pets_list.size()):
			var pet: Dictionary = pets_list[i]
			var pet_card := PanelContainer.new()
			var pc_style := StyleBoxFlat.new()
			pc_style.bg_color = Color("#edf3fa") if is_light else Color("#07131e")
			pc_style.border_color = Color("#10b981").darkened(0.35) if is_light else Color("#10b981").darkened(0.2)
			pc_style.set_border_width_all(2)
			pc_style.set_corner_radius_all(12)
			pet_card.add_theme_stylebox_override("panel", pc_style)
			sv.add_child(pet_card)

			var pm := MarginContainer.new()
			pm.add_theme_constant_override("margin_left", 16)
			pm.add_theme_constant_override("margin_right", 16)
			pm.add_theme_constant_override("margin_top", 14)
			pm.add_theme_constant_override("margin_bottom", 14)
			pet_card.add_child(pm)

			var pv := VBoxContainer.new()
			pv.add_theme_constant_override("separation", 8)
			pm.add_child(pv)

			var p_icon: String = str(pet.get("icon", "🐾"))
			var p_name: String = str(pet.get("name", "Companion"))
			var p_breed: String = str(pet.get("breed", pet.get("species", "Animal")))
			var p_age: int = int(pet.get("age", 1))
			var p_upkeep: int = int(pet.get("upkeep", 100))
			var p_health: int = int(pet.get("health", 100))
			var p_hap: int = int(pet.get("happiness", 100))

			var header_lbl := Label.new()
			header_lbl.text = "%s %s • %s (%d yrs old)" % [p_icon, p_name, p_breed, p_age]
			header_lbl.add_theme_font_size_override("font_size", 22)
			header_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
			pv.add_child(header_lbl)

			var stats_lbl := Label.new()
			stats_lbl.text = "❤️ Health: %d%%   •   😊 Happiness: %d%%   •   🥩 Upkeep: $%s/yr" % [
				p_health,
				p_hap,
				_format_number(p_upkeep)
			]
			stats_lbl.add_theme_font_size_override("font_size", 19)
			stats_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#4ade80"))
			pv.add_child(stats_lbl)

			var act_h := HBoxContainer.new()
			act_h.add_theme_constant_override("separation", 10)
			pv.add_child(act_h)

			var pet_id: String = str(pet.get("id", ""))
			var has_played_this_year: bool = int(pet.get("last_play_age", -1)) == PlayerData.age
			var btn_play := _create_cyber_button("🎾 Play (Used)" if has_played_this_year else "🎾 Play", Color("#38bdf8"), func():
				var res := PetManager.interact_pet(PlayerData, pet_id, "play")
				add_life_event(res["message"], "relationship")
				update_ui()
				update_assets_panel()
			)
			btn_play.custom_minimum_size.y = 48
			btn_play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_play.add_theme_font_size_override("font_size", 18)
			if has_played_this_year:
				btn_play.disabled = true
				btn_play.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_play.tooltip_text = "Completed for Age %d (Wait until next year)" % PlayerData.age
			act_h.add_child(btn_play)

			var has_walked_this_year: bool = int(pet.get("last_walk_age", -1)) == PlayerData.age
			var btn_walk := _create_cyber_button("🦮 Walk (Used)" if has_walked_this_year else "🦮 Walk", Color("#10b981"), func():
				var res := PetManager.interact_pet(PlayerData, pet_id, "walk")
				add_life_event(res["message"], "relationship")
				update_ui()
				update_assets_panel()
			)
			btn_walk.custom_minimum_size.y = 48
			btn_walk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_walk.add_theme_font_size_override("font_size", 18)
			if has_walked_this_year:
				btn_walk.disabled = true
				btn_walk.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_walk.tooltip_text = "Completed for Age %d (Wait until next year)" % PlayerData.age
			act_h.add_child(btn_walk)

			var has_treated_this_year: bool = int(pet.get("last_treat_age", -1)) == PlayerData.age
			var btn_treat := _create_cyber_button("🍖 Treat (Used)" if has_treated_this_year else "🍖 Treat", Color("#f59e0b"), func():
				var res := PetManager.interact_pet(PlayerData, pet_id, "treat")
				add_life_event(res["message"], "relationship")
				update_ui()
				update_assets_panel()
			)
			btn_treat.custom_minimum_size.y = 48
			btn_treat.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_treat.add_theme_font_size_override("font_size", 18)
			if has_treated_this_year:
				btn_treat.disabled = true
				btn_treat.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_treat.tooltip_text = "Completed for Age %d (Wait until next year)" % PlayerData.age
			act_h.add_child(btn_treat)

			var has_vetted_this_year: bool = int(pet.get("last_vet_age", -1)) == PlayerData.age
			var btn_vet := _create_cyber_button("🩺 Vet (Used)" if has_vetted_this_year else "🩺 Vet Checkup", Color("#f43f5e"), func():
				var res := PetManager.interact_pet(PlayerData, pet_id, "vet")
				add_life_event(res["message"], "relationship")
				update_ui()
				update_assets_panel()
			)
			btn_vet.custom_minimum_size.y = 48
			btn_vet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_vet.add_theme_font_size_override("font_size", 18)
			if has_vetted_this_year:
				btn_vet.disabled = true
				btn_vet.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_vet.tooltip_text = "Completed for Age %d (Wait until next year)" % PlayerData.age
			act_h.add_child(btn_vet)

	assets_list.add_child(section_card)


func _open_asset_marketplace_modal(category: String) -> void:
	var title_text: String = AssetCatalog.get_category_display_title(category)
	var subtitle_text: String = AssetCatalog.get_category_subtitle(category)
	var border_color: Color = Color("#0284c7")
	match category:
		AssetCatalog.CATEGORY_MOTORCYCLES:
			border_color = Color("#8b5cf6")
		AssetCatalog.CATEGORY_BICYCLES:
			border_color = Color("#06b6d4")
		AssetCatalog.CATEGORY_JEWELRY:
			border_color = Color("#f59e0b")
		AssetCatalog.CATEGORY_INSTRUMENTS:
			border_color = Color("#ec4899")
		AssetCatalog.CATEGORY_PROPERTIES:
			border_color = Color("#10b981")
		AssetCatalog.CATEGORY_AIRCRAFT:
			border_color = Color("#38bdf8")
		AssetCatalog.CATEGORY_YACHTS:
			border_color = Color("#2563eb")
		AssetCatalog.CATEGORY_FIREARMS:
			border_color = Color("#ef4444")

	var is_light: bool = LifeLibrary.data.theme == "light"
	var modal_dict: Dictionary = _create_cyber_modal(title_text, subtitle_text, border_color)
	var content_list: VBoxContainer = modal_dict["list"]
	var overlay: Control = modal_dict["overlay"]

	# Balance overview banner
	var bal_card := PanelContainer.new()
	bal_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_color))
	var bm := MarginContainer.new()
	bm.add_theme_constant_override("margin_left", 18)
	bm.add_theme_constant_override("margin_right", 18)
	bm.add_theme_constant_override("margin_top", 12)
	bm.add_theme_constant_override("margin_bottom", 12)
	bal_card.add_child(bm)

	var bal_lbl := Label.new()
	bal_lbl.text = "💳 Available Funds: Cash $%s   •   Bank Savings: $%s   (Total: $%s)" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		_format_number(PlayerData.money + PlayerData.bank_savings)
	]
	bal_lbl.add_theme_font_size_override("font_size", 22)
	bal_lbl.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color("#38bdf8"))
	bal_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bm.add_child(bal_lbl)
	content_list.add_child(bal_card)

	var items: Array[Dictionary] = AssetCatalog.get_items_by_category(category)
	for item in items:
		var item_id: String = str(item.get("id", ""))
		var item_name: String = str(item.get("name", ""))
		var price: int = int(item.get("price", 0))
		var upkeep: int = int(item.get("upkeep", 0))
		var happiness_bonus: int = int(item.get("happiness_bonus", 5))
		var desc: String = str(item.get("desc", ""))
		var img_path: String = str(item.get("image_path", ""))
		var min_age: int = int(item.get("min_age", 18))

		var card := PanelContainer.new()
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color("#edf3fa") if is_light else Color("#070e1c")
		card_style.border_color = border_color.darkened(0.35) if is_light else border_color.darkened(0.2)
		card_style.set_border_width_all(2)
		card_style.set_corner_radius_all(14)
		card_style.shadow_color = Color(0, 0, 0, 0.15 if is_light else 0.5)
		card_style.shadow_size = 8
		card.add_theme_stylebox_override("panel", card_style)
		content_list.add_child(card)

		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 24)
		cm.add_theme_constant_override("margin_right", 24)
		cm.add_theme_constant_override("margin_top", 22)
		cm.add_theme_constant_override("margin_bottom", 22)
		card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 14)
		cm.add_child(cv)

		# 1. IMAGE OR GLYPH BADGE
		var img_center := CenterContainer.new()
		img_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_child(img_center)

		var img_frame := PanelContainer.new()
		var img_frame_style := StyleBoxFlat.new()
		img_frame_style.bg_color = Color("#e2edf8") if is_light else Color("#030712")
		img_frame_style.border_color = border_color.darkened(0.35)
		img_frame_style.set_border_width_all(2)
		img_frame_style.set_corner_radius_all(14)
		img_frame.add_theme_stylebox_override("panel", img_frame_style)
		img_center.add_child(img_frame)

		if img_path != "" and ResourceLoader.exists(img_path):
			var p_img := TextureRect.new()
			p_img.custom_minimum_size = Vector2(400, 300)
			p_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			p_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			p_img.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			p_img.texture = load(img_path)
			img_frame.add_child(p_img)
		else:
			var icon_lbl := Label.new()
			var glyph := "🛍️"
			match category:
				AssetCatalog.CATEGORY_BICYCLES: glyph = "🚲"
				AssetCatalog.CATEGORY_JEWELRY: glyph = "💎"
				AssetCatalog.CATEGORY_INSTRUMENTS: glyph = "🎸"
				AssetCatalog.CATEGORY_AIRCRAFT: glyph = "✈️"
				AssetCatalog.CATEGORY_YACHTS: glyph = "🛥️"
			icon_lbl.text = glyph
			icon_lbl.custom_minimum_size = Vector2(280, 150)
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			icon_lbl.add_theme_font_size_override("font_size", 76)
			img_frame.add_child(icon_lbl)

		# 2. PRODUCT NAME  ------- PRICE
		var row_name_price := HBoxContainer.new()
		row_name_price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_child(row_name_price)

		var item_name_lbl := Label.new()
		item_name_lbl.text = item_name
		item_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_name_lbl.add_theme_font_size_override("font_size", 28)
		item_name_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		item_name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row_name_price.add_child(item_name_lbl)

		var price_label := Label.new()
		price_label.text = "$%s" % _format_number(price)
		price_label.add_theme_font_size_override("font_size", 30)
		price_label.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#4ade80"))
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row_name_price.add_child(price_label)

		# 3. UPKEEP   -------   PERK
		var row_upkeep_perk := HBoxContainer.new()
		row_upkeep_perk.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_child(row_upkeep_perk)

		var upkeep_lbl := Label.new()
		upkeep_lbl.text = "Annual Upkeep: $%s/yr" % _format_number(upkeep)
		upkeep_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		upkeep_lbl.add_theme_font_size_override("font_size", 22)
		upkeep_lbl.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color("#38bdf8"))
		row_upkeep_perk.add_child(upkeep_lbl)

		var perk_word := "Performance"
		match category:
			AssetCatalog.CATEGORY_CARS, AssetCatalog.CATEGORY_MOTORCYCLES, AssetCatalog.CATEGORY_BICYCLES:
				perk_word = "Ride"
			AssetCatalog.CATEGORY_PROPERTIES:
				perk_word = "Residential"
			AssetCatalog.CATEGORY_JEWELRY:
				perk_word = "Prestige"
			AssetCatalog.CATEGORY_INSTRUMENTS:
				perk_word = "Virtuoso"
			AssetCatalog.CATEGORY_AIRCRAFT:
				perk_word = "Flight"
			AssetCatalog.CATEGORY_YACHTS:
				perk_word = "Cruise"

		var perk_lbl := Label.new()
		perk_lbl.text = "%s Lifestyle Asset" % perk_word
		perk_lbl.add_theme_font_size_override("font_size", 22)
		perk_lbl.add_theme_color_override("font_color", Color("#db2777") if is_light else Color("#f472b6"))
		perk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row_upkeep_perk.add_child(perk_lbl)

		# 4. DESCRIPTION
		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.add_theme_font_size_override("font_size", 21)
		desc_lbl.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(desc_lbl)

		# 5. REQUIREMENTS
		var can_afford: bool = AssetCatalog.can_afford(PlayerData, price)
		var is_of_age: bool = PlayerData.age >= min_age
		var total_available: int = PlayerData.money + PlayerData.bank_savings

		var has_veh_license: bool = true
		var lic_required_name: String = ""
		match category:
			AssetCatalog.CATEGORY_CARS:
				has_veh_license = PlayerData.has_license("license_car")
				lic_required_name = "Driver's License (Class C)"
			AssetCatalog.CATEGORY_MOTORCYCLES:
				has_veh_license = PlayerData.has_license("license_motorcycle")
				lic_required_name = "Motorcycle Operator License (Class M)"
			AssetCatalog.CATEGORY_AIRCRAFT:
				has_veh_license = PlayerData.has_license("license_pilot")
				lic_required_name = "Private Pilot & Rotorcraft License"
			AssetCatalog.CATEGORY_YACHTS:
				has_veh_license = PlayerData.has_license("license_boating")
				lic_required_name = "Master Coastal Boater & Yachting License"

		var can_afford_funds: bool = total_available >= price
		var can_afford_cc: bool = PlayerData.has_credit_card and PlayerData.get_credit_card_available() >= price
		var can_afford_any: bool = can_afford_funds or can_afford_cc

		var req_lbl := Label.new()
		req_lbl.add_theme_font_size_override("font_size", 20)
		req_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if not is_of_age:
			req_lbl.text = "⚠️ Legal Requirement: Minimum Age %d+ Required (You are Age %d)" % [min_age, PlayerData.age]
			req_lbl.add_theme_color_override("font_color", Color("#dc2626") if is_light else Color("#f87171"))
		elif not has_veh_license:
			req_lbl.text = "🔒 License Requirement: %s Required (❌ Not Certified • Visit Licensing Bureau in Activities)" % lic_required_name
			req_lbl.add_theme_color_override("font_color", Color("#dc2626") if is_light else Color("#f87171"))
		elif not can_afford_any:
			if PlayerData.has_credit_card:
				req_lbl.text = "⚠️ Financial Requirement: $%s Required • Short on Funds ($%s avail) & Credit ($%s avail)" % [
					_format_number(price),
					_format_number(total_available),
					_format_number(PlayerData.get_credit_card_available())
				]
			else:
				var shortage := price - total_available
				req_lbl.text = "⚠️ Financial Requirement: $%s Required • Short by $%s (Available Funds: $%s)" % [
					_format_number(price),
					_format_number(shortage),
					_format_number(total_available)
				]
			req_lbl.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#fbbf24"))
		else:
			var lic_status := " • License Certified" if lic_required_name != "" else ""
			if PlayerData.has_credit_card:
				req_lbl.text = "✅ Requirements Met: Age %d+ Verified%s • Funds: $%s • Credit Available: $%s" % [
					min_age,
					lic_status,
					_format_number(total_available),
					_format_number(PlayerData.get_credit_card_available())
				]
			else:
				req_lbl.text = "✅ Requirements Met: Age %d+ Verified%s • Available Funds: $%s" % [min_age, lic_status, _format_number(total_available)]
			req_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#34d399"))
		cv.add_child(req_lbl)

		# 6. PURCHASE ACTION BUTTONS
		if PlayerData.has_credit_card:
			var btn_buy_funds := _create_cyber_button("💵 Purchase with Funds ($%s)" % _format_number(price), border_color, func():
				var buy_res = AssetCatalog.buy_asset(PlayerData, item_id, "funds")
				if buy_res["success"]:
					add_life_event("🛍️ NEW ACQUISITION: You purchased %s for $%s!" % [item_name, _format_number(price)], "finance")
					overlay.queue_free()
					update_ui()
					update_assets_panel()
					SaveManager.save_game()
				else:
					add_life_event(buy_res["message"], "finance")
					show_tab("timeline")
			, true)
			btn_buy_funds.custom_minimum_size.y = 56
			btn_buy_funds.add_theme_font_size_override("font_size", 22)
			btn_buy_funds.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn_buy_funds.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_buy_funds.set_meta("center_text", true)

			if not is_of_age:
				btn_buy_funds.disabled = true
				btn_buy_funds.text = "Age Restricted (Requires Age %d+)" % min_age
			elif not has_veh_license:
				btn_buy_funds.disabled = true
				btn_buy_funds.text = "🔒 Requires %s" % lic_required_name
			elif not can_afford_funds:
				btn_buy_funds.disabled = true
				btn_buy_funds.text = "Insufficient Funds ($%s available)" % _format_number(total_available)
			cv.add_child(btn_buy_funds)

			var btn_buy_cc := _create_cyber_button("💳 Charge to %s Card ($%s)" % [PlayerData.credit_card_tier, _format_number(price)], Color("#38bdf8"), func():
				var buy_res = AssetCatalog.buy_asset(PlayerData, item_id, "credit_card")
				if buy_res["success"]:
					add_life_event("💳 ASSET CHARGED TO CARD: You purchased %s for $%s using your %s Credit Card (Current Usage: $%s, Available Credit: $%s)!" % [
						item_name,
						_format_number(price),
						PlayerData.credit_card_tier,
						_format_number(PlayerData.credit_card_balance),
						_format_number(PlayerData.get_credit_card_available())
					], "finance")
					overlay.queue_free()
					update_ui()
					update_assets_panel()
					SaveManager.save_game()
				else:
					add_life_event(buy_res["message"], "finance")
					show_tab("timeline")
			, true)
			btn_buy_cc.custom_minimum_size.y = 56
			btn_buy_cc.add_theme_font_size_override("font_size", 22)
			btn_buy_cc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn_buy_cc.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_buy_cc.set_meta("center_text", true)

			if not is_of_age:
				btn_buy_cc.disabled = true
				btn_buy_cc.text = "Age Restricted (Requires Age %d+)" % min_age
			elif not has_veh_license:
				btn_buy_cc.disabled = true
				btn_buy_cc.text = "🔒 Requires %s" % lic_required_name
			elif not can_afford_cc:
				btn_buy_cc.disabled = true
				btn_buy_cc.text = "💳 Exceeds Card Limit ($%s available)" % _format_number(PlayerData.get_credit_card_available())
			cv.add_child(btn_buy_cc)
		else:
			var btn_buy := _create_cyber_button("", border_color, func():
				var buy_res = AssetCatalog.buy_asset(PlayerData, item_id, "funds")
				if buy_res["success"]:
					add_life_event("🛍️ NEW ACQUISITION: You purchased %s for $%s!" % [item_name, _format_number(price)], "finance")
					overlay.queue_free()
					update_ui()
					update_assets_panel()
					SaveManager.save_game()
				else:
					add_life_event(buy_res["message"], "finance")
					show_tab("timeline")
			, true)
			btn_buy.custom_minimum_size.y = 62
			btn_buy.add_theme_font_size_override("font_size", 24)
			btn_buy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn_buy.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_buy.set_meta("center_text", true)

			if not is_of_age:
				btn_buy.disabled = true
				btn_buy.modulate = Color(0.5, 0.5, 0.5, 0.6)
				btn_buy.text = "Age Restricted (Requires Age %d+)" % min_age
			elif not has_veh_license:
				btn_buy.disabled = true
				btn_buy.modulate = Color(0.5, 0.5, 0.5, 0.6)
				btn_buy.text = "🔒 Requires %s" % lic_required_name
			elif not can_afford_funds:
				btn_buy.disabled = true
				btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.65)
				btn_buy.text = "Cannot Afford ($%s)" % _format_number(price)
			else:
				btn_buy.text = "Purchase for $%s" % _format_number(price)

			cv.add_child(btn_buy)

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(content_list)


func load_style_box_cyber_card(border_col: Color = Color("#22d3ee")) -> StyleBoxFlat:
	var is_light: bool = LifeLibrary.data.theme == "light"
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#edf3fa") if is_light else Color("#090f1d")
	style.border_color = border_col.darkened(0.35) if (is_light and border_col.get_luminance() > 0.45) else border_col
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0, 0, 0, 0.15 if is_light else 0.6)
	style.shadow_size = 10
	return style


func update_bank_panel() -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	bank_checking_label.text = "Cash: $%s   •   Bank Balance: $%s\n🎯 Credit Score: %d (%s)" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		PlayerData.credit_score,
		PlayerData.get_credit_rating()
	]
	bank_checking_label.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color(0.396, 0.902, 1, 1))
	var bank_status_lbl := get_node_or_null("BankPanel/BankMargin/BankContent/BankScroll/BankList/BankCard/Margin/VBox/BankStatusLabel") as Label
	if bank_status_lbl != null:
		bank_status_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color(0.68, 0.78, 0.9, 1))

	if bank_list == null:
		return

	# Remove any previous dynamic cards added to bank_list (keep the first BankCard intact)
	for i in range(bank_list.get_child_count() - 1, 0, -1):
		var child: Node = bank_list.get_child(i)
		bank_list.remove_child(child)
		child.queue_free()

	# 1. High-Yield Savings Card
	var savings_card := PanelContainer.new()
	savings_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#15803d") if is_light else Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 28)
	sm.add_theme_constant_override("margin_right", 28)
	sm.add_theme_constant_override("margin_top", 24)
	sm.add_theme_constant_override("margin_bottom", 24)
	savings_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var sav_title := Label.new()
	sav_title.text = "🏦 HIGH-YIELD SAVINGS ACCOUNT (2.5% APR)"
	sav_title.add_theme_font_size_override("font_size", 28)
	sav_title.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#34d399"))
	sv.add_child(sav_title)

	var sav_bal := Label.new()
	sav_bal.text = "• Bank Balance: $%s  (Protected for Inheritance)\n• Cash: $%s" % [
		_format_number(PlayerData.bank_savings),
		_format_number(PlayerData.money)
	]
	sav_bal.add_theme_font_size_override("font_size", 24)
	sav_bal.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
	sv.add_child(sav_bal)

	var dep_title := Label.new()
	dep_title.text = "Deposit Cash into Bank Balance:"
	dep_title.add_theme_font_size_override("font_size", 22)
	dep_title.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
	sv.add_child(dep_title)

	var dep_row := HBoxContainer.new()
	dep_row.add_theme_constant_override("separation", 8)
	sv.add_child(dep_row)

	var btn_dep_100 := _create_cyber_button("Deposit $100", Color("#10b981"), func(): _deposit_money(100), true)
	btn_dep_100.disabled = PlayerData.money < 100
	btn_dep_100.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_dep_100.set_meta("center_text", true)
	dep_row.add_child(btn_dep_100)

	var btn_dep_1k := _create_cyber_button("Deposit $1,000", Color("#10b981"), func(): _deposit_money(1000), true)
	btn_dep_1k.disabled = PlayerData.money < 1000
	btn_dep_1k.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_dep_1k.set_meta("center_text", true)
	dep_row.add_child(btn_dep_1k)

	var btn_dep_all := _create_cyber_button("Deposit All", Color("#10b981"), func(): _deposit_money(PlayerData.money), true)
	btn_dep_all.disabled = PlayerData.money <= 0
	btn_dep_all.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_dep_all.set_meta("center_text", true)
	dep_row.add_child(btn_dep_all)
	var deposit_custom := _create_cyber_button("Deposit Amount", Color("#10b981"), func(): _show_bank_transfer(true), true)
	deposit_custom.disabled = PlayerData.money <= 0
	deposit_custom.alignment = HORIZONTAL_ALIGNMENT_CENTER
	deposit_custom.set_meta("center_text", true)
	sv.add_child(deposit_custom)

	var wth_title := Label.new()
	wth_title.text = "Withdraw from Bank Balance to Cash:"
	wth_title.add_theme_font_size_override("font_size", 22)
	wth_title.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#fbbf24"))
	sv.add_child(wth_title)

	var wth_row := HBoxContainer.new()
	wth_row.add_theme_constant_override("separation", 8)
	sv.add_child(wth_row)

	var btn_wth_100 := _create_cyber_button("Withdraw $100", Color("#fbbf24"), func(): _withdraw_money(100), true)
	btn_wth_100.disabled = PlayerData.bank_savings < 100
	btn_wth_100.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_wth_100.set_meta("center_text", true)
	wth_row.add_child(btn_wth_100)

	var btn_wth_1k := _create_cyber_button("Withdraw $1,000", Color("#fbbf24"), func(): _withdraw_money(1000), true)
	btn_wth_1k.disabled = PlayerData.bank_savings < 1000
	btn_wth_1k.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_wth_1k.set_meta("center_text", true)
	wth_row.add_child(btn_wth_1k)

	var btn_wth_all := _create_cyber_button("Withdraw All", Color("#fbbf24"), func(): _withdraw_money(PlayerData.bank_savings), true)
	btn_wth_all.disabled = PlayerData.bank_savings <= 0
	btn_wth_all.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_wth_all.set_meta("center_text", true)
	wth_row.add_child(btn_wth_all)
	var withdraw_custom := _create_cyber_button("Withdraw Amount", Color("#fbbf24"), func(): _show_bank_transfer(false), true)
	withdraw_custom.disabled = PlayerData.bank_savings <= 0
	withdraw_custom.alignment = HORIZONTAL_ALIGNMENT_CENTER
	withdraw_custom.set_meta("center_text", true)
	sv.add_child(withdraw_custom)

	bank_list.add_child(savings_card)

	# 2. Debt & Loan Summary Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#0284c7") if is_light else Color("#38bdf8")))
	var summary_margin := MarginContainer.new()
	summary_margin.add_theme_constant_override("margin_left", 28)
	summary_margin.add_theme_constant_override("margin_right", 28)
	summary_margin.add_theme_constant_override("margin_top", 24)
	summary_margin.add_theme_constant_override("margin_bottom", 24)
	summary_card.add_child(summary_margin)

	var summary_vbox := VBoxContainer.new()
	summary_vbox.add_theme_constant_override("separation", 10)
	summary_margin.add_child(summary_vbox)

	var sum_title := Label.new()
	sum_title.text = "💳 LIABILITIES & DEBT OVERVIEW"
	sum_title.add_theme_font_size_override("font_size", 28)
	sum_title.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
	summary_vbox.add_child(sum_title)

	var cs_lbl := Label.new()
	cs_lbl.text = "• Credit Score: %d (%s)" % [PlayerData.credit_score, PlayerData.get_credit_rating()]
	cs_lbl.add_theme_font_size_override("font_size", 24)
	cs_lbl.add_theme_color_override("font_color", PlayerData.get_credit_score_color())
	summary_vbox.add_child(cs_lbl)

	var loan_lbl := Label.new()
	loan_lbl.text = "• Active Bank Loan: $%s  (@ %d%% APR)" % [_format_number(PlayerData.loan_balance), int(PlayerData.loan_interest_rate * 100)]
	loan_lbl.add_theme_font_size_override("font_size", 24)
	loan_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
	summary_vbox.add_child(loan_lbl)

	var tax_lbl := Label.new()
	var cc_text := ("\n• Credit Card Balance: $%s" % _format_number(PlayerData.credit_card_balance)) if PlayerData.credit_card_balance > 0 else ""
	tax_lbl.text = "• Unpaid Tax: $%s%s\n• Other Outstanding Debt: $%s" % [_format_number(PlayerData.tax_debt), cc_text, _format_number(PlayerData.debt)]
	tax_lbl.add_theme_font_size_override("font_size", 24)
	tax_lbl.add_theme_color_override("font_color", Color("#dc2626") if PlayerData.tax_debt + PlayerData.debt + PlayerData.credit_card_balance > 0 else (Color("#0f172a") if is_light else Color("#f8fafc")))
	summary_vbox.add_child(tax_lbl)

	var total_debt_lbl := Label.new()
	total_debt_lbl.text = "• Total Debt Burden: $%s" % _format_number(PlayerData.get_total_debt())
	total_debt_lbl.add_theme_font_size_override("font_size", 26)
	total_debt_lbl.add_theme_color_override("font_color", (Color("#dc2626") if is_light else Color("#ef4444")) if PlayerData.get_total_debt() > 0 else (Color("#15803d") if is_light else Color("#22c55e")))
	summary_vbox.add_child(total_debt_lbl)

	bank_list.add_child(summary_card)

	# 2b. Credit Card Facility Card
	var cc_card := PanelContainer.new()
	var cc_color: Color = (Color("#b45309") if is_light else Color("#eab308")) if PlayerData.has_credit_card else (Color("#7e22ce") if is_light else Color("#a855f7"))
	cc_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(cc_color))
	var cc_margin := MarginContainer.new()
	cc_margin.add_theme_constant_override("margin_left", 28)
	cc_margin.add_theme_constant_override("margin_right", 28)
	cc_margin.add_theme_constant_override("margin_top", 24)
	cc_margin.add_theme_constant_override("margin_bottom", 24)
	cc_card.add_child(cc_margin)

	var cc_vbox := VBoxContainer.new()
	cc_vbox.add_theme_constant_override("separation", 10)
	cc_margin.add_child(cc_vbox)

	var cc_title := Label.new()
	cc_title.text = "💳 REVOLVING CREDIT CARD FACILITY" if PlayerData.has_credit_card else "💳 REVOLVING CREDIT CARD & CREDIT SCORE"
	cc_title.add_theme_font_size_override("font_size", 28)
	cc_title.add_theme_color_override("font_color", cc_color)
	cc_vbox.add_child(cc_title)

	var cc_score_lbl := Label.new()
	cc_score_lbl.text = "• Credit Score: %d (%s)  [300–850 Range]" % [PlayerData.credit_score, PlayerData.get_credit_rating()]
	cc_score_lbl.add_theme_font_size_override("font_size", 24)
	cc_score_lbl.add_theme_color_override("font_color", PlayerData.get_credit_score_color())
	cc_vbox.add_child(cc_score_lbl)

	if PlayerData.has_credit_card:
		var cc_detail := Label.new()
		cc_detail.text = "• Card Tier: %s Credit Card\n• Dynamic Limit: $%s  (@ %d%% APR)\n• Available Credit: $%s\n• Current Card Usage: $%s\n• Dynamic Limit Profile: Allowance $%s/yr • Personal Assets $%s • Net Worth $%s" % [
			PlayerData.credit_card_tier,
			_format_number(PlayerData.credit_card_limit),
			int(PlayerData.credit_card_apr * 100),
			_format_number(PlayerData.get_credit_card_available()),
			_format_number(PlayerData.credit_card_balance),
			_format_number(PlayerData.job_salary),
			_format_number(PlayerData.get_total_asset_value()),
			_format_number(PlayerData.get_personal_net_worth())
		]
		cc_detail.add_theme_font_size_override("font_size", 24)
		cc_detail.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		cc_vbox.add_child(cc_detail)

		if PlayerData.credit_card_balance > 0:
			var min_pay: int = maxi(1, int(ceil(PlayerData.credit_card_balance * 0.10)))
			var pay_20: int = maxi(min_pay, int(ceil(PlayerData.credit_card_balance * 0.20)))
			var total_funds: int = PlayerData.get_available_funds()

			var pay_title := Label.new()
			pay_title.text = "💳 MANUAL USAGE REPAYMENT (Term Min: 10%% = $%s)" % _format_number(min_pay)
			pay_title.add_theme_font_size_override("font_size", 22)
			pay_title.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#22c55e"))
			cc_vbox.add_child(pay_title)

			var cc_pay_row := HBoxContainer.new()
			cc_pay_row.add_theme_constant_override("separation", 10)
			cc_vbox.add_child(cc_pay_row)

			var btn_pay_10 := _create_cyber_button("Pay 10%% ($%s)" % _format_number(min_pay), Color("#22c55e"), func():
				_execute_manual_cc_repay(min_pay)
			, true)
			btn_pay_10.disabled = total_funds < min_pay
			btn_pay_10.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_pay_10.set_meta("center_text", true)
			btn_pay_10.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_pay_10.tooltip_text = "Pay minimum locked 10%% usage payment ($%s)." % _format_number(min_pay)
			cc_pay_row.add_child(btn_pay_10)

			var btn_pay_20 := _create_cyber_button("Pay 20%% ($%s)" % _format_number(pay_20), Color("#10b981"), func():
				_execute_manual_cc_repay(pay_20)
			, true)
			btn_pay_20.disabled = total_funds < pay_20
			btn_pay_20.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_pay_20.set_meta("center_text", true)
			btn_pay_20.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_pay_20.tooltip_text = "Pay 20%% usage payment ($%s)." % _format_number(pay_20)
			cc_pay_row.add_child(btn_pay_20)

			var btn_pay_custom := _create_cyber_button("Input Amount", Color("#06b6d4"), func():
				_show_credit_card_custom_amount_modal(min_pay, PlayerData.credit_card_balance)
			, true)
			btn_pay_custom.disabled = total_funds < min_pay
			btn_pay_custom.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_pay_custom.set_meta("center_text", true)
			btn_pay_custom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_pay_custom.tooltip_text = "Enter custom payment amount (Min 10% up to 100%)."
			cc_pay_row.add_child(btn_pay_custom)
		else:
			var standing_lbl := Label.new()
			standing_lbl.text = "✅ Account in Good Standing • No Payments Due ($0 Usage)"
			standing_lbl.add_theme_font_size_override("font_size", 22)
			standing_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#22c55e"))
			cc_vbox.add_child(standing_lbl)

			var btn_req_limit := _create_cyber_button("🚀 Request Higher Credit Limit", Color("#38bdf8"), _request_credit_limit_increase, true)
			btn_req_limit.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_req_limit.set_meta("center_text", true)
			btn_req_limit.tooltip_text = "Request dynamic limit recalculation based on your updated allowance and personal assets."
			cc_vbox.add_child(btn_req_limit)

		var cc_sub_row := HBoxContainer.new()
		cc_sub_row.add_theme_constant_override("separation", 10)
		cc_vbox.add_child(cc_sub_row)

		if PlayerData.credit_card_tier.to_lower() != "platinum":
			var btn_upgrade := _create_cyber_button("Upgrade Card Tier", Color("#a855f7"), _show_credit_card_application, true)
			btn_upgrade.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_upgrade.set_meta("center_text", true)
			btn_upgrade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cc_sub_row.add_child(btn_upgrade)

		var btn_cancel_cc := _create_cyber_button("Cancel Card", Color("#ef4444"), _cancel_credit_card, true)
		btn_cancel_cc.disabled = PlayerData.credit_card_balance > 0
		btn_cancel_cc.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_cancel_cc.set_meta("center_text", true)
		btn_cancel_cc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_cancel_cc.tooltip_text = "Close your credit card account (Usage must be paid down to $0)."
		cc_sub_row.add_child(btn_cancel_cc)
	else:
		var cc_info := Label.new()
		cc_info.text = "• Status: No Active Credit Card\n• Approval Criteria: Zero debt, zero unpaid taxes, qualifying credit score & net worth."
		cc_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cc_info.add_theme_font_size_override("font_size", 22)
		cc_info.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		cc_vbox.add_child(cc_info)

		var btn_apply := _create_cyber_button("Apply for Credit Card", Color("#a855f7"), _show_credit_card_application, true)
		btn_apply.disabled = PlayerData.age < 18
		btn_apply.tooltip_text = "Must be at least 18 years old to apply." if btn_apply.disabled else "Open credit card application modal."
		btn_apply.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_apply.set_meta("center_text", true)
		cc_vbox.add_child(btn_apply)

	bank_list.add_child(cc_card)

	# 2c. Bank Loans Borrowing Card
	var loan_card := PanelContainer.new()
	loan_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#0284c7") if is_light else Color("#38bdf8")))
	var loan_margin := MarginContainer.new()
	loan_margin.add_theme_constant_override("margin_left", 28)
	loan_margin.add_theme_constant_override("margin_right", 28)
	loan_margin.add_theme_constant_override("margin_top", 24)
	loan_margin.add_theme_constant_override("margin_bottom", 24)
	loan_card.add_child(loan_margin)

	var loan_vbox := VBoxContainer.new()
	loan_vbox.add_theme_constant_override("separation", 12)
	loan_margin.add_child(loan_vbox)

	var loan_title := Label.new()
	loan_title.text = "🏦 BORROW FUNDS (INSTANT BANK LOANS)"
	loan_title.add_theme_font_size_override("font_size", 28)
	loan_title.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
	loan_vbox.add_child(loan_title)

	var loan_tiers := [
		["Borrow $1,000 (Micro Advance • 5% APR)", 1000, 0.05],
		["Borrow $5,000 (Personal Loan • 7% APR)", 5000, 0.07],
		["Borrow $25,000 (Major Commercial • 8% APR)", 25000, 0.08],
		["Borrow $100,000 (Executive Capital • 10% APR)", 100000, 0.10],
		["Borrow $250,000 (Corporate Enterprise • 12% APR)", 250000, 0.12],
		["Borrow $500,000 (Jumbo Syndicated • 14% APR)", 500000, 0.14]
	]

	for tier in loan_tiers:
		var btn := _create_cyber_button(tier[0], Color("#38bdf8"), func(): _borrow_loan(tier[1], tier[2]))
		btn.disabled = PlayerData.loan_balance > 0
		btn.tooltip_text = "Repay your current bank loan in full before taking another loan." if btn.disabled else "Only one bank loan can be active at a time."
		loan_vbox.add_child(btn)
	if PlayerData.loan_balance > 0:
		var locked_note := Label.new()
		locked_note.text = "Repay the remaining $%s bank loan to unlock borrowing." % _format_number(PlayerData.loan_balance)
		locked_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		locked_note.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		loan_vbox.add_child(locked_note)

	bank_list.add_child(loan_card)

	# 3. Debt Repayment Card
	var repay_card := PanelContainer.new()
	repay_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#15803d") if is_light else Color("#22c55e")))
	var repay_margin := MarginContainer.new()
	repay_margin.add_theme_constant_override("margin_left", 28)
	repay_margin.add_theme_constant_override("margin_right", 28)
	repay_margin.add_theme_constant_override("margin_top", 24)
	repay_margin.add_theme_constant_override("margin_bottom", 24)
	repay_card.add_child(repay_margin)

	var repay_vbox := VBoxContainer.new()
	repay_vbox.add_theme_constant_override("separation", 12)
	repay_margin.add_child(repay_vbox)

	var repay_title := Label.new()
	repay_title.text = "💸 REPAY OUTSTANDING DEBT & LOANS"
	repay_title.add_theme_font_size_override("font_size", 28)
	repay_title.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#22c55e"))
	repay_vbox.add_child(repay_title)
	var btn_pay_tax := _create_cyber_button("Pay Tax $%s" % _format_number(PlayerData.tax_debt), Color("#38bdf8"), _pay_tax, true)
	btn_pay_tax.name = "PayTaxButton"
	btn_pay_tax.disabled = PlayerData.tax_debt <= 0 or PlayerData.get_available_funds() < PlayerData.tax_debt
	btn_pay_tax.tooltip_text = "Pay outstanding tax using cash and bank funds."
	btn_pay_tax.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_pay_tax.set_meta("center_text", true)
	repay_vbox.add_child(btn_pay_tax)
	var btn_custom := _create_cyber_button("Repay Loan — Enter Amount", Color("#22c55e"), _show_loan_repayment, true)
	btn_custom.name = "CustomLoanRepaymentButton"
	btn_custom.disabled = PlayerData.loan_balance <= 0 or PlayerData.get_available_funds() <= 0
	btn_custom.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_custom.set_meta("center_text", true)
	repay_vbox.add_child(btn_custom)

	var non_cc_debt: int = PlayerData.tax_debt + PlayerData.debt + PlayerData.loan_balance
	var btn_pay_1k := _create_cyber_button("Repay $1,000", Color("#22c55e"), func(): _repay_debt(1000), true)
	btn_pay_1k.disabled = PlayerData.get_available_funds() < 1000 or non_cc_debt <= 0
	btn_pay_1k.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_pay_1k.set_meta("center_text", true)
	repay_vbox.add_child(btn_pay_1k)

	var btn_pay_all := _create_cyber_button("Repay Full Debt ($%s)" % _format_number(non_cc_debt), Color("#22c55e"), func(): _repay_debt(non_cc_debt), true)
	btn_pay_all.disabled = PlayerData.get_available_funds() < non_cc_debt or non_cc_debt <= 0
	btn_pay_all.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_pay_all.set_meta("center_text", true)
	repay_vbox.add_child(btn_pay_all)

	if PlayerData.credit_card_balance > 0:
		var cc_note := Label.new()
		cc_note.text = "ℹ️ Note: Credit card usage ($%s) must be paid inside the Revolving Credit Card facility above." % _format_number(PlayerData.credit_card_balance)
		cc_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cc_note.add_theme_font_size_override("font_size", 18)
		cc_note.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		repay_vbox.add_child(cc_note)

	bank_list.add_child(repay_card)

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(bank_list)


func _borrow_loan(amount: int, interest_rate: float) -> void:
	if not PlayerData.take_bank_loan(amount, interest_rate):
		update_bank_panel()
		return
	add_life_event("You approved a $%s loan from First National Pixel Bank (Interest: %d%% APR)." % [
		_format_number(amount),
		int(interest_rate * 100)
	], "finance")
	update_ui()
	update_bank_panel()
	SaveManager.save_game()


func _show_loan_repayment() -> void:
	var modal := _create_cyber_modal("REPAY BANK LOAN", "Choose how much to repay. This payment goes directly toward your bank loan.", Color("#22c55e"))
	var summary := Label.new()
	summary.text = "Loan balance: $%s • Available funds: $%s" % [_format_number(PlayerData.loan_balance), _format_number(PlayerData.get_available_funds())]
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("#334155") if LifeLibrary.data.theme == "light" else Color("#e2e8f0"))
	summary.add_theme_font_size_override("font_size", 26)
	modal.list.add_child(summary)
	var amount := LineEdit.new()
	amount.name = "LoanRepaymentAmount"
	amount.placeholder_text = "Enter amount in whole dollars"
	amount.max_length = 15
	amount.custom_minimum_size.y = 80
	amount.virtual_keyboard_enabled = true
	amount.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount)
	get_node("OptionsMenu")._style_input(amount)
	MobileKeyboardManager.attach_to_input(amount, "How much would you like to repay? (Whole dollars)")
	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(amount, "⌨️ Type Custom Repayment Amount", "How much would you like to repay? (Whole dollars)", Color("#22c55e"))
	modal.list.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(amount, "How much would you like to repay? (Whole dollars)")
	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#b91c1c") if LifeLibrary.data.theme == "light" else Color("#fca5a5"))
	feedback.add_theme_font_size_override("font_size", 26)
	modal.list.add_child(feedback)
	var submit := _create_cyber_button("Repay Loan", Color("#22c55e"), func():
		var requested := _parse_loan_payment(amount.text)
		if requested <= 0 or requested > mini(PlayerData.get_available_funds(), PlayerData.loan_balance):
			feedback.text = "Enter a positive whole-dollar amount within your available funds and loan balance."
			return
		var paid := PlayerData.repay_bank_loan(requested)
		if paid <= 0:
			return
		add_life_event("You repaid $%s of your bank loan (Remaining Loan: $%s)." % [_format_number(paid), _format_number(PlayerData.loan_balance)], "finance")
		update_ui()
		update_bank_panel()
		SaveManager.save_game()
		preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)
	amount.text_changed.connect(func(value: String):
		var requested := _parse_loan_payment(value)
		submit.disabled = requested <= 0 or requested > mini(PlayerData.get_available_funds(), PlayerData.loan_balance)
		feedback.text = "Enter a positive whole-dollar amount within your available funds and loan balance." if submit.disabled and not value.is_empty() else ""
	)


static func _parse_loan_payment(value: String) -> int:
	var cleaned := value.strip_edges()
	if cleaned.is_empty() or cleaned.length() > 15:
		return 0
	for character in cleaned:
		if character < "0" or character > "9":
			return 0
	return cleaned.to_int()


func _pay_tax() -> void:
	var paid := PlayerData.pay_outstanding_tax()
	if paid <= 0:
		update_bank_panel()
		return
	add_life_event("You paid your outstanding tax of $%s." % _format_number(paid), "finance")
	update_ui()
	update_bank_panel()
	SaveManager.save_game()


func _repay_debt(amount: int) -> void:
	var total_debt: int = PlayerData.get_total_debt()
	if amount <= 0 or total_debt <= 0 or PlayerData.get_available_funds() <= 0:
		return

	var pay_amount: int = mini(amount, mini(PlayerData.get_available_funds(), total_debt))
	PlayerData.debit_funds(pay_amount)

	# Pay tax first, then other debt and loans; each balance is charged only once.
	var remaining_pay: int = pay_amount
	if PlayerData.tax_debt > 0:
		var paid_tax: int = mini(remaining_pay, PlayerData.tax_debt)
		PlayerData.tax_debt -= paid_tax
		remaining_pay -= paid_tax
	if PlayerData.debt > 0:
		var paid_other: int = mini(remaining_pay, PlayerData.debt)
		PlayerData.debt -= paid_other
		remaining_pay -= paid_other

	if remaining_pay > 0 and PlayerData.loan_balance > 0:
		var paid_loan: int = mini(remaining_pay, PlayerData.loan_balance)
		PlayerData.loan_balance -= paid_loan
		remaining_pay -= paid_loan

	PlayerData.modify_credit_score(mini(15, maxi(3, int(pay_amount / 1000))))

	add_life_event("You paid $%s towards your outstanding liabilities (Remaining Debt: $%s)." % [
		_format_number(pay_amount),
		_format_number(PlayerData.get_total_debt())
	], "finance")
	update_ui()
	update_bank_panel()
	SaveManager.save_game()


func _show_bank_transfer(deposit: bool) -> void:
	var verb := "Deposit" if deposit else "Withdraw"
	var modal := _create_cyber_modal(verb.to_upper() + " AMOUNT", "Choose an amount to transfer between cash and your bank account.", Color("#10b981"))
	var available: int = PlayerData.money if deposit else PlayerData.bank_savings
	var summary := Label.new()
	summary.text = "Available to %s: $%s" % [verb.to_lower(), _format_number(available)]
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("#334155") if LifeLibrary.data.theme == "light" else Color("#e2e8f0"))
	modal.list.add_child(summary)
	var amount := LineEdit.new()
	amount.name = "BankTransferAmount"
	amount.placeholder_text = "Enter amount in whole dollars"
	amount.max_length = 15
	amount.custom_minimum_size.y = 80
	amount.virtual_keyboard_enabled = true
	amount.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount)
	MobileKeyboardManager.attach_to_input(amount, verb + " amount (whole dollars)")
	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(amount, "⌨️ Type Custom %s Amount" % verb, verb + " amount (whole dollars)", Color("#10b981") if deposit else Color("#fbbf24"))
	modal.list.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(amount, verb + " amount (whole dollars)")
	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#b91c1c") if LifeLibrary.data.theme == "light" else Color("#fca5a5"))
	modal.list.add_child(feedback)
	var submit := _create_cyber_button(verb, Color("#10b981"), func():
		var requested := _parse_loan_payment(amount.text)
		var limit: int = PlayerData.money if deposit else PlayerData.bank_savings
		if requested <= 0 or requested > limit:
			feedback.text = "Enter a positive whole-dollar amount within your available balance."
			return
		if deposit:
			_deposit_money(requested)
		else:
			_withdraw_money(requested)
		preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)
	amount.text_changed.connect(func(value: String):
		var requested := _parse_loan_payment(value)
		var limit: int = PlayerData.money if deposit else PlayerData.bank_savings
		submit.disabled = requested <= 0 or requested > limit
		feedback.text = "Enter a positive whole-dollar amount within your available balance." if submit.disabled and not value.is_empty() else ""
	)


func _deposit_money(amount: int) -> void:
	if amount <= 0:
		return
	var actual := PlayerData.deposit_cash(amount)
	if actual <= 0:
		add_life_event("You do not have any cash on hand to deposit.", "finance")
		return
	add_life_event("You deposited $%s cash into your bank balance." % _format_number(actual), "finance")
	update_ui()
	update_bank_panel()
	SaveManager.save_game()


func _withdraw_money(amount: int) -> void:
	if amount <= 0:
		return
	var actual := PlayerData.withdraw_cash(amount)
	if actual <= 0:
		add_life_event("You do not have any funds in your bank balance to withdraw.", "finance")
		return
	add_life_event("You withdrew $%s from your bank balance into cash." % _format_number(actual), "finance")
	update_ui()
	update_bank_panel()
	SaveManager.save_game()


func _show_credit_card_application() -> void:
	var modal := _create_cyber_modal("CREDIT CARD APPLICATION", "Apply for a revolving credit line. Approval is strictly determined by zero debt, zero unpaid taxes, qualifying credit score and net worth.", Color("#38bdf8"))
	var is_light: bool = LifeLibrary.data.theme == "light"

	var app_info := PanelContainer.new()
	app_info.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var aim := MarginContainer.new()
	aim.add_theme_constant_override("margin_left", 20)
	aim.add_theme_constant_override("margin_right", 20)
	aim.add_theme_constant_override("margin_top", 16)
	aim.add_theme_constant_override("margin_bottom", 16)
	app_info.add_child(aim)
	var aiv := VBoxContainer.new()
	aiv.add_theme_constant_override("separation", 8)
	aim.add_child(aiv)

	var app_title := Label.new()
	app_title.text = "📋 APPLICANT FINANCIAL PROFILE"
	app_title.add_theme_font_size_override("font_size", 24)
	app_title.add_theme_color_override("font_color", Color("#38bdf8"))
	aiv.add_child(app_title)

	var app_stats := Label.new()
	app_stats.text = "• Age: %d (18+ required)\n• Credit Score: %d (%s)\n• Net Worth: $%s\n• Active Debt & Loans: $%s\n• Unpaid Taxes: $%s" % [
		PlayerData.age,
		PlayerData.credit_score,
		PlayerData.get_credit_rating(),
		_format_number(PlayerData.get_net_worth()),
		_format_number(PlayerData.debt + PlayerData.loan_balance + PlayerData.credit_card_balance),
		_format_number(PlayerData.tax_debt)
	]
	app_stats.add_theme_font_size_override("font_size", 22)
	app_stats.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f1f5f9"))
	aiv.add_child(app_stats)

	if PlayerData.get_total_debt() > 0:
		var debt_warn := Label.new()
		debt_warn.text = "⚠️ AUTOMATIC DECLINE: All credit card applications are immediately declined if you carry any active debt, unpaid taxes, or bank loans. Clear all debt to apply."
		debt_warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		debt_warn.add_theme_font_size_override("font_size", 20)
		debt_warn.add_theme_color_override("font_color", Color("#ef4444"))
		aiv.add_child(debt_warn)

	modal.list.add_child(app_info)

	var tiers := [
		{"tier": "Silver", "limit": 5000, "apr": 0.18, "score": 600, "nw": 5000, "color": Color("#94a3b8")},
		{"tier": "Gold", "limit": 25000, "apr": 0.15, "score": 700, "nw": 30000, "color": Color("#eab308")},
		{"tier": "Platinum", "limit": 100000, "apr": 0.12, "score": 780, "nw": 150000, "color": Color("#a855f7")}
	]

	for t in tiers:
		var card_p := PanelContainer.new()
		card_p.add_theme_stylebox_override("panel", load_style_box_cyber_card(t.color))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 14)
		cm.add_theme_constant_override("margin_bottom", 14)
		card_p.add_child(cm)
		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 6)
		cm.add_child(cv)

		var est_limit := PlayerData.calculate_dynamic_credit_limit(t.tier)
		var t_title := Label.new()
		t_title.text = "💳 %s CREDIT CARD — $%s DYNAMIC LIMIT" % [t.tier.to_upper(), _format_number(est_limit)]
		t_title.add_theme_font_size_override("font_size", 24)
		t_title.add_theme_color_override("font_color", t.color)
		cv.add_child(t_title)

		var t_desc := Label.new()
		t_desc.text = "APR: %d%% • Min Score: %d • Min Personal Net Worth: $%s • (Base Limit: $%s)" % [
			int(t.apr * 100),
			t.score,
			_format_number(t.nw),
			_format_number(t.limit)
		]
		t_desc.add_theme_font_size_override("font_size", 20)
		t_desc.add_theme_color_override("font_color", Color("#64748b") if is_light else Color("#cbd5e1"))
		cv.add_child(t_desc)

		var check: Dictionary = PlayerData.can_apply_credit_card(t.tier)
		var eligible: bool = bool(check.get("eligible", false))
		var is_current: bool = PlayerData.has_credit_card and PlayerData.credit_card_tier.to_lower() == t.tier.to_lower()

		if is_current:
			var curr_lbl := Label.new()
			curr_lbl.text = "✔ CURRENT ACTIVE CARD"
			curr_lbl.add_theme_font_size_override("font_size", 20)
			curr_lbl.add_theme_color_override("font_color", Color("#22c55e"))
			cv.add_child(curr_lbl)
		else:
			var btn_text := "Apply for %s Card" % t.tier
			var btn := _create_cyber_button(btn_text, t.color, func():
				if PlayerData.approve_credit_card(t.tier):
					add_life_event("🎉 CREDIT CARD APPROVED! You received the %s Credit Card ($%s Dynamic Limit • %d%% APR). Credit score boosted to %d!" % [
						t.tier,
						_format_number(PlayerData.credit_card_limit),
						int(t.apr * 100),
						PlayerData.credit_score
					], "finance")
					PlayerData.add_milestone("Approved for %s Credit Card ($%s Limit)." % [t.tier, _format_number(PlayerData.credit_card_limit)], PlayerData.age, "💳")
					update_ui()
					update_bank_panel()
					SaveManager.save_game()
					preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
			, true)
			btn.disabled = not eligible
			btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.set_meta("center_text", true)
			cv.add_child(btn)

			if not eligible:
				var reason_lbl := Label.new()
				reason_lbl.text = "❌ %s" % str(check.get("reason", "Ineligible"))
				reason_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				reason_lbl.add_theme_font_size_override("font_size", 19)
				reason_lbl.add_theme_color_override("font_color", Color("#ef4444"))
				cv.add_child(reason_lbl)

		modal.list.add_child(card_p)


func _show_credit_card_advance() -> void:
	if not PlayerData.has_credit_card or PlayerData.get_credit_card_available() <= 0:
		return
	var modal := _create_cyber_modal("CREDIT CARD ADVANCE", "Draw funds from your %s Credit Card into your bank balance." % PlayerData.credit_card_tier, Color("#f59e0b"))
	var summary := Label.new()
	summary.text = "Available Credit Limit: $%s • Current Card Balance: $%s" % [
		_format_number(PlayerData.get_credit_card_available()),
		_format_number(PlayerData.credit_card_balance)
	]
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("#334155") if LifeLibrary.data.theme == "light" else Color("#e2e8f0"))
	summary.add_theme_font_size_override("font_size", 26)
	modal.list.add_child(summary)

	var amount := LineEdit.new()
	amount.name = "CreditCardAdvanceAmount"
	amount.placeholder_text = "Enter amount in whole dollars"
	amount.max_length = 15
	amount.custom_minimum_size.y = 80
	amount.virtual_keyboard_enabled = true
	amount.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount)
	get_node("OptionsMenu")._style_input(amount)
	MobileKeyboardManager.attach_to_input(amount, "How much to draw from credit card? (Whole dollars)")

	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#ef4444"))
	feedback.add_theme_font_size_override("font_size", 24)
	modal.list.add_child(feedback)

	var submit := _create_cyber_button("Draw Credit Advance", Color("#f59e0b"), func():
		var requested := _parse_loan_payment(amount.text)
		if requested <= 0 or requested > PlayerData.get_credit_card_available():
			feedback.text = "Enter a positive amount within your available credit limit."
			return
		if PlayerData.draw_credit_card_advance(requested):
			add_life_event("💳 Credit Card Draw: You charged $%s to your %s Credit Card (New Balance: $%s, Available: $%s)." % [
				_format_number(requested),
				PlayerData.credit_card_tier,
				_format_number(PlayerData.credit_card_balance),
				_format_number(PlayerData.get_credit_card_available())
			], "finance")
			update_ui()
			update_bank_panel()
			SaveManager.save_game()
			preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)

	amount.text_changed.connect(func(value: String):
		var requested := _parse_loan_payment(value)
		submit.disabled = requested <= 0 or requested > PlayerData.get_credit_card_available()
		feedback.text = "Enter a positive amount within your available credit limit." if submit.disabled and not value.is_empty() else ""
	)


func _show_credit_card_repay_dialog() -> void:
	if not PlayerData.has_credit_card or PlayerData.credit_card_balance <= 0 or PlayerData.get_available_funds() <= 0:
		return
	var min_pay: int = maxi(1, int(ceil(PlayerData.credit_card_balance * 0.10)))
	_show_credit_card_custom_amount_modal(min_pay, PlayerData.credit_card_balance)


func _execute_manual_cc_repay(amount: int) -> void:
	if not PlayerData.has_credit_card or amount <= 0:
		return
	var min_pay: int = maxi(1, int(ceil(PlayerData.credit_card_balance * 0.10)))
	if amount < min_pay and PlayerData.credit_card_balance > 0:
		add_life_event("⚠️ Payment rejected: Minimum payment is locked at 10%% ($%s)." % _format_number(min_pay), "finance")
		return
	var paid := PlayerData.repay_credit_card(amount)
	if paid > 0:
		add_life_event("💳 CREDIT CARD PAYMENT: You manually paid $%s toward your credit card usage (Remaining Usage: $%s, Credit Score: %d)." % [
			_format_number(paid),
			_format_number(PlayerData.credit_card_balance),
			PlayerData.credit_score
		], "finance")
		update_ui()
		update_bank_panel()
		SaveManager.save_game()


func _show_credit_card_custom_amount_modal(min_pay: int, total_usage: int) -> void:
	if not PlayerData.has_credit_card or total_usage <= 0 or PlayerData.get_available_funds() <= 0:
		return
	var modal := _create_cyber_modal("INPUT REPAYMENT AMOUNT", "Specify your credit card usage repayment. Minimum payment is locked at 10%% ($%s) up to 100%% ($%s)." % [_format_number(min_pay), _format_number(total_usage)], Color("#06b6d4"))
	var summary := Label.new()
	summary.text = "Card Usage: $%s • Minimum Payment: $%s (10%% Locked) • Available Funds: $%s" % [
		_format_number(total_usage),
		_format_number(min_pay),
		_format_number(PlayerData.get_available_funds())
	]
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("#334155") if LifeLibrary.data.theme == "light" else Color("#e2e8f0"))
	summary.add_theme_font_size_override("font_size", 24)
	modal.list.add_child(summary)

	var quick_row := HBoxContainer.new()
	quick_row.add_theme_constant_override("separation", 8)
	modal.list.add_child(quick_row)

	var amount_input := LineEdit.new()
	amount_input.name = "CreditCardCustomRepayAmount"
	amount_input.placeholder_text = "Enter whole dollars ($%s to $%s)" % [_format_number(min_pay), _format_number(total_usage)]
	amount_input.max_length = 15
	amount_input.custom_minimum_size.y = 80
	amount_input.virtual_keyboard_enabled = true
	amount_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount_input)
	MobileKeyboardManager.attach_to_input(amount_input, "Repayment amount (Min 10%%: $%d)" % min_pay)
	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(amount_input, "⌨️ Type Custom Repayment Amount", "Repayment amount (Min 10%%: $%d)" % min_pay, Color("#06b6d4"))
	modal.list.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(amount_input, "Repayment amount (Min 10%%: $%d)" % min_pay)

	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#ef4444"))
	feedback.add_theme_font_size_override("font_size", 22)
	feedback.text = "Minimum payment is locked at 10%% ($%s)." % _format_number(min_pay)
	modal.list.add_child(feedback)

	var submit := _create_cyber_button("Submit Repayment", Color("#06b6d4"), func():
		var requested := _parse_loan_payment(amount_input.text)
		if requested < min_pay:
			feedback.text = "⚠️ Minimum payment is strictly locked at 10%% ($%s)." % _format_number(min_pay)
			return
		if requested > total_usage:
			feedback.text = "⚠️ Payment cannot exceed total usage ($%s)." % _format_number(total_usage)
			return
		if requested > PlayerData.get_available_funds():
			feedback.text = "⚠️ Insufficient funds. Available: $%s." % _format_number(PlayerData.get_available_funds())
			return
		_execute_manual_cc_repay(requested)
		preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)

	var validate_input := func(val_str: String):
		var val := _parse_loan_payment(val_str)
		if val <= 0 and val_str.is_empty():
			submit.disabled = true
			feedback.text = "Minimum payment is locked at 10%% ($%s)." % _format_number(min_pay)
			feedback.add_theme_color_override("font_color", Color("#94a3b8"))
		elif val < min_pay:
			submit.disabled = true
			feedback.text = "⚠️ Minimum payment is strictly locked at 10%% ($%s)." % _format_number(min_pay)
			feedback.add_theme_color_override("font_color", Color("#ef4444"))
		elif val > total_usage:
			submit.disabled = true
			feedback.text = "⚠️ Payment cannot exceed total usage ($%s)." % _format_number(total_usage)
			feedback.add_theme_color_override("font_color", Color("#ef4444"))
		elif val > PlayerData.get_available_funds():
			submit.disabled = true
			feedback.text = "⚠️ Insufficient funds. You have $%s available." % _format_number(PlayerData.get_available_funds())
			feedback.add_theme_color_override("font_color", Color("#ef4444"))
		else:
			submit.disabled = false
			submit.text = "Submit Payment ($%s)" % _format_number(val)
			feedback.text = "✅ Valid repayment: $%s (Usage remaining: $%s)." % [_format_number(val), _format_number(total_usage - val)]
			feedback.add_theme_color_override("font_color", Color("#22c55e"))

	amount_input.text_changed.connect(validate_input)

	# Quick preset buttons
	var presets := [
		{"label": "10%% Min ($%s)" % _format_number(min_pay), "val": min_pay},
		{"label": "20%% ($%s)" % _format_number(maxi(min_pay, int(ceil(total_usage * 0.20)))), "val": maxi(min_pay, int(ceil(total_usage * 0.20)))},
		{"label": "50%% ($%s)" % _format_number(maxi(min_pay, int(ceil(total_usage * 0.50)))), "val": maxi(min_pay, int(ceil(total_usage * 0.50)))},
		{"label": "100%% Full ($%s)" % _format_number(total_usage), "val": total_usage}
	]
	for p in presets:
		var p_btn := _create_cyber_button(p.label, Color("#06b6d4"), func():
			amount_input.text = str(p.val)
			validate_input.call(str(p.val))
		, true)
		p_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		p_btn.set_meta("center_text", true)
		p_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		p_btn.custom_minimum_size.y = 44
		p_btn.add_theme_font_size_override("font_size", 18)
		quick_row.add_child(p_btn)


func _request_credit_limit_increase() -> void:
	if not PlayerData.has_credit_card:
		return
	var res := PlayerData.request_credit_limit_increase()
	if bool(res.get("success", false)):
		add_life_event("🎉 CREDIT LIMIT INCREASE: %s" % str(res.get("message", "")), "finance")
		var modal := _create_cyber_modal("CREDIT LIMIT INCREASE APPROVED", str(res.get("message", "")), Color("#22c55e"))
		var ok_btn := _create_cyber_button("Accept New Limit", Color("#22c55e"), func():
			preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
		, true)
		ok_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		ok_btn.set_meta("center_text", true)
		modal.list.add_child(ok_btn)
	else:
		var modal := _create_cyber_modal("CREDIT LIMIT REVIEW", str(res.get("message", "")), Color("#eab308"))
		var ok_btn := _create_cyber_button("Understood", Color("#eab308"), func():
			preload("res://scripts/ui/panel_close.gd").dismiss(modal.overlay, true)
		, true)
		ok_btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		ok_btn.set_meta("center_text", true)
		modal.list.add_child(ok_btn)
	update_ui()
	update_bank_panel()
	SaveManager.save_game()


func _cancel_credit_card() -> void:
	if not PlayerData.has_credit_card or PlayerData.credit_card_balance > 0:
		return
	get_node("OptionsMenu").confirm("CANCEL CREDIT CARD", "Are you sure you want to cancel and close your %s Credit Card account?" % PlayerData.credit_card_tier, func():
		var tier_name := PlayerData.credit_card_tier
		if PlayerData.cancel_credit_card():
			add_life_event("You closed your %s Credit Card account." % tier_name, "finance")
			update_ui()
			update_bank_panel()
			SaveManager.save_game()
	)


func _relationship_status_text(val: int) -> String:
	if val >= 80:
		return "Warm & Loving (%d%%)" % val
	elif val >= 55:
		return "Good (%d%%)" % val
	elif val >= 30:
		return "Neutral (%d%%)" % val
	else:
		return "Strained (%d%%)" % val


func _setup_parent_action_row(vbox: VBoxContainer, parent_type: String) -> void:
	var row_name := parent_type.capitalize() + "ActionRow"

	# Immediately remove and queue_free ANY existing action rows for this parent
	for child in vbox.get_children():
		if child.name.begins_with(row_name):
			vbox.remove_child(child)
			child.queue_free()

	var is_mother := parent_type == "mother"
	var is_alive := PlayerData.mother_alive if is_mother else PlayerData.father_alive
	if not is_alive:
		return

	var row := GridContainer.new()
	row.name = row_name
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_theme_constant_override("h_separation", 12)
	row.add_theme_constant_override("v_separation", 10)

	var actions := []
	if PlayerData.age < 5:
		# Early childhood: infants and toddlers can ONLY spend time with parents
		# INFANTS SHOULD NOT BE ALLOWED TO ASK PARENTS FOR MONEY
		# INFANTS COULD ONLY SPEND TIME WITH PARENTS
		actions.append(["Spend Time", "spend_time", "#0284c7"])
	else:
		actions.append(["Spend Time", "spend_time", "#0284c7"])
		actions.append(["Compliment", "compliment", "#8b5cf6"])
		actions.append(["Ask Money", "ask_money", "#10b981"])

	# Age Gating: Infants and kids cannot pay for parents' medication (requires age >= 13)
	if PlayerData.age >= 13:
		actions.append(["🏥 Pay Meds ($800)", "pay_medication", "#ec4899"])

	# Doctor Occupation Special Perk: Care for parents' health with clinical checkup & vitamin shots
	# NOTE: Plastic surgery is STRICTLY PROHIBITED on parents per requirements
	if PlayerData.is_doctor():
		actions.append(["🩺 Doctor Checkup (Free)", "doctor_checkup", "#06b6d4"])
		actions.append(["💉 Vitamin Shot ($30)", "doctor_vitamin_shot", "#10b981"])

	row.columns = 2 if actions.size() > 1 else 1

	for act in actions:
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		btn.custom_minimum_size = Vector2(100, 52)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.add_theme_font_size_override("font_size", 20)
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

		var act_key: String = act[1]
		var is_used_this_year := false
		if act_key == "spend_time":
			if is_mother and PlayerData.last_mother_spend_time_age == PlayerData.age:
				is_used_this_year = true
			elif not is_mother and PlayerData.last_father_spend_time_age == PlayerData.age:
				is_used_this_year = true
		elif act_key == "compliment":
			if is_mother and PlayerData.last_mother_compliment_age == PlayerData.age:
				is_used_this_year = true
			elif not is_mother and PlayerData.last_father_compliment_age == PlayerData.age:
				is_used_this_year = true
		elif act_key == "ask_money":
			if is_mother and PlayerData.last_mother_ask_money_age == PlayerData.age:
				is_used_this_year = true
			elif not is_mother and PlayerData.last_father_ask_money_age == PlayerData.age:
				is_used_this_year = true
		elif act_key == "pay_medication":
			if is_mother and PlayerData.last_mother_pay_meds_age == PlayerData.age:
				is_used_this_year = true
			elif not is_mother and PlayerData.last_father_pay_meds_age == PlayerData.age:
				is_used_this_year = true
		elif act_key == "doctor_checkup":
			if is_mother and PlayerData.last_mother_doctor_checkup_age == PlayerData.age:
				is_used_this_year = true
			elif not is_mother and PlayerData.last_father_doctor_checkup_age == PlayerData.age:
				is_used_this_year = true
		elif act_key == "doctor_vitamin_shot":
			if is_mother and PlayerData.last_mother_vitamin_shot_age == PlayerData.age:
				is_used_this_year = true
			elif not is_mother and PlayerData.last_father_vitamin_shot_age == PlayerData.age:
				is_used_this_year = true

		var col := Color(act[2])
		var is_light: bool = LifeLibrary.data.theme == "light"
		btn.set_meta("reference_part", true)
		btn.set_meta("market_button", true)

		if is_used_this_year:
			btn.text = act[0] + " (Used)"
			btn.disabled = true
			btn.tooltip_text = "Already used with your %s this year. Available again next year." % ("mother" if is_mother else "father")
			var disabled_sb := StyleBoxFlat.new()
			disabled_sb.bg_color = Color("#94a3b8" if is_light else "#334155")
			disabled_sb.border_color = Color("#cbd5e1" if is_light else "#475569")
			disabled_sb.set_border_width_all(2)
			disabled_sb.set_corner_radius_all(10)
			disabled_sb.content_margin_left = 12
			disabled_sb.content_margin_right = 12
			disabled_sb.content_margin_top = 8
			disabled_sb.content_margin_bottom = 8
			btn.add_theme_stylebox_override("disabled", disabled_sb)
			btn.add_theme_stylebox_override("normal", disabled_sb)
			btn.add_theme_color_override("font_disabled_color", Color("#e2e8f0" if is_light else "#64748b"))
		else:
			btn.text = act[0]
			var normal_sb := StyleBoxFlat.new()
			normal_sb.bg_color = col.darkened(0.18) if is_light else col.darkened(0.42)
			normal_sb.border_color = col.lightened(0.2)
			normal_sb.set_border_width_all(2)
			normal_sb.set_corner_radius_all(10)
			normal_sb.shadow_color = Color(0, 0, 0, 0.28)
			normal_sb.shadow_size = 4
			normal_sb.shadow_offset = Vector2(0, 3)
			normal_sb.content_margin_left = 12
			normal_sb.content_margin_right = 12
			normal_sb.content_margin_top = 8
			normal_sb.content_margin_bottom = 8
			btn.add_theme_stylebox_override("normal", normal_sb)

			var hover_sb := normal_sb.duplicate() as StyleBoxFlat
			hover_sb.bg_color = col.lightened(0.08) if is_light else col.darkened(0.2)
			hover_sb.border_color = Color.WHITE
			hover_sb.shadow_size = 6
			btn.add_theme_stylebox_override("hover", hover_sb)

			var pressed_sb := normal_sb.duplicate() as StyleBoxFlat
			pressed_sb.bg_color = col.darkened(0.4) if is_light else col.darkened(0.6)
			pressed_sb.shadow_size = 1
			pressed_sb.shadow_offset = Vector2(0, 1)
			btn.add_theme_stylebox_override("pressed", pressed_sb)

			btn.add_theme_color_override("font_color", Color.WHITE)
			btn.add_theme_color_override("font_hover_color", Color.WHITE)
			btn.add_theme_color_override("font_pressed_color", Color.WHITE)
			btn.add_theme_color_override("font_focus_color", Color.WHITE)
			btn.pressed.connect(func(): _interact_parent(parent_type, act_key))
		row.add_child(btn)

	vbox.add_child(row)



func _interact_parent(parent_type: String, action: String) -> void:
	var is_mother := parent_type == "mother"
	var parent_name := PlayerData.mother_name if is_mother else PlayerData.father_name
	var role := "mother" if is_mother else "father"

	match action:
		"spend_time":
			var already_used: bool = (is_mother and PlayerData.last_mother_spend_time_age == PlayerData.age) or (not is_mother and PlayerData.last_father_spend_time_age == PlayerData.age)
			if already_used:
				add_life_event("⏳ You have already spent quality time with your %s this year. Available again next year!" % role, "relationship")
				update_ui()
				return
			if is_mother:
				PlayerData.last_mother_spend_time_age = PlayerData.age
			else:
				PlayerData.last_father_spend_time_age = PlayerData.age

			var rel_gain := randi_range(6, 12)
			var happy_gain := randi_range(4, 9)
			if is_mother:
				PlayerData.mother_relationship = mini(100, PlayerData.mother_relationship + rel_gain)
			else:
				PlayerData.father_relationship = mini(100, PlayerData.father_relationship + rel_gain)
			PlayerData.happiness = mini(100, PlayerData.happiness + happy_gain)
			if PlayerData.age == 0:
				add_life_event("🍼 You cuddled warmly, cooed, and babbled in your %s's (%s) loving arms." % [role, parent_name], "relationship")
			elif PlayerData.age < 5:
				add_life_event("🧸 You giggled, babbled, and played peek-a-boo with your %s, %s." % [role, parent_name], "relationship")
			else:
				add_life_event("You spent quality time chatting and hanging out with your %s, %s." % [role, parent_name], "relationship")

		"compliment":
			if PlayerData.age < 5:
				add_life_event("🍼 Restricted: Infants and toddlers can only express affection by spending time.", "relationship")
				return
			var already_used: bool = (is_mother and PlayerData.last_mother_compliment_age == PlayerData.age) or (not is_mother and PlayerData.last_father_compliment_age == PlayerData.age)
			if already_used:
				add_life_event("⏳ You have already given your %s a heartfelt compliment this year. Available again next year!" % role, "relationship")
				update_ui()
				return
			if is_mother:
				PlayerData.last_mother_compliment_age = PlayerData.age
			else:
				PlayerData.last_father_compliment_age = PlayerData.age

			var rel_gain := randi_range(4, 8)
			if is_mother:
				PlayerData.mother_relationship = mini(100, PlayerData.mother_relationship + rel_gain)
			else:
				PlayerData.father_relationship = mini(100, PlayerData.father_relationship + rel_gain)
			PlayerData.karma = mini(100, PlayerData.karma + 2)
			PlayerData.happiness = mini(100, PlayerData.happiness + 2)
			add_life_event("You gave your %s, %s, a heartfelt compliment. They beamed with joy!" % [role, parent_name], "relationship")

		"ask_money":
			if PlayerData.age < 5:
				add_life_event("🍼 Restricted: Infants and toddlers cannot ask parents for money.", "relationship")
				return
			var already_used: bool = (is_mother and PlayerData.last_mother_ask_money_age == PlayerData.age) or (not is_mother and PlayerData.last_father_ask_money_age == PlayerData.age)
			if already_used:
				add_life_event("⏳ You have already asked your %s for money this year. Available again next year!" % role, "relationship")
				update_ui()
				return
			if is_mother:
				PlayerData.last_mother_ask_money_age = PlayerData.age
			else:
				PlayerData.last_father_ask_money_age = PlayerData.age

			var rel := PlayerData.mother_relationship if is_mother else PlayerData.father_relationship
			var wealth := PlayerData.family_wealth
			var decline_chance := 0.40
			var min_amt := 15
			var max_amt := 40

			match wealth:
				"poor":
					# Poor parents: high chance of declining (75%), if accepted: small money ($2-$12)
					decline_chance = 0.75
					min_amt = 2
					max_amt = 12
				"wealthy":
					# Wealthy parents: low chance of declining (15%), if accepted: high money ($50-$150)
					decline_chance = 0.15
					min_amt = 50
					max_amt = 150
				_: # middle_class
					# Medium rich / middle class parents: medium chance of declining (40%), if accepted: medium money ($15-$40)
					decline_chance = 0.40
					min_amt = 15
					max_amt = 40

			if rel < 35:
				decline_chance = minf(0.95, decline_chance + 0.35)

			var accepted: bool = randf() >= decline_chance
			if accepted:
				var amount := randi_range(min_amt, max_amt) if PlayerData.age < 18 else randi_range(int(min_amt * 1.5), int(max_amt * 1.5))
				PlayerData.money += amount
				PlayerData.happiness = mini(100, PlayerData.happiness + 3)
				if wealth == "poor":
					add_life_event("You asked your %s for money. They scraped together what little loose change they had and gave you $%d." % [role, amount], "relationship")
				elif wealth == "wealthy":
					add_life_event("You asked your %s for money. They generously handed you $%d without hesitation." % [role, amount], "relationship")
				else:
					add_life_event("You asked your %s, %s, for some pocket cash. They happily gave you $%d." % [role, parent_name, amount], "relationship")
			else:
				if is_mother:
					PlayerData.mother_relationship = maxi(0, PlayerData.mother_relationship - 2)
				else:
					PlayerData.father_relationship = maxi(0, PlayerData.father_relationship - 2)
				if wealth == "poor":
					add_life_event("You asked your %s for money, but they sighed with a heavy heart, explaining that finances are desperately tight and they cannot afford a single extra dollar." % role, "relationship")
				elif wealth == "wealthy":
					add_life_event("You asked your %s for money, but they declined, lecturing you that money doesn't grow on trees and you must learn financial responsibility." % role, "relationship")
				else:
					add_life_event("You asked your %s for money, but they reminded you to be responsible with your expenses and declined." % role, "relationship")

		"pay_medication":
			var already_used_meds: bool = (is_mother and PlayerData.last_mother_pay_meds_age == PlayerData.age) or (not is_mother and PlayerData.last_father_pay_meds_age == PlayerData.age)
			if already_used_meds:
				add_life_event("⏳ You have already paid for your %s's medication this year. Available again next year!" % role, "relationship")
				update_ui()
				return
			if PlayerData.get_available_funds() >= 800:
				if is_mother:
					PlayerData.last_mother_pay_meds_age = PlayerData.age
				else:
					PlayerData.last_father_pay_meds_age = PlayerData.age
				PlayerData.debit_funds(800)
				var new_health: int = 0
				if is_mother:
					PlayerData.mother_health = mini(100, PlayerData.mother_health + 20)
					PlayerData.mother_relationship = mini(100, PlayerData.mother_relationship + 10)
					new_health = PlayerData.mother_health
				else:
					PlayerData.father_health = mini(100, PlayerData.father_health + 20)
					PlayerData.father_relationship = mini(100, PlayerData.father_relationship + 10)
					new_health = PlayerData.father_health
				PlayerData.karma += 4
				add_life_event("You paid $800 for your %s's medical prescriptions. Their condition stabilized to %d%%." % [role, new_health], "relationship")
			else:
				add_life_event("You didn't have enough money ($800 required) to pay for your %s's medication." % role, "relationship")

		"doctor_checkup":
			var already_used_checkup: bool = (is_mother and PlayerData.last_mother_doctor_checkup_age == PlayerData.age) or (not is_mother and PlayerData.last_father_doctor_checkup_age == PlayerData.age)
			if already_used_checkup:
				add_life_event("⏳ You have already given your %s a clinical examination this year. Available again next year!" % role, "relationship")
				update_ui()
				return
			if is_mother:
				PlayerData.last_mother_doctor_checkup_age = PlayerData.age
			else:
				PlayerData.last_father_doctor_checkup_age = PlayerData.age
			var health_boost := 15
			var rel_boost := 10
			if is_mother:
				PlayerData.mother_health = mini(100, PlayerData.mother_health + health_boost)
				PlayerData.mother_relationship = mini(100, PlayerData.mother_relationship + rel_boost)
			else:
				PlayerData.father_health = mini(100, PlayerData.father_health + health_boost)
				PlayerData.father_relationship = mini(100, PlayerData.father_relationship + rel_boost)
			PlayerData.karma = mini(100, PlayerData.karma + 3)
			add_life_event("Applying your medical doctor credentials, you gave your %s a thorough clinical examination. Their vitals improved." % role, "relationship")

		"doctor_vitamin_shot":
			var already_used_shot: bool = (is_mother and PlayerData.last_mother_vitamin_shot_age == PlayerData.age) or (not is_mother and PlayerData.last_father_vitamin_shot_age == PlayerData.age)
			if already_used_shot:
				add_life_event("⏳ You have already administered a vitamin shot to your %s this year. Available again next year!" % role, "relationship")
				update_ui()
				return
			if PlayerData.get_available_funds() >= 30:
				if is_mother:
					PlayerData.last_mother_vitamin_shot_age = PlayerData.age
				else:
					PlayerData.last_father_vitamin_shot_age = PlayerData.age
				PlayerData.debit_funds(30)
				var health_boost := 10
				var rel_boost := 6
				if is_mother:
					PlayerData.mother_health = mini(100, PlayerData.mother_health + health_boost)
					PlayerData.mother_relationship = mini(100, PlayerData.mother_relationship + rel_boost)
				else:
					PlayerData.father_health = mini(100, PlayerData.father_health + health_boost)
					PlayerData.father_relationship = mini(100, PlayerData.father_relationship + rel_boost)
				PlayerData.karma = mini(100, PlayerData.karma + 2)
				add_life_event("You administered a clinical vitamin & nutrient infusion to your %s ($30 at-cost)." % role, "relationship")
			else:
				add_life_event("You didn't have enough funds ($30 wholesale) for the vitamin infusion.", "relationship")

	update_ui()
	SaveManager.save_game()


func update_relationships_panel() -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	for card in [mother_card, father_card]:
		if card != null:
			var m := card.get_node_or_null("Margin") as MarginContainer
			if m != null:
				m.add_theme_constant_override("margin_left", 32)
				m.add_theme_constant_override("margin_right", 32)
				m.add_theme_constant_override("margin_top", 20)
				m.add_theme_constant_override("margin_bottom", 20)

	var mom_age: int = PlayerData.mother_base_age + PlayerData.age
	var mom_vbox := mother_name_label.get_parent() as VBoxContainer

	mother_name_label.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color(0.396, 0.902, 1, 1))
	mother_job_label.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color(0.9, 0.94, 0.98, 1))

	if PlayerData.mother_alive:
		if PlayerData.mother_name != "":
			mother_name_label.text = "Mother: %s (Age %d)" % [PlayerData.mother_name, mom_age]
			mother_job_label.text = "Occupation: %s" % PlayerData.mother_job
		else:
			mother_name_label.text = "Mother: Unknown (Age %d)" % mom_age
			mother_job_label.text = "Occupation: Homemaker"
		mother_status_label.text = "Health: %d%%  •  Relationship: %d%% (%s)" % [
			PlayerData.mother_health,
			PlayerData.mother_relationship,
			_relationship_status_text(PlayerData.mother_relationship)
		]
		var mom_health_col: Color = (Color("#15803d") if is_light else Color("#22c55e")) if PlayerData.mother_health > 35 else (Color("#b45309") if is_light else Color("#f59e0b"))
		mother_status_label.add_theme_color_override("font_color", mom_health_col)
		if mom_vbox != null:
			var mom_debuff_lbl := mom_vbox.get_node_or_null("MotherDebuffLabel") as Label
			if PlayerData.mother_condition != "":
				if mom_debuff_lbl == null:
					mom_debuff_lbl = Label.new()
					mom_debuff_lbl.name = "MotherDebuffLabel"
					mom_debuff_lbl.set_meta("reference_part", true)
					mom_debuff_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
					mom_debuff_lbl.add_theme_font_size_override("font_size", 20)
					mom_vbox.add_child(mom_debuff_lbl)
					mom_vbox.move_child(mom_debuff_lbl, mother_status_label.get_index() + 1)
				mom_debuff_lbl.visible = true
				mom_debuff_lbl.text = "⚠️ Condition: %s" % PlayerData.mother_condition
				mom_debuff_lbl.add_theme_color_override("font_color", Color("#dc2626") if is_light else Color("#ef4444"))
			elif mom_debuff_lbl != null:
				mom_debuff_lbl.visible = false

			_setup_relationship_bar(mom_vbox, "MotherRelBar", PlayerData.mother_relationship)
			_setup_parent_action_row(mom_vbox, "mother")
	else:
		mother_name_label.text = "Mother: %s (Deceased)" % PlayerData.mother_name
		mother_job_label.text = "Occupation: In Memoriam"
		mother_status_label.text = "Status: Passed Away • Rest in Peace"
		mother_status_label.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		if mom_vbox != null:
			var mom_debuff_lbl := mom_vbox.get_node_or_null("MotherDebuffLabel")
			if mom_debuff_lbl != null:
				mom_debuff_lbl.queue_free()
			var old_bar := mom_vbox.get_node_or_null("MotherRelBar")
			if old_bar != null:
				old_bar.queue_free()
			var act_row := mom_vbox.get_node_or_null("MotherActionRow")
			if act_row != null:
				act_row.queue_free()

	mother_icon.texture = PortraitCatalog.get_portrait(mom_age, "FEMALE", PlayerData.mother_portrait_track, PlayerData.ethnicity)
	mother_icon.material = PortraitCatalog.cutout_material()
	mother_icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	# Father
	if PlayerData.father_name != "" and PlayerData.father_name != "Unknown":
		father_card.visible = true
		var dad_age: int = PlayerData.father_base_age + PlayerData.age
		var dad_vbox := father_name_label.get_parent() as VBoxContainer
		father_name_label.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color(0.396, 0.902, 1, 1))
		father_job_label.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color(0.9, 0.94, 0.98, 1))

		if PlayerData.father_alive:
			father_name_label.text = "Father: %s (Age %d)" % [PlayerData.father_name, dad_age]
			father_job_label.text = "Occupation: %s" % PlayerData.father_job
			father_status_label.text = "Health: %d%%  •  Relationship: %d%% (%s)" % [
				PlayerData.father_health,
				PlayerData.father_relationship,
				_relationship_status_text(PlayerData.father_relationship)
			]
			var dad_health_col: Color = (Color("#15803d") if is_light else Color("#22c55e")) if PlayerData.father_health > 35 else (Color("#b45309") if is_light else Color("#f59e0b"))
			father_status_label.add_theme_color_override("font_color", dad_health_col)
			if dad_vbox != null:
				var dad_debuff_lbl := dad_vbox.get_node_or_null("FatherDebuffLabel") as Label
				if PlayerData.father_condition != "":
					if dad_debuff_lbl == null:
						dad_debuff_lbl = Label.new()
						dad_debuff_lbl.name = "FatherDebuffLabel"
						dad_debuff_lbl.set_meta("reference_part", true)
						dad_debuff_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
						dad_debuff_lbl.add_theme_font_size_override("font_size", 20)
						dad_vbox.add_child(dad_debuff_lbl)
						dad_vbox.move_child(dad_debuff_lbl, father_status_label.get_index() + 1)
					dad_debuff_lbl.visible = true
					dad_debuff_lbl.text = "⚠️ Condition: %s" % PlayerData.father_condition
					dad_debuff_lbl.add_theme_color_override("font_color", Color("#dc2626") if is_light else Color("#ef4444"))
				elif dad_debuff_lbl != null:
					dad_debuff_lbl.visible = false

				_setup_relationship_bar(dad_vbox, "FatherRelBar", PlayerData.father_relationship)
				_setup_parent_action_row(dad_vbox, "father")
		else:
			father_name_label.text = "Father: %s (Deceased)" % PlayerData.father_name
			father_job_label.text = "Occupation: In Memoriam"
			father_status_label.text = "Status: Passed Away • Rest in Peace"
			father_status_label.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
			if dad_vbox != null:
				var dad_debuff_lbl := dad_vbox.get_node_or_null("FatherDebuffLabel")
				if dad_debuff_lbl != null:
					dad_debuff_lbl.queue_free()
				var old_bar := dad_vbox.get_node_or_null("FatherRelBar")
				if old_bar != null:
					old_bar.queue_free()
				var act_row := dad_vbox.get_node_or_null("FatherActionRow")
				if act_row != null:
					act_row.queue_free()

		father_icon.texture = PortraitCatalog.get_portrait(dad_age, "MALE", PlayerData.father_portrait_track, PlayerData.ethnicity)
		father_icon.material = PortraitCatalog.cutout_material()
		father_icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	else:
		father_card.visible = false

	# Partner / Romantic Relationship Card
	_setup_partner_card_ui()
	_setup_children_cards_ui()

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(relationships_panel)


func _setup_relationship_bar(vbox: VBoxContainer, bar_name: String, rel_val: int) -> ProgressBar:
	var bar: ProgressBar = null
	for child in vbox.get_children():
		if child is ProgressBar and child.name.begins_with(bar_name):
			if bar == null:
				bar = child
			else:
				vbox.remove_child(child)
				child.queue_free()

	if bar == null:
		bar = ProgressBar.new()
		bar.name = bar_name
		bar.min_value = 0
		bar.max_value = 100
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 14)
		vbox.add_child(bar)

	bar.value = clampi(rel_val, 0, 100)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("#0f172a")
	bg.border_color = Color("#334155")
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	if rel_val >= 70:
		fill.bg_color = Color("#10b981") # Emerald
	elif rel_val >= 40:
		fill.bg_color = Color("#f59e0b") # Amber
	else:
		fill.bg_color = Color("#ef4444") # Crimson
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)

	return bar


func _setup_partner_card_ui() -> void:
	var rel_list := get_node_or_null("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList") as VBoxContainer
	if rel_list == null:
		return

	# Immediately detach and free ANY existing PartnerCard or SinglePromptCard instances
	for child in rel_list.get_children():
		if child.name.begins_with("PartnerCard") or child.name.begins_with("SinglePromptCard"):
			rel_list.remove_child(child)
			child.queue_free()

	if PlayerData.has_partner():
		var p: Dictionary = PlayerData.partner
		NpcLifeProgress.ensure(p)
		var p_name: String = str(p.get("name", "Partner"))
		var p_status: String = str(p.get("status", "Partner"))
		var p_age: int = int(p.get("age", 20))
		var p_gender: String = str(p.get("gender", "FEMALE" if PlayerData.gender == "MALE" else "MALE"))
		var p_rel: int = int(p.get("relationship", 75))
		var p_variant: int = int(p.get("portrait_variant", 0))
		var p_hobbies: Array = p.get("hobbies", ["Music", "Reading", "Gaming"])
		var p_years: int = int(p.get("years_together", 0))

		var is_light: bool = LifeLibrary.data.theme == "light"
		var card := PanelContainer.new()
		card.name = "PartnerCard"
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#e11d48") if is_light else Color("#f43f5e")))

		var cm := MarginContainer.new()
		cm.name = "Margin"
		cm.add_theme_constant_override("margin_left", 48)
		cm.add_theme_constant_override("margin_top", 20)
		cm.add_theme_constant_override("margin_right", 32)
		cm.add_theme_constant_override("margin_bottom", 20)
		card.add_child(cm)

		var ch := HBoxContainer.new()
		ch.name = "HBox"
		ch.add_theme_constant_override("separation", 20)
		cm.add_child(ch)

		# Avatar
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(96, 96)
		icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.texture = PortraitCatalog.texture(p_age, p_gender, p_variant, str(p.get("ethnicity", "")))
		icon.material = PortraitCatalog.cutout_material()
		ch.add_child(icon)

		# Info VBox
		var cv := VBoxContainer.new()
		cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_theme_constant_override("separation", 6)
		ch.add_child(cv)

		var name_lbl := Label.new()
		name_lbl.text = "%s: %s (Age %d)" % [p_status, p_name, p_age]
		name_lbl.add_theme_font_size_override("font_size", 28)
		name_lbl.add_theme_color_override("font_color", Color("#e11d48") if is_light else Color("#f43f5e"))
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(name_lbl)

		var occ_lbl := Label.new()
		occ_lbl.text = NpcLifeProgress.get_occupation_display(p)
		occ_lbl.add_theme_font_size_override("font_size", 22)
		occ_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		occ_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(occ_lbl)

		var edu_lbl := Label.new()
		edu_lbl.text = NpcLifeProgress.get_education_display(p)
		edu_lbl.add_theme_font_size_override("font_size", 20)
		edu_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#cbd5e1"))
		edu_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(edu_lbl)

		var biz_str := NpcLifeProgress.get_business_display(p)
		if not biz_str.is_empty():
			var biz_lbl := Label.new()
			biz_lbl.text = biz_str
			biz_lbl.add_theme_font_size_override("font_size", 20)
			biz_lbl.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#fbbf24"))
			biz_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cv.add_child(biz_lbl)

		var wealth_lbl := Label.new()
		wealth_lbl.text = NpcLifeProgress.get_finances_display(p)
		wealth_lbl.add_theme_font_size_override("font_size", 20)
		wealth_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#34d399"))
		wealth_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(wealth_lbl)

		var hob_lbl := Label.new()
		hob_lbl.text = "Interests: %s" % ", ".join(p_hobbies)
		hob_lbl.add_theme_font_size_override("font_size", 20)
		hob_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#cbd5e1"))
		hob_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(hob_lbl)

		var stat_lbl := Label.new()
		var yr_str := "year" if p_years == 1 else "years"
		stat_lbl.text = "Relationship: %d%% (%s)  •  Together: %d %s" % [p_rel, _relationship_status_text(p_rel), p_years, yr_str]
		stat_lbl.add_theme_font_size_override("font_size", 22)
		stat_lbl.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
		stat_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(stat_lbl)

		# Visual Relationship Bar
		_setup_relationship_bar(cv, "PartnerRelBar", p_rel)

		# Action Row - 2 Columns ensures touch-friendly, comfortable buttons that never clip
		var act_row := GridContainer.new()
		act_row.columns = 2
		act_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		act_row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		act_row.add_theme_constant_override("h_separation", 12)
		act_row.add_theme_constant_override("v_separation", 10)

		var actions: Array = [
			["Spend Time", "spend_time", "#0284c7"],
			["Compliment", "compliment", "#8b5cf6"],
			["🎁 Choose Gift", "gift", "#10b981"]
		]

		if p_status in ["Boyfriend", "Girlfriend"]:
			actions.append(["💍 Propose", "propose", "#ec4899"])
		elif p_status in ["Fiancé", "Fiancée"]:
			actions.append(["💍 Marry", "marry", "#eab308"])
			actions.append(["Postpone", "postpone", "#8b5cf6"])
			RomanceRules.normalize(PlayerData)
			var engagement_note := Label.new()
			engagement_note.text = "Engaged at age %d • Wedding from age %d\nLonger postponements reduce your bond and both partners' happiness." % [int(p.engaged_age), int(p.engaged_age) + 1]
			engagement_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			engagement_note.add_theme_font_size_override("font_size", 20)
			cv.add_child(engagement_note)
		var partner_joy := Label.new()
		partner_joy.text = "Partner happiness: %d%%" % int(p.get("happiness", 50))
		partner_joy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		partner_joy.add_theme_font_size_override("font_size", 20)
		cv.add_child(partner_joy)

		var break_word := "Divorce" if p_status in ["Wife", "Husband"] else "Break Up"
		actions.append(["💔 " + break_word, "breakup", "#ef4444"])
		actions.append(["🍼 Have Baby", "have_baby", "#ec4899"])

		for act in actions:
			var btn := Button.new()
			var act_key: String = act[1]
			var is_locked := false
			var lock_tooltip := ""
			var button_title: String = act[0]

			if act_key == "spend_time":
				if PlayerData.last_partner_spend_time_age == PlayerData.age:
					is_locked = true
					button_title = "Spend Time (Used)"
					lock_tooltip = "Already spent time with your partner this year. Available again next year."
			elif act_key == "compliment":
				if PlayerData.last_partner_compliment_age == PlayerData.age:
					is_locked = true
					button_title = "Compliment (Used)"
					lock_tooltip = "Already gave a compliment this year. Available again next year."
			elif act_key == "gift":
				if PlayerData.last_partner_gift_age == PlayerData.age:
					is_locked = true
					button_title = "🎁 Gift (Used)"
					lock_tooltip = "Already gave a gift to your partner this year. Available again next year."
			elif act_key == "propose":
				if PlayerData.last_partner_propose_age == PlayerData.age:
					is_locked = true
					button_title = "💍 Propose (Locked)"
					lock_tooltip = "Already proposed this year. Available again next year."
			elif act_key == "breakup":
				if PlayerData.last_breakup_age == PlayerData.age:
					is_locked = true
					button_title = "💔 " + break_word + " (Locked)"
					lock_tooltip = "Already broke up/divorced this year. Available again next year."
			elif act_key == "have_baby":
				if p_status not in ["Wife", "Husband"]:
					is_locked = true
					button_title = "Have Baby (Marry First)"
					lock_tooltip = "Planned babies unlock after marriage."
				elif not PlayerData.pregnancy.is_empty():
					is_locked = true
					button_title = "Baby Expected"
					lock_tooltip = "A baby is already expected next year."
				elif PlayerData.last_baby_age != -1 and (PlayerData.age - PlayerData.last_baby_age < 2):
					var wait_years: int = 2 - (PlayerData.age - PlayerData.last_baby_age)
					is_locked = true
					button_title = "🍼 Have Baby (%d-Yr Wait)" % wait_years
					lock_tooltip = "You can only try to have a baby once every 2 years. Wait %d more year(s)." % wait_years
			elif act_key == "marry" and not RomanceRules.can_marry(PlayerData):
				is_locked = true
				lock_tooltip = "You must age up before marrying."

			btn.text = button_title
			btn.custom_minimum_size = Vector2(100, 52)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			btn.add_theme_font_size_override("font_size", 20)
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

			var col := Color(act[2])
			btn.set_meta("reference_part", true)
			btn.set_meta("market_button", true)

			if is_locked:
				btn.disabled = true
				btn.tooltip_text = lock_tooltip
				var disabled_sb := StyleBoxFlat.new()
				disabled_sb.bg_color = Color("#94a3b8" if is_light else "#334155")
				disabled_sb.border_color = Color("#cbd5e1" if is_light else "#475569")
				disabled_sb.set_border_width_all(2)
				disabled_sb.set_corner_radius_all(10)
				disabled_sb.content_margin_left = 12
				disabled_sb.content_margin_right = 12
				disabled_sb.content_margin_top = 8
				disabled_sb.content_margin_bottom = 8
				btn.add_theme_stylebox_override("disabled", disabled_sb)
				btn.add_theme_stylebox_override("normal", disabled_sb)
				btn.add_theme_color_override("font_disabled_color", Color("#e2e8f0" if is_light else "#64748b"))
			else:
				var normal_sb := StyleBoxFlat.new()
				normal_sb.bg_color = col.darkened(0.18) if is_light else col.darkened(0.42)
				normal_sb.border_color = col.lightened(0.2)
				normal_sb.set_border_width_all(2)
				normal_sb.set_corner_radius_all(10)
				normal_sb.shadow_color = Color(0, 0, 0, 0.28)
				normal_sb.shadow_size = 4
				normal_sb.shadow_offset = Vector2(0, 3)
				normal_sb.content_margin_left = 12
				normal_sb.content_margin_right = 12
				normal_sb.content_margin_top = 8
				normal_sb.content_margin_bottom = 8
				btn.add_theme_stylebox_override("normal", normal_sb)

				var hover_sb := normal_sb.duplicate() as StyleBoxFlat
				hover_sb.bg_color = col.lightened(0.08) if is_light else col.darkened(0.2)
				hover_sb.border_color = Color.WHITE
				hover_sb.shadow_size = 6
				btn.add_theme_stylebox_override("hover", hover_sb)

				var pressed_sb := normal_sb.duplicate() as StyleBoxFlat
				pressed_sb.bg_color = col.darkened(0.4) if is_light else col.darkened(0.6)
				pressed_sb.shadow_size = 1
				pressed_sb.shadow_offset = Vector2(0, 1)
				btn.add_theme_stylebox_override("pressed", pressed_sb)

				btn.add_theme_color_override("font_color", Color.WHITE)
				btn.add_theme_color_override("font_hover_color", Color.WHITE)
				btn.add_theme_color_override("font_pressed_color", Color.WHITE)
				btn.add_theme_color_override("font_focus_color", Color.WHITE)
				btn.pressed.connect(func(): _interact_partner(act_key))
			act_row.add_child(btn)

		cv.add_child(act_row)
		rel_list.add_child(card)

	else:
		# Single Status Card
		var is_light: bool = LifeLibrary.data.theme == "light"
		var single_card := PanelContainer.new()
		single_card.name = "SinglePromptCard"
		single_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#475569") if is_light else Color("#64748b")))

		var sm := MarginContainer.new()
		sm.add_theme_constant_override("margin_left", 20)
		sm.add_theme_constant_override("margin_top", 18)
		sm.add_theme_constant_override("margin_right", 20)
		sm.add_theme_constant_override("margin_bottom", 18)
		single_card.add_child(sm)

		var sv := VBoxContainer.new()
		sv.add_theme_constant_override("separation", 10)
		sm.add_child(sv)

		var stitle := Label.new()
		stitle.text = "💔 NO ROMANTIC PARTNER"
		stitle.add_theme_font_size_override("font_size", 24)
		stitle.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		sv.add_child(stitle)

		var sdesc := Label.new()
		sdesc.text = "You are currently single. Looking for companionship or love? Launch the Dating App in Activities to browse compatible profiles, chat, and ask potential partners out!"
		sdesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sdesc.add_theme_font_size_override("font_size", 20)
		sdesc.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
		sv.add_child(sdesc)

		var open_app_btn := _create_cyber_button("💘 Launch Dating App (Activities)", Color("#f43f5e"), func():
			_on_dating_app_item_pressed()
		)
		sv.add_child(open_app_btn)

		rel_list.add_child(single_card)


func _setup_children_cards_ui() -> void:
	var rel_list := get_node_or_null("RelationshipsPanel/RelMargin/RelContent/RelScroll/RelList") as VBoxContainer
	if rel_list == null:
		return

	for child in rel_list.get_children():
		if child.name.begins_with("ChildCard_") or child.name == "ChildrenHeaderCard":
			rel_list.remove_child(child)
			child.queue_free()

	if PlayerData.children.is_empty():
		return

	var is_light: bool = LifeLibrary.data.theme == "light"
	var header := PanelContainer.new()
	header.name = "ChildrenHeaderCard"
	header.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#db2777") if is_light else Color("#ec4899")))
	var hm := MarginContainer.new()
	hm.add_theme_constant_override("margin_left", 20)
	hm.add_theme_constant_override("margin_top", 12)
	hm.add_theme_constant_override("margin_right", 20)
	hm.add_theme_constant_override("margin_bottom", 12)
	header.add_child(hm)
	var hlbl := Label.new()
	hlbl.text = "👶 CHILDREN & LINEAGE (%d)" % PlayerData.children.size()
	hlbl.add_theme_font_size_override("font_size", 24)
	hlbl.add_theme_color_override("font_color", Color("#db2777") if is_light else Color("#f472b6"))
	hm.add_child(hlbl)
	rel_list.add_child(header)

	for i in range(PlayerData.children.size()):
		var c: Dictionary = PlayerData.children[i]
		NpcLifeProgress.ensure(c)
		var c_name: String = str(c.get("name", "Child"))
		var c_age: int = int(c.get("age", 0))
		var c_gender: String = str(c.get("gender", "MALE"))
		var c_rel: int = int(c.get("relationship", 80))
		var c_variant: int = int(c.get("portrait_track", c.get("portrait_variant", 0)))
		var c_eth: String = str(c.get("ethnicity", PlayerData.ethnicity))

		var card := PanelContainer.new()
		card.name = "ChildCard_%d" % i
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#db2777") if is_light else Color("#f472b6")))

		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 48)
		cm.add_theme_constant_override("margin_top", 18)
		cm.add_theme_constant_override("margin_right", 32)
		cm.add_theme_constant_override("margin_bottom", 18)
		card.add_child(cm)

		var ch := HBoxContainer.new()
		ch.add_theme_constant_override("separation", 20)
		cm.add_child(ch)

		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(96, 96)
		icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = PortraitCatalog.texture(c_age, c_gender, c_variant, c_eth)
		icon.material = PortraitCatalog.cutout_material()
		ch.add_child(icon)

		var cv := VBoxContainer.new()
		cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_theme_constant_override("separation", 6)
		ch.add_child(cv)

		var title := Label.new()
		title.text = "%s (%s, Age %d)" % [c_name, "Daughter" if c_gender == "FEMALE" else "Son", c_age]
		title.add_theme_font_size_override("font_size", 24)
		title.add_theme_color_override("font_color", Color("#db2777") if is_light else Color("#f472b6"))
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(title)

		var occ_lbl := Label.new()
		occ_lbl.text = NpcLifeProgress.get_occupation_display(c)
		occ_lbl.add_theme_font_size_override("font_size", 20)
		occ_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		occ_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(occ_lbl)

		var edu_lbl := Label.new()
		edu_lbl.text = NpcLifeProgress.get_education_display(c)
		edu_lbl.add_theme_font_size_override("font_size", 19)
		edu_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#cbd5e1"))
		edu_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(edu_lbl)

		var biz_str := NpcLifeProgress.get_business_display(c)
		if not biz_str.is_empty():
			var biz_lbl := Label.new()
			biz_lbl.text = biz_str
			biz_lbl.add_theme_font_size_override("font_size", 19)
			biz_lbl.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#fbbf24"))
			biz_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cv.add_child(biz_lbl)

		if c_age >= 18:
			var wealth_lbl := Label.new()
			wealth_lbl.text = NpcLifeProgress.get_finances_display(c)
			wealth_lbl.add_theme_font_size_override("font_size", 19)
			wealth_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#34d399"))
			wealth_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cv.add_child(wealth_lbl)

		_setup_relationship_bar(cv, "ChildRel_%d" % i, c_rel)

		var act_row := HBoxContainer.new()
		act_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		act_row.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		act_row.add_theme_constant_override("separation", 12)

		var child_spent: bool = int(c.get("last_spend_time_age", -1)) == PlayerData.age
		var child_gifted: bool = int(c.get("last_gift_age", -1)) == PlayerData.age

		var spend_text := "Spend Time (Used)" if child_spent else "Spend Time"
		var btn_spend := _create_cyber_button(spend_text, Color("#0284c7"), func():
			var idx = i
			var cur_c: Dictionary = PlayerData.children[idx]
			if int(cur_c.get("last_spend_time_age", -1)) == PlayerData.age:
				return
			cur_c["last_spend_time_age"] = PlayerData.age
			cur_c["relationship"] = mini(100, int(cur_c.get("relationship", 80)) + randi_range(8, 14))
			PlayerData.happiness = mini(100, PlayerData.happiness + randi_range(5, 8))
			add_life_event("You spent heartwarming quality time with your child %s!" % cur_c.name, "family")
			update_relationships_panel()
			update_ui()
		)
		btn_spend.custom_minimum_size = Vector2(100, 52)
		btn_spend.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_spend.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		btn_spend.add_theme_font_size_override("font_size", 20)
		btn_spend.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_spend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if child_spent:
			btn_spend.disabled = true
			btn_spend.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_spend.tooltip_text = "Already spent time with %s this year. Available again next year." % c_name
		act_row.add_child(btn_spend)

		var is_baby_or_toddler: bool = c_age < 5
		var gift_text := "🎁 Gift (Used)" if child_gifted else "🎁 Choose Gift"
		if is_baby_or_toddler:
			gift_text = "🎁 Gift (Age 5+)"

		var btn_gift := _create_cyber_button(gift_text, Color("#10b981"), func():
			var idx = i
			_show_child_gift_modal(idx)
		)
		btn_gift.custom_minimum_size = Vector2(100, 52)
		btn_gift.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_gift.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		btn_gift.add_theme_font_size_override("font_size", 20)
		btn_gift.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_gift.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		if is_baby_or_toddler:
			btn_gift.disabled = true
			btn_gift.modulate = Color(0.5, 0.5, 0.5, 0.6)
			btn_gift.tooltip_text = "%s is an infant/toddler. Gifts unlock when they turn into a Child (Age 5)." % c_name
		elif child_gifted:
			btn_gift.disabled = true
			btn_gift.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_gift.tooltip_text = "Already gave a gift to %s this year. Available again next year." % c_name
		act_row.add_child(btn_gift)

		cv.add_child(act_row)
		rel_list.add_child(card)


func _interact_partner(action: String) -> void:
	if not PlayerData.has_partner():
		return
	var p_name: String = PlayerData.get_partner_name()
	var p_status: String = PlayerData.get_partner_status()
	var p_rel: int = PlayerData.get_partner_relationship()

	match action:
		"spend_time":
			if PlayerData.last_partner_spend_time_age == PlayerData.age:
				add_life_event("⏳ You have already spent quality time with %s this year. Available again next year!" % p_name, "relationship")
				update_ui()
				return
			PlayerData.last_partner_spend_time_age = PlayerData.age
			var rel_gain := randi_range(7, 12)
			var happy_gain := randi_range(5, 9)
			PlayerData.set_partner_relationship(p_rel + rel_gain)
			PlayerData.happiness = mini(100, PlayerData.happiness + happy_gain)
			PlayerData.last_partner_interact_age = PlayerData.age
			add_life_event("You spent quality romantic time chatting and walking through the city with your %s, %s." % [
				p_status.to_lower(),
				p_name
			], "relationship")

		"compliment":
			if PlayerData.last_partner_compliment_age == PlayerData.age:
				add_life_event("⏳ You have already complimented %s this year. Available again next year!" % p_name, "relationship")
				update_ui()
				return
			PlayerData.last_partner_compliment_age = PlayerData.age
			var rel_gain := randi_range(5, 8)
			PlayerData.set_partner_relationship(p_rel + rel_gain)
			PlayerData.happiness = mini(100, PlayerData.happiness + 3)
			PlayerData.last_partner_interact_age = PlayerData.age
			add_life_event("You gave your %s, %s, a heartfelt compliment. They blushed with joy!" % [
				p_status.to_lower(),
				p_name
			], "relationship")

		"gift":
			_show_partner_gift_modal()
			return

		"propose":
			if PlayerData.last_partner_propose_age == PlayerData.age:
				add_life_event("💍 You have already proposed to %s this year. Give your relationship time before asking again next year!" % p_name, "relationship")
				update_ui()
				return
			_show_proposal_modal()
			return

		"marry":
			_show_wedding_modal()
			return
		"postpone":
			_show_postpone_modal()
			return

		"breakup":
			if PlayerData.last_breakup_age == PlayerData.age:
				add_life_event("💔 You have already gone through a breakup/divorce this year.", "relationship")
				update_ui()
				return
			_break_up_with_partner()
			return

		"have_baby":
			if PlayerData.last_baby_age != -1 and (PlayerData.age - PlayerData.last_baby_age < 2):
				var wait_years: int = 2 - (PlayerData.age - PlayerData.last_baby_age)
				add_life_event("🍼 You must wait %d more year(s) before having another baby (2-year interval required)." % wait_years, "relationship")
				update_ui()
				return
			if PlayerData.age < 18:
				add_life_event("You are too young to start a family.", "relationship")
				return
			if p_rel < 50:
				add_life_event("%s gently tells you they aren't ready to have a baby together yet. (Requires 50%+ Relationship)" % p_name, "relationship")
				return
			PlayerData.last_baby_age = PlayerData.age
			var baby_female: bool = (randf() < 0.5)
			var country_for_names: String = PlayerData.birthplace if PlayerData.birthplace != "" else "United States"
			var raw_name: String = NameCatalog.random_name(country_for_names, baby_female)
			var baby_name: String = raw_name.split(" ")[0]
			var _child_dict: Dictionary = PlayerData.add_player_child(baby_name, "FEMALE" if baby_female else "MALE", 0)
			PlayerData.happiness = mini(100, PlayerData.happiness + 25)
			PlayerData.set_partner_relationship(p_rel + 20)
			PlayerData.last_partner_interact_age = PlayerData.age
			PlayerData.add_milestone("Welcomed baby %s (%s) into the world with %s." % [
				baby_name,
				"daughter" if baby_female else "son",
				p_name
			], PlayerData.age, "👶")
			add_life_event("🍼 BABY BORN! You and %s welcomed a beautiful baby %s, %s, into the world!" % [
				p_name,
				"daughter" if baby_female else "son",
				baby_name
			], "family")
			update_relationships_panel()
			update_ui()
			SaveManager.save_game()
			return

	update_ui()
	SaveManager.save_game()


func _finish_romance_action(message: String, kind: String = "relationship") -> void:
	if message.is_empty():
		return
	if is_instance_valid(romance_action_modal_overlay):
		romance_action_modal_overlay.queue_free()
	romance_action_modal_overlay = null
	add_life_event(message, kind)
	update_ui()
	SaveManager.save_game()
	show_tab("timeline")


func _show_proposal_modal() -> void:
	if PlayerData.is_dead or PlayerData.age < 18 or not PlayerData.has_partner() or PlayerData.get_partner_status() not in ["Boyfriend", "Girlfriend"]:
		return
	var modal := _create_cyber_modal("💍 MARRIAGE PROPOSAL", "Choose one or more gifts for %s. More expensive gifts add more partner happiness, but acceptance is never guaranteed. Gifts are paid for even if the proposal is declined." % PlayerData.get_partner_name(), Color("#ec4899"))
	romance_action_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list
	var selected: Array = []
	var total := Label.new()
	total.add_theme_font_size_override("font_size", 26)
	total.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var confirm := _create_cyber_button("💍 Propose with Gifts", Color("#ec4899"), func():
		PlayerData.last_partner_propose_age = PlayerData.age
		var message := RomanceRules.propose(PlayerData, selected, randf())
		_finish_romance_action(message)
	)
	var refresh := func():
		var cost := 0
		var joy := 0
		for id in selected:
			cost += int(RomanceRules.GIFTS[id].cost)
			joy += int(RomanceRules.GIFTS[id].joy)
		total.text = "Total: $%s\nAvailable funds: $%s" % [_format_number(cost), _format_number(PlayerData.money + PlayerData.bank_savings)]
		confirm.disabled = selected.is_empty() or not PlayerData.can_afford(cost)
	for id in range(RomanceRules.GIFTS.size()):
		var gift: Dictionary = RomanceRules.GIFTS[id]
		var emoji: String = str(gift.get("emoji", "🎁"))
		var gift_text := "%s %s • $%s" % [emoji, gift.name, _format_number(int(gift.cost))]
		var button := _create_cyber_button(gift_text, Color("#ec4899"), func(): pass)
		button.toggle_mode = true
		var selected_style := StyleBoxFlat.new()
		selected_style.bg_color = Color("#302040")
		selected_style.border_color = Color("#ff8fc7")
		selected_style.set_border_width_all(3)
		selected_style.set_corner_radius_all(8)
		button.add_theme_stylebox_override("pressed", selected_style)
		button.add_theme_stylebox_override("hover_pressed", selected_style)
		button.toggled.connect(func(on: bool):
			button.text = ("[SELECTED] " if on else "") + gift_text
			if on:
				selected.append(id)
			else:
				selected.erase(id)
			if refresh.is_valid():
				refresh.call()
		)
		list.add_child(button)
	list.add_child(total)
	list.add_child(confirm)
	if refresh.is_valid():
		refresh.call()


func _apply_romance_icon(_button: Button, _icon_name: String) -> void:
	# Deprecated: Emoji glyphs in button labels now match the game's theme seamlessly.
	pass


func _show_partner_gift_modal() -> void:
	if PlayerData.is_dead or not PlayerData.has_partner():
		return
	var modal := _create_cyber_modal("🎁 A LITTLE SOMETHING", "Choose an everyday gift for %s. One gift per year; proposal gifts are separate." % PlayerData.get_partner_name(), Color("#34d399"))
	romance_action_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list
	for id in range(RelationshipExtras.GIFTS.size()):
		var gift: Dictionary = RelationshipExtras.GIFTS[id]
		var emoji: String = str(gift.get("emoji", "🎁"))
		var cost: int = int(gift.cost)
		var button := _create_cyber_button("%s %s • $%s" % [emoji, gift.name, _format_number(cost)], Color("#34d399"), func():
			_finish_romance_action(RelationshipExtras.give_gift(PlayerData, id))
		)
		button.disabled = PlayerData.last_partner_gift_age == PlayerData.age or not PlayerData.can_afford(cost)
		list.add_child(button)


func _show_child_gift_modal(child_index: int) -> void:
	if child_index < 0 or child_index >= PlayerData.children.size():
		return
	var c: Dictionary = PlayerData.children[child_index]
	var c_name: String = str(c.get("name", "Child"))
	var c_age: int = int(c.get("age", 0))

	if c_age < 5:
		add_life_event("%s is an infant/toddler and too young for gifts. Gifts unlock at Age 5 (Child stage)." % c_name, "family")
		return
	if int(c.get("last_gift_age", -1)) == PlayerData.age:
		add_life_event("You already gave %s a gift this year. Available again next year." % c_name, "family")
		return

	var modal := _create_cyber_modal("🎁 GIFTS FOR %s" % c_name.to_upper(), "Choose a thoughtful gift for %s (Age %d). Gifts strengthen your familial bond and bring great happiness." % [c_name, c_age], Color("#10b981"))
	romance_action_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	for id in range(RelationshipExtras.CHILD_GIFTS.size()):
		var gift: Dictionary = RelationshipExtras.CHILD_GIFTS[id]
		var emoji: String = str(gift.get("emoji", "🎁"))
		var cost: int = int(gift.cost)
		var min_age: int = int(gift.get("min_age", 5))
		var age_ok: bool = c_age >= min_age
		var can_afford: bool = PlayerData.can_afford(cost)

		var label_str: String
		if not age_ok:
			label_str = "%s %s • $%s (Unlocks Age %d)" % [emoji, gift.name, _format_number(cost), min_age]
		else:
			label_str = "%s %s • $%s" % [emoji, gift.name, _format_number(cost)]

		var btn := _create_cyber_button(label_str, Color("#10b981"), func():
			var msg := RelationshipExtras.give_child_gift(PlayerData, child_index, id)
			if not msg.is_empty():
				add_life_event(msg, "family")
				update_relationships_panel()
				update_ui()
				SaveManager.save_game()
				if is_instance_valid(modal.overlay):
					modal.overlay.queue_free()
		)
		btn.disabled = (not age_ok) or (not can_afford)
		if not age_ok:
			btn.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn.tooltip_text = "%s must be at least age %d to receive this gift." % [c_name, min_age]
		elif not can_afford:
			btn.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn.tooltip_text = "Insufficient funds (Total available: $%s)." % _format_number(PlayerData.money + PlayerData.bank_savings)
		list.add_child(btn)


func _show_wedding_modal() -> void:
	if not RomanceRules.can_marry(PlayerData):
		return
	var modal := _create_cyber_modal("💍 PLAN YOUR WEDDING", "Choose a venue, celebration style and guest list for your wedding with %s. Each choice changes the total price and ceremony ambiance." % PlayerData.get_partner_name(), Color("#38bdf8"))
	romance_action_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list
	var selected: Array[int] = [0, 0, 0]
	var total := Label.new()
	total.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	total.add_theme_font_size_override("font_size", 26)
	var confirm := _create_cyber_button("💍 Celebrate & Marry", Color("#38bdf8"), func():
		var p_name: String = PlayerData.get_partner_name()
		PlayerData.add_milestone("Married %s." % p_name, PlayerData.age, "💍")
		_finish_romance_action(RelationshipExtras.celebrate_wedding(PlayerData, selected[0], selected[1], selected[2]), "milestone")
	)
	var refresh := func():
		var quote := RelationshipExtras.wedding_quote(selected[0], selected[1], selected[2])
		total.text = "Total: $%s\nAvailable funds: $%s" % [_format_number(int(quote.cost)), _format_number(PlayerData.money + PlayerData.bank_savings)]
		confirm.disabled = not PlayerData.can_afford(int(quote.cost))
	var headings: Array[String] = ["VENUE", "CELEBRATION STYLE", "GUEST LIST"]
	var options: Array = [RelationshipExtras.VENUES, RelationshipExtras.STYLES, RelationshipExtras.GUESTS]
	for section in range(options.size()):
		var heading := Label.new()
		heading.text = headings[section]
		heading.add_theme_font_size_override("font_size", 28)
		heading.add_theme_color_override("font_color", Color("#64e6ff"))
		list.add_child(heading)
		var group := ButtonGroup.new()
		for index in range(options[section].size()):
			var option: Dictionary = options[section][index]
			var caption := "%s • $%s" % [option.name, _format_number(int(option.cost))]
			var button := _create_cyber_button(caption, Color("#38bdf8"), func(): pass)
			button.toggle_mode = true
			button.button_group = group
			var selected_style := load_style_box_cyber_card(Color("#64e6ff"))
			selected_style.bg_color = Color("#19354c")
			button.add_theme_stylebox_override("pressed", selected_style)
			button.add_theme_stylebox_override("hover_pressed", selected_style)
			button.toggled.connect(func(on: bool):
				button.text = ("[SELECTED] " if on else "") + caption
				if on:
					selected[section] = index
					if refresh.is_valid():
						refresh.call()
			)
			list.add_child(button)
			button.button_pressed = index == 0
	list.add_child(total)
	list.add_child(confirm)
	list.add_child(_create_cyber_button("Postpone wedding", Color("#8b5cf6"), func():
		if is_instance_valid(romance_action_modal_overlay):
			romance_action_modal_overlay.queue_free()
		_show_postpone_modal()
	))
	if refresh.is_valid():
		refresh.call()


func _show_postpone_modal() -> void:
	if not RomanceRules.engaged(PlayerData):
		return
	RomanceRules.normalize(PlayerData)
	var modal := _create_cyber_modal("POSTPONE WEDDING", "You decide when you are ready. Delay penalties grow each year and affect your relationship and emotional closeness.", Color("#8b5cf6"))
	romance_action_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list
	var already_delayed := int(PlayerData.partner.get("last_delay_age", -1)) >= PlayerData.age
	var waiting := PlayerData.age <= int(PlayerData.partner.engaged_age)
	if waiting or already_delayed:
		var note := Label.new()
		note.text = "You are already waiting this year. Revisit wedding plans after your next birthday."
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.add_theme_font_size_override("font_size", 26)
		list.add_child(note)
		return
	list.add_child(_create_cyber_button("Wait another year", Color("#8b5cf6"), func():
		_finish_romance_action(RomanceRules.delay_wedding(PlayerData, true))
	))


func _break_up_with_partner() -> void:
	if not PlayerData.has_partner():
		return
	if PlayerData.last_breakup_age == PlayerData.age:
		return
	PlayerData.last_breakup_age = PlayerData.age
	var p_name: String = PlayerData.get_partner_name()
	var p_status: String = PlayerData.get_partner_status()

	if p_status in ["Wife", "Husband"]:
		var settlement: int = int(PlayerData.bank_savings * 0.5)
		PlayerData.bank_savings -= settlement
		PlayerData.happiness = maxi(5, PlayerData.happiness - 25)
		add_life_event("⚖️ DIVORCE: You and %s officially finalized your divorce. Half of your bank savings ($%s) were divided in settlement." % [
			p_name,
			_format_number(settlement)
		], "relationship")
	else:
		PlayerData.happiness = maxi(5, PlayerData.happiness - 15)
		add_life_event("💔 BREAKUP: You and %s decided to end your relationship and part ways." % p_name, "relationship")

	PlayerData.ex_partners.append(PlayerData.partner)
	PlayerData.partner = {}
	update_ui()
	SaveManager.save_game()
	show_tab("timeline")


# --- DATING APP SYSTEM ---

func _close_dating_app_modal() -> void:
	if dating_app_modal_overlay != null and is_instance_valid(dating_app_modal_overlay):
		dating_app_modal_overlay.queue_free()
		dating_app_modal_overlay = null
	show_tab("timeline")


func _generate_dating_candidate() -> Dictionary:
	# STRICT REQUIREMENT: OPPOSITE GENDER ONLY
	var target_gender: String = "FEMALE" if PlayerData.gender == "MALE" else "MALE"

	var female_names := [
		"Maya Lin", "Elena Rostova", "Sophia Vance", "Chloe Sterling",
		"Aria Thorne", "Zara Chen", "Naomi Mercer", "Luna Zhao",
		"Jade Kowalski", "Kira Novak", "Amara Reyes", "Freya Lindholm",
		"Sienna Sinclair", "Ruby O'Connor", "Ivy Moreau"
	]
	var male_names := [
		"Kai Mercer", "Julian Vance", "Ethan Sterling", "Lucas Chen",
		"Noah Thorne", "Mateo Reyes", "Damian Novak", "Adrian Kowalski",
		"Caleb Sinclair", "Ezra Moreau", "Silas O'Connor", "Dorian Zhao",
		"Nico Lindholm", "Jax Blackwood", "Finn Takahashi"
	]

	var chosen_name: String = (female_names if target_gender == "FEMALE" else male_names).pick_random()
	var cand_age: int = clampi(PlayerData.age + randi_range(-3, 3), 18, 85)

	var occupations := [
		"Software Engineer", "Cyberneticist", "Graphic Designer", "Architect",
		"Emergency Room Nurse", "Chef & Restaurateur", "Music Producer",
		"Commercial Pilot", "University Lecturer", "Fashion Stylist",
		"Data Analyst", "Game Developer", "Biotech Researcher",
		"Attorney at Law", "Physical Therapist"
	]
	var educations := [
		"University Graduate (Computer Science)", "University Graduate (Business Management)",
		"Medical School Graduate", "Fine Arts Academy Graduate",
		"Master of Engineering", "Law School Graduate",
		"High School Graduate", "University Graduate (Cyber Security)"
	]
	var hobby_pool := [
		"Cyber Bouldering", "Retro Synthwave", "Neon Photography", "Gourmet Cooking",
		"Sci-Fi Literature", "Indie Gaming", "Scuba Diving", "Acoustic Guitar",
		"Astronomy & Stargazing", "Coffee Roasting", "Martial Arts", "Vintage Cars",
		"Botanical Gardening", "Drone Racing"
	]

	hobby_pool.shuffle()
	var cand_hobbies: Array = [hobby_pool[0], hobby_pool[1], hobby_pool[2]]

	var bios := [
		"Coffee snob by day, synth musician by night. Looking for genuine connections.",
		"Seeking someone to explore neon city rooftops and debate sci-fi lore with.",
		"Looking for real chemistry, spontaneous road trips, and hearty laughs.",
		"Passionate about art, tech, and deep late-night conversations.",
		"Fitness fanatic and food lover looking for my player two.",
		"Always curious, loves stargazing and finding hidden speakeasies in the city."
	]

	var cand_eth: String = PortraitCatalog.ETHNICITIES.pick_random()
	var cand_track: int = randi_range(0, 3)
	var custom := LifeLibrary.custom_candidate(target_gender)
	var cand_country: String = PlayerData.birthplace
	if not custom.is_empty() and randf() < 0.5:
		chosen_name = str(custom.name)
		cand_eth = str(custom.ethnicity)
		cand_track = int(custom.portrait_track)
		cand_country = str(custom.country)

	var cand := {
		"name": chosen_name,
		"nationality": cand_country,
		"gender": target_gender,
		"age": cand_age,
		"occupation": occupations.pick_random(),
		"education": educations.pick_random(),
		"hobbies": cand_hobbies,
		"bio": bios.pick_random(),
		"ethnicity": cand_eth,
		"portrait_track": cand_track,
		"portrait_variant": cand_track,
		"compatibility": randi_range(80, 98),
		"smarts": randi_range(55, 88),
		"health": randi_range(70, 90),
		"looks": randi_range(60, 90)
	}
	NpcLifeProgress.ensure(cand)
	return cand


func _show_dating_app_modal() -> void:
	if dating_app_modal_overlay != null and is_instance_valid(dating_app_modal_overlay):
		dating_app_modal_overlay.queue_free()

	var modal := _create_cyber_modal("💘 NEON DATE • SMART MATCHMAKING", "Browse verified singles in your metropolis • Swipe, match and connect", Color("#f43f5e"))
	dating_app_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	if current_dating_candidate.is_empty():
		current_dating_candidate = _generate_dating_candidate()

	_render_dating_candidate_ui(list)
	dating_app_modal_overlay.visible = true


func _render_dating_candidate_ui(list: VBoxContainer) -> void:
	# Clear previous cards in the modal list
	for child in list.get_children():
		child.queue_free()

	if PlayerData.has_partner():
		var warn_card := PanelContainer.new()
		warn_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var wm := MarginContainer.new()
		wm.add_theme_constant_override("margin_left", 20)
		wm.add_theme_constant_override("margin_top", 16)
		wm.add_theme_constant_override("margin_right", 20)
		wm.add_theme_constant_override("margin_bottom", 16)
		warn_card.add_child(wm)

		var wv := VBoxContainer.new()
		wv.add_theme_constant_override("separation", 8)
		wm.add_child(wv)

		var wtitle := Label.new()
		wtitle.text = "⚠️ CURRENTLY IN A RELATIONSHIP"
		wtitle.add_theme_font_size_override("font_size", 22)
		wtitle.add_theme_color_override("font_color", Color("#fbbf24"))
		wv.add_child(wtitle)

		var wdesc := Label.new()
		wdesc.text = "You are currently with %s (%s). In order to date someone new on Neon Date, you must first break up or divorce in the Relationships panel." % [
			PlayerData.get_partner_name(),
			PlayerData.get_partner_status()
		]
		wdesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		wdesc.add_theme_font_size_override("font_size", 20)
		wdesc.add_theme_color_override("font_color", Color("#f1f5f9"))
		wv.add_child(wdesc)

		list.add_child(warn_card)

	var cand: Dictionary = current_dating_candidate

	# Candidate Profile Card
	var profile_card := PanelContainer.new()
	profile_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f43f5e")))
	var pm := MarginContainer.new()
	pm.add_theme_constant_override("margin_left", 22)
	pm.add_theme_constant_override("margin_top", 20)
	pm.add_theme_constant_override("margin_right", 22)
	pm.add_theme_constant_override("margin_bottom", 20)
	profile_card.add_child(pm)

	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 14)
	pm.add_child(pv)

	# Avatar & Primary Info Row
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", 24)
	pv.add_child(ph)

	# Avatar TextureRect
	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(130, 130)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	avatar.texture = PortraitCatalog.texture(int(cand["age"]), str(cand["gender"]), int(cand.get("portrait_track", cand.get("portrait_variant", 0))), str(cand.get("ethnicity", "")))
	avatar.material = PortraitCatalog.cutout_material()
	ph.add_child(avatar)

	# Info Details
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 6)
	ph.add_child(info_vbox)

	var name_lbl := Label.new()
	name_lbl.text = "%s, %d" % [str(cand["name"]), int(cand["age"])]
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.add_theme_font_size_override("font_size", 34)
	name_lbl.add_theme_color_override("font_color", Color("#f43f5e"))
	info_vbox.add_child(name_lbl)
	if not str(cand.get("nationality", "")).is_empty():
		var nationality := Label.new()
		nationality.text = str(cand.nationality)
		nationality.add_theme_font_size_override("font_size", 22)
		nationality.add_theme_color_override("font_color", Color("#aee4f5"))
		info_vbox.add_child(nationality)

	var match_lbl := Label.new()
	match_lbl.text = "💖 %d%% Compatibility Match" % int(cand["compatibility"])
	match_lbl.add_theme_font_size_override("font_size", 22)
	match_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
	info_vbox.add_child(match_lbl)

	var job_lbl := Label.new()
	job_lbl.text = "💼 %s" % str(cand["occupation"])
	job_lbl.add_theme_font_size_override("font_size", 24)
	job_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
	info_vbox.add_child(job_lbl)

	var edu_lbl := Label.new()
	edu_lbl.text = "🎓 %s" % str(cand["education"])
	edu_lbl.add_theme_font_size_override("font_size", 20)
	edu_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	info_vbox.add_child(edu_lbl)

	var biz_str := NpcLifeProgress.get_business_display(cand)
	if not biz_str.is_empty():
		var biz_lbl := Label.new()
		biz_lbl.text = biz_str
		biz_lbl.add_theme_font_size_override("font_size", 20)
		biz_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		info_vbox.add_child(biz_lbl)

	# Hobbies Section
	var hob_title := Label.new()
	hob_title.text = "🎯 Hobbies & Interests:"
	hob_title.add_theme_font_size_override("font_size", 20)
	hob_title.add_theme_color_override("font_color", Color("#34d399"))
	pv.add_child(hob_title)

	var hobs: Array = cand["hobbies"]
	var hob_lbl := Label.new()
	hob_lbl.text = " •  %s  •  %s  •  %s" % [str(hobs[0]), str(hobs[1]), str(hobs[2])]
	hob_lbl.add_theme_font_size_override("font_size", 22)
	hob_lbl.add_theme_color_override("font_color", Color("#ffffff"))
	pv.add_child(hob_lbl)

	# Bio Quote Box
	var bio_box := PanelContainer.new()
	var bio_style := StyleBoxFlat.new()
	bio_style.bg_color = Color("#1e293b")
	bio_style.set_corner_radius_all(6)
	bio_box.add_theme_stylebox_override("panel", bio_style)

	var bm := MarginContainer.new()
	bm.add_theme_constant_override("margin_left", 14)
	bm.add_theme_constant_override("margin_top", 10)
	bm.add_theme_constant_override("margin_right", 14)
	bm.add_theme_constant_override("margin_bottom", 10)
	bio_box.add_child(bm)

	var bio_lbl := Label.new()
	bio_lbl.text = "\"%s\"" % str(cand["bio"])
	bio_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bio_lbl.add_theme_font_size_override("font_size", 20)
	bio_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	bm.add_child(bio_lbl)
	pv.add_child(bio_box)

	list.add_child(profile_card)

	# Action Buttons
	var has_dated_this_year: bool = (PlayerData.last_dating_app_age == PlayerData.age)
	if has_dated_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 20)
		lm.add_theme_constant_override("margin_right", 20)
		lm.add_theme_constant_override("margin_top", 14)
		lm.add_theme_constant_override("margin_bottom", 14)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL DATING SEARCH COMPLETED\nYou have already explored matchmaking singles for Age %d.\nGive romantic connections time to develop. Advance age (+1 Year) to swipe and match again!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 23)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

		var done_btn := _create_disabled_cyber_button("💘 Matchmaking Completed for Age %d" % PlayerData.age, "Advance age (+1 Year) to swipe again.")
		list.add_child(done_btn)
	else:
		var ask_out_btn := _create_cyber_button("💘 ASK OUT / MATCH\nShoot your shot and ask %s to become your partner" % str(cand["name"]), Color("#f43f5e"), func():
			_ask_out_dating_candidate(list)
		)
		list.add_child(ask_out_btn)

		var pass_btn := _create_cyber_button("⏭️ PASS / NEXT PROFILE\nBrowse the next available single in your area", Color("#64748b"), func():
			current_dating_candidate = _generate_dating_candidate()
			_render_dating_candidate_ui(list)
		)
		list.add_child(pass_btn)


func _ask_out_dating_candidate(list: VBoxContainer) -> void:
	if PlayerData.last_dating_app_age == PlayerData.age:
		return

	if PlayerData.has_partner():
		add_life_event("⚠️ You are already in a relationship with %s! Break up or divorce first before dating someone new." % PlayerData.get_partner_name(), "relationship")
		show_tab("timeline")
		_close_dating_app_modal()
		return

	if PlayerData.last_breakup_age == PlayerData.age:
		add_life_event("💔 Heartbreak Cooldown: You went through a breakup/divorce this year. Take time to heal before dating someone new! Available again next year.", "relationship")
		show_tab("timeline")
		_close_dating_app_modal()
		return

	PlayerData.last_dating_app_age = PlayerData.age

	var cand: Dictionary = current_dating_candidate
	var match_chance: int = 60 + int(PlayerData.looks * 0.25) + int(PlayerData.smarts * 0.15)
	var roll := randi_range(1, 100)

	if roll <= match_chance:
		var target_gender: String = str(cand["gender"])
		PlayerData.partner = cand.duplicate(true)
		PlayerData.partner["status"] = "Girlfriend" if target_gender == "FEMALE" else "Boyfriend"
		PlayerData.partner["relationship"] = randi_range(76, 88)
		PlayerData.partner["years_together"] = 0
		PlayerData.partner["is_alive"] = true
		PlayerData.last_partner_interact_age = PlayerData.age
		PlayerData.happiness = mini(100, PlayerData.happiness + 20)

		add_life_event("💘 DATING APP: You matched with %s (%s) on Neon Date and asked them out. With a glowing smile, they said YES! You are now officially dating your %s." % [
			cand["name"],
			cand["occupation"],
			PlayerData.partner["status"]
		], "relationship")

		current_dating_candidate = {}
		_close_dating_app_modal()
		update_ui()
		SaveManager.save_game()
		show_tab("timeline")
	else:
		add_life_event("💔 %s smiled politely: 'You seem very nice, but I'm looking for a different romantic connection right now. Best of luck on Neon Date!'" % cand["name"], "relationship")
		current_dating_candidate = _generate_dating_candidate()
		_render_dating_candidate_ui(list)


func _process_relationships_aging() -> void:
	_process_parents_aging()

	# Mother relationship decay & consequences
	if PlayerData.mother_alive and PlayerData.mother_name != "":
		if not BalanceRules.maintained_parent(PlayerData, "mother"):
			PlayerData.mother_relationship = maxi(0, PlayerData.mother_relationship - randi_range(2, 3))
		if PlayerData.mother_relationship < 25:
			PlayerData.happiness = maxi(5, PlayerData.happiness - 3)
			add_life_event("Your mother called feeling neglected and distant. Your bond is strained.", "relationship")
		elif PlayerData.mother_relationship >= 80:
			var gives_cash: bool = false
			var gift: int = 0
			if PlayerData.age >= 5:
				if PlayerData.family_wealth == "wealthy" and randf() < 0.25:
					gives_cash = true
					gift = randi_range(50, 150)
				elif PlayerData.family_wealth == "middle_class" and randf() < 0.15:
					gives_cash = true
					gift = randi_range(20, 50)

			if gives_cash:
				PlayerData.money += gift
				PlayerData.happiness = mini(100, PlayerData.happiness + 4)
				add_life_event("Your mother sent you a warm birthday card and a $%d gift!" % gift, "relationship")
			elif randf() < 0.20:
				PlayerData.happiness = mini(100, PlayerData.happiness + 2)
				add_life_event("Your mother sent you a loving birthday message wishing you a wonderful year.", "relationship")

	# Father relationship decay & consequences
	if PlayerData.father_alive and PlayerData.father_name != "" and PlayerData.father_name != "Unknown":
		if not BalanceRules.maintained_parent(PlayerData, "father"):
			PlayerData.father_relationship = maxi(0, PlayerData.father_relationship - randi_range(2, 3))
		if PlayerData.father_relationship < 25:
			PlayerData.happiness = maxi(5, PlayerData.happiness - 3)
			add_life_event("Your father feels out of touch with you. Family bond is strained.", "relationship")
		elif PlayerData.father_relationship >= 80:
			var gives_cash: bool = false
			var gift: int = 0
			if PlayerData.age >= 5:
				if PlayerData.family_wealth == "wealthy" and randf() < 0.25:
					gives_cash = true
					gift = randi_range(50, 150)
				elif PlayerData.family_wealth == "middle_class" and randf() < 0.15:
					gives_cash = true
					gift = randi_range(20, 50)

			if gives_cash:
				PlayerData.money += gift
				PlayerData.happiness = mini(100, PlayerData.happiness + 4)
				add_life_event("Your father sent you a supportive birthday card and a $%d gift!" % gift, "relationship")
			elif randf() < 0.20:
				PlayerData.happiness = mini(100, PlayerData.happiness + 2)
				add_life_event("Your father sent you a supportive birthday message wishing you success.", "relationship")

	# Partner aging, relationship decay & consequences
	if PlayerData.has_partner():
		var delay_message := RomanceRules.delay_wedding(PlayerData)
		if not delay_message.is_empty():
			add_life_event(delay_message, "relationship")
		PlayerData.partner["age"] = int(PlayerData.partner.get("age", 20)) + 1
		PlayerData.partner["years_together"] = int(PlayerData.partner.get("years_together", 0)) + 1
		NpcLifeProgress.ensure(PlayerData.partner)
		var p_name: String = PlayerData.get_partner_name()
		var p_status: String = PlayerData.get_partner_status()
		var p_rel: int = PlayerData.get_partner_relationship()

		if PlayerData.last_partner_interact_age < PlayerData.age - 1:
			p_rel = maxi(0, p_rel - randi_range(2, 4))
			PlayerData.set_partner_relationship(p_rel)

		if p_rel < 20:
			if p_status in ["Wife", "Husband"]:
				var settlement: int = int(PlayerData.bank_savings * 0.5)
				PlayerData.bank_savings -= settlement
				PlayerData.happiness = maxi(5, PlayerData.happiness - 30)
				add_life_event("⚖️ DIVORCE: %s couldn't stand the emotional neglect anymore and filed for divorce. Half of your bank savings ($%s) were awarded in settlement." % [
					p_name,
					_format_number(settlement)
				], "relationship")
			else:
				PlayerData.happiness = maxi(5, PlayerData.happiness - 20)
				add_life_event("💔 BREAKUP: %s felt completely neglected and distant over the past year. They packed their bags and broke up with you." % p_name, "relationship")
			PlayerData.ex_partners.append(PlayerData.partner)
			PlayerData.partner = {}
		elif p_rel >= 80 and delay_message.is_empty():
			var yrs: int = int(PlayerData.partner.get("years_together", 1))
			PlayerData.happiness = mini(100, PlayerData.happiness + 8)
			add_life_event("❤️ ANNIVERSARY: You and %s celebrated %d %s together with a romantic candlelight dinner!" % [
				p_name,
				yrs,
				"year" if yrs == 1 else "years"
			], "relationship")

	# Children aging & relationship decay
	for child in PlayerData.children:
		if child is Dictionary and bool(child.get("is_alive", true)):
			child["age"] = int(child.get("age", 0)) + 1
			NpcLifeProgress.ensure(child)
			var c_age: int = int(child["age"])
			var c_name: String = str(child.get("name", "Child"))
			if c_age == 18:
				add_life_event("🎓 Your child %s celebrated their 18th birthday and graduated into adulthood!" % c_name, "family")
			elif c_age == 22 and str(child.get("life_progress", {}).get("education_level", "")) == "University Graduate":
				var d_title: String = str(child.get("life_progress", {}).get("university_degree", "degree"))
				add_life_event("🎓 PROUD MOMENT: Your child %s graduated from university with a %s!" % [c_name, d_title], "family")
			var biz_list: Array = child.get("life_progress", {}).get("owned_businesses", [])
			if not biz_list.is_empty() and int(biz_list[0].get("founded_age", -1)) == c_age:
				var b_title: String = str(biz_list[0].get("name", "an enterprise"))
				add_life_event("🚀 FAMILY ENTERPRISE: Your child %s founded their own business '%s'!" % [c_name, b_title], "family")

			if maxi(int(child.get("last_spend_time_age", -1)), int(child.get("last_gift_age", -1))) < PlayerData.age - 1:
				child["relationship"] = clampi(int(child.get("relationship", 80)) - randi_range(1, 2), 0, 100)

	# Enforce buffs & debuffs constraints on active stats
	PlayerData.enforce_buffs_and_debuffs()


# Activity Item Handlers
func _on_jobs_item_pressed() -> void:
	_show_jobs_modal()


func _on_freelance_item_pressed() -> void:
	if PlayerData.age < 18:
		add_life_event("💻 Freelance client marketplaces require you to be an adult (Age 18+). Current age: %d." % PlayerData.age, "activity")
		show_tab("timeline")
		return
	_show_freelance_modal()


func _on_licensing_item_pressed() -> void:
	if PlayerData.age < 16:
		add_life_event("📜 State licensing boards require applicants to be at least 16 years of age (Current age: %d)." % PlayerData.age, "activity")
		show_tab("timeline")
		return
	_show_licensing_modal()


func _on_business_item_pressed() -> void:
	if PlayerData.age < 18:
		add_life_event("🏢 Commercial business incorporation requires legal majority (Age 18+). Current age: %d." % PlayerData.age, "activity")
		show_tab("timeline")
		return
	_show_business_modal()


func _on_education_item_pressed() -> void:
	_show_education_modal()


func _on_doctor_item_pressed() -> void:
	if PlayerData.age < 5:
		if PlayerData.age == 0:
			add_life_event("🍼 Infant healthcare is handled automatically by your parents.", "health")
		else:
			add_life_event("🧸 Toddler healthcare is handled automatically by your parents.", "health")
		show_tab("timeline")
		return
	_show_doctor_modal()


func _on_mind_body_item_pressed() -> void:
	if PlayerData.age < 5:
		if PlayerData.age == 0:
			add_life_event("🍼 You are an infant! Wellness activities unlock at age 5.", "activity")
		else:
			add_life_event("🧸 You are a toddler! Wellness activities unlock at age 5.", "activity")
		show_tab("timeline")
		return
	_show_mind_and_body_modal()


func _on_shopping_item_pressed() -> void:
	if PlayerData.age < 6:
		if PlayerData.age == 0:
			add_life_event("🍼 You are an infant! Shopping unlocks at age 6.", "finance")
		else:
			add_life_event("🧸 You are a toddler! Children cannot shop for vehicles or properties.", "finance")
		show_tab("timeline")
		return
	_show_shopping_modal()


func _on_social_media_item_pressed() -> void:
	if PlayerData.age < 13:
		add_life_event("🔒 Social Media Regulations: You must be at least 13 years old to create and manage social media accounts (Current age: %d)." % PlayerData.age, "lifestyle")
		show_tab("timeline")
		return
	_show_social_media_modal()


func _on_pet_adoption_item_pressed() -> void:
	if PlayerData.age < 6:
		add_life_event("🧸 You are too young to care for a pet on your own. Pet adoption unlocks at age 6!", "relationship")
		show_tab("timeline")
		return
	_show_pet_adoption_modal()


func _on_will_item_pressed() -> void:
	if PlayerData.age < 18:
		add_life_event("⚖️ Legal Requirement: Last Will & Testament estate planning unlocks at adulthood (Age 18+).", "finance")
		show_tab("timeline")
		return
	_show_will_modal()


func _on_gym_item_pressed() -> void:
	if PlayerData.age < 13:
		add_life_event("🏋️ Gym facilities and athletic clubs require an age of at least 13 (Current age: %d)." % PlayerData.age, "activity")
		show_tab("timeline")
		return
	_show_gym_modal()


func _on_lottery_item_pressed() -> void:
	if PlayerData.age < 21:
		add_life_event("🚫 Underage: You must be at least 21 years old to enter the casino and purchase lottery tickets (Current age: %d)." % PlayerData.age, "finance")
		show_tab("timeline")
		return
	_show_casino_modal()


func _on_street_hustle_item_pressed() -> void:
	if PlayerData.age < 17:
		add_life_event("🔒 Restricted: Underground street hustles and criminal syndicates unlock at age 17.", "crime")
		show_tab("timeline")
		return
	_show_crime_modal()


func _on_mind_item_pressed() -> void:
	if PlayerData.age < 5:
		if PlayerData.age == 0:
			add_life_event("🍼 You are an infant! Infants cannot meditate yet—tap the AGE button to grow up.", "activity")
		else:
			add_life_event("🧸 You are a toddler! Toddlers cannot meditate yet—tap the AGE button to grow up.", "activity")
		show_tab("timeline")
		return
	_show_meditation_modal()


func _on_dating_app_item_pressed() -> void:
	if PlayerData.age < 18:
		add_life_event("🔞 Underage: You must be at least 18 years old to register and use dating apps (Current age: %d)." % PlayerData.age, "activity")
		show_tab("timeline")
		return
	_show_dating_app_modal()


func _on_charity_item_pressed() -> void:
	if PlayerData.age < 6:
		if PlayerData.age == 0:
			add_life_event("🍼 You are an infant! Infants cannot participate in philanthropy yet—tap the AGE button to grow up.", "activity")
		else:
			add_life_event("🧸 You are too young! Children under age 6 cannot manage money or donate to charity yet.", "activity")
		show_tab("timeline")
		return
	_show_charity_modal()


func _show_career_ladder() -> void:
	if PlayerData.job_id.is_empty():
		return
	var job: Dictionary = JobManager.get_job_by_id(PlayerData.job_id)
	var modal := _create_cyber_modal("CAREER LADDER", "Promotions reward completed years in this job. Age requirements also apply. Resigning, being fired, or changing jobs restarts tenure. Prison years do not count.", Color("#38bdf8"))
	var list: VBoxContainer = modal.list
	var stages: Array = [{"title": job.get("title", PlayerData.job_title), "salary": job.get("salary", PlayerData.job_salary), "years": 0, "min_age": JobManager.minimum_age(job)}]
	stages.append_array(CareerProgression.paths().get(PlayerData.job_id, []))
	for index in range(stages.size()):
		var stage: Dictionary = stages[index]
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 27)
		label.add_theme_color_override("font_color", Color("#34d399") if index == int(PlayerData.career_progress.get("rank", 0)) else Color("#b8dcf5"))
		label.text = "%s%s\n%d years of service • Age %d+ • $%s/year\n" % ["CURRENT: " if index == int(PlayerData.career_progress.get("rank", 0)) else "", stage.title, int(stage.years), int(stage.min_age), _format_number(int(stage.salary))]
		list.add_child(label)


func _show_jobs_modal() -> void:
	if jobs_modal_overlay != null and is_instance_valid(jobs_modal_overlay):
		jobs_modal_overlay.queue_free()

	var modal := _create_cyber_modal("💼 CAREERS & OCCUPATION", "Browse Opportunities, Apply for Roles & Manage Employment", Color("#38bdf8"))
	jobs_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# Current Employment Status Card
	var cur_card := PanelContainer.new()
	cur_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var cur_m := MarginContainer.new()
	cur_m.add_theme_constant_override("margin_left", 20)
	cur_m.add_theme_constant_override("margin_right", 20)
	cur_m.add_theme_constant_override("margin_top", 16)
	cur_m.add_theme_constant_override("margin_bottom", 16)
	cur_card.add_child(cur_m)

	var cur_v := VBoxContainer.new()
	cur_v.add_theme_constant_override("separation", 8)
	cur_m.add_child(cur_v)

	var cur_title := Label.new()
	cur_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cur_title.add_theme_font_size_override("font_size", 24)
	cur_title.add_theme_color_override("font_color", Color("#38bdf8"))

	var cur_desc := Label.new()
	cur_desc.add_theme_font_size_override("font_size", 22)
	cur_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if PlayerData.job_title != "":
		cur_title.text = "CURRENT OCCUPATION"
		cur_desc.text = "%s  •  %s\n💰 Annual Salary: $%s / yr" % [PlayerData.job_title, PlayerData.job_company, _format_number(PlayerData.job_salary)]
		cur_desc.text += "\n" + CareerProgression.summary(PlayerData)
		cur_desc.add_theme_color_override("font_color", Color("#34d399"))
		cur_v.add_child(cur_title)
		cur_v.add_child(cur_desc)
		cur_v.add_child(_create_cyber_button("View career ladder", Color("#38bdf8"), func(): _show_career_ladder()))

		var ot_used: bool = PlayerData.last_overtime_age == PlayerData.age
		var ot_text := "⏱️ Work Overtime (Used)\nAnnual overtime limit reached for Age %d. Age up to work extra hours next year." % PlayerData.age if ot_used else "⏱️ Work Overtime\nPut in extra hours at %s. +$%s Bonus" % [PlayerData.job_company, _format_number(maxi(150, int(PlayerData.job_salary * 0.05)))]
		var btn_ot := _create_cyber_button(ot_text, Color("#38bdf8"), func():
			if PlayerData.last_overtime_age == PlayerData.age:
				return
			PlayerData.last_overtime_age = PlayerData.age
			var bonus := maxi(150, int(PlayerData.job_salary * 0.05))
			PlayerData.money += bonus
			PlayerData.happiness = maxi(5, PlayerData.happiness - 5)
			add_life_event("You worked late overtime at %s. Earned a hard-work bonus of $%s!" % [PlayerData.job_company, _format_number(bonus)], "job")
			update_ui()
			SaveManager.save_game()
			_show_jobs_modal()
		)
		if ot_used:
			btn_ot.disabled = true
			btn_ot.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_ot.tooltip_text = "Already worked overtime this year. Available again next year."
		cur_v.add_child(btn_ot)

		var btn_quit := _create_cyber_button("🚪 Resign / Quit Job", Color("#ef4444"), func():
			quit_job()
			_show_jobs_modal()
		)
		cur_v.add_child(btn_quit)
	elif PlayerData.age < 14:
		cur_title.text = "OCCUPATIONAL STATUS: STUDENT / MINOR (Age %d)" % PlayerData.age
		cur_desc.text = "👶 Child Labor Regulations: Formal employment opens at age 12-14 for odd jobs (Newspaper Courier, Babysitting, Lawn Care) and age 16 for standard careers. Childhood earnings and helper activities are available below:"
		cur_desc.add_theme_color_override("font_color", Color("#93c5fd"))
		cur_v.add_child(cur_title)
		cur_v.add_child(cur_desc)

		var gig_used: bool = PlayerData.last_childhood_gig_age == PlayerData.age

		if PlayerData.age < 4:
			var toy_text := "🍼 Toy Cash Register & Play Coins (Used)" if gig_used else "🍼 Toy Cash Register & Play Coins\nPlay with pretend cash and count plastic coins."
			var btn_toy := _create_cyber_button(toy_text, Color("#38bdf8"), func():
				if PlayerData.last_childhood_gig_age == PlayerData.age:
					return
				PlayerData.last_childhood_gig_age = PlayerData.age
				PlayerData.smarts = mini(100, PlayerData.smarts + 2)
				PlayerData.happiness = mini(100, PlayerData.happiness + 4)
				add_life_event("You had fun ringing up items on your toy cash register! 'Beep beep!' (+Smarts, +Happiness)", "activity")
				update_ui()
				SaveManager.save_game()
				_show_jobs_modal()
			)
			if gig_used:
				btn_toy.disabled = true
				btn_toy.modulate = Color(0.6, 0.6, 0.6, 0.65)
				btn_toy.tooltip_text = "Activity completed for Age %d (Age up to play again next year)." % PlayerData.age
			cur_v.add_child(btn_toy)
		elif PlayerData.age < 10:
			var chores_text := "🧹 Help Parents with Household Chores ($15 Cash) (Used)" if gig_used else "🧹 Help Parents with Household Chores ($15 Cash)\nClean your room and organize the kitchen with your family."
			var btn_chores := _create_cyber_button(chores_text, Color("#10b981"), func():
				if PlayerData.last_childhood_gig_age == PlayerData.age:
					return
				PlayerData.last_childhood_gig_age = PlayerData.age
				PlayerData.money += 15
				PlayerData.happiness = mini(100, PlayerData.happiness + 3)
				if PlayerData.mother_relationship > 0:
					PlayerData.mother_relationship = mini(100, PlayerData.mother_relationship + 5)
				if PlayerData.father_relationship > 0:
					PlayerData.father_relationship = mini(100, PlayerData.father_relationship + 5)
				add_life_event("You helped your parents vacuum and wash dishes. They proudly gave you $15 allowance!", "finance")
				update_ui()
				SaveManager.save_game()
				_show_jobs_modal()
			)
			if gig_used:
				btn_chores.disabled = true
				btn_chores.modulate = Color(0.6, 0.6, 0.6, 0.65)
				btn_chores.tooltip_text = "Completed for Age %d (Age up to do chores next year)." % PlayerData.age
			cur_v.add_child(btn_chores)

			var comics_text := "🎨 Draw & Sell Hand-Drawn Comics ($10 Cash) (Used)" if gig_used else "🎨 Draw & Sell Hand-Drawn Comics ($10 Cash)\nSketch mini comic strips and sell them to school friends."
			var btn_comics := _create_cyber_button(comics_text, Color("#f59e0b"), func():
				if PlayerData.last_childhood_gig_age == PlayerData.age:
					return
				PlayerData.last_childhood_gig_age = PlayerData.age
				PlayerData.money += 10
				PlayerData.smarts = mini(100, PlayerData.smarts + 3)
				PlayerData.happiness = mini(100, PlayerData.happiness + 4)
				add_life_event("You drew hilarious cartoon superhero comics and sold copies to schoolmates for $10!", "finance")
				update_ui()
				SaveManager.save_game()
				_show_jobs_modal()
			)
			if gig_used:
				btn_comics.disabled = true
				btn_comics.modulate = Color(0.6, 0.6, 0.6, 0.65)
				btn_comics.tooltip_text = "Completed for Age %d (Age up to sell comics next year)." % PlayerData.age
			cur_v.add_child(btn_comics)
		else:
			var lemonade_text := "🍋 Run a Neighborhood Lemonade Stand ($35 Cash) (Used)" if gig_used else "🍋 Run a Neighborhood Lemonade Stand ($35 Cash)\nMix fresh lemonade and sell cups on the sidewalk."
			var btn_lemonade := _create_cyber_button(lemonade_text, Color("#f59e0b"), func():
				if PlayerData.last_childhood_gig_age == PlayerData.age:
					return
				PlayerData.last_childhood_gig_age = PlayerData.age
				PlayerData.money += 35
				PlayerData.smarts = mini(100, PlayerData.smarts + 3)
				PlayerData.happiness = mini(100, PlayerData.happiness + 6)
				add_life_event("You set up a lemonade stand on a sunny afternoon and earned $35 in profit!", "finance")
				update_ui()
				SaveManager.save_game()
				_show_jobs_modal()
			)
			if gig_used:
				btn_lemonade.disabled = true
				btn_lemonade.modulate = Color(0.6, 0.6, 0.6, 0.65)
				btn_lemonade.tooltip_text = "Completed for Age %d (Age up to run stand next year)." % PlayerData.age
			cur_v.add_child(btn_lemonade)

			var mow_text := "🌱 Mow Lawns & Rake Leaves for Neighbors ($45 Cash) (Used)" if gig_used else "🌱 Mow Lawns & Rake Leaves for Neighbors ($45 Cash)\nOffer yard work services to neighbors on weekends."
			var btn_mow := _create_cyber_button(mow_text, Color("#10b981"), func():
				if PlayerData.last_childhood_gig_age == PlayerData.age:
					return
				PlayerData.last_childhood_gig_age = PlayerData.age
				PlayerData.money += 45
				PlayerData.health = mini(100, PlayerData.health + 4)
				PlayerData.karma += 3
				add_life_event("You spent the morning mowing lawns and raking leaves for neighbors. Earned $45!", "finance")
				update_ui()
				SaveManager.save_game()
				_show_jobs_modal()
			)
			if gig_used:
				btn_mow.disabled = true
				btn_mow.modulate = Color(0.6, 0.6, 0.6, 0.65)
				btn_mow.tooltip_text = "Completed for Age %d (Age up to mow lawns next year)." % PlayerData.age
			cur_v.add_child(btn_mow)
	else:
		cur_title.text = "CURRENT OCCUPATION"
		cur_desc.text = "Status: Currently Unemployed\nBrowse the open positions below and apply for jobs you qualify for!"
		cur_desc.add_theme_color_override("font_color", Color("#94a3b8"))
		cur_v.add_child(cur_title)
		cur_v.add_child(cur_desc)

	list.add_child(cur_card)

	# Career Hubs & Occupational Sectors
	var sec_header := VBoxContainer.new()
	sec_header.add_theme_constant_override("separation", 4)

	var sec_title := Label.new()
	sec_title.text = "🏢 CAREER SECTORS & OCCUPATIONAL HUBS"
	sec_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sec_title.add_theme_font_size_override("font_size", 24)
	sec_title.add_theme_color_override("font_color", Color("#38bdf8"))
	sec_header.add_child(sec_title)

	var sec_desc := Label.new()
	sec_desc.text = "Select an industry sector to view open positions, salary packages, and qualification requirements."
	sec_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sec_desc.add_theme_font_size_override("font_size", 20)
	sec_desc.add_theme_color_override("font_color", Color("#94a3b8"))
	sec_header.add_child(sec_desc)

	list.add_child(sec_header)

	var all_categories: Array = JobManager.get_categories()
	for cat in all_categories:
		if cat is not Dictionary:
			continue
		var cat_id: String = str(cat.get("id", ""))
		var cat_name: String = str(cat.get("name", "Category"))
		var cat_icon: String = str(cat.get("icon", "💼"))
		var cat_desc_text: String = str(cat.get("description", ""))
		var cat_color: Color = Color(cat.get("color", "#38bdf8"))
		var cat_jobs: Array = JobManager.get_jobs_in_category(cat_id)

		var btn_label := "%s %s (%d Positions)\n%s" % [cat_icon, cat_name, cat_jobs.size(), cat_desc_text]
		var cat_btn := _create_cyber_button(btn_label, cat_color, func():
			_show_job_category_modal(cat_id)
		)
		cat_btn.custom_minimum_size.y = 82
		cat_btn.add_theme_font_size_override("font_size", 24)
		list.add_child(cat_btn)

	jobs_modal_overlay.visible = true


func _show_job_category_modal(category_id: String) -> void:
	if job_category_modal_overlay != null and is_instance_valid(job_category_modal_overlay):
		job_category_modal_overlay.queue_free()

	if jobs_modal_overlay != null and is_instance_valid(jobs_modal_overlay):
		jobs_modal_overlay.queue_free()

	var cat: Dictionary = JobManager.get_category_by_id(category_id)
	var cat_name: String = str(cat.get("name", "Career Sector"))
	var cat_icon: String = str(cat.get("icon", "💼"))
	var cat_desc_text: String = str(cat.get("description", "Open employment opportunities."))
	var cat_color: Color = Color(cat.get("color", "#38bdf8"))

	var modal := _create_cyber_modal("%s %s" % [cat_icon, cat_name.to_upper()], cat_desc_text, cat_color)
	job_category_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var close_btn: Button = modal.get("close_btn")
	if close_btn != null:
		close_btn.pressed.connect(func():
			_show_jobs_modal()
		)

	# Back to Careers Hub Button
	var back_btn := _create_cyber_button("← Back to All Career Sectors", cat_color, func():
		if is_instance_valid(job_category_modal_overlay):
			job_category_modal_overlay.queue_free()
		_show_jobs_modal()
	)
	back_btn.custom_minimum_size.y = 70
	back_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(back_btn)

	# Jobs in this category
	var category_jobs: Array = JobManager.get_jobs_in_category(category_id)
	for job in category_jobs:
		if job is not Dictionary:
			continue

		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(cat_color))

		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 20)
		m.add_theme_constant_override("margin_right", 20)
		m.add_theme_constant_override("margin_top", 16)
		m.add_theme_constant_override("margin_bottom", 16)
		card.add_child(m)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		m.add_child(vbox)

		var title_lbl := Label.new()
		title_lbl.text = "%s  •  %s" % [job.get("title", "Job"), job.get("workplace", "Company")]
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.add_theme_font_size_override("font_size", 30)
		title_lbl.add_theme_color_override("font_color", cat_color)
		vbox.add_child(title_lbl)

		var salary_val: int = int(job.get("salary", 0))
		var salary_lbl := Label.new()
		salary_lbl.text = "💰 Salary: $%s / yr   •   Min Age: %d" % [_format_number(salary_val), JobManager.minimum_age(job)]
		salary_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		salary_lbl.add_theme_font_size_override("font_size", 26)
		salary_lbl.add_theme_color_override("font_color", Color("#34d399"))
		vbox.add_child(salary_lbl)

		var reqs: Dictionary = job.get("requirements", {})
		var req_parts: Array = []
		if reqs.has("min_grades"):
			req_parts.append("Min Grades: %d%%" % int(reqs["min_grades"]))
		if reqs.has("min_education"):
			req_parts.append("Degree: %s" % str(reqs["min_education"]))
		if reqs.has("required_major"):
			var m_title := JobManager.get_major_display_name(str(reqs["required_major"]))
			req_parts.append("Major: %s" % m_title)
		if reqs.has("required_license"):
			var lic_def := LicenseManager.get_license_by_id(str(reqs["required_license"]))
			req_parts.append("License: %s" % str(lic_def.get("name", reqs["required_license"])))
		if reqs.has("min_health"):
			req_parts.append("Min Health: %d" % int(reqs["min_health"]))
		if reqs.has("min_smarts"):
			req_parts.append("Min Smarts: %d" % int(reqs["min_smarts"]))
		if reqs.has("min_looks"):
			req_parts.append("Min Looks: %d" % int(reqs["min_looks"]))
		if reqs.has("min_karma"):
			req_parts.append("Min Karma: %d" % int(reqs["min_karma"]))
		if reqs.has("max_karma"):
			req_parts.append("Underworld Rep Required")

		if not req_parts.is_empty():
			var req_lbl := Label.new()
			req_lbl.text = "📋 " + " • ".join(req_parts)
			req_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			req_lbl.add_theme_font_size_override("font_size", 24)
			req_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
			vbox.add_child(req_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = str(job.get("description", ""))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 23)
		desc_lbl.add_theme_color_override("font_color", Color("#e2e8f0"))
		vbox.add_child(desc_lbl)

		var eval: Dictionary = JobManager.can_apply(job, PlayerData.age, PlayerData.get_stats(), {
			"grades": PlayerData.grades,
			"education_level": PlayerData.education_level,
			"major": PlayerData.university_major,
			"university_name": PlayerData.university_name,
			"degrees": PlayerData.degrees,
			"licenses": PlayerData.licenses
		})
		var is_qualified: bool = bool(eval.get("allowed", false))
		var is_current: bool = PlayerData.job_id == str(job.get("id", ""))

		var btn: Button
		if is_current:
			btn = _create_disabled_cyber_button("✓ CURRENT OCCUPATION", "Currently employed in this position.")
			btn.custom_minimum_size.y = 74
			btn.add_theme_font_size_override("font_size", 26)
			var cur_style := StyleBoxFlat.new()
			cur_style.bg_color = Color("#0e3a2f")
			cur_style.border_color = Color("#10b981")
			cur_style.set_border_width_all(2)
			cur_style.set_corner_radius_all(10)
			btn.add_theme_stylebox_override("disabled", cur_style)
			btn.add_theme_color_override("font_color", Color("#6ee7b7"))
		elif is_qualified:
			var jid: String = str(job.get("id", ""))
			btn = _create_cyber_button("APPLY FOR ROLE", Color("#10b981"), func():
				apply_for_job(jid)
				_show_job_category_modal(category_id)
			)
			btn.custom_minimum_size.y = 74
			btn.add_theme_font_size_override("font_size", 26)
		else:
			var lock_text := "🔒 LOCKED: Requires Age %d+ (Current: %d)" % [JobManager.minimum_age(job), PlayerData.age] if PlayerData.age < JobManager.minimum_age(job) else "🔒 LOCKED: " + str(eval.get("reason", "Not qualified"))
			btn = _create_disabled_cyber_button(lock_text, "")
			btn.custom_minimum_size.y = 74
			btn.add_theme_font_size_override("font_size", 26)

		vbox.add_child(btn)
		list.add_child(card)

	job_category_modal_overlay.visible = true


func _show_simple_popup(title_text: String, msg_text: String, border_color: Color = Color("#00f0ff")) -> void:
	var m: Dictionary = _create_cyber_modal(title_text, "", border_color)
	var lbl := Label.new()
	lbl.text = msg_text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	var list_node: VBoxContainer = m.get("list")
	list_node.add_child(lbl)
	var ov: Control = m.get("overlay")
	var close_btn := _create_cyber_button("Dismiss", border_color, func():
		if is_instance_valid(ov):
			ov.queue_free()
	)
	list_node.add_child(close_btn)
	ov.visible = true


# -----------------------------------------------------------------------------
# LICENSING & STATE CERTIFICATIONS SYSTEM
# -----------------------------------------------------------------------------
const ROAD_SIGN_QUIZ: Array[Dictionary] = [
	{
		"id": "sign_stop",
		"title": "STOP SIGN",
		"icon": "🛑",
		"sign_type": "REGULATORY MANDATE",
		"bg_color": "#b91c1c",
		"border_color": "#ffffff",
		"text_color": "#ffffff",
		"sign_text": "STOP",
		"meaning": "Come to a complete stop before the stop line, crosswalk, or intersection and yield right-of-way.",
		"distractors": [
			"Slow down to 5 mph and roll through if intersection is clear.",
			"Stop only if oncoming vehicles or pedestrians are actively present.",
			"Yield right-of-way but maintaining rolling speed is permitted when turning right."
		]
	},
	{
		"id": "sign_yield",
		"title": "YIELD / GIVE WAY SIGN",
		"icon": "🔻",
		"sign_type": "REGULATORY PRIORITY",
		"bg_color": "#dc2626",
		"border_color": "#ffffff",
		"text_color": "#ffffff",
		"sign_text": "YIELD",
		"meaning": "Slow down and give right-of-way to all vehicles and pedestrians on the cross street.",
		"distractors": [
			"Always make a complete 3-second stop before proceeding.",
			"Accelerate to merge before oncoming vehicles can reach your lane.",
			"Vehicles on the merging side street have priority over highway traffic."
		]
	},
	{
		"id": "sign_no_entry",
		"title": "DO NOT ENTER / NO ENTRY SIGN",
		"icon": "⛔",
		"sign_type": "REGULATORY PROHIBITION",
		"bg_color": "#dc2626",
		"border_color": "#ffffff",
		"text_color": "#ffffff",
		"sign_text": "DO NOT ENTER",
		"meaning": "Road is closed to all vehicular traffic from this direction (one-way or restricted street).",
		"distractors": [
			"Authorized delivery vehicles and motorcycles may enter at any time.",
			"Proceed with caution during non-peak daytime hours.",
			"Entry is allowed only when following emergency vehicles."
		]
	},
	{
		"id": "sign_slippery",
		"title": "SLIPPERY WHEN WET SIGN",
		"icon": "🌧️",
		"sign_type": "HAZARD WARNING",
		"bg_color": "#ca8a04",
		"border_color": "#000000",
		"text_color": "#000000",
		"sign_text": "SLIPPERY",
		"meaning": "Roadway becomes slick during wet conditions; reduce speed and increase braking distance.",
		"distractors": [
			"Tire chains are mandatory at all times on this stretch of road.",
			"Vehicle hydroplaning is impossible below 55 mph on this surface.",
			"Flooded road ahead; vehicles must turn around immediately."
		]
	},
	{
		"id": "sign_pedestrian",
		"title": "PEDESTRIAN & SCHOOL CROSSING",
		"icon": "🚸",
		"sign_type": "PEDESTRIAN SAFETY WARNING",
		"bg_color": "#ca8a04",
		"border_color": "#000000",
		"text_color": "#000000",
		"sign_text": "CROSSING",
		"meaning": "Pedestrians or schoolchildren may be crossing ahead; be prepared to slow down or stop.",
		"distractors": [
			"Pedestrians must yield to oncoming motor vehicles in this zone.",
			"Honk horn twice when approaching this area to alert pedestrians.",
			"Pedestrian crossing is only active after sunset."
		]
	},
	{
		"id": "sign_curve",
		"title": "SHARP CURVE / WINDING ROAD",
		"icon": "⚠️",
		"sign_type": "ROADWAY ALIGNMENT WARNING",
		"bg_color": "#ca8a04",
		"border_color": "#000000",
		"text_color": "#000000",
		"sign_text": "SHARP CURVE",
		"meaning": "Sharp bend or winding curve in roadway ahead; decelerate to safe advisory speed.",
		"distractors": [
			"Maintain speed to carry momentum safely through the turn.",
			"Passing and overtaking vehicles is encouraged on this bend.",
			"Lane splits into two separate one-way lanes ahead."
		]
	},
	{
		"id": "sign_roundabout",
		"title": "ROUNDABOUT / CIRCULAR INTERSECTION",
		"icon": "🔄",
		"sign_type": "INTERSECTION CONTROL",
		"bg_color": "#0284c7",
		"border_color": "#ffffff",
		"text_color": "#ffffff",
		"sign_text": "ROUNDABOUT",
		"meaning": "Approach a traffic circle; yield right-of-way to circulating traffic already in the ring.",
		"distractors": [
			"Vehicles entering the roundabout always have priority over circulating traffic.",
			"Come to a full stop before entering even if the roundabout is completely clear.",
			"Vehicles inside the circle must stop to allow waiting cars to enter."
		]
	},
	{
		"id": "sign_no_u_turn",
		"title": "NO U-TURN PERMITTED",
		"icon": "🚫",
		"sign_type": "REGULATORY PROHIBITION",
		"bg_color": "#ffffff",
		"border_color": "#dc2626",
		"text_color": "#dc2626",
		"sign_text": "NO U-TURN",
		"meaning": "Turning around 180 degrees to reverse direction of travel is strictly prohibited.",
		"distractors": [
			"U-turns are permitted if no vehicles are visible within 200 feet.",
			"Only commercial trucks are forbidden from executing a U-turn.",
			"U-turns are permitted during green arrow light phases only."
		]
	},
	{
		"id": "sign_bike_lane",
		"title": "BICYCLE ROUTE CROSSING",
		"icon": "🚴",
		"sign_type": "SHARED ROADWAY WARNING",
		"bg_color": "#ca8a04",
		"border_color": "#000000",
		"text_color": "#000000",
		"sign_text": "BIKE LANE",
		"meaning": "Bicycle pathway crosses or shares the roadway; check blind spots and maintain 3+ feet clearance.",
		"distractors": [
			"Motorcycles and cars may park in the bicycle lane during daytime.",
			"Cyclists are required to ride on the opposite side against vehicular traffic.",
			"Motorists have exclusive right-of-way over cyclists at all intersections."
		]
	},
	{
		"id": "sign_fuel",
		"title": "HIGHWAY SERVICE & FUEL STATION",
		"icon": "⛽",
		"sign_type": "MOTORIST SERVICE GUIDE",
		"bg_color": "#1d4ed8",
		"border_color": "#ffffff",
		"text_color": "#ffffff",
		"sign_text": "FUEL & EV",
		"meaning": "Motor vehicle service, fueling station, or EV fast charging is available at this exit.",
		"distractors": [
			"Hazardous fuel transport trucks have exclusive lane access ahead.",
			"Flammable materials are strictly prohibited beyond this point.",
			"Toll booth requiring exact fuel tax payment is located ahead."
		]
	},
	{
		"id": "sign_parking",
		"title": "AUTHORIZED PARKING ZONE",
		"icon": "🅿️",
		"sign_type": "PUBLIC GUIDE & PERMIT",
		"bg_color": "#1d4ed8",
		"border_color": "#ffffff",
		"text_color": "#ffffff",
		"sign_text": "PARKING",
		"meaning": "Designated public vehicle parking facility or street parking zone.",
		"distractors": [
			"Stopping and idling is prohibited in this entire municipal sector.",
			"Designated police emergency vehicle parking only.",
			"Paid vehicle permit is required for any pedestrian walking through."
		]
	},
	{
		"id": "sign_construction",
		"title": "ROAD WORK / CONSTRUCTION ZONE",
		"icon": "🚧",
		"sign_type": "CONSTRUCTION WARNING",
		"bg_color": "#ea580c",
		"border_color": "#000000",
		"text_color": "#000000",
		"sign_text": "ROAD WORK",
		"meaning": "Highway maintenance, road crew or heavy equipment ahead; obey flaggers and speed reductions.",
		"distractors": [
			"Highway is permanently closed; all traffic must take an alternate interstate.",
			"Speed limit increases to expedite clearing through the work zone.",
			"Fines for traffic violations are waived in construction corridors."
		]
	}
]


func _show_licensing_modal() -> void:
	if licensing_modal_overlay != null and is_instance_valid(licensing_modal_overlay):
		licensing_modal_overlay.queue_free()
	if license_category_modal_overlay != null and is_instance_valid(license_category_modal_overlay):
		license_category_modal_overlay.queue_free()

	var modal := _create_cyber_modal("📜 LICENSING & STATE CERTIFICATIONS", "State Boards, Trade Qualifications & Professional Permits", Color("#06b6d4"))
	licensing_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# Summary Card
	var info_card := PanelContainer.new()
	info_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#06b6d4")))
	var im := MarginContainer.new()
	im.add_theme_constant_override("margin_left", 20)
	im.add_theme_constant_override("margin_right", 20)
	im.add_theme_constant_override("margin_top", 16)
	im.add_theme_constant_override("margin_bottom", 16)
	info_card.add_child(im)

	var iv := VBoxContainer.new()
	iv.add_theme_constant_override("separation", 8)
	im.add_child(iv)

	var ih := Label.new()
	ih.text = "🏛️ OFFICIAL STATE LICENSING BUREAU"
	ih.add_theme_font_size_override("font_size", 26)
	ih.add_theme_color_override("font_color", Color("#22d3ee"))
	iv.add_child(ih)

	var idesc := Label.new()
	idesc.text = "Select a licensing sector below to review state qualifications, age criteria, and certification examinations.\n\nAvailable Funds: $%s Cash  •  $%s Bank Savings" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings)
	]
	idesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	idesc.add_theme_font_size_override("font_size", 22)
	idesc.add_theme_color_override("font_color", Color("#cbd5e1"))
	iv.add_child(idesc)
	list.add_child(info_card)

	# Dedicated Category Buttons
	var all_categories: Array = LicenseManager.get_categories()
	for cat in all_categories:
		if cat is not Dictionary:
			continue
		var cat_id: String = str(cat.get("id", ""))
		var cat_name: String = str(cat.get("name", "License Sector"))
		var cat_icon: String = str(cat.get("icon", "📜"))
		var cat_desc_text: String = str(cat.get("description", ""))
		var cat_color: Color = Color(cat.get("color", "#06b6d4"))
		var cat_licenses: Array = LicenseManager.get_licenses_in_category(cat_id)

		var btn_label := "%s %s (%d Certifications)\n%s" % [cat_icon, cat_name, cat_licenses.size(), cat_desc_text]
		var cat_btn := _create_cyber_button(btn_label, cat_color, func():
			_show_license_category_modal(cat_id)
		)
		cat_btn.custom_minimum_size.y = 82
		cat_btn.add_theme_font_size_override("font_size", 24)
		list.add_child(cat_btn)

	licensing_modal_overlay.visible = true


func _show_license_category_modal(category_id: String) -> void:
	if license_category_modal_overlay != null and is_instance_valid(license_category_modal_overlay):
		license_category_modal_overlay.queue_free()
	if licensing_modal_overlay != null and is_instance_valid(licensing_modal_overlay):
		licensing_modal_overlay.queue_free()

	var cat: Dictionary = LicenseManager.get_category_by_id(category_id)
	var cat_name: String = str(cat.get("name", "License Category"))
	var cat_icon: String = str(cat.get("icon", "📜"))
	var cat_desc_text: String = str(cat.get("description", "Certified qualifications and state licenses."))
	var cat_color: Color = Color(cat.get("color", "#06b6d4"))

	var modal := _create_cyber_modal("%s %s" % [cat_icon, cat_name.to_upper()], cat_desc_text, cat_color)
	license_category_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var close_btn: Button = modal.get("close_btn")
	if close_btn != null:
		close_btn.pressed.connect(func():
			_show_licensing_modal()
		)

	# Back button
	var back_btn := _create_cyber_button("← Back to All Licensing Sectors", cat_color, func():
		if is_instance_valid(license_category_modal_overlay):
			license_category_modal_overlay.queue_free()
		_show_licensing_modal()
	)
	back_btn.custom_minimum_size.y = 70
	back_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(back_btn)

	# Licenses in this category
	var category_lics: Array = LicenseManager.get_licenses_in_category(category_id)
	for lic in category_lics:
		if lic is not Dictionary:
			continue
		var lic_id: String = str(lic.get("id", ""))
		var lic_name: String = str(lic.get("name", ""))
		var lic_icon: String = str(lic.get("icon", "📜"))
		var fee: int = int(lic.get("fee", 0))
		var min_age: int = int(lic.get("min_age", 18))
		var unlocked: String = str(lic.get("unlocked_feature", ""))
		var desc: String = str(lic.get("description", ""))

		var card := PanelContainer.new()
		var is_certified: bool = PlayerData.has_license(lic_id)
		var theme_col: Color = Color("#10b981") if is_certified else cat_color
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(theme_col))

		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var header_row := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = "%s %s" % [lic_icon, lic_name]
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.add_theme_font_size_override("font_size", 24)
		title_lbl.add_theme_color_override("font_color", Color("#ffffff"))
		header_row.add_child(title_lbl)

		var fee_lbl := Label.new()
		fee_lbl.text = "$%s Fee" % _format_number(fee)
		fee_lbl.add_theme_font_size_override("font_size", 24)
		fee_lbl.add_theme_color_override("font_color", Color("#34d399") if is_certified else Color("#38bdf8"))
		header_row.add_child(fee_lbl)
		cv.add_child(header_row)

		var meta_lbl := Label.new()
		meta_lbl.text = "Min Age: %d+  •  Authorizes: %s" % [min_age, unlocked]
		meta_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		meta_lbl.add_theme_font_size_override("font_size", 21)
		meta_lbl.add_theme_color_override("font_color", Color("#a5f3fc"))
		cv.add_child(meta_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 21)
		desc_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
		cv.add_child(desc_lbl)

		if is_certified:
			var cert_btn := Button.new()
			cert_btn.custom_minimum_size.y = 52
			cert_btn.disabled = true
			cert_btn.text = "✓ FLIGHT SCHOOL COMPLETED" if bool(lic.get("is_course", false)) else "✓ CERTIFIED & ACTIVE"
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color("#064e3b")
			sb.border_color = Color("#10b981")
			sb.set_border_width_all(2)
			sb.set_corner_radius_all(6)
			cert_btn.add_theme_stylebox_override("normal", sb)
			cert_btn.add_theme_stylebox_override("disabled", sb)
			cert_btn.add_theme_color_override("font_color", Color("#6ee7b7"))
			cert_btn.add_theme_color_override("font_disabled_color", Color("#6ee7b7"))
			cert_btn.add_theme_font_size_override("font_size", 22)
			cv.add_child(cert_btn)
		else:
			var eval := LicenseManager.can_take_license(lic_id)
			if bool(eval.get("allowed", false)):
				var action_text := "✈ Pay $%s & Complete Flight School" if bool(lic.get("is_course", false)) else ("🚗 Pay $%s & Obtain Driver's License" if lic_id == "license_car" else ("🏍️ Pay $%s & Obtain Motorcycle License" if lic_id == "license_motorcycle" else "📜 Pay $%s & Take Qualification Exam"))
				var btn_take := _create_cyber_button(action_text % _format_number(fee), cat_color, func():
					var res := LicenseManager.take_license(lic_id)
					if bool(res.get("allowed", false)):
						add_life_event(str(res.get("message", "License acquired!")), "milestone")
						update_ui()
						SaveManager.save_game()
						_show_license_category_modal(category_id)
					else:
						add_life_event(str(res.get("reason", "Could not take exam.")), "activity")
				)
				btn_take.custom_minimum_size.y = 52
				btn_take.add_theme_font_size_override("font_size", 22)
				cv.add_child(btn_take)
			else:
				var lk_btn := _create_disabled_cyber_button(str(eval.get("reason", "Ineligible to take qualification exam.")))
				lk_btn.custom_minimum_size.y = 52
				lk_btn.add_theme_font_size_override("font_size", 20)
				cv.add_child(lk_btn)

		list.add_child(card)

	license_category_modal_overlay.visible = true


func _start_driving_exam_minigame(license_id: String, category_id: String = "vehicle") -> void:
	var eval := LicenseManager.can_take_license(license_id)
	if not bool(eval.get("allowed", false)):
		_show_simple_popup("EXAMINATION INELIGIBLE", str(eval.get("reason", "Ineligible to take exam.")), Color("#ef4444"))
		return

	if license_category_modal_overlay != null and is_instance_valid(license_category_modal_overlay):
		license_category_modal_overlay.queue_free()
	if licensing_modal_overlay != null and is_instance_valid(licensing_modal_overlay):
		licensing_modal_overlay.queue_free()
	if driving_exam_modal_overlay != null and is_instance_valid(driving_exam_modal_overlay):
		driving_exam_modal_overlay.queue_free()

	# Pick 3 random distinct questions from ROAD_SIGN_QUIZ
	var pool := ROAD_SIGN_QUIZ.duplicate()
	pool.shuffle()
	var selected_questions: Array = []
	for i in range(mini(3, pool.size())):
		selected_questions.append(pool[i])

	var exam_state := {
		"license_id": license_id,
		"category_id": category_id,
		"questions": selected_questions,
		"q_index": 0,
		"score": 0
	}
	_render_driving_exam_step(exam_state)


func _render_driving_exam_step(exam_state: Dictionary) -> void:
	if driving_exam_modal_overlay != null and is_instance_valid(driving_exam_modal_overlay):
		driving_exam_modal_overlay.queue_free()

	var q_idx: int = int(exam_state.get("q_index", 0))
	var questions: Array = exam_state.get("questions", [])
	if q_idx >= questions.size():
		_render_driving_exam_results(exam_state)
		return

	var current_q: Dictionary = questions[q_idx]
	var lic_def := LicenseManager.get_license_by_id(str(exam_state.get("license_id", "")))
	var lic_name: String = str(lic_def.get("name", "Driver's License"))

	var modal := _create_cyber_modal(
		"🚦 ROAD SIGN EXAM — QUESTION %d OF %d" % [q_idx + 1, questions.size()],
		"Demonstrate official road sign identification to qualify for your %s." % lic_name,
		Color("#38bdf8")
	)
	driving_exam_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var close_btn: Button = modal.get("close_btn")
	if close_btn != null:
		close_btn.pressed.connect(func():
			if is_instance_valid(driving_exam_modal_overlay):
				driving_exam_modal_overlay.queue_free()
			_show_license_category_modal(str(exam_state.get("category_id", "vehicle")))
		)

	# Score & Progress Tracker Bar
	var tracker := PanelContainer.new()
	tracker.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var tm := MarginContainer.new()
	tm.add_theme_constant_override("margin_left", 16)
	tm.add_theme_constant_override("margin_right", 16)
	tm.add_theme_constant_override("margin_top", 10)
	tm.add_theme_constant_override("margin_bottom", 10)
	tracker.add_child(tm)

	var thbox := HBoxContainer.new()
	var tlbl := Label.new()
	tlbl.text = "📋 Progress: Question %d of %d  •  Passing Standard: 2 of 3" % [
		q_idx + 1,
		questions.size()
	]
	tlbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tlbl.add_theme_font_size_override("font_size", 21)
	tlbl.add_theme_color_override("font_color", Color("#93c5fd"))
	thbox.add_child(tlbl)

	var score_lbl := Label.new()
	score_lbl.text = "Current Score: %d" % int(exam_state.get("score", 0))
	score_lbl.add_theme_font_size_override("font_size", 22)
	score_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
	thbox.add_child(score_lbl)
	tm.add_child(thbox)
	list.add_child(tracker)

	# Traffic Sign Visual Card
	var sign_card := PanelContainer.new()
	sign_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#1e293b")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	sign_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.alignment = BoxContainer.ALIGNMENT_CENTER
	sv.add_theme_constant_override("separation", 12)
	sm.add_child(sv)

	var stype_lbl := Label.new()
	stype_lbl.text = "OFFICIAL TRAFFIC SIGN: [ %s ]" % str(current_q.get("sign_type", "ROAD SIGN"))
	stype_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stype_lbl.add_theme_font_size_override("font_size", 20)
	stype_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
	sv.add_child(stype_lbl)

	# Graphic Sign Display Container
	var sign_box := PanelContainer.new()
	var sign_sb := StyleBoxFlat.new()
	sign_sb.bg_color = Color(str(current_q.get("bg_color", "#b91c1c")))
	sign_sb.border_color = Color(str(current_q.get("border_color", "#ffffff")))
	sign_sb.set_border_width_all(4)
	sign_sb.set_corner_radius_all(14)
	sign_box.add_theme_stylebox_override("panel", sign_sb)
	sign_box.custom_minimum_size = Vector2(300, 160)
	sign_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var sbm := MarginContainer.new()
	sbm.add_theme_constant_override("margin_left", 24)
	sbm.add_theme_constant_override("margin_right", 24)
	sbm.add_theme_constant_override("margin_top", 16)
	sbm.add_theme_constant_override("margin_bottom", 16)
	sign_box.add_child(sbm)

	var sbv := VBoxContainer.new()
	sbv.alignment = BoxContainer.ALIGNMENT_CENTER
	sbv.add_theme_constant_override("separation", 6)
	sbm.add_child(sbv)

	var icon_lbl := Label.new()
	icon_lbl.text = str(current_q.get("icon", "🛑"))
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 54)
	sbv.add_child(icon_lbl)

	var sign_text_str: String = str(current_q.get("sign_text", ""))
	if not sign_text_str.is_empty():
		var text_lbl := Label.new()
		text_lbl.text = sign_text_str
		text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text_lbl.add_theme_font_size_override("font_size", 24)
		text_lbl.add_theme_color_override("font_color", Color(str(current_q.get("text_color", "#ffffff"))))
		sbv.add_child(text_lbl)

	sv.add_child(sign_box)

	var prompt_lbl := Label.new()
	prompt_lbl.text = "❓ What is the legal meaning of this road sign?"
	prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 24)
	prompt_lbl.add_theme_color_override("font_color", Color("#ffffff"))
	sv.add_child(prompt_lbl)

	list.add_child(sign_card)

	# Feedback container placeholder
	var feedback_container := VBoxContainer.new()
	feedback_container.add_theme_constant_override("separation", 8)
	list.add_child(feedback_container)

	# Options Builder
	var correct_meaning: String = str(current_q.get("meaning", ""))
	var options_list: Array[String] = [correct_meaning]
	var distractors: Array = current_q.get("distractors", [])
	for d in distractors:
		options_list.append(str(d))
	options_list.shuffle()

	var option_buttons: Array[Button] = []
	var letters := ["A", "B", "C", "D"]

	for i in range(options_list.size()):
		var opt_text: String = options_list[i]
		var letter_prefix: String = letters[i] if i < letters.size() else str(i + 1)
		var btn_label := "%s)  %s" % [letter_prefix, opt_text]

		var opt_btn := _create_cyber_button(btn_label, Color("#0284c7"))
		opt_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		opt_btn.custom_minimum_size.y = 64
		opt_btn.add_theme_font_size_override("font_size", 21)
		opt_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		opt_btn.pressed.connect(func():
			# Disable all option buttons immediately
			for b in option_buttons:
				b.disabled = true

			var is_correct: bool = (opt_text == correct_meaning)
			if is_correct:
				exam_state["score"] = int(exam_state.get("score", 0)) + 1
				score_lbl.text = "Current Score: %d" % int(exam_state["score"])

				var win_sb := StyleBoxFlat.new()
				win_sb.bg_color = Color("#064e3b")
				win_sb.border_color = Color("#10b981")
				win_sb.set_border_width_all(3)
				win_sb.set_corner_radius_all(8)
				opt_btn.add_theme_stylebox_override("disabled", win_sb)
				opt_btn.add_theme_color_override("font_disabled_color", Color("#6ee7b7"))

				var fb_card := PanelContainer.new()
				fb_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
				var fbm := MarginContainer.new()
				fbm.add_theme_constant_override("margin_left", 16)
				fbm.add_theme_constant_override("margin_right", 16)
				fbm.add_theme_constant_override("margin_top", 12)
				fbm.add_theme_constant_override("margin_bottom", 12)
				fb_card.add_child(fbm)

				var fb_lbl := Label.new()
				fb_lbl.text = "✓ CORRECT ANSWER! %s" % correct_meaning
				fb_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				fb_lbl.add_theme_font_size_override("font_size", 22)
				fb_lbl.add_theme_color_override("font_color", Color("#6ee7b7"))
				fbm.add_child(fb_lbl)
				feedback_container.add_child(fb_card)
			else:
				var lose_sb := StyleBoxFlat.new()
				lose_sb.bg_color = Color("#7f1d1d")
				lose_sb.border_color = Color("#ef4444")
				lose_sb.set_border_width_all(3)
				lose_sb.set_corner_radius_all(8)
				opt_btn.add_theme_stylebox_override("disabled", lose_sb)
				opt_btn.add_theme_color_override("font_disabled_color", Color("#fca5a5"))

				# Highlight the correct one
				for b in option_buttons:
					if b.text.contains(correct_meaning):
						var correct_sb := StyleBoxFlat.new()
						correct_sb.bg_color = Color("#064e3b")
						correct_sb.border_color = Color("#10b981")
						correct_sb.set_border_width_all(3)
						correct_sb.set_corner_radius_all(8)
						b.add_theme_stylebox_override("disabled", correct_sb)
						b.add_theme_color_override("font_disabled_color", Color("#6ee7b7"))

				var fb_card := PanelContainer.new()
				fb_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#ef4444")))
				var fbm := MarginContainer.new()
				fbm.add_theme_constant_override("margin_left", 16)
				fbm.add_theme_constant_override("margin_right", 16)
				fbm.add_theme_constant_override("margin_top", 12)
				fbm.add_theme_constant_override("margin_bottom", 12)
				fb_card.add_child(fbm)

				var fb_lbl := Label.new()
				fb_lbl.text = "❌ INCORRECT. The correct road rule is:\n%s" % correct_meaning
				fb_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				fb_lbl.add_theme_font_size_override("font_size", 22)
				fb_lbl.add_theme_color_override("font_color", Color("#fca5a5"))
				fbm.add_child(fb_lbl)
				feedback_container.add_child(fb_card)

			var is_last_q := (q_idx + 1 >= questions.size())
			var next_text := "🏁 View Final Examination Results →" if is_last_q else "Continue to Next Question (%d of %d) →" % [q_idx + 2, questions.size()]
			var next_btn := _create_cyber_button(next_text, Color("#10b981") if is_correct else Color("#38bdf8"), func():
				exam_state["q_index"] = q_idx + 1
				_render_driving_exam_step(exam_state)
			)
			next_btn.custom_minimum_size.y = 56
			next_btn.add_theme_font_size_override("font_size", 22)
			feedback_container.add_child(next_btn)
		)

		option_buttons.append(opt_btn)
		list.add_child(opt_btn)

	driving_exam_modal_overlay.visible = true


func _render_driving_exam_results(exam_state: Dictionary) -> void:
	if driving_exam_modal_overlay != null and is_instance_valid(driving_exam_modal_overlay):
		driving_exam_modal_overlay.queue_free()

	var score: int = int(exam_state.get("score", 0))
	var total: int = int(exam_state.get("questions", []).size())
	var passed: bool = (score >= 2)
	var lic_id: String = str(exam_state.get("license_id", ""))
	var lic_def := LicenseManager.get_license_by_id(lic_id)
	var lic_name: String = str(lic_def.get("name", "Driver's License"))
	var lic_icon: String = str(lic_def.get("icon", "🚗"))
	var cat_id: String = str(exam_state.get("category_id", "vehicle"))

	var theme_color := Color("#10b981") if passed else Color("#ef4444")
	var title_text := "🎉 DRIVING EXAM PASSED!" if passed else "❌ DRIVING EXAM FAILED"
	var subtitle_text := "Official State Department of Motor Vehicles Examination Scorecard"

	var modal := _create_cyber_modal(title_text, subtitle_text, theme_color)
	driving_exam_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var close_btn: Button = modal.get("close_btn")
	if close_btn != null:
		close_btn.pressed.connect(func():
			if is_instance_valid(driving_exam_modal_overlay):
				driving_exam_modal_overlay.queue_free()
			_show_license_category_modal(cat_id)
		)

	var res_card := PanelContainer.new()
	res_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(theme_color))
	var rm := MarginContainer.new()
	rm.add_theme_constant_override("margin_left", 24)
	rm.add_theme_constant_override("margin_right", 24)
	rm.add_theme_constant_override("margin_top", 20)
	rm.add_theme_constant_override("margin_bottom", 20)
	res_card.add_child(rm)

	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 14)
	rm.add_child(rv)

	var score_header := Label.new()
	score_header.text = "EXAMINATION SCORE: %d / %d (Passing Standard: 2/3)" % [score, total]
	score_header.add_theme_font_size_override("font_size", 26)
	score_header.add_theme_color_override("font_color", Color("#ffffff"))
	rv.add_child(score_header)

	if passed:
		var grant_res := LicenseManager.take_license(lic_id)
		if bool(grant_res.get("allowed", false)):
			add_life_event(str(grant_res.get("message", "Earned %s!" % lic_name)), "milestone")
			update_ui()
			SaveManager.save_game()

		var pass_desc := Label.new()
		pass_desc.text = "Congratulations! You correctly identified the road signs and demonstrated state driving competency.\n\nYour official %s has been stamped, registered, and authorized on your public record!" % lic_name
		pass_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		pass_desc.add_theme_font_size_override("font_size", 22)
		pass_desc.add_theme_color_override("font_color", Color("#a7f3d0"))
		rv.add_child(pass_desc)

		var badge_lbl := Label.new()
		badge_lbl.text = "%s  %s — Active Qualification Granted!" % [lic_icon, lic_name]
		badge_lbl.add_theme_font_size_override("font_size", 24)
		badge_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		rv.add_child(badge_lbl)
	else:
		var fail_desc := Label.new()
		fail_desc.text = "You scored %d / %d. The state road bureau requires a minimum score of 2 out of 3 correct answers to certify driving qualifications.\n\nNo license fee was charged. You may review traffic signs and retake the test at any time." % [score, total]
		fail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fail_desc.add_theme_font_size_override("font_size", 22)
		fail_desc.add_theme_color_override("font_color", Color("#fca5a5"))
		rv.add_child(fail_desc)

	list.add_child(res_card)

	if passed:
		var back_btn := _create_cyber_button("✓ Return to Vehicle Licenses", Color("#10b981"), func():
			if is_instance_valid(driving_exam_modal_overlay):
				driving_exam_modal_overlay.queue_free()
			_show_license_category_modal(cat_id)
		)
		back_btn.custom_minimum_size.y = 56
		back_btn.add_theme_font_size_override("font_size", 22)
		list.add_child(back_btn)
	else:
		var retake_btn := _create_cyber_button("🔄 Retake Examination", Color("#38bdf8"), func():
			_start_driving_exam_minigame(lic_id, cat_id)
		)
		retake_btn.custom_minimum_size.y = 56
		retake_btn.add_theme_font_size_override("font_size", 22)
		list.add_child(retake_btn)

		var exit_btn := _create_cyber_button("← Return to Vehicle Licenses", Color("#64748b"), func():
			if is_instance_valid(driving_exam_modal_overlay):
				driving_exam_modal_overlay.queue_free()
			_show_license_category_modal(cat_id)
		)
		exit_btn.custom_minimum_size.y = 54
		exit_btn.add_theme_font_size_override("font_size", 20)
		list.add_child(exit_btn)

	driving_exam_modal_overlay.visible = true


# -----------------------------------------------------------------------------
# FREELANCE MARKETPLACE SYSTEM
# -----------------------------------------------------------------------------
func _show_freelance_modal() -> void:
	if freelance_modal_overlay != null and is_instance_valid(freelance_modal_overlay):
		freelance_modal_overlay.queue_free()

	var modal := _create_cyber_modal("💻 FREELANCE MARKETPLACE", "12 Certified Freelance Occupations • Dynamic Project Income • Client Contracts", Color("#a855f7"))
	freelance_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# Marketplace Overview Card
	var info_card := PanelContainer.new()
	info_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#a855f7")))
	var im := MarginContainer.new()
	im.add_theme_constant_override("margin_left", 20)
	im.add_theme_constant_override("margin_right", 20)
	im.add_theme_constant_override("margin_top", 16)
	im.add_theme_constant_override("margin_bottom", 16)
	info_card.add_child(im)

	var iv := VBoxContainer.new()
	iv.add_theme_constant_override("separation", 8)
	im.add_child(iv)

	var ih := Label.new()
	ih.text = "🌐 FREELANCE CLIENT CONTRACT HUB"
	ih.add_theme_font_size_override("font_size", 26)
	ih.add_theme_color_override("font_color", Color("#c084fc"))
	iv.add_child(ih)

	var idesc := Label.new()
	idesc.text = "Freelance occupations do not pay fixed annual salaries. Instead, income is generated per client project. Once registered, client contract requests arrive automatically each year during aging, or you can actively pitch for gigs right now!"
	idesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	idesc.add_theme_font_size_override("font_size", 22)
	idesc.add_theme_color_override("font_color", Color("#cbd5e1"))
	iv.add_child(idesc)
	list.add_child(info_card)

	var all_jobs := FreelanceManager.get_all_jobs()
	for job in all_jobs:
		var j_id: String = str(job["id"])
		var j_title: String = str(job["title"])
		var j_icon: String = str(job["icon"])
		var req_lic: String = str(job["required_license"])
		var lic_title: String = str(job["license_title"])
		var min_pay: int = int(job["min_pay"])
		var max_pay: int = int(job["max_pay"])
		var desc: String = str(job["description"])

		var is_registered: bool = PlayerData.active_freelance_jobs.has(j_id)
		var has_license: bool = PlayerData.has_license(req_lic)

		var card := PanelContainer.new()
		var border_col: Color = Color("#10b981") if is_registered else (Color("#8b5cf6") if has_license else Color("#475569"))
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_col))

		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var top_row := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = "%s %s" % [j_icon, j_title]
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.add_theme_font_size_override("font_size", 24)
		title_lbl.add_theme_color_override("font_color", Color("#ffffff"))
		top_row.add_child(title_lbl)

		var pay_lbl := Label.new()
		pay_lbl.text = "$%s - $%s / Project" % [_format_number(min_pay), _format_number(max_pay)]
		pay_lbl.add_theme_font_size_override("font_size", 22)
		pay_lbl.add_theme_color_override("font_color", Color("#34d399"))
		top_row.add_child(pay_lbl)
		cv.add_child(top_row)

		var lic_lbl := Label.new()
		lic_lbl.text = "Required Credential: %s (%s)" % [lic_title, "✓ Certified" if has_license else "❌ Not Certified"]
		lic_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lic_lbl.add_theme_font_size_override("font_size", 21)
		lic_lbl.add_theme_color_override("font_color", Color("#a7f3d0") if has_license else Color("#fca5a5"))
		cv.add_child(lic_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 21)
		desc_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
		cv.add_child(desc_lbl)

		if is_registered:
			var reg_info := Label.new()
			reg_info.text = "✓ Client Roster Active: Projects will automatically offer contracts annually."
			reg_info.add_theme_font_size_override("font_size", 21)
			reg_info.add_theme_color_override("font_color", Color("#34d399"))
			cv.add_child(reg_info)

			var btn_row := HBoxContainer.new()
			btn_row.add_theme_constant_override("separation", 12)

			var can_pitch: bool = int(PlayerData.last_freelance_pitch_age.get(j_id, -1)) != PlayerData.age
			if can_pitch:
				var pitch_btn := _create_cyber_button("🚀 Pitch Client Gigs Now", Color("#a855f7"), func():
					var res := FreelanceManager.pitch_gig(j_id)
					if bool(res.get("success", false)):
						var proj: Dictionary = res.get("project", {})
						_show_simple_popup("💼 CONTRACT COMPLETED!", "Client: %s\nProject: %s\n\n%s\n\nPayment Earned: $%s credited to your funds!" % [
							str(proj.get("client", "Client")),
							str(proj.get("title", "Project")),
							str(proj.get("scope", "")),
							_format_number(int(res.get("pay", 0)))
						], Color("#10b981"))
						update_ui()
						SaveManager.save_game()
						_show_freelance_modal()
					else:
						add_life_event(str(res.get("message", "Pitch unsuccessful.")), "activity")
				)
				pitch_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				pitch_btn.custom_minimum_size.y = 52
				pitch_btn.add_theme_font_size_override("font_size", 21)
				btn_row.add_child(pitch_btn)
			else:
				var done_pitch := _create_disabled_cyber_button("✓ Pitched for Age %d" % PlayerData.age, "Annual pitch quota reached.")
				done_pitch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				done_pitch.custom_minimum_size.y = 52
				done_pitch.add_theme_font_size_override("font_size", 20)
				btn_row.add_child(done_pitch)

			var pause_btn := _create_cyber_button("⏸️ Pause Roster", Color("#ef4444"), func():
				FreelanceManager.unregister_job(j_id)
				update_ui()
				SaveManager.save_game()
				_show_freelance_modal()
			)
			pause_btn.custom_minimum_size.y = 52
			pause_btn.add_theme_font_size_override("font_size", 21)
			btn_row.add_child(pause_btn)

			cv.add_child(btn_row)
		elif has_license:
			var reg_btn := _create_cyber_button("💼 Register & Open Client Roster", Color("#06b6d4"), func():
				var res := FreelanceManager.register_job(j_id)
				if bool(res.get("allowed", false)):
					update_ui()
					SaveManager.save_game()
					_show_freelance_modal()
			)
			reg_btn.custom_minimum_size.y = 52
			reg_btn.add_theme_font_size_override("font_size", 22)
			cv.add_child(reg_btn)
		else:
			var lk_btn := _create_disabled_cyber_button("Requires %s" % lic_title, "You must take the qualification exam in the Licensing Panel first.")
			lk_btn.custom_minimum_size.y = 52
			lk_btn.add_theme_font_size_override("font_size", 20)
			cv.add_child(lk_btn)

		list.add_child(card)

	freelance_modal_overlay.visible = true


# -----------------------------------------------------------------------------
# COMMERCIAL BUSINESSES & ENTERPRISE SYSTEM
# -----------------------------------------------------------------------------
func _show_business_modal(initial_tab: String = "", selected_uid: String = "") -> void:
	if business_category_modal_overlay != null and is_instance_valid(business_category_modal_overlay):
		business_category_modal_overlay.queue_free()

	var modal := _refresh_cyber_modal(business_modal_overlay, "🏢 ENTERPRISES & COMMERCIAL VENTURES", "Found Companies, Manage Corporate Financials, Pay Taxes & Scale Ventures", Color("#f59e0b"))
	business_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var tab: String = initial_tab
	if tab == "":
		tab = "enterprises" if PlayerData.owned_businesses.size() > 0 else "incorporate"

	# Top Tab Bar (Pinned above scroll container)
	var tab_bar := HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 10)
	tab_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var btn_tab_ent := _create_cyber_button("📊 My Enterprises (%d)" % PlayerData.owned_businesses.size(), Color("#f59e0b") if tab == "enterprises" else Color("#475569"), func():
		_show_business_modal("enterprises", selected_uid)
	)
	btn_tab_ent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_ent.custom_minimum_size.y = 50
	btn_tab_ent.add_theme_font_size_override("font_size", 21)
	btn_tab_ent.alignment = HORIZONTAL_ALIGNMENT_CENTER
	tab_bar.add_child(btn_tab_ent)

	var btn_tab_inc := _create_cyber_button("🚀 Incorporate (7 Sectors)", Color("#f59e0b") if tab == "incorporate" else Color("#475569"), func():
		_show_business_modal("incorporate", selected_uid)
	)
	btn_tab_inc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_inc.custom_minimum_size.y = 50
	btn_tab_inc.add_theme_font_size_override("font_size", 21)
	btn_tab_inc.alignment = HORIZONTAL_ALIGNMENT_CENTER
	tab_bar.add_child(btn_tab_inc)

	if not PlayerData.owned_businesses.is_empty():
		var btn_tab_fin := _create_cyber_button("💰 Financials & Loans", Color("#f59e0b") if tab == "financials" else Color("#475569"), func():
			_show_business_modal("financials", selected_uid)
		)
		btn_tab_fin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_tab_fin.custom_minimum_size.y = 50
		btn_tab_fin.add_theme_font_size_override("font_size", 21)
		btn_tab_fin.alignment = HORIZONTAL_ALIGNMENT_CENTER
		tab_bar.add_child(btn_tab_fin)

	modal.vbox.add_child(tab_bar)
	modal.vbox.move_child(tab_bar, 2)

	# Content based on tab
	match tab:
		"enterprises":
			_render_business_tab_enterprises(list)
		"incorporate":
			_render_business_tab_incorporate(list)
		"financials":
			_render_business_tab_financials(list, selected_uid)

	business_modal_overlay.visible = true
	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(business_modal_overlay)


func _render_business_tab_enterprises(list: VBoxContainer) -> void:
	if PlayerData.owned_businesses.is_empty():
		var empty_card := PanelContainer.new()
		empty_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#475569")))
		var em := MarginContainer.new()
		em.add_theme_constant_override("margin_left", 24)
		em.add_theme_constant_override("margin_right", 24)
		em.add_theme_constant_override("margin_top", 20)
		em.add_theme_constant_override("margin_bottom", 20)
		empty_card.add_child(em)

		var ev := VBoxContainer.new()
		ev.add_theme_constant_override("separation", 10)
		em.add_child(ev)

		var etitle := Label.new()
		etitle.text = "🏢 No Commercial Enterprises Owned Yet"
		etitle.add_theme_font_size_override("font_size", 24)
		etitle.add_theme_color_override("font_color", Color("#fbbf24"))
		ev.add_child(etitle)

		var edesc := Label.new()
		edesc.text = "You do not own any operating commercial companies. Complete the corresponding 4-year degree at university, then explore available business types in the 'Incorporate (16 Types)' tab!"
		edesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		edesc.add_theme_font_size_override("font_size", 21)
		edesc.add_theme_color_override("font_color", Color("#cbd5e1"))
		ev.add_child(edesc)

		var goto_inc := _create_cyber_button("🚀 Explore 16 Business Incorporation Opportunities", Color("#f59e0b"), func():
			_show_business_modal("incorporate")
		)
		goto_inc.custom_minimum_size.y = 54
		goto_inc.add_theme_font_size_override("font_size", 22)
		ev.add_child(goto_inc)

		list.add_child(empty_card)
		return

	# Portfolio Header
	var total_val := BusinessManager.get_total_business_valuation()
	var hdr := Label.new()
	hdr.text = "🏢 COMMERCIAL PORTFOLIO (%d Enterprises • Combined Valuation: $%s)" % [
		PlayerData.owned_businesses.size(),
		_format_number(total_val)
	]
	hdr.add_theme_font_size_override("font_size", 24)
	hdr.add_theme_color_override("font_color", Color("#fbbf24"))
	list.add_child(hdr)

	for b in PlayerData.owned_businesses:
		var uid: String = str(b.get("uid", ""))
		var b_name: String = str(b.get("name", "Enterprise"))
		var b_icon: String = str(b.get("icon", "🏢"))
		var val: int = int(b.get("valuation", 0))
		var treasury: int = int(b.get("treasury", 0))
		var employees: int = int(b.get("employees", 4))
		var marketing: int = int(b.get("marketing_budget", 5000))
		var rev: int = int(b.get("annual_revenue", 0))
		var net_p: int = int(b.get("net_profit", 0))
		var unpaid_tax: int = int(b.get("unpaid_taxes", 0))
		var loan_bal: int = int(b.get("loan_balance", 0))

		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var is_unlic: bool = bool(b.get("is_unlicensed", false))
		var branches: int = int(b.get("branches", 1))
		var fac_tier: int = int(b.get("facility_tier", 1))

		var top_row := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = "%s %s" % [b_icon, b_name]
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.add_theme_font_size_override("font_size", 26)
		title_lbl.add_theme_color_override("font_color", Color("#ffffff"))
		top_row.add_child(title_lbl)

		var val_lbl := Label.new()
		val_lbl.text = "Valuation: $%s" % _format_number(val)
		val_lbl.add_theme_font_size_override("font_size", 24)
		val_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		top_row.add_child(val_lbl)
		cv.add_child(top_row)

		var status_badge := Label.new()
		if is_unlic:
			status_badge.text = "⚠️ UNLICENSED ENTERPRISE (CRIME • HIGH RISK OF RAIDS, AUDITS & PRISON)"
			status_badge.add_theme_color_override("font_color", Color("#f87171"))
		else:
			status_badge.text = "✓ Legally Chartered & Licensed Enterprise"
			status_badge.add_theme_color_override("font_color", Color("#86efac"))
		status_badge.add_theme_font_size_override("font_size", 20)
		cv.add_child(status_badge)

		var stats_lbl := Label.new()
		var p_str := ("+$%s" % _format_number(net_p)) if net_p >= 0 else ("-$%s" % _format_number(abs(net_p)))
		stats_lbl.text = "💰 Treasury: $%s  •  🏢 Branches: %d  •  ⚙️ Grade %d Facility  •  👥 Staff: %d\n📊 Last Revenue: $%s  •  Net Profit: %s  •  Taxes Due: $%s  •  Bank Loan: $%s" % [
			_format_number(treasury),
			branches,
			fac_tier,
			employees,
			_format_number(rev),
			p_str,
			_format_number(unpaid_tax),
			_format_number(loan_bal)
		]
		stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		stats_lbl.add_theme_font_size_override("font_size", 21)
		stats_lbl.add_theme_color_override("font_color", Color("#e2e8f0"))
		cv.add_child(stats_lbl)

		var actions_row := HBoxContainer.new()
		actions_row.add_theme_constant_override("separation", 10)

		var btn_fin := _create_cyber_button("💰 Treasury & Financials", Color("#f59e0b"), func():
			_show_business_modal("financials", uid)
		)
		btn_fin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_fin.custom_minimum_size.y = 50
		btn_fin.add_theme_font_size_override("font_size", 21)
		actions_row.add_child(btn_fin)

		var btn_rename := _create_cyber_button("✏️ Rename", Color("#3b82f6"), func():
			_show_rename_business_modal(b)
		)
		btn_rename.custom_minimum_size.y = 50
		btn_rename.add_theme_font_size_override("font_size", 20)
		actions_row.add_child(btn_rename)

		var btn_hire := _create_cyber_button("👥 + Staff", Color("#06b6d4"), func():
			var r: Dictionary = BusinessManager.adjust_staff(b, 1)
			add_life_event(str(r.get("message", "Staff hired.")), "activity")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("enterprises", uid)
		)
		btn_hire.custom_minimum_size.y = 50
		btn_hire.add_theme_font_size_override("font_size", 20)
		actions_row.add_child(btn_hire)

		var btn_sell := _create_cyber_button("🏷️ Sell / Exit", Color("#ef4444"), func():
			var r: Dictionary = BusinessManager.liquidate_business(uid)
			add_life_event(str(r.get("message", "Business sold.")), "finance")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("enterprises")
		)
		btn_sell.custom_minimum_size.y = 50
		btn_sell.add_theme_font_size_override("font_size", 20)
		actions_row.add_child(btn_sell)

		cv.add_child(actions_row)
		list.add_child(card)


func _render_business_tab_incorporate(list: VBoxContainer) -> void:
	var info_card := PanelContainer.new()
	info_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var im := MarginContainer.new()
	im.add_theme_constant_override("margin_left", 20)
	im.add_theme_constant_override("margin_right", 20)
	im.add_theme_constant_override("margin_top", 16)
	im.add_theme_constant_override("margin_bottom", 16)
	info_card.add_child(im)

	var iv := VBoxContainer.new()
	iv.add_theme_constant_override("separation", 8)
	im.add_child(iv)

	var ih := Label.new()
	ih.text = "🏛️ COMMERCIAL ENTERPRISE SECTORS"
	ih.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ih.add_theme_font_size_override("font_size", 26)
	ih.add_theme_color_override("font_color", Color("#fbbf24"))
	iv.add_child(ih)

	var idesc := Label.new()
	idesc.text = "Legally incorporating a commercial company requires holding a state-certified license in that field. Startup capital initializes operations, storefronts, and working treasury.\n\n⚠️ UNLICENSED BUSINESS: You may also choose to operate without a license or degree, but operating without a license is a crime and risks regulatory audits, civil lawsuits, forced closures, and prison sentences.\n\nAvailable Funds: $%s Cash  •  $%s Bank" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings)
	]
	idesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	idesc.add_theme_font_size_override("font_size", 22)
	idesc.add_theme_color_override("font_color", Color("#cbd5e1"))
	iv.add_child(idesc)
	list.add_child(info_card)

	# Dedicated Sector Buttons (Matching Career & Occupations Pattern)
	var all_categories: Array = BusinessManager.get_categories()
	for cat in all_categories:
		if cat is not Dictionary:
			continue
		var cat_id: String = str(cat.get("id", ""))
		var cat_name: String = str(cat.get("name", "Business Sector"))
		var cat_icon: String = str(cat.get("icon", "🏢"))
		var cat_desc_text: String = str(cat.get("description", ""))
		var cat_color: Color = Color(cat.get("color", "#f59e0b"))
		var cat_businesses: Array = BusinessManager.get_businesses_in_category(cat_id)

		var btn_label := "%s %s (%d Enterprises)\n%s" % [cat_icon, cat_name, cat_businesses.size(), cat_desc_text]
		var cat_btn := _create_cyber_button(btn_label, cat_color, func():
			_show_business_category_modal(cat_id)
		)
		cat_btn.custom_minimum_size.y = 82
		cat_btn.add_theme_font_size_override("font_size", 24)
		list.add_child(cat_btn)


func _show_business_category_modal(category_id: String) -> void:
	if business_category_modal_overlay != null and is_instance_valid(business_category_modal_overlay):
		business_category_modal_overlay.queue_free()
	if business_modal_overlay != null and is_instance_valid(business_modal_overlay):
		business_modal_overlay.queue_free()

	var cat: Dictionary = BusinessManager.get_category_by_id(category_id)
	var cat_name: String = str(cat.get("name", "Commercial Sector"))
	var cat_icon: String = str(cat.get("icon", "🏢"))
	var cat_desc_text: String = str(cat.get("description", "Enterprise incorporation and commercial ventures."))
	var cat_color: Color = Color(cat.get("color", "#f59e0b"))

	var modal := _create_cyber_modal("%s %s" % [cat_icon, cat_name.to_upper()], cat_desc_text, cat_color)
	business_category_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var close_btn: Button = modal.get("close_btn")
	if close_btn != null:
		close_btn.pressed.connect(func():
			if is_instance_valid(business_category_modal_overlay):
				business_category_modal_overlay.queue_free()
			_show_business_modal("incorporate")
		)

	# Back to Enterprise Sectors Button
	var back_btn := _create_cyber_button("← Back to Enterprise Sectors", cat_color, func():
		if is_instance_valid(business_category_modal_overlay):
			business_category_modal_overlay.queue_free()
		_show_business_modal("incorporate")
	)
	back_btn.custom_minimum_size.y = 70
	back_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(back_btn)

	# Businesses in this category
	var category_businesses: Array = BusinessManager.get_businesses_in_category(category_id)
	for b_def in category_businesses:
		if b_def is not Dictionary:
			continue
		var b_id: String = str(b_def["id"])
		var b_name: String = str(b_def["name"])
		var b_icon: String = str(b_def["icon"])
		var req_maj: String = str(b_def.get("required_major", ""))
		var req_lic: String = str(b_def.get("required_license", ""))
		var lic_title: String = str(b_def.get("required_license_title", "Commercial License"))
		var cost: int = int(b_def["startup_cost"])
		var rev_min: int = int(b_def["base_revenue_min"])
		var rev_max: int = int(b_def["base_revenue_max"])
		var opex: int = int(b_def["base_opex"])
		var desc: String = str(b_def["description"])

		var has_license: bool = PlayerData.has_license(req_lic)
		if not has_license and req_maj != "" and BusinessManager.player_has_required_degree(req_maj):
			has_license = true

		var card := PanelContainer.new()
		var border_col: Color = cat_color if has_license else Color("#475569")
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_col))

		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var top_row := HBoxContainer.new()
		var title_lbl := Label.new()
		title_lbl.text = "%s %s" % [b_icon, b_name]
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title_lbl.add_theme_font_size_override("font_size", 24)
		title_lbl.add_theme_color_override("font_color", Color("#ffffff"))
		top_row.add_child(title_lbl)

		var cost_lbl := Label.new()
		cost_lbl.text = "$%s Capital" % _format_number(cost)
		cost_lbl.add_theme_font_size_override("font_size", 24)
		cost_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		top_row.add_child(cost_lbl)
		cv.add_child(top_row)

		var lic_lbl := Label.new()
		lic_lbl.text = "Commercial Qualification: %s (%s)" % [lic_title, "✓ Certified License" if has_license else "❌ Unlicensed (Required for Legal Charter)"]
		lic_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lic_lbl.add_theme_font_size_override("font_size", 21)
		lic_lbl.add_theme_color_override("font_color", Color("#a7f3d0") if has_license else Color("#fca5a5"))
		cv.add_child(lic_lbl)

		var proj_lbl := Label.new()
		proj_lbl.text = "Projected Revenue: $%s - $%s/yr  •  Base OpEx: $%s/yr" % [_format_number(rev_min), _format_number(rev_max), _format_number(opex)]
		proj_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		proj_lbl.add_theme_font_size_override("font_size", 21)
		proj_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
		cv.add_child(proj_lbl)

		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 21)
		desc_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
		cv.add_child(desc_lbl)

		var total_funds: int = PlayerData.money + PlayerData.bank_savings
		if total_funds >= cost:
			var name_box := VBoxContainer.new()
			name_box.add_theme_constant_override("separation", 6)

			var name_lbl := Label.new()
			name_lbl.text = "Business / Trade Name:"
			name_lbl.add_theme_font_size_override("font_size", 20)
			name_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
			name_box.add_child(name_lbl)

			var name_edit := LineEdit.new()
			name_edit.text = b_name
			name_edit.placeholder_text = "Enter custom business name..."
			name_edit.custom_minimum_size.y = 48
			name_edit.add_theme_font_size_override("font_size", 21)
			name_edit.add_theme_color_override("font_color", Color("#ffffff"))
			name_edit.add_theme_color_override("placeholder_color", Color("#64748b"))

			var edit_sb := StyleBoxFlat.new()
			edit_sb.bg_color = Color("#071022")
			edit_sb.border_color = cat_color
			edit_sb.set_border_width_all(2)
			edit_sb.set_corner_radius_all(8)
			edit_sb.content_margin_left = 16
			edit_sb.content_margin_right = 16
			edit_sb.content_margin_top = 8
			edit_sb.content_margin_bottom = 8
			name_edit.add_theme_stylebox_override("normal", edit_sb)
			name_edit.add_theme_stylebox_override("focus", edit_sb)
			MobileKeyboardManager.attach_to_input(name_edit, "Enter custom business name:")
			name_box.add_child(name_edit)

			var name_kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(name_edit, "⌨️ Enter Custom Business Name", "Enter custom business name:", cat_color)
			name_kb_btn.custom_minimum_size.y = 44
			name_kb_btn.add_theme_font_size_override("font_size", 19)
			name_box.add_child(name_kb_btn)
			cv.add_child(name_box)

			if has_license:
				var btn_found := _create_cyber_button("🚀 Incorporate Licensed Enterprise ($%s Capital)" % _format_number(cost), cat_color, func():
					var custom_name := name_edit.text.strip_edges()
					if custom_name.is_empty():
						custom_name = b_name
					var res := BusinessManager.found_business(b_id, custom_name, false)
					if bool(res.get("allowed", false)):
						var b_data: Dictionary = res.get("business", {})
						var registered_name: String = str(b_data.get("name", custom_name))
						add_life_event("🚀 ENTERPRISE INCORPORATED: Congratulations! '%s' has been officially incorporated under state charter. Business treasury seeded with $10,000 working capital." % registered_name, "milestone")
						update_ui()
						SaveManager.save_game()
						if is_instance_valid(business_category_modal_overlay):
							business_category_modal_overlay.queue_free()
						_show_business_modal("financials", str(b_data.get("uid", "")))
					else:
						add_life_event(str(res.get("reason", "Could not incorporate.")), "activity")
				)
				btn_found.custom_minimum_size.y = 52
				btn_found.add_theme_font_size_override("font_size", 22)
				cv.add_child(btn_found)

			# EXTRA BUTTON (Item 6): Allow creating business WITHOUT a license or degree
			var btn_unlic := _create_cyber_button("⚠️ Operate Without License (Underground Enterprise • $%s Capital)" % _format_number(cost), Color("#ef4444"), func():
				var custom_name := name_edit.text.strip_edges()
				if custom_name.is_empty():
					custom_name = b_name
				var res := BusinessManager.found_business(b_id, custom_name, true)
				if bool(res.get("allowed", false)):
					var b_data: Dictionary = res.get("business", {})
					var registered_name: String = str(b_data.get("name", custom_name))
					add_life_event("⚠️ UNLICENSED ENTERPRISE OPENED: You launched '%s' WITHOUT a commercial license! Operating without a license is a crime and risks audits, lawsuits, closures, and prison sentences!" % registered_name, "crime")
					update_ui()
					SaveManager.save_game()
					if is_instance_valid(business_category_modal_overlay):
						business_category_modal_overlay.queue_free()
					_show_business_modal("financials", str(b_data.get("uid", "")))
				else:
					add_life_event(str(res.get("reason", "Could not operate.")), "activity")
			)
			btn_unlic.custom_minimum_size.y = 50
			btn_unlic.add_theme_font_size_override("font_size", 20)
			cv.add_child(btn_unlic)

			var unlic_warn := Label.new()
			unlic_warn.text = "⚠️ Unlicensed operation is illegal. High annual risk of police audits, lawsuits, shutdown, and prison."
			unlic_warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			unlic_warn.add_theme_font_size_override("font_size", 18)
			unlic_warn.add_theme_color_override("font_color", Color("#fca5a5"))
			cv.add_child(unlic_warn)
		else:
			var lk_funds := _create_disabled_cyber_button("Insufficient Funds ($%s Required • You have $%s)" % [_format_number(cost), _format_number(total_funds)], "Deposit or save more cash to meet startup incorporation requirements.")
			lk_funds.custom_minimum_size.y = 52
			lk_funds.add_theme_font_size_override("font_size", 20)
			cv.add_child(lk_funds)

		list.add_child(card)

	business_category_modal_overlay.visible = true
	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(business_category_modal_overlay)


func _render_business_tab_financials(list: VBoxContainer, selected_uid: String) -> void:
	if PlayerData.owned_businesses.is_empty():
		_render_business_tab_enterprises(list)
		return

	# Find targeted enterprise
	var target_biz: Dictionary = {}
	if selected_uid != "":
		for b in PlayerData.owned_businesses:
			if str(b.get("uid", "")) == selected_uid:
				target_biz = b
				break
	if target_biz.is_empty():
		target_biz = PlayerData.owned_businesses[0]

	var cur_uid: String = str(target_biz.get("uid", ""))
	var b_name: String = str(target_biz.get("name", "Enterprise"))
	var b_icon: String = str(target_biz.get("icon", "🏢"))

	# Multi-business selector
	if PlayerData.owned_businesses.size() > 1:
		var sel_row := HBoxContainer.new()
		sel_row.add_theme_constant_override("separation", 8)
		for ob in PlayerData.owned_businesses:
			var ob_uid: String = str(ob.get("uid", ""))
			var ob_name: String = str(ob.get("name", "Business"))
			var is_curr: bool = (ob_uid == cur_uid)
			var b_btn := _create_cyber_button(ob_name, Color("#f59e0b") if is_curr else Color("#334155"), func():
				_show_business_modal("financials", ob_uid)
			)
			b_btn.custom_minimum_size.y = 44
			b_btn.add_theme_font_size_override("font_size", 19)
			sel_row.add_child(b_btn)
		list.add_child(sel_row)

	# Entity Separation Banner
	var sep_card := PanelContainer.new()
	sep_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#0284c7")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 14)
	sm.add_theme_constant_override("margin_bottom", 14)
	sep_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 6)
	sm.add_child(sv)

	var stitle := Label.new()
	stitle.text = "🏛️ STRICT CORPORATE ENTITY SEPARATION"
	stitle.add_theme_font_size_override("font_size", 24)
	stitle.add_theme_color_override("font_color", Color("#38bdf8"))
	sv.add_child(stitle)

	var sdesc := Label.new()
	sdesc.text = "%s operates with an independent corporate bank treasury and balance sheet, completely separated from your personal cash wallet ($%s) and bank savings ($%s)." % [
		b_name,
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings)
	]
	sdesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sdesc.add_theme_font_size_override("font_size", 21)
	sdesc.add_theme_color_override("font_color", Color("#e0f2fe"))
	sv.add_child(sdesc)
	list.add_child(sep_card)

	# 1. Financial Statement Card
	var fin_card := PanelContainer.new()
	fin_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var fm := MarginContainer.new()
	fm.add_theme_constant_override("margin_left", 20)
	fm.add_theme_constant_override("margin_right", 20)
	fm.add_theme_constant_override("margin_top", 16)
	fm.add_theme_constant_override("margin_bottom", 16)
	fin_card.add_child(fm)

	var fv := VBoxContainer.new()
	fv.add_theme_constant_override("separation", 10)
	fm.add_child(fv)

	var f_title := Label.new()
	f_title.text = "%s %s — CORPORATE BALANCE SHEET" % [b_icon, b_name]
	f_title.add_theme_font_size_override("font_size", 26)
	f_title.add_theme_color_override("font_color", Color("#ffffff"))
	fv.add_child(f_title)

	var treasury: int = int(target_biz.get("treasury", 0))
	var val: int = int(target_biz.get("valuation", 0))
	var rev: int = int(target_biz.get("annual_revenue", 0))
	var opex: int = int(target_biz.get("annual_opex", 0))
	var net_p: int = int(target_biz.get("net_profit", 0))
	var p_str := ("+$%s" % _format_number(net_p)) if net_p >= 0 else ("-$%s" % _format_number(abs(net_p)))

	var f_body := Label.new()
	f_body.text = "• Corporate Treasury (Business Cash): $%s\n• Enterprise Market Valuation: $%s\n• Annual Gross Revenue: $%s\n• Annual Operating Expenses (OpEx): $%s\n• Net Operating Profit / Loss: %s" % [
		_format_number(treasury),
		_format_number(val),
		_format_number(rev),
		_format_number(opex),
		p_str
	]
	f_body.add_theme_font_size_override("font_size", 22)
	f_body.add_theme_color_override("font_color", Color("#fef08a"))
	fv.add_child(f_body)
	list.add_child(fin_card)

	# 2. Corporate Tax Payment Section
	var tax_card := PanelContainer.new()
	var unpaid_tax: int = int(target_biz.get("unpaid_taxes", 0))
	tax_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#ef4444") if unpaid_tax > 0 else Color("#10b981")))
	var tm := MarginContainer.new()
	tm.add_theme_constant_override("margin_left", 20)
	tm.add_theme_constant_override("margin_right", 20)
	tm.add_theme_constant_override("margin_top", 16)
	tm.add_theme_constant_override("margin_bottom", 16)
	tax_card.add_child(tm)

	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 10)
	tm.add_child(tv)

	var t_title := Label.new()
	t_title.text = "🏛️ CORPORATE TAX COMPLIANCE SECTION"
	t_title.add_theme_font_size_override("font_size", 25)
	t_title.add_theme_color_override("font_color", Color("#ffffff"))
	tv.add_child(t_title)

	var total_biz_count := PlayerData.owned_businesses.size()
	var cur_tax_rate := BusinessManager.get_corporate_tax_rate(total_biz_count, int(target_biz.get("net_profit", 0)))
	var t_desc := Label.new()
	t_desc.text = "Corporate Tax Rate: %d%% (Scaling with %d owned enterprises)\nUnpaid Corporate Taxes: $%s (Last Filing: Age %d)" % [
		int(cur_tax_rate * 100),
		total_biz_count,
		_format_number(unpaid_tax),
		int(target_biz.get("last_tax_paid_year", PlayerData.age))
	]
	t_desc.add_theme_font_size_override("font_size", 22)
	t_desc.add_theme_color_override("font_color", Color("#fca5a5") if unpaid_tax > 0 else Color("#86efac"))
	tv.add_child(t_desc)

	if unpaid_tax > 0:
		var btn_pay_tax := _create_cyber_button("🏛️ Pay Corporate Taxes ($%s)" % _format_number(unpaid_tax), Color("#10b981"), func():
			var r: Dictionary = BusinessManager.pay_business_taxes(target_biz)
			if bool(r.get("success", false)):
				add_life_event(str(r.get("message", "Corporate taxes paid.")), "finance")
				update_ui()
				SaveManager.save_game()
				_show_business_modal("financials", cur_uid)
			else:
				add_life_event(str(r.get("message", "Could not pay taxes.")), "finance")
		)
		btn_pay_tax.custom_minimum_size.y = 52
		btn_pay_tax.add_theme_font_size_override("font_size", 22)
		tv.add_child(btn_pay_tax)
	else:
		var paid_lbl := Label.new()
		paid_lbl.text = "✓ All corporate taxes are fully paid and in compliance."
		paid_lbl.add_theme_font_size_override("font_size", 21)
		paid_lbl.add_theme_color_override("font_color", Color("#86efac"))
		tv.add_child(paid_lbl)

	list.add_child(tax_card)

	# 3. Commercial Loans & Bank Credit Section
	var loan_card := PanelContainer.new()
	loan_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#8b5cf6")))
	var lm := MarginContainer.new()
	lm.add_theme_constant_override("margin_left", 20)
	lm.add_theme_constant_override("margin_right", 20)
	lm.add_theme_constant_override("margin_top", 16)
	lm.add_theme_constant_override("margin_bottom", 16)
	loan_card.add_child(lm)

	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 10)
	lm.add_child(lv)

	var l_title := Label.new()
	l_title.text = "🏦 COMMERCIAL LOANS & CREDIT FACILITY SECTION"
	l_title.add_theme_font_size_override("font_size", 25)
	l_title.add_theme_color_override("font_color", Color("#ffffff"))
	lv.add_child(l_title)

	var cur_loan: int = int(target_biz.get("loan_balance", 0))
	var l_desc := Label.new()
	l_desc.text = "Active Commercial Loan Balance: $%s  •  Interest Rate: 7.5%% APR\nDisbursed loans are directly deposited into the business corporate treasury." % _format_number(cur_loan)
	l_desc.add_theme_font_size_override("font_size", 22)
	l_desc.add_theme_color_override("font_color", Color("#ddd6fe"))
	lv.add_child(l_desc)

	# Borrow Row
	var borrow_row := HBoxContainer.new()
	borrow_row.add_theme_constant_override("separation", 10)

	var btn_b25 := _create_cyber_button("🏦 Borrow $25,000", Color("#8b5cf6"), func():
		var r: Dictionary = BusinessManager.take_business_loan(target_biz, 25000)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Commercial loan of $25,000 disbursed into corporate treasury.")), "finance")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("financials", cur_uid)
		else:
			add_life_event(str(r.get("message", "Loan declined.")), "finance")
	)
	btn_b25.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_b25.custom_minimum_size.y = 50
	btn_b25.add_theme_font_size_override("font_size", 20)
	borrow_row.add_child(btn_b25)

	var btn_b100 := _create_cyber_button("🏦 Borrow $100,000", Color("#8b5cf6"), func():
		var r: Dictionary = BusinessManager.take_business_loan(target_biz, 100000)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Commercial loan of $100,000 disbursed into corporate treasury.")), "finance")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("financials", cur_uid)
		else:
			add_life_event(str(r.get("message", "Loan declined.")), "finance")
	)
	btn_b100.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_b100.custom_minimum_size.y = 50
	btn_b100.add_theme_font_size_override("font_size", 20)
	borrow_row.add_child(btn_b100)

	var btn_b500 := _create_cyber_button("🏦 Borrow $500,000", Color("#8b5cf6"), func():
		var r: Dictionary = BusinessManager.take_business_loan(target_biz, 500000)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Commercial loan of $500,000 disbursed into corporate treasury.")), "finance")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("financials", cur_uid)
		else:
			add_life_event(str(r.get("message", "Loan declined.")), "finance")
	)
	btn_b500.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_b500.custom_minimum_size.y = 50
	btn_b500.add_theme_font_size_override("font_size", 20)
	borrow_row.add_child(btn_b500)

	lv.add_child(borrow_row)

	# Repay Row
	if cur_loan > 0:
		var repay_row := HBoxContainer.new()
		repay_row.add_theme_constant_override("separation", 10)

		var btn_rep10 := _create_cyber_button("💳 Repay $10,000 Principal", Color("#10b981"), func():
			var r: Dictionary = BusinessManager.repay_business_loan(target_biz, 10000)
			if bool(r.get("success", false)):
				add_life_event(str(r.get("message", "Repaid $10,000 commercial loan principal from treasury.")), "finance")
				update_ui()
				SaveManager.save_game()
				_show_business_modal("financials", cur_uid)
			else:
				add_life_event(str(r.get("message", "Repayment failed.")), "finance")
		)
		btn_rep10.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_rep10.custom_minimum_size.y = 50
		btn_rep10.add_theme_font_size_override("font_size", 20)
		repay_row.add_child(btn_rep10)

		var btn_rep_all := _create_cyber_button("💳 Repay Full Balance ($%s)" % _format_number(cur_loan), Color("#10b981"), func():
			var r: Dictionary = BusinessManager.repay_business_loan(target_biz, cur_loan)
			if bool(r.get("success", false)):
				add_life_event(str(r.get("message", "Repaid entire commercial loan balance from treasury.")), "finance")
				update_ui()
				SaveManager.save_game()
				_show_business_modal("financials", cur_uid)
			else:
				add_life_event(str(r.get("message", "Repayment failed.")), "finance")
		)
		btn_rep_all.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_rep_all.custom_minimum_size.y = 50
		btn_rep_all.add_theme_font_size_override("font_size", 20)
		repay_row.add_child(btn_rep_all)

		var btn_rep_custom := _create_cyber_button("💳 Repay Custom Principal", Color("#10b981"), func():
			_show_business_repay_custom_loan(target_biz, cur_uid)
		, true)
		btn_rep_custom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_rep_custom.custom_minimum_size.y = 50
		btn_rep_custom.add_theme_font_size_override("font_size", 20)
		btn_rep_custom.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_rep_custom.set_meta("center_text", true)
		repay_row.add_child(btn_rep_custom)

		lv.add_child(repay_row)

	list.add_child(loan_card)

	# 4. Owner Capital Transfers & Dividends Section
	var equity_card := PanelContainer.new()
	equity_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#059669")))
	var em := MarginContainer.new()
	em.add_theme_constant_override("margin_left", 20)
	em.add_theme_constant_override("margin_right", 20)
	em.add_theme_constant_override("margin_top", 16)
	em.add_theme_constant_override("margin_bottom", 16)
	equity_card.add_child(em)

	var ev := VBoxContainer.new()
	ev.add_theme_constant_override("separation", 10)
	em.add_child(ev)

	var e_title := Label.new()
	e_title.text = "💵 CAPITAL TRANSFERS & OWNER DIVIDENDS"
	e_title.add_theme_font_size_override("font_size", 25)
	e_title.add_theme_color_override("font_color", Color("#ffffff"))
	ev.add_child(e_title)

	var e_desc := Label.new()
	e_desc.text = "Transfer liquidity between your personal funds and corporate treasury."
	e_desc.add_theme_font_size_override("font_size", 21)
	e_desc.add_theme_color_override("font_color", Color("#a7f3d0"))
	ev.add_child(e_desc)

	var transfer_amounts: Array[int] = [10000, 50000, 100000]
	for amt in transfer_amounts:
		var eq_row := HBoxContainer.new()
		eq_row.add_theme_constant_override("separation", 10)

		var btn_div := _create_cyber_button("💰 Withdraw $%s Dividend (Treasury -> Cash)" % _format_number(amt), Color("#10b981"), func():
			var r: Dictionary = BusinessManager.withdraw_owner_dividend(target_biz, amt)
			if bool(r.get("success", false)):
				add_life_event(str(r.get("message", "Withdrew $%s owner dividend." % _format_number(amt))), "finance")
				update_ui()
				SaveManager.save_game()
				_show_business_modal("financials", cur_uid)
			else:
				add_life_event(str(r.get("message", "Withdrawal failed.")), "finance")
		, true)
		btn_div.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_div.custom_minimum_size.y = 50
		btn_div.add_theme_font_size_override("font_size", 20)
		btn_div.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_div.set_meta("center_text", true)
		eq_row.add_child(btn_div)

		var btn_inj := _create_cyber_button("💵 Inject $%s Capital (Cash -> Treasury)" % _format_number(amt), Color("#0284c7"), func():
			var r: Dictionary = BusinessManager.deposit_owner_capital(target_biz, amt)
			if bool(r.get("success", false)):
				add_life_event(str(r.get("message", "Injected $%s capital into corporate treasury." % _format_number(amt))), "finance")
				update_ui()
				SaveManager.save_game()
				_show_business_modal("financials", cur_uid)
			else:
				add_life_event(str(r.get("message", "Injection failed.")), "finance")
		, true)
		btn_inj.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_inj.custom_minimum_size.y = 50
		btn_inj.add_theme_font_size_override("font_size", 20)
		btn_inj.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn_inj.set_meta("center_text", true)
		eq_row.add_child(btn_inj)

		ev.add_child(eq_row)

	var custom_eq_row := HBoxContainer.new()
	custom_eq_row.add_theme_constant_override("separation", 10)

	var btn_custom_div := _create_cyber_button("💰 Withdraw Custom Dividend", Color("#10b981"), func():
		_show_business_custom_dividend(target_biz, cur_uid)
	, true)
	btn_custom_div.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_custom_div.custom_minimum_size.y = 50
	btn_custom_div.add_theme_font_size_override("font_size", 20)
	btn_custom_div.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_custom_div.set_meta("center_text", true)
	custom_eq_row.add_child(btn_custom_div)

	var btn_custom_inj := _create_cyber_button("💵 Inject Custom Capital", Color("#0284c7"), func():
		_show_business_custom_capital(target_biz, cur_uid)
	, true)
	btn_custom_inj.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_custom_inj.custom_minimum_size.y = 50
	btn_custom_inj.add_theme_font_size_override("font_size", 20)
	btn_custom_inj.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_custom_inj.set_meta("center_text", true)
	custom_eq_row.add_child(btn_custom_inj)

	ev.add_child(custom_eq_row)
	list.add_child(equity_card)

	# 5. Corporate Treasury Expansion & Growth Operations (Item 3)
	var exp_card := PanelContainer.new()
	exp_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#0284c7")))
	var exp_m := MarginContainer.new()
	exp_m.add_theme_constant_override("margin_left", 20)
	exp_m.add_theme_constant_override("margin_right", 20)
	exp_m.add_theme_constant_override("margin_top", 16)
	exp_m.add_theme_constant_override("margin_bottom", 16)
	exp_card.add_child(exp_m)

	var exp_v := VBoxContainer.new()
	exp_v.add_theme_constant_override("separation", 10)
	exp_m.add_child(exp_v)

	var exp_title := Label.new()
	exp_title.text = "🚀 CORPORATE TREASURY REINVESTMENT & EXPANSION"
	exp_title.add_theme_font_size_override("font_size", 25)
	exp_title.add_theme_color_override("font_color", Color("#ffffff"))
	exp_v.add_child(exp_title)

	var exp_desc := Label.new()
	var cur_treasury: int = int(target_biz.get("treasury", 0))
	var branches: int = int(target_biz.get("branches", 1))
	var fac_tier: int = int(target_biz.get("facility_tier", 1))
	exp_desc.text = "Available Corporate Treasury: $%s\nDeploy corporate treasury funds to expand business branches, automate facilities, or fund advertising campaigns." % _format_number(cur_treasury)
	exp_desc.add_theme_font_size_override("font_size", 21)
	exp_desc.add_theme_color_override("font_color", Color("#bae6fd"))
	exp_v.add_child(exp_desc)

	# Branch Expansion Button
	var next_branch_cost := BusinessManager.get_branch_expansion_cost(target_biz)
	var btn_branch := _create_cyber_button("🏢 Open Branch #%d (Deploy $%s Treasury Funds)" % [branches + 1, _format_number(next_branch_cost)], Color("#0284c7"), func():
		_show_expand_branch_modal(target_biz, cur_uid)
	, true)
	btn_branch.custom_minimum_size.y = 52
	btn_branch.add_theme_font_size_override("font_size", 21)
	btn_branch.disabled = cur_treasury < next_branch_cost
	btn_branch.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_branch.set_meta("center_text", true)
	exp_v.add_child(btn_branch)

	# Facility Upgrade Button
	var fac_cost := 25000 * fac_tier
	var btn_fac := _create_cyber_button("⚙️ Upgrade Automation to Grade %d ($%s Treasury)" % [fac_tier + 1, _format_number(fac_cost)], Color("#8b5cf6"), func():
		var r := BusinessManager.upgrade_business_facilities(target_biz)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Facility upgraded!")), "finance")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("financials", cur_uid)
		else:
			add_life_event(str(r.get("message", "Could not upgrade.")), "finance")
	, true)
	btn_fac.custom_minimum_size.y = 52
	btn_fac.add_theme_font_size_override("font_size", 21)
	btn_fac.disabled = cur_treasury < fac_cost or fac_tier >= 5
	btn_fac.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_fac.set_meta("center_text", true)
	exp_v.add_child(btn_fac)

	# Marketing Blitz Button
	var btn_ad := _create_cyber_button("📢 Launch $25,000 National Advertising Blitz (Treasury)", Color("#f59e0b"), func():
		var r := BusinessManager.launch_treasury_marketing_blitz(target_biz, 25000)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Campaign launched!")), "finance")
			update_ui()
			SaveManager.save_game()
			_show_business_modal("financials", cur_uid)
		else:
			add_life_event(str(r.get("message", "Could not fund ad blitz.")), "finance")
	, true)
	btn_ad.custom_minimum_size.y = 52
	btn_ad.add_theme_font_size_override("font_size", 21)
	btn_ad.disabled = cur_treasury < 25000
	btn_ad.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_ad.set_meta("center_text", true)
	exp_v.add_child(btn_ad)

	list.add_child(exp_card)


func _show_rename_business_modal(biz: Dictionary) -> void:
	var uid: String = str(biz.get("uid", ""))
	var cur_name: String = str(biz.get("name", "Business"))
	var modal := _create_cyber_modal("✏️ RENAME ENTERPRISE", "Enter your desired trade or legal name for this enterprise.", Color("#f59e0b"))
	var list: VBoxContainer = modal.list

	var close_btn: Button = modal.get("close_btn")
	if close_btn != null:
		close_btn.pressed.connect(func():
			if is_instance_valid(modal.overlay):
				modal.overlay.queue_free()
		)

	var edit_box := VBoxContainer.new()
	edit_box.add_theme_constant_override("separation", 8)

	var name_lbl := Label.new()
	name_lbl.text = "New Enterprise Name:"
	name_lbl.add_theme_font_size_override("font_size", 21)
	name_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
	edit_box.add_child(name_lbl)

	var name_edit := LineEdit.new()
	name_edit.text = cur_name
	name_edit.placeholder_text = "Enter custom business name..."
	name_edit.custom_minimum_size.y = 50
	name_edit.add_theme_font_size_override("font_size", 22)
	var edit_sb := StyleBoxFlat.new()
	edit_sb.bg_color = Color("#071022")
	edit_sb.border_color = Color("#f59e0b")
	edit_sb.set_border_width_all(2)
	edit_sb.set_corner_radius_all(8)
	edit_sb.content_margin_left = 16
	edit_sb.content_margin_right = 16
	edit_sb.content_margin_top = 8
	edit_sb.content_margin_bottom = 8
	name_edit.add_theme_stylebox_override("normal", edit_sb)
	name_edit.add_theme_stylebox_override("focus", edit_sb)
	MobileKeyboardManager.attach_to_input(name_edit, "Enter new name for %s:" % cur_name)
	edit_box.add_child(name_edit)

	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(name_edit, "⌨️ Type New Business Name", "Enter new name for %s:" % cur_name, Color("#f59e0b"))
	edit_box.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(name_edit, "Enter new name for %s:" % cur_name)
	list.add_child(edit_box)

	var btn_save := _create_cyber_button("💾 Save Business Name", Color("#10b981"), func():
		var new_name := name_edit.text.strip_edges()
		if new_name != "":
			var r := BusinessManager.rename_business(uid, new_name)
			if bool(r.get("success", false)):
				add_life_event(str(r.get("message", "Enterprise name updated.")), "activity")
				update_ui()
				SaveManager.save_game()
				if is_instance_valid(modal.overlay):
					modal.overlay.queue_free()
				_show_business_modal("enterprises", uid)
			else:
				add_life_event(str(r.get("message", "Could not rename.")), "activity")
	)
	btn_save.custom_minimum_size.y = 54
	btn_save.add_theme_font_size_override("font_size", 22)
	list.add_child(btn_save)

func _show_expand_branch_modal(biz: Dictionary, cur_uid: String) -> void:
	var next_cost := BusinessManager.get_branch_expansion_cost(biz)
	var cur_treasury: int = int(biz.get("treasury", 0))
	var branches: int = int(biz.get("branches", 1))
	var parent_name: String = str(biz.get("name", "Enterprise"))
	var default_branch_name := "%s - Branch %d" % [parent_name, branches + 1]

	var modal := _create_cyber_modal("EXPAND BUSINESS BRANCH", "Deploy corporate treasury funds to establish an independent operational branch. The expanded business appears in your Owned Businesses with its own dedicated staff, finances, and micromanagement.", Color("#0284c7"))

	var summary := Label.new()
	summary.text = "🏛️ Parent Enterprise: %s\n💰 Available Corporate Treasury: $%s\n🏷️ Branch Capital Investment: $%s\n📊 Conglomerate Portfolio Tax: %d%% across all owned businesses" % [
		parent_name,
		_format_number(cur_treasury),
		_format_number(next_cost),
		int(BusinessManager.get_corporate_tax_rate(PlayerData.owned_businesses.size() + 1) * 100)
	]
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 23)
	summary.add_theme_color_override("font_color", Color("#bae6fd"))
	modal.list.add_child(summary)

	var name_box := VBoxContainer.new()
	name_box.add_theme_constant_override("separation", 8)

	var name_lbl := Label.new()
	name_lbl.text = "BRANCH TRADE NAME:"
	name_lbl.add_theme_font_size_override("font_size", 20)
	name_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	name_box.add_child(name_lbl)

	var name_edit := LineEdit.new()
	name_edit.text = default_branch_name
	name_edit.placeholder_text = "Enter custom branch name..."
	name_edit.custom_minimum_size.y = 54
	name_edit.add_theme_font_size_override("font_size", 22)
	get_node("OptionsMenu")._style_input(name_edit)
	MobileKeyboardManager.attach_to_input(name_edit, "Enter branch name for %s:" % parent_name)
	name_box.add_child(name_edit)

	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(name_edit, "⌨️ Enter Custom Branch Name", "Enter branch name for %s:" % parent_name, Color("#0284c7"))
	name_box.add_child(kb_btn)
	modal.list.add_child(name_box)

	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#ef4444"))
	feedback.add_theme_font_size_override("font_size", 22)
	modal.list.add_child(feedback)

	var btn_deploy := _create_cyber_button("🏢 Deploy $%s & Establish Branch" % _format_number(next_cost), Color("#0284c7"), func():
		var b_name := name_edit.text.strip_edges()
		if b_name.is_empty():
			feedback.text = "⚠️ Branch name cannot be blank."
			return
		if cur_treasury < next_cost:
			feedback.text = "⚠️ Insufficient corporate treasury ($%s available)." % _format_number(cur_treasury)
			return

		var r := BusinessManager.open_business_branch(biz, b_name)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Branch established!")), "milestone")
			update_ui()
			SaveManager.save_game()
			if is_instance_valid(modal.overlay):
				modal.overlay.queue_free()
			var new_uid: String = str(r.get("branch", {}).get("uid", cur_uid))
			_show_business_modal("overview", new_uid)
		else:
			feedback.text = "⚠️ " + str(r.get("message", "Could not open branch."))
	, true)
	btn_deploy.custom_minimum_size.y = 54
	btn_deploy.add_theme_font_size_override("font_size", 22)
	btn_deploy.alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_deploy.set_meta("center_text", true)
	btn_deploy.disabled = cur_treasury < next_cost
	modal.list.add_child(btn_deploy)

	modal.overlay.visible = true
	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(modal.overlay)


func _show_business_repay_custom_loan(biz: Dictionary, cur_uid: String) -> void:
	var cur_loan: int = int(biz.get("loan_balance", 0))
	var cur_treasury: int = int(biz.get("treasury", 0))
	var modal := _create_cyber_modal("REPAY COMMERCIAL LOAN", "Repay principal on this enterprise's commercial debt directly from corporate treasury.", Color("#10b981"))
	var summary := Label.new()
	summary.text = "Commercial Loan: $%s • Corporate Treasury: $%s" % [_format_number(cur_loan), _format_number(cur_treasury)]
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 24)
	summary.add_theme_color_override("font_color", Color("#e2e8f0"))
	modal.list.add_child(summary)

	var amount_input := LineEdit.new()
	amount_input.name = "CustomBusinessLoanRepayInput"
	amount_input.placeholder_text = "Enter whole dollars (Max: $%s)" % _format_number(mini(cur_loan, cur_treasury))
	amount_input.max_length = 15
	amount_input.custom_minimum_size.y = 70
	amount_input.virtual_keyboard_enabled = true
	amount_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount_input)
	get_node("OptionsMenu")._style_input(amount_input)

	MobileKeyboardManager.attach_to_input(amount_input, "Enter loan repayment amount (whole dollars):")
	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(amount_input, "⌨️ Type Custom Repayment Amount", "Enter loan repayment amount (whole dollars):", Color("#10b981"))
	modal.list.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(amount_input, "Enter loan repayment amount (whole dollars):")

	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#ef4444"))
	feedback.add_theme_font_size_override("font_size", 22)
	modal.list.add_child(feedback)

	var submit := _create_cyber_button("💳 Repay Commercial Loan", Color("#10b981"), func():
		var requested := _parse_loan_payment(amount_input.text)
		if requested <= 0:
			feedback.text = "⚠️ Enter a positive whole-dollar amount."
			return
		if requested > cur_loan:
			feedback.text = "⚠️ Repayment cannot exceed loan balance ($%s)." % _format_number(cur_loan)
			return
		if requested > cur_treasury:
			feedback.text = "⚠️ Insufficient corporate treasury ($%s available)." % _format_number(cur_treasury)
			return
		var r := BusinessManager.repay_business_loan(biz, requested)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Repaid $%s commercial loan principal from treasury." % _format_number(requested))), "finance")
			update_ui()
			SaveManager.save_game()
			if is_instance_valid(modal.overlay):
				modal.overlay.queue_free()
			_show_business_modal("financials", cur_uid)
		else:
			feedback.text = "⚠️ " + str(r.get("message", "Repayment failed."))
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)

	amount_input.text_changed.connect(func(val: String):
		var req := _parse_loan_payment(val)
		submit.disabled = req <= 0 or req > cur_loan or req > cur_treasury
		if submit.disabled and not val.is_empty():
			if req > cur_loan:
				feedback.text = "⚠️ Repayment cannot exceed loan balance ($%s)." % _format_number(cur_loan)
			elif req > cur_treasury:
				feedback.text = "⚠️ Insufficient treasury ($%s available)." % _format_number(cur_treasury)
			else:
				feedback.text = "⚠️ Enter a valid positive whole number."
		else:
			feedback.text = ""
	)

	modal.overlay.visible = true
	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(modal.overlay)


func _show_business_custom_dividend(biz: Dictionary, cur_uid: String) -> void:
	var cur_treasury: int = int(biz.get("treasury", 0))
	var modal := _create_cyber_modal("WITHDRAW OWNER DIVIDEND", "Withdraw funds from the corporate treasury directly into your personal cash.", Color("#10b981"))
	var summary := Label.new()
	summary.text = "Available Corporate Treasury: $%s" % _format_number(cur_treasury)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 24)
	summary.add_theme_color_override("font_color", Color("#a7f3d0"))
	modal.list.add_child(summary)

	var amount_input := LineEdit.new()
	amount_input.name = "CustomDividendInput"
	amount_input.placeholder_text = "Enter dividend amount (Max: $%s)" % _format_number(cur_treasury)
	amount_input.max_length = 15
	amount_input.custom_minimum_size.y = 70
	amount_input.virtual_keyboard_enabled = true
	amount_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount_input)
	get_node("OptionsMenu")._style_input(amount_input)

	MobileKeyboardManager.attach_to_input(amount_input, "Enter dividend withdrawal amount (whole dollars):")
	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(amount_input, "⌨️ Type Custom Dividend Amount", "Enter dividend withdrawal amount (whole dollars):", Color("#10b981"))
	modal.list.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(amount_input, "Enter dividend withdrawal amount (whole dollars):")

	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#ef4444"))
	feedback.add_theme_font_size_override("font_size", 22)
	modal.list.add_child(feedback)

	var submit := _create_cyber_button("💰 Withdraw Dividend", Color("#10b981"), func():
		var requested := _parse_loan_payment(amount_input.text)
		if requested <= 0:
			feedback.text = "⚠️ Enter a positive whole-dollar amount."
			return
		if requested > cur_treasury:
			feedback.text = "⚠️ Withdrawal cannot exceed treasury ($%s available)." % _format_number(cur_treasury)
			return
		var r := BusinessManager.withdraw_owner_dividend(biz, requested)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Withdrew $%s owner dividend." % _format_number(requested))), "finance")
			update_ui()
			SaveManager.save_game()
			if is_instance_valid(modal.overlay):
				modal.overlay.queue_free()
			_show_business_modal("financials", cur_uid)
		else:
			feedback.text = "⚠️ " + str(r.get("message", "Withdrawal failed."))
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)

	amount_input.text_changed.connect(func(val: String):
		var req := _parse_loan_payment(val)
		submit.disabled = req <= 0 or req > cur_treasury
		if submit.disabled and not val.is_empty():
			feedback.text = "⚠️ Amount must be between $1 and $%s." % _format_number(cur_treasury)
		else:
			feedback.text = ""
	)

	modal.overlay.visible = true
	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(modal.overlay)


func _show_business_custom_capital(biz: Dictionary, cur_uid: String) -> void:
	var avail_funds: int = PlayerData.get_available_funds()
	var modal := _create_cyber_modal("INJECT OWNER CAPITAL", "Inject personal cash and savings into the corporate treasury to expand working capital.", Color("#0284c7"))
	var summary := Label.new()
	summary.text = "Available Personal Funds: $%s" % _format_number(avail_funds)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_font_size_override("font_size", 24)
	summary.add_theme_color_override("font_color", Color("#bae6fd"))
	modal.list.add_child(summary)

	var amount_input := LineEdit.new()
	amount_input.name = "CustomCapitalInput"
	amount_input.placeholder_text = "Enter capital injection (Max: $%s)" % _format_number(avail_funds)
	amount_input.max_length = 15
	amount_input.custom_minimum_size.y = 70
	amount_input.virtual_keyboard_enabled = true
	amount_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	amount_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal.list.add_child(amount_input)
	get_node("OptionsMenu")._style_input(amount_input)

	MobileKeyboardManager.attach_to_input(amount_input, "Enter capital injection amount (whole dollars):")
	var kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(amount_input, "⌨️ Type Custom Capital Amount", "Enter capital injection amount (whole dollars):", Color("#0284c7"))
	modal.list.add_child(kb_btn)
	MobileKeyboardManager.open_keyboard.call_deferred(amount_input, "Enter capital injection amount (whole dollars):")

	var feedback := Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.add_theme_color_override("font_color", Color("#ef4444"))
	feedback.add_theme_font_size_override("font_size", 22)
	modal.list.add_child(feedback)

	var submit := _create_cyber_button("💵 Inject Capital", Color("#0284c7"), func():
		var requested := _parse_loan_payment(amount_input.text)
		if requested <= 0:
			feedback.text = "⚠️ Enter a positive whole-dollar amount."
			return
		if requested > avail_funds:
			feedback.text = "⚠️ Injection cannot exceed available funds ($%s available)." % _format_number(avail_funds)
			return
		var r := BusinessManager.deposit_owner_capital(biz, requested)
		if bool(r.get("success", false)):
			add_life_event(str(r.get("message", "Injected $%s capital into corporate treasury." % _format_number(requested))), "finance")
			update_ui()
			SaveManager.save_game()
			if is_instance_valid(modal.overlay):
				modal.overlay.queue_free()
			_show_business_modal("financials", cur_uid)
		else:
			feedback.text = "⚠️ " + str(r.get("message", "Injection failed."))
	, true)
	submit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	submit.set_meta("center_text", true)
	submit.disabled = true
	modal.list.add_child(submit)

	amount_input.text_changed.connect(func(val: String):
		var req := _parse_loan_payment(val)
		submit.disabled = req <= 0 or req > avail_funds
		if submit.disabled and not val.is_empty():
			feedback.text = "⚠️ Amount must be between $1 and $%s." % _format_number(avail_funds)
		else:
			feedback.text = ""
	)

	modal.overlay.visible = true
	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(modal.overlay)


# -----------------------------------------------------------------------------
# ASSET PANEL OWNED BUSINESSES SECTION
# -----------------------------------------------------------------------------
func _render_owned_businesses_section() -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"
	var section_card := PanelContainer.new()
	section_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	section_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 14)
	sm.add_child(sv)

	var stitle := Label.new()
	stitle.text = "🏢 COMMERCIAL ENTERPRISES & BUSINESSES (%d)" % PlayerData.owned_businesses.size()
	stitle.add_theme_font_size_override("font_size", 24)
	stitle.add_theme_color_override("font_color", Color("#b45309") if is_light else Color("#fbbf24"))
	sv.add_child(stitle)

	# Dedicated business button located directly below owned real estate
	var btn_biz := _create_cyber_button("🏢 Cyber Enterprises (Business Acquisitions & Startups)", Color("#f59e0b"), func():
		_show_business_modal()
	)
	btn_biz.custom_minimum_size.y = 56
	btn_biz.add_theme_font_size_override("font_size", 22)
	sv.add_child(btn_biz)

	if PlayerData.owned_businesses.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "You do not currently own any commercial enterprises. Click the button above to explore business incorporation opportunities!"
		empty_lbl.add_theme_font_size_override("font_size", 20)
		empty_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sv.add_child(empty_lbl)
	else:
		for b in PlayerData.owned_businesses:
			var card := PanelContainer.new()
			card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#d97706")))
			var cm := MarginContainer.new()
			cm.add_theme_constant_override("margin_left", 16)
			cm.add_theme_constant_override("margin_right", 16)
			cm.add_theme_constant_override("margin_top", 14)
			cm.add_theme_constant_override("margin_bottom", 14)
			card.add_child(cm)

			var cv := VBoxContainer.new()
			cv.add_theme_constant_override("separation", 8)
			cm.add_child(cv)

			var name_lbl := Label.new()
			name_lbl.text = "%s %s" % [str(b.get("icon", "🏢")), str(b.get("name", "Business"))]
			name_lbl.add_theme_font_size_override("font_size", 24)
			name_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#ffffff"))
			name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			cv.add_child(name_lbl)

			var val_lbl := Label.new()
			val_lbl.text = "Valuation: $%s  •  Treasury: $%s  •  Staff: %d" % [
				_format_number(int(b.get("valuation", 0))),
				_format_number(int(b.get("treasury", 0))),
				int(b.get("employees", 4))
			]
			val_lbl.add_theme_font_size_override("font_size", 20)
			val_lbl.add_theme_color_override("font_color", Color("#15803d") if is_light else Color("#fde68a"))
			cv.add_child(val_lbl)

			var btn_manage := _create_cyber_button("💰 Open Financials & Operations", Color("#f59e0b"), func():
				_show_business_modal("financials", str(b.get("uid", "")))
			)
			btn_manage.custom_minimum_size.y = 48
			btn_manage.add_theme_font_size_override("font_size", 20)
			cv.add_child(btn_manage)

			sv.add_child(card)

	assets_list.add_child(section_card)


# -----------------------------------------------------------------------------
# YEARLY AGING EVENT HELPERS (DISASTERS, FREELANCE, BUSINESSES)
# -----------------------------------------------------------------------------
func _check_asset_disaster_event() -> void:
	if PlayerData.owned_assets.is_empty():
		return

	var disaster_chance: float = 0.015
	if PlayerData.karma < 25:
		disaster_chance = 0.035

	if randf() > disaster_chance:
		return

	var count: int = PlayerData.owned_assets.size()
	var disasters := [
		{
			"title": "🌋 Catastrophic Regional Earthquake",
			"msg": "A devastating 7.8 magnitude earthquake leveled the metro district! Your residences collapsed into rubble and garage foundations caved in. All %d of your titled properties and vehicle assets have been completely destroyed!" % count
		},
		{
			"title": "🔥 Uncontrolled Urban Wildfire",
			"msg": "An uncontrollable industrial mega-fire swept through the hillside district. Despite automated sprinkler systems, raging flames destroyed all %d of your vehicles and properties!" % count
		},
		{
			"title": "⚖️ High-Court Lawsuit & Asset Forfeiture",
			"msg": "A crushing corporate liability verdict and civil lawsuit judgment ruled against you! Court bailiffs and federal marshals seized all %d of your titled real estate and vehicle assets for liquidation!" % count
		},
		{
			"title": "🏴‍☠️ Syndicate Organized Grand Heist",
			"msg": "An elite cyber criminal syndicate breached municipal title databases and executed an armed raid! All %d of your registered vehicles and deeded real estate holdings were stolen, title-wiped, and lost!" % count
		}
	]

	var disaster: Dictionary = disasters.pick_random()
	PlayerData.owned_assets.clear()
	PlayerData.happiness = maxi(5, PlayerData.happiness - 30)
	add_life_event("🚨 %s: %s" % [disaster["title"], disaster["msg"]], "disaster")
	_show_simple_popup("🚨 CATASTROPHIC ASSET LOSS", "%s\n\n%s" % [disaster["title"], disaster["msg"]], Color("#ef4444"))


func _process_yearly_freelance_projects() -> void:
	if PlayerData.active_freelance_jobs.is_empty():
		return

	var completed: Array[Dictionary] = FreelanceManager.generate_yearly_random_projects()
	for item in completed:
		var proj: Dictionary = item.get("project", {})
		var res: Dictionary = item.get("result", {})
		add_life_event("💼 FREELANCE PROJECT: Completed '%s' for %s (Earned $%s)." % [
			str(proj.get("title", "Project")),
			str(proj.get("client", "Client")),
			_format_number(int(res.get("pay", 0)))
		], "finance")


func _process_yearly_business_operations() -> void:
	if PlayerData.owned_businesses.is_empty():
		return

	var results: Array[Dictionary] = BusinessManager.simulate_yearly_businesses()
	for r in results:
		var profit_str: String = ("+$%s" % _format_number(int(r["net_profit"]))) if int(r["net_profit"]) >= 0 else ("-$%s" % _format_number(abs(int(r["net_profit"]))))
		add_life_event("🏢 %s Year-End Audit: Revenue: $%s | Net Profit: %s | Corporate Tax Accrued: $%s." % [
			str(r.get("name", "Business")),
			_format_number(int(r.get("revenue", 0))),
			profit_str,
			_format_number(int(r.get("tax_accrued", 0)))
		], "finance")


func _show_education_modal() -> void:
	if education_modal_overlay != null and is_instance_valid(education_modal_overlay):
		education_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🎓 ACADEMY & EDUCATION", "Academic Records, Grades, Study Habits & Scholarships", Color("#818cf8"))
	education_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# Academic Summary Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#818cf8")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 12)
	sm.add_child(sv)

	var level_lbl := Label.new()
	if PlayerData.age < 3:
		level_lbl.text = "🏫 Academic Status: Early Childhood (Age %d)" % PlayerData.age
	else:
		level_lbl.text = "🏫 Academic Status: %s" % PlayerData.get_education_display_string()
	level_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_lbl.add_theme_font_size_override("font_size", 28)
	level_lbl.add_theme_color_override("font_color", Color("#c7d2fe"))
	sv.add_child(level_lbl)

	var grade_color := Color("#22c55e") if PlayerData.grades >= 80 else (Color("#38bdf8") if PlayerData.grades >= 65 else Color("#f87171"))
	var grade_lbl := Label.new()
	if PlayerData.age < 3:
		grade_lbl.text = "🧸 School Enrollment: Kindergarten begins at age 3 (in %d year%s)" % [3 - PlayerData.age, "s" if (3 - PlayerData.age) > 1 else ""]
		grade_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
	else:
		grade_lbl.text = "📊 Current Marks / GPA: %d%% (%s)" % [PlayerData.grades, PlayerData.get_letter_grade()]
		grade_lbl.add_theme_color_override("font_color", grade_color)
	grade_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	grade_lbl.add_theme_font_size_override("font_size", 28)
	sv.add_child(grade_lbl)

	var schol_lbl := Label.new()
	if PlayerData.has_scholarship:
		schol_lbl.text = "🏆 University Scholarship: 100% Full-Ride Tuition Waiver Active"
		schol_lbl.add_theme_color_override("font_color", Color("#34d399"))
	elif PlayerData.education_level == "University Student":
		schol_lbl.text = "🏛️ University Tuition: $%s / yr (%s)" % [_format_number(PlayerData.university_tuition), PlayerData.university_name]
		schol_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
	elif PlayerData.age < 14:
		schol_lbl.text = "🏆 University Scholarship: Unlocks in High School (Age 16+)"
		schol_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	else:
		schol_lbl.text = "🏆 University Scholarship: None (Tuition varies by institution)"
		schol_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	schol_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	schol_lbl.add_theme_font_size_override("font_size", 25)
	sv.add_child(schol_lbl)

	var impact_lbl := Label.new()
	impact_lbl.text = "Career Impact: Academic marks directly dictate career qualification. High grades unlock high-paying corporate, tech, and medical careers; failing grades restrict you to low-paying manual labor."
	impact_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	impact_lbl.add_theme_font_size_override("font_size", 23)
	impact_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	sv.add_child(impact_lbl)

	list.add_child(summary_card)

	var is_student: bool = PlayerData.education_level in ["Kindergarten", "Primary School", "Middle School", "High School", "University Student"]

	# Academic Refresher Course / Expired Standing Alert (MANDATORY when grades == 0)
	if PlayerData.grades == 0 and PlayerData.age >= 3:
		var alert_card := PanelContainer.new()
		alert_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#ef4444")))
		var am := MarginContainer.new()
		am.add_theme_constant_override("margin_left", 22)
		am.add_theme_constant_override("margin_right", 22)
		am.add_theme_constant_override("margin_top", 16)
		am.add_theme_constant_override("margin_bottom", 16)
		alert_card.add_child(am)

		var av := VBoxContainer.new()
		av.add_theme_constant_override("separation", 12)
		am.add_child(av)

		var atitle := Label.new()
		atitle.text = "🚨 ACADEMIC RECORD EXPIRED (0% MARKS)"
		atitle.add_theme_font_size_override("font_size", 28)
		atitle.add_theme_color_override("font_color", Color("#ef4444"))
		av.add_child(atitle)

		var adesc := Label.new()
		adesc.text = "Your academic qualification has completely lapsed due to prolonged neglect. University admissions and formal job applications are locked. YOU MUST COMPLETE AN ACADEMIC REFRESHER COURSE TO RESTORE YOUR STANDING."
		adesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		adesc.add_theme_font_size_override("font_size", 23)
		adesc.add_theme_color_override("font_color", Color("#fca5a5"))
		av.add_child(adesc)

		var course_cost: int = 500 if (PlayerData.age < 18 or is_student) else 1200
		var cost_str := "$%s Tuition" % _format_number(course_cost)
		var btn_course := _create_cyber_button("🎓 Take Academic Refresher Course (%s)\nComplete remedial coursework and exams to restore your marks to 75%%!" % cost_str, Color("#ef4444"), func():
			_start_refresher_course(course_cost)
		)
		av.add_child(btn_course)

		list.add_child(alert_card)
	elif PlayerData.grades < 70 and PlayerData.age >= 6:
		var improve_cost: int = 250 if (PlayerData.age < 18 or is_student) else 600
		var cost_str := "$%s Tuition" % _format_number(improve_cost)
		var btn_improve := _create_cyber_button("📚 Take Academic Improvement Course (%s)\nEnroll in remedial curriculum to restore your marks to at least 75%%!" % cost_str, Color("#f59e0b"), func():
			_start_refresher_course(improve_cost)
		)
		list.add_child(btn_improve)

	# Interactive Educational Minigames Section (Math & Trivia Guessing directly affect grades)
	if PlayerData.age >= 3:
		var mg_header := Label.new()
		mg_header.text = "🎮 EDUCATIONAL MINIGAMES & PRACTICAL EXAMS"
		mg_header.add_theme_font_size_override("font_size", 28)
		mg_header.add_theme_color_override("font_color", Color("#38bdf8"))
		list.add_child(mg_header)

		var mg_desc := Label.new()
		mg_desc.text = "Participate in educational challenges! Correct answers directly boost your Academic Marks (+5% per answer) and protect against yearly degradation:"
		mg_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		mg_desc.add_theme_font_size_override("font_size", 22)
		mg_desc.add_theme_color_override("font_color", Color("#cbd5e1"))
		list.add_child(mg_desc)

		var has_done_mg_this_year: bool = (PlayerData.last_school_activity_age == PlayerData.age)
		if has_done_mg_this_year:
			list.add_child(_create_disabled_cyber_button("📐 Quick Math Challenge\nCompleted for Age %d (Age up to play again next year)" % PlayerData.age, "Annual educational activity completed."))
			list.add_child(_create_disabled_cyber_button("🧠 Trivia & Knowledge Guessing\nCompleted for Age %d (Age up to play again next year)" % PlayerData.age, "Annual educational activity completed."))
		else:
			var btn_math := _create_cyber_button("📐 Quick Math Challenge\nSolve rapid math equations • Correct answers directly boost Grades & Smarts!", Color("#38bdf8"), func():
				_start_education_minigame("math")
			)
			list.add_child(btn_math)

			var btn_trivia := _create_cyber_button("🧠 Trivia & Knowledge Guessing\nAnswer science, history & logic questions • Directly boosts Grades!", Color("#a855f7"), func():
				_start_education_minigame("trivia")
			)
			list.add_child(btn_trivia)

	# Annual Action Gating Banner
	var has_done_school_activity_this_year: bool = (PlayerData.last_school_activity_age == PlayerData.age)
	if has_done_school_activity_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 20)
		lm.add_theme_constant_override("margin_right", 20)
		lm.add_theme_constant_override("margin_top", 14)
		lm.add_theme_constant_override("margin_bottom", 14)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL SCHOOL PARTICIPATION COMPLETED\nYou have already taken a school activity for Age %d.\nAcademic activities are concluded for this school year. Advance age (+1 Year) to participate again!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 23)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

	# Interactive Academic Options


	if PlayerData.age < 3:
		# Early Childhood Development Activities
		var infant_tip := Label.new()
		infant_tip.text = "🧸 Early Cognitive Development: Kindergarten enrollment begins at age 3. Interactive learning activities build your character's intelligence and emotional happiness early on:"
		infant_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		infant_tip.add_theme_font_size_override("font_size", 21)
		infant_tip.add_theme_color_override("font_color", Color("#93c5fd"))
		list.add_child(infant_tip)

		if has_done_school_activity_this_year:
			list.add_child(_create_disabled_cyber_button("🧸 Picture Books & Nursery Rhymes\nExplore colorful books and alphabet songs.", "Completed for Age %d (Age up to continue next year)" % PlayerData.age))
			list.add_child(_create_disabled_cyber_button("🧩 Shape Sorting & Building Blocks\nSolve motor puzzles and spatial coordination.", "Completed for Age %d (Age up to continue next year)" % PlayerData.age))
			list.add_child(_create_disabled_cyber_button("🎨 Finger Painting & Music Play\nExplore vibrant colors and playful sounds.", "Completed for Age %d (Age up to continue next year)" % PlayerData.age))
		else:
			var btn_books := _create_cyber_button("🧸 Picture Books & Nursery Rhymes\nExplore colorful books and alphabet songs.", Color("#818cf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				PlayerData.smarts = mini(100, PlayerData.smarts + randi_range(3, 5))
				PlayerData.happiness = mini(100, PlayerData.happiness + randi_range(5, 8))
				add_life_event("You flipped through colorful picture books and learned letters and animal sounds. (+Smarts, +Happiness)", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_books)

			var btn_blocks := _create_cyber_button("🧩 Shape Sorting & Building Blocks\nSolve motor puzzles and spatial coordination.", Color("#38bdf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				PlayerData.smarts = mini(100, PlayerData.smarts + randi_range(4, 6))
				PlayerData.happiness = mini(100, PlayerData.happiness + randi_range(3, 6))
				add_life_event("You successfully fitted triangular and circular wooden blocks into the sorter! (+Smarts, +Happiness)", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_blocks)

			var btn_music := _create_cyber_button("🎨 Finger Painting & Music Play\nExplore vibrant colors and playful sounds.", Color("#ec4899"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				PlayerData.smarts = mini(100, PlayerData.smarts + randi_range(1, 3))
				PlayerData.happiness = mini(100, PlayerData.happiness + randi_range(7, 10))
				add_life_event("You gleefully smeared bright finger paint all over paper (and your face)! (+Happiness)", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_music)

	elif is_student:
		# 1. Study Hard
		if has_done_school_activity_this_year:
			list.add_child(_create_disabled_cyber_button("📖 Study Diligently\nHit the books and complete extra homework assignments.", "Already studied or engaged in school activities for Age %d (Age up to next year)" % PlayerData.age))
		else:
			var btn_study := _create_cyber_button("📖 Study Diligently\nHit the books and complete extra homework assignments.", Color("#818cf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var g_gain := randi_range(6, 10)
				var s_gain := randi_range(2, 4)
				var h_loss := randi_range(3, 5)
				PlayerData.grades = mini(100, PlayerData.grades + g_gain)
				PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
				PlayerData.happiness = maxi(0, PlayerData.happiness - h_loss)
				add_life_event("You studied diligently, completing extra credit and reviewing notes.", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_study)

		# 2. Slack Off at School
		if has_done_school_activity_this_year:
			list.add_child(_create_disabled_cyber_button("🎮 Slack Off in Class\nDaydream, mess around, and skip homework.", "Already participated in school activities for Age %d (Age up to next year)" % PlayerData.age))
		else:
			var btn_slack := _create_cyber_button("🎮 Slack Off in Class\nDaydream, mess around, and skip homework.", Color("#f59e0b"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var g_loss := randi_range(8, 14)
				var h_gain := randi_range(6, 11)
				PlayerData.grades = maxi(0, PlayerData.grades - g_loss)
				PlayerData.happiness = mini(100, PlayerData.happiness + h_gain)
				PlayerData.smarts = maxi(0, PlayerData.smarts - 1)
				if randf() < 0.28:
					PlayerData.happiness = maxi(5, PlayerData.happiness - 8)
					add_life_event("🚨 DETENTION: A teacher caught you goofing off during class and assigned after-school detention!", "education")
				else:
					add_life_event("You slacked off in class, joked around with friends, and skipped homework.", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_slack)

		# 3. Bully Someone
		if has_done_school_activity_this_year:
			list.add_child(_create_disabled_cyber_button("😈 Bully a Classmate\nRisk of Getting Beaten Up or Suspended", "Already engaged in school conduct for Age %d (Age up to next year)" % PlayerData.age))
		else:
			var btn_bully := _create_cyber_button("😈 Bully a Classmate\nRisk of Getting Beaten Up or Suspended", Color("#ef4444"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var roll := randf()
				if roll < 0.40:
					PlayerData.karma -= 20
					PlayerData.happiness = mini(100, PlayerData.happiness + 4)
					add_life_event("😈 Cruel Victory: You bullied a classmate and mocked their clothes. They ran away crying.", "education")
				elif roll < 0.75:
					PlayerData.karma -= 20
					PlayerData.health = maxi(5, PlayerData.health - randi_range(8, 15))
					PlayerData.happiness = maxi(5, PlayerData.happiness - 10)
					add_life_event("💥 RETALIATION: You tried to bully someone, but they punched you right in the nose!", "education")
				else:
					PlayerData.karma -= 25
					PlayerData.happiness = maxi(5, PlayerData.happiness - 15)
					if PlayerData.mother_relationship > 0:
						PlayerData.mother_relationship = maxi(0, PlayerData.mother_relationship - 15)
					add_life_event("🚨 SUSPENDED: The principal caught you bullying and suspended you for 3 days! Your parents are thoroughly disgusted.", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_bully)

		# 4. Lead Group Study
		if has_done_school_activity_this_year:
			list.add_child(_create_disabled_cyber_button("👥 Lead Group Study\nOrganize a collaborative study group with peers. (Req: 55%+ Grades)", "Already participated in school activities for Age %d (Age up to next year)" % PlayerData.age))
		else:
			var btn_group := _create_cyber_button("👥 Lead Group Study\nOrganize a collaborative study group with peers. (Req: 55%+ Grades)", Color("#22c55e"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				if PlayerData.grades < 55:
					add_life_event("Low Marks: You need at least 55%% academic marks to tutor and lead a study group (Current: %d%%)." % PlayerData.grades, "education")
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var g_gain := randi_range(4, 7)
				var s_gain := randi_range(2, 4)
				var k_gain := randi_range(10, 15)
				PlayerData.grades = mini(100, PlayerData.grades + g_gain)
				PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
				PlayerData.karma += k_gain
				PlayerData.happiness = mini(100, PlayerData.happiness + 6)
				add_life_event("👥 Group Leadership: You organized an effective peer study group. Everyone's marks improved! Grades +%d%%." % g_gain, "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_group)

		# 5. Drop Out of School (High School only; forbidden for younger)
		if PlayerData.education_level == "High School":
			var btn_dropout := _create_cyber_button("🚪 Drop Out of High School\nQuit school permanently. Locks out college & professional degree careers.", Color("#dc2626"), func():
				PlayerData.education_level = "High School Dropout"
				PlayerData.happiness = maxi(5, PlayerData.happiness - 10)
				add_life_event("🚪 You made the drastic decision to drop out of High School at age %d to enter the real world. University is now out of reach." % PlayerData.age, "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_dropout)
		elif PlayerData.education_level in ["Kindergarten", "Primary School", "Middle School"]:
			var btn_dropout_lock := _create_cyber_button("🚪 Drop Out of School [LOCKED]\nTruancy laws mandate compulsory education. Kindergarten, Primary, and Middle schoolers cannot drop out!", Color("#475569"), func():
				add_life_event("Compulsory Education: By law, students cannot drop out before High School (Age 14+).", "education")
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_dropout_lock)

		# 6. Private Tutor
		if has_done_school_activity_this_year:
			list.add_child(_create_disabled_cyber_button("👨‍🏫 Hire Academic Tutor ($200)\nPrivate instruction to reinforce challenging subjects.", "Already engaged private tutoring or study activities for Age %d (Age up to next year)" % PlayerData.age))
		else:
			var btn_tutor := _create_cyber_button("👨‍🏫 Hire Academic Tutor ($200)\nPrivate instruction to reinforce challenging subjects.", Color("#38bdf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				if PlayerData.get_available_funds() >= 200:
					PlayerData.last_school_activity_age = PlayerData.age
					PlayerData.debit_funds(200)
					var g_gain := randi_range(10, 15)
					PlayerData.grades = mini(100, PlayerData.grades + g_gain)
					add_life_event("You worked with a private academic tutor ($200). Grades improved +%d%%!" % g_gain, "education")
					update_ui()
					SaveManager.save_game()
					_close_education_modal_and_return_to_main()
				elif PlayerData.age < 18 and (PlayerData.mother_relationship >= 60 or PlayerData.father_relationship >= 60):
					PlayerData.last_school_activity_age = PlayerData.age
					var g_gain := randi_range(10, 15)
					PlayerData.grades = mini(100, PlayerData.grades + g_gain)
					add_life_event("Your supportive parents happily paid $200 for a private tutor. Grades improved +%d%%!" % g_gain, "education")
					update_ui()
					SaveManager.save_game()
					_close_education_modal_and_return_to_main()
				else:
					add_life_event("You cannot afford a private academic tutor ($200 required).", "education")
					_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_tutor)

	# Apply for Scholarship (High Schoolers Age 16+)
	if PlayerData.age >= 16 and PlayerData.education_level == "High School" and not PlayerData.has_scholarship:
		if PlayerData.last_scholarship_applied_age == PlayerData.age:
			list.add_child(_create_disabled_cyber_button("🏆 Apply for Full-Ride Scholarship\n100% University Tuition Waiver (Req: 82%+ Grades, 65+ Smarts)", "Scholarship application already submitted for Age %d (Awaiting board review next year)" % PlayerData.age))
		else:
			var btn_schol := _create_cyber_button("🏆 Apply for Full-Ride Scholarship\n100% University Tuition Waiver (Req: 82%+ Grades, 65+ Smarts)", Color("#fbbf24"), func():
				PlayerData.last_scholarship_applied_age = PlayerData.age
				if PlayerData.grades >= 82 and PlayerData.smarts >= 65:
					PlayerData.has_scholarship = true
					PlayerData.happiness = mini(100, PlayerData.happiness + 20)
					PlayerData.karma += 5
					add_life_event("🏆 SCHOLARSHIP AWARDED! The National Academic Board awarded you a 100% full-ride tuition waiver for university!", "education")
				else:
					PlayerData.happiness = maxi(0, PlayerData.happiness - 5)
					add_life_event("Scholarship Denied: Committee requires at least 82%% academic grades and 65 smarts (Current: %d%% grades, %d smarts)." % [PlayerData.grades, PlayerData.smarts], "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_schol)

	# Active University Student Status Card
	if PlayerData.education_level == "University Student":
		var uni_active := PanelContainer.new()
		uni_active.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#00f0ff")))
		var um := MarginContainer.new()
		um.add_theme_constant_override("margin_left", 24)
		um.add_theme_constant_override("margin_right", 24)
		um.add_theme_constant_override("margin_top", 18)
		um.add_theme_constant_override("margin_bottom", 18)
		uni_active.add_child(um)

		var uv := VBoxContainer.new()
		uv.add_theme_constant_override("separation", 14)
		um.add_child(uv)

		var u_title := Label.new()
		u_title.text = "🏛️ ACTIVE UNIVERSITY ENROLLMENT (OBLIGATED 4 YEARS)"
		u_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		u_title.add_theme_font_size_override("font_size", 28)
		u_title.add_theme_color_override("font_color", Color("#00f0ff"))
		uv.add_child(u_title)

		var u_inst := Label.new()
		var yr_current: int = maxi(1, PlayerData.university_years + 1)
		u_inst.text = "Institution: %s\nMajor: %s   •   Degree in Progress: %s\nProgress: Completed %d of 4 Years (Currently in Year %d)" % [
			PlayerData.university_name,
			PlayerData.university_major_title,
			PlayerData.university_degree,
			PlayerData.university_years,
			yr_current
		]
		u_inst.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		u_inst.add_theme_font_size_override("font_size", 24)
		u_inst.add_theme_color_override("font_color", Color("#f8fafc"))
		uv.add_child(u_inst)

		var t_info := Label.new()
		var t_cost: int = PlayerData.university_tuition if PlayerData.university_tuition > 0 else 12000
		t_info.text = "Annual Tuition: Free (Scholarship Active)" if PlayerData.has_scholarship else "Annual Tuition: $%s / yr" % _format_number(t_cost)
		t_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t_info.add_theme_font_size_override("font_size", 23)
		t_info.add_theme_color_override("font_color", Color("#34d399") if PlayerData.has_scholarship else Color("#fbbf24"))
		uv.add_child(t_info)

		if has_done_school_activity_this_year:
			uv.add_child(_create_disabled_cyber_button("📖 Intensive Major Coursework Study\nHit the library and master course exams.", "Completed for Age %d (Age up to study again next year)" % PlayerData.age))
		else:
			var btn_study_uni := _create_cyber_button("📖 Intensive Major Coursework Study\nHit the library and master course exams.", Color("#38bdf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var g_gain := randi_range(2, 4)
				var s_gain := randi_range(2, 4)
				PlayerData.grades = mini(100, PlayerData.grades + g_gain)
				PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
				PlayerData.happiness = maxi(5, PlayerData.happiness - 3)
				add_life_event("You studied late into the night preparing for %s midterms." % PlayerData.university_major_title, "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			uv.add_child(btn_study_uni)

		# Drop out choice: allowed ONLY after completing Year 1, 2, or 3 (PlayerData.university_years in [1, 2, 3])
		if PlayerData.university_years < 1:
			var btn_drop_locked := _create_disabled_cyber_button(
				"🚪 Drop Out of University",
				"OBLIGATED: You are currently completing Year 1. Dropping out unlocks after completing Year 1 (Years 1-3)."
			)
			uv.add_child(btn_drop_locked)
		elif PlayerData.university_years in [1, 2, 3]:
			var btn_drop_uni := _create_cyber_button(
				"🚪 Drop Out of University (Completed Year %d of 4)\nAbandon degree in %s. Stop tuition and enter workforce or take another path later." % [
					PlayerData.university_years,
					PlayerData.university_major_title
				],
				Color("#ef4444"),
				func():
					var u_name := PlayerData.university_name
					var m_name := PlayerData.university_major_title
					var yrs := PlayerData.university_years
					PlayerData.education_level = "University Dropout"
					PlayerData.university_years = 0
					PlayerData.university_name = ""
					PlayerData.university_major = ""
					PlayerData.university_major_title = ""
					PlayerData.university_degree = ""
					PlayerData.university_tuition = 0
					add_life_event("🚪 You made the choice to drop out of %s after completing %d year(s) in %s. You can enter the workforce or enroll in another study path in the future." % [u_name, yrs, m_name], "education")
					update_ui()
					SaveManager.save_game()
					_close_education_modal_and_return_to_main()
			)
			uv.add_child(btn_drop_uni)

		list.add_child(uni_active)

	# -------------------------------------------------------------
	# UNIVERSITY ENROLLMENT & STUDY PATHS (DEDICATED BUTTON)
	# -------------------------------------------------------------
	var uni_header := Label.new()
	uni_header.text = "🏛️ UNIVERSITY ENROLLMENT & STUDY PATHS"
	uni_header.add_theme_font_size_override("font_size", 28)
	uni_header.add_theme_color_override("font_color", Color("#38bdf8"))
	list.add_child(uni_header)

	var can_view_uni_catalog: bool = PlayerData.age >= 18 and (PlayerData.education_level in ["High School", "High School Graduate", "University Graduate", "University Dropout", "University Student"])
	if can_view_uni_catalog:
		var uni_btn_desc := ""
		if PlayerData.education_level == "University Student":
			uni_btn_desc = "Currently enrolled at %s (Year %d of 4) • View enrollment status, course catalog & study paths >" % [
				PlayerData.university_name,
				maxi(1, PlayerData.university_years + 1)
			]
		elif PlayerData.degrees.size() > 0:
			uni_btn_desc = "%d Degree(s) Conferred (Alumnus) • Explore new university majors & career study paths >" % PlayerData.degrees.size()
		elif PlayerData.education_level == "High School Dropout":
			uni_btn_desc = "Browse accredited institutions & degree study paths (GED required to enroll) >"
		else:
			uni_btn_desc = "Browse accredited institutions, admission prerequisites, tuitions & career trajectories >"

		var btn_uni := _create_cyber_button("🏛️ University Enrollment & Study Paths\n%s" % uni_btn_desc, Color("#38bdf8"), func():
			_show_university_modal("enrollment")
		)
		btn_uni.custom_minimum_size.y = 80
		list.add_child(btn_uni)
	else:
		var btn_uni_locked := _create_disabled_cyber_button(
			"🏛️ University Enrollment & Study Paths\nBrowse accredited institutions, admission prerequisites, tuitions & career trajectories",
			"Unlocks at Age 18 upon high school graduation (or GED equivalency)."
		)
		list.add_child(btn_uni_locked)

	# Dropout Overview Card & GED option
	if PlayerData.education_level == "High School Dropout":
		var drop_card := PanelContainer.new()
		drop_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#ef4444")))
		var dm := MarginContainer.new()
		dm.add_theme_constant_override("margin_left", 20)
		dm.add_theme_constant_override("margin_right", 20)
		dm.add_theme_constant_override("margin_top", 14)
		dm.add_theme_constant_override("margin_bottom", 14)
		drop_card.add_child(dm)
		var dl := Label.new()
		dl.text = "⚠️ DROPOUT STATUS: You dropped out of high school. High-skill careers and University admission are barred. You can study for your GED to restore high school credential."
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.add_theme_font_size_override("font_size", 21)
		dl.add_theme_color_override("font_color", Color("#fca5a5"))
		dm.add_child(dl)
		list.add_child(drop_card)

		if PlayerData.last_ged_attempt_age == PlayerData.age:
			list.add_child(_create_disabled_cyber_button("📜 Study & Sit for GED Equivalency ($500)\nHigh school equivalency credential restores university admission (Req: 60+ Smarts)", "Already sat for GED examination for Age %d (Retakes available next year)" % PlayerData.age))
		else:
			var btn_ged := _create_cyber_button("📜 Study & Sit for GED Equivalency ($500)\nHigh school equivalency credential restores university admission (Req: 60+ Smarts)", Color("#38bdf8"), func():
				if PlayerData.get_available_funds() < 500:
					add_life_event("You cannot afford the $500 GED exam registration fees.", "education")
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_ged_attempt_age = PlayerData.age
				PlayerData.debit_funds(500)
				if PlayerData.smarts >= 60:
					PlayerData.education_level = "High School Graduate"
					PlayerData.grades = 75
					PlayerData.happiness = mini(100, PlayerData.happiness + 20)
					add_life_event("🎉 DIPLOMA EARNED! You passed the GED examinations! You are now a certified High School Graduate.", "education")
				else:
					PlayerData.happiness = maxi(5, PlayerData.happiness - 10)
					add_life_event("GED Failed: You scored below passing grade. Boost your Smarts before retaking.", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			list.add_child(btn_ged)

	# University Graduate Honors Card
	if PlayerData.education_level == "University Graduate" or PlayerData.degrees.size() > 0:
		var grad_card := PanelContainer.new()
		grad_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
		var gm := MarginContainer.new()
		gm.add_theme_constant_override("margin_left", 24)
		gm.add_theme_constant_override("margin_right", 24)
		gm.add_theme_constant_override("margin_top", 18)
		gm.add_theme_constant_override("margin_bottom", 18)
		grad_card.add_child(gm)

		var gv := VBoxContainer.new()
		gv.add_theme_constant_override("separation", 10)
		gm.add_child(gv)

		var gl := Label.new()
		gl.text = "🎓 UNIVERSITY ALUMNUS • COMPLETED DEGREES (%d)" % maxi(1, PlayerData.degrees.size())
		gl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		gl.add_theme_font_size_override("font_size", 28)
		gl.add_theme_color_override("font_color", Color("#34d399"))
		gv.add_child(gl)

		if PlayerData.degrees.is_empty():
			var d_str: String = PlayerData.university_degree if PlayerData.university_degree != "" else "Bachelor's Degree"
			var m_str: String = PlayerData.university_major_title if PlayerData.university_major_title != "" else "Specialized Major"
			var g_sub := Label.new()
			g_sub.text = "%s in %s @ %s\nFinal Academic Marks: %d%% (%s)\nAll careers requiring %s are permanently unlocked!" % [
				d_str,
				m_str,
				PlayerData.university_name,
				PlayerData.grades,
				PlayerData.get_letter_grade(),
				m_str
			]
			g_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			g_sub.add_theme_font_size_override("font_size", 24)
			g_sub.add_theme_color_override("font_color", Color("#a7f3d0"))
			gv.add_child(g_sub)
		else:
			for d_idx in range(PlayerData.degrees.size()):
				var deg_item: Dictionary = PlayerData.degrees[d_idx]
				var deg_lbl := Label.new()
				deg_lbl.text = "Degree #%d: %s in %s @ %s (Graduated Age %d)" % [
					d_idx + 1,
					str(deg_item.get("degree", "Bachelor's Degree")),
					str(deg_item.get("major_title", "Major")),
					str(deg_item.get("university", "University")),
					int(deg_item.get("year_graduated", PlayerData.age))
				]
				deg_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				deg_lbl.add_theme_font_size_override("font_size", 24)
				deg_lbl.add_theme_color_override("font_color", Color("#a7f3d0"))
				gv.add_child(deg_lbl)

		var path_note := Label.new()
		path_note.text = "✨ Multiple Study Paths: Having completed a 4-year degree, you are free to enroll in another university and pursue additional degrees at any time!"
		path_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_note.add_theme_font_size_override("font_size", 22)
		path_note.add_theme_color_override("font_color", Color("#6ee7b7"))
		gv.add_child(path_note)

		list.add_child(grad_card)

	# 8. Public Library & Lifelong Self-Study (Age 5+)
	if PlayerData.age >= 5:
		var lib_card := PanelContainer.new()
		lib_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
		var lm_lib := MarginContainer.new()
		lm_lib.add_theme_constant_override("margin_left", 24)
		lm_lib.add_theme_constant_override("margin_right", 24)
		lm_lib.add_theme_constant_override("margin_top", 18)
		lm_lib.add_theme_constant_override("margin_bottom", 18)
		lib_card.add_child(lm_lib)

		var lv_lib := VBoxContainer.new()
		lv_lib.add_theme_constant_override("separation", 12)
		lm_lib.add_child(lv_lib)

		var lib_title := Label.new()
		lib_title.text = "📚 PUBLIC LIBRARY & LIFELONG SELF-STUDY"
		lib_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lib_title.add_theme_font_size_override("font_size", 28)
		lib_title.add_theme_color_override("font_color", Color("#38bdf8"))
		lv_lib.add_child(lib_title)

		var lib_desc := Label.new()
		lib_desc.text = "Cognitive Maintenance: Without regular education, reading, or mental challenge, your Smarts level naturally degrades each year. Reading literature or taking professional workshops maintains and expands your intellect."
		lib_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lib_desc.add_theme_font_size_override("font_size", 22)
		lib_desc.add_theme_color_override("font_color", Color("#cbd5e1"))
		lv_lib.add_child(lib_desc)

		if has_done_school_activity_this_year:
			lv_lib.add_child(_create_disabled_cyber_button("📖 Read Non-Fiction & Books at Public Library (Free)\nBroaden your knowledge and prevent annual cognitive decline", "Annual academic study completed for Age %d (Age up to read again next year)" % PlayerData.age))
			lv_lib.add_child(_create_disabled_cyber_button("💻 Professional Skill & Certification Seminar ($150)\nAttend intensive professional skill workshops and seminars", "Annual academic study completed for Age %d (Age up to attend next year)" % PlayerData.age))
		else:
			var btn_read := _create_cyber_button("📖 Read Non-Fiction & Books at Public Library (Free)\nBroaden your knowledge and prevent annual cognitive decline", Color("#38bdf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var s_gain := randi_range(2, 4)
				PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
				PlayerData.happiness = mini(100, PlayerData.happiness + randi_range(2, 4))
				add_life_event("📖 You spent the afternoon reading science, history, and philosophy books at the public library. Knowledge broadened!", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			lv_lib.add_child(btn_read)

			var btn_seminar := _create_cyber_button("💻 Professional Skill & Certification Seminar ($150)\nAttend intensive professional skill workshops and seminars", Color("#818cf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					_close_education_modal_and_return_to_main()
					return
				if PlayerData.get_available_funds() < 150:
					add_life_event("You cannot afford the $150 registration fee for the professional certification seminar.", "education")
					_close_education_modal_and_return_to_main()
					return
				PlayerData.last_school_activity_age = PlayerData.age
				PlayerData.debit_funds(150)
				var s_gain := randi_range(3, 5)
				PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
				PlayerData.happiness = mini(100, PlayerData.happiness + 2)
				add_life_event("💻 You completed an intensive accredited professional skill seminar ($150). Analytical prowess sharpened!", "education")
				update_ui()
				SaveManager.save_game()
				_close_education_modal_and_return_to_main()
			)
			lv_lib.add_child(btn_seminar)

		list.add_child(lib_card)

	education_modal_overlay.visible = true


func _show_university_modal(initial_tab: String = "enrollment") -> void:
	if university_modal_overlay != null and is_instance_valid(university_modal_overlay):
		university_modal_overlay.queue_free()

	var tab: String = initial_tab if initial_tab in ["enrollment", "study_paths"] else "enrollment"

	var modal := _create_cyber_modal("🏛️ UNIVERSITY & STUDY PATHS", "Accredited Institutions, Degree Tracks & Career Trajectories", Color("#38bdf8"))
	university_modal_overlay = modal.overlay
	university_modal_overlay.z_index = 85
	var list: VBoxContainer = modal.list

	var is_light: bool = LifeLibrary.data.theme == "light"

	# Top Category Tab Bar (Pinned above scroll container)
	var tab_bar := HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 12)
	tab_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var btn_tab_enroll := _create_cyber_button("🏛️ Enrollment List", Color("#38bdf8") if tab == "enrollment" else Color("#475569"), func():
		_show_university_modal("enrollment")
	)
	btn_tab_enroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_enroll.custom_minimum_size.y = 52
	btn_tab_enroll.add_theme_font_size_override("font_size", 21)
	btn_tab_enroll.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_category_tab_styling(btn_tab_enroll, tab == "enrollment", is_light)
	tab_bar.add_child(btn_tab_enroll)

	var btn_tab_paths := _create_cyber_button("📜 Study Paths", Color("#38bdf8") if tab == "study_paths" else Color("#475569"), func():
		_show_university_modal("study_paths")
	)
	btn_tab_paths.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_paths.custom_minimum_size.y = 52
	btn_tab_paths.add_theme_font_size_override("font_size", 21)
	btn_tab_paths.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_category_tab_styling(btn_tab_paths, tab == "study_paths", is_light)
	tab_bar.add_child(btn_tab_paths)

	modal.vbox.add_child(tab_bar)
	modal.vbox.move_child(tab_bar, 2)

	# Content based on selected tab
	match tab:
		"enrollment":
			_render_university_enrollment_category(list)
		"study_paths":
			_render_university_study_paths_category(list)

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(university_modal_overlay)

	university_modal_overlay.visible = true


func _apply_category_tab_styling(btn: Button, is_active: bool, is_light: bool) -> void:
	var style := StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10

	if is_active:
		style.bg_color = Color("#bae6fd") if is_light else Color("#0c4a6e")
		style.border_color = Color("#0284c7") if is_light else Color("#38bdf8")
		btn.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color("#f0f9ff"))
	else:
		style.bg_color = Color("#f1f5f9") if is_light else Color("#0f172a")
		style.border_color = Color("#cbd5e1") if is_light else Color("#334155")
		btn.add_theme_color_override("font_color", Color("#64748b") if is_light else Color("#94a3b8"))

	btn.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#93c5fd") if is_light else Color("#1e3a5f")
	btn.add_theme_stylebox_override("hover", hover)


func _render_university_enrollment_category(list: VBoxContainer) -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"

	# Academic Credentials & Standing Summary Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var status_lbl := Label.new()
	status_lbl.text = "🏫 Academic Status: %s" % PlayerData.get_education_display_string()
	status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_lbl.add_theme_font_size_override("font_size", 28)
	status_lbl.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
	sv.add_child(status_lbl)

	var g_color := Color("#16a34a") if is_light else Color("#22c55e")
	if PlayerData.grades < 65:
		g_color = Color("#dc2626") if is_light else Color("#f87171")
	elif PlayerData.grades < 80:
		g_color = Color("#0284c7") if is_light else Color("#38bdf8")

	var grade_lbl := Label.new()
	grade_lbl.text = "📊 Current Marks / GPA: %d%% (%s)   •   🧠 Smarts: %d" % [
		PlayerData.grades,
		PlayerData.get_letter_grade(),
		PlayerData.smarts
	]
	grade_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	grade_lbl.add_theme_font_size_override("font_size", 24)
	grade_lbl.add_theme_color_override("font_color", g_color)
	sv.add_child(grade_lbl)

	var schol_lbl := Label.new()
	if PlayerData.has_scholarship:
		schol_lbl.text = "🏆 University Scholarship: 100% Full-Ride Tuition Waiver Active"
		schol_lbl.add_theme_color_override("font_color", Color("#059669") if is_light else Color("#34d399"))
	else:
		schol_lbl.text = "🏆 University Scholarship: None (Standard annual tuition applies)"
		schol_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
	schol_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	schol_lbl.add_theme_font_size_override("font_size", 23)
	sv.add_child(schol_lbl)

	var funds_lbl := Label.new()
	var total_avail: int = PlayerData.money + PlayerData.bank_savings
	funds_lbl.text = "💳 Financial Capital: Cash $%s   •   Bank Savings: $%s (Total: $%s)" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		_format_number(total_avail)
	]
	funds_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	funds_lbl.add_theme_font_size_override("font_size", 23)
	funds_lbl.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
	sv.add_child(funds_lbl)

	list.add_child(summary_card)

	# Active University Student Status Card (if currently enrolled)
	var is_currently_enrolled: bool = (PlayerData.education_level == "University Student")
	if is_currently_enrolled:
		var uni_active := PanelContainer.new()
		uni_active.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#0284c7") if is_light else Color("#00f0ff")))
		var um := MarginContainer.new()
		um.add_theme_constant_override("margin_left", 24)
		um.add_theme_constant_override("margin_right", 24)
		um.add_theme_constant_override("margin_top", 18)
		um.add_theme_constant_override("margin_bottom", 18)
		uni_active.add_child(um)

		var uv := VBoxContainer.new()
		uv.add_theme_constant_override("separation", 14)
		um.add_child(uv)

		var u_title := Label.new()
		u_title.text = "🏛️ ACTIVE UNIVERSITY ENROLLMENT (OBLIGATED 4 YEARS)"
		u_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		u_title.add_theme_font_size_override("font_size", 28)
		u_title.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#00f0ff"))
		uv.add_child(u_title)

		var u_inst := Label.new()
		var yr_current: int = maxi(1, PlayerData.university_years + 1)
		u_inst.text = "Institution: %s\nMajor: %s   •   Degree in Progress: %s\nProgress: Completed %d of 4 Years (Currently in Year %d)" % [
			PlayerData.university_name,
			PlayerData.university_major_title,
			PlayerData.university_degree,
			PlayerData.university_years,
			yr_current
		]
		u_inst.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		u_inst.add_theme_font_size_override("font_size", 24)
		u_inst.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		uv.add_child(u_inst)

		var t_info := Label.new()
		var t_cost: int = PlayerData.university_tuition if PlayerData.university_tuition > 0 else 12000
		t_info.text = "Annual Tuition: Free (Scholarship Active)" if PlayerData.has_scholarship else "Annual Tuition: $%s / yr" % _format_number(t_cost)
		t_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		t_info.add_theme_font_size_override("font_size", 23)
		t_info.add_theme_color_override("font_color", Color("#059669") if is_light else Color("#34d399") if PlayerData.has_scholarship else (Color("#b45309") if is_light else Color("#fbbf24")))
		uv.add_child(t_info)

		var has_done_study: bool = (PlayerData.last_school_activity_age == PlayerData.age)
		if has_done_study:
			uv.add_child(_create_disabled_cyber_button("📖 Intensive Major Coursework Study\nHit the library and master course exams.", "Completed for Age %d (Age up to study again next year)" % PlayerData.age))
		else:
			var btn_study_uni := _create_cyber_button("📖 Intensive Major Coursework Study\nHit the library and master course exams.", Color("#38bdf8"), func():
				if PlayerData.last_school_activity_age == PlayerData.age:
					return
				PlayerData.last_school_activity_age = PlayerData.age
				var g_gain := randi_range(2, 4)
				var s_gain := randi_range(2, 4)
				PlayerData.grades = mini(100, PlayerData.grades + g_gain)
				PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
				PlayerData.happiness = maxi(5, PlayerData.happiness - 3)
				add_life_event("You studied late into the night preparing for %s midterms. Grades +%d%%, Smarts +%d." % [PlayerData.university_major_title, g_gain, s_gain], "education")
				update_ui()
				SaveManager.save_game()
				_show_university_modal("enrollment")
			)
			uv.add_child(btn_study_uni)

		if PlayerData.university_years < 1:
			var btn_drop_locked := _create_disabled_cyber_button(
				"🚪 Drop Out of University",
				"OBLIGATED: You are currently completing Year 1. Dropping out unlocks after completing Year 1 (Years 1-3)."
			)
			uv.add_child(btn_drop_locked)
		elif PlayerData.university_years in [1, 2, 3]:
			var btn_drop_uni := _create_cyber_button(
				"🚪 Drop Out of University (Completed Year %d of 4)\nAbandon degree in %s. Stop tuition and enter workforce or take another path later." % [
					PlayerData.university_years,
					PlayerData.university_major_title
				],
				Color("#ef4444"),
				func():
					var u_name := PlayerData.university_name
					var m_name := PlayerData.university_major_title
					var yrs := PlayerData.university_years
					PlayerData.education_level = "University Dropout"
					PlayerData.university_years = 0
					PlayerData.university_name = ""
					PlayerData.university_major = ""
					PlayerData.university_major_title = ""
					PlayerData.university_degree = ""
					PlayerData.university_tuition = 0
					add_life_event("🚪 You made the choice to drop out of %s after completing %d year(s) in %s. You can enter the workforce or enroll in another study path in the future." % [u_name, yrs, m_name], "education")
					update_ui()
					SaveManager.save_game()
					_show_university_modal("enrollment")
			)
			uv.add_child(btn_drop_uni)

		list.add_child(uni_active)

	# Institutions Catalog
	var cat_header := Label.new()
	cat_header.text = "🏛️ ACCREDITED INSTITUTIONS & ENROLLMENT"
	cat_header.add_theme_font_size_override("font_size", 30)
	cat_header.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
	list.add_child(cat_header)

	var cat_sub := Label.new()
	cat_sub.text = "Choose an accredited institution and major. Characters may only enroll in one university at a time and are obligated to study for 4 years. After graduating, you can take another study path!"
	cat_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cat_sub.add_theme_font_size_override("font_size", 23)
	cat_sub.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#cbd5e1"))
	list.add_child(cat_sub)

	var institutions: Array = EducationCatalog.get_all_institutions()
	for inst in institutions:
		if not (inst is Dictionary):
			continue
		var raw_col := Color(str(inst.get("theme_color", "#38bdf8")))
		var col := raw_col.darkened(0.35) if (is_light and raw_col.get_luminance() > 0.45) else raw_col
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(col))

		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 22)
		m.add_theme_constant_override("margin_right", 22)
		m.add_theme_constant_override("margin_top", 18)
		m.add_theme_constant_override("margin_bottom", 18)
		card.add_child(m)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 10)
		m.add_child(vb)

		var inst_title := Label.new()
		inst_title.text = "%s  %s" % [str(inst.get("icon", "🏛️")), str(inst.get("name", ""))]
		inst_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inst_title.add_theme_font_size_override("font_size", 28)
		inst_title.add_theme_color_override("font_color", col)
		vb.add_child(inst_title)

		var inst_tagline := Label.new()
		inst_tagline.text = str(inst.get("tagline", ""))
		inst_tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inst_tagline.add_theme_font_size_override("font_size", 23)
		inst_tagline.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color("#93c5fd"))
		vb.add_child(inst_tagline)

		var inst_major := Label.new()
		inst_major.text = "🎓 Major: %s  •  %s" % [str(inst.get("major_title", "")), str(inst.get("degree_title", ""))]
		inst_major.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inst_major.add_theme_font_size_override("font_size", 25)
		inst_major.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		vb.add_child(inst_major)

		var inst_careers := Label.new()
		var c_list: Array = inst.get("unlocked_careers", [])
		inst_careers.text = "🎯 Unlocks Careers: %s" % ", ".join(c_list)
		inst_careers.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inst_careers.add_theme_font_size_override("font_size", 23)
		inst_careers.add_theme_color_override("font_color", Color("#059669") if is_light else Color("#34d399"))
		vb.add_child(inst_careers)

		var inst_desc := Label.new()
		inst_desc.text = str(inst.get("description", ""))
		inst_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inst_desc.add_theme_font_size_override("font_size", 22)
		inst_desc.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
		vb.add_child(inst_desc)

		var tuition_amount: int = int(inst.get("tuition", 12000))
		var tuition_text := "Free (Scholarship Active)" if PlayerData.has_scholarship else "$%s / yr" % _format_number(tuition_amount)
		var req_eval: Dictionary = EducationCatalog.can_enroll(inst, PlayerData.grades, PlayerData.smarts)
		var is_eligible: bool = bool(req_eval.get("allowed", false))

		if is_currently_enrolled:
			var locked_btn := Button.new()
			locked_btn.set_meta("reference_part", true)
			locked_btn.set_meta("market_button", true)
			locked_btn.custom_minimum_size.y = 52
			locked_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			locked_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			locked_btn.text = "🔒 OBLIGATED: Currently studying at %s (Year %d of 4)\nOnly 1 university allowed at a time. Must complete 4-year degree or drop out before enrolling." % [
				PlayerData.university_name,
				maxi(1, PlayerData.university_years + 1)
			]
			locked_btn.disabled = true
			var lk_style := StyleBoxFlat.new()
			lk_style.bg_color = Color("#e2e8f0") if is_light else Color("#181f2f")
			lk_style.border_color = Color("#94a3b8") if is_light else Color("#475569")
			lk_style.set_border_width_all(2)
			lk_style.set_corner_radius_all(10)
			lk_style.content_margin_left = 16
			lk_style.content_margin_right = 16
			lk_style.content_margin_top = 10
			lk_style.content_margin_bottom = 10
			locked_btn.add_theme_stylebox_override("disabled", lk_style)
			locked_btn.add_theme_color_override("font_disabled_color", Color("#475569") if is_light else Color("#94a3b8"))
			locked_btn.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
			locked_btn.add_theme_font_size_override("font_size", 20)
			vb.add_child(locked_btn)
		elif is_eligible:
			var enroll_btn := _create_cyber_button("🏛️ Enroll in %s (%s)\nReq Met: %d%% GPA & %d Smarts" % [
				str(inst.get("major_title", "")),
				tuition_text,
				int(inst.get("min_grades", 60)),
				int(inst.get("min_smarts", 50))
			], col, func():
				PlayerData.education_level = "University Student"
				PlayerData.university_name = str(inst.get("name", ""))
				PlayerData.university_major = str(inst.get("major", ""))
				PlayerData.university_major_title = str(inst.get("major_title", ""))
				PlayerData.university_degree = str(inst.get("degree_title", ""))
				PlayerData.university_tuition = tuition_amount
				PlayerData.university_years = 0
				add_life_event("🏛️ You enrolled at %s majoring in %s! Complete 4 years to earn your %s." % [
					PlayerData.university_name,
					PlayerData.university_major_title,
					PlayerData.university_degree
				], "milestone")
				update_ui()
				SaveManager.save_game()
				_show_university_modal("enrollment")
				if education_modal_overlay != null and is_instance_valid(education_modal_overlay):
					_show_education_modal()
			)
			vb.add_child(enroll_btn)
		else:
			var locked_btn := Button.new()
			locked_btn.set_meta("reference_part", true)
			locked_btn.set_meta("market_button", true)
			locked_btn.custom_minimum_size.y = 52
			locked_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			locked_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			locked_btn.text = "🔒 LOCKED: " + str(req_eval.get("reason", "Ineligible"))
			locked_btn.disabled = true
			var lk_style := StyleBoxFlat.new()
			lk_style.bg_color = Color("#e2e8f0") if is_light else Color("#181f2f")
			lk_style.border_color = Color("#cbd5e1") if is_light else Color("#334155")
			lk_style.set_border_width_all(2)
			lk_style.set_corner_radius_all(10)
			lk_style.content_margin_left = 16
			lk_style.content_margin_right = 16
			lk_style.content_margin_top = 10
			lk_style.content_margin_bottom = 10
			locked_btn.add_theme_stylebox_override("disabled", lk_style)
			locked_btn.add_theme_color_override("font_disabled_color", Color("#64748b") if is_light else Color("#94a3b8"))
			locked_btn.add_theme_color_override("font_color", Color("#64748b") if is_light else Color("#94a3b8"))
			locked_btn.add_theme_font_size_override("font_size", 20)
			vb.add_child(locked_btn)

		list.add_child(card)


func _render_university_study_paths_category(list: VBoxContainer) -> void:
	var is_light: bool = LifeLibrary.data.theme == "light"

	# Orientation / Summary Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var p_title := Label.new()
	p_title.text = "📜 ACADEMIC STUDY PATHS & CAREER TRAJECTORIES"
	p_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p_title.add_theme_font_size_override("font_size", 28)
	p_title.add_theme_color_override("font_color", Color("#059669") if is_light else Color("#34d399"))
	sv.add_child(p_title)

	var p_desc := Label.new()
	p_desc.text = "Higher education unlocks high-earning professional careers. Completing a 4-year degree permanently confers the degree and qualifies you for its corporate, tech, medical, and specialized jobs. Characters are free to take multiple study paths throughout their lifetime!"
	p_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p_desc.add_theme_font_size_override("font_size", 23)
	p_desc.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
	sv.add_child(p_desc)

	list.add_child(summary_card)

	# Completed Degrees Summary Card (if any)
	if PlayerData.degrees.size() > 0:
		var deg_card := PanelContainer.new()
		deg_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
		var dm := MarginContainer.new()
		dm.add_theme_constant_override("margin_left", 24)
		dm.add_theme_constant_override("margin_right", 24)
		dm.add_theme_constant_override("margin_top", 18)
		dm.add_theme_constant_override("margin_bottom", 18)
		deg_card.add_child(dm)

		var dv := VBoxContainer.new()
		dv.add_theme_constant_override("separation", 10)
		dm.add_child(dv)

		var deg_header := Label.new()
		deg_header.text = "🎓 CONFERRED DEGREES & ALUMNUS HONORS (%d)" % PlayerData.degrees.size()
		deg_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		deg_header.add_theme_font_size_override("font_size", 26)
		deg_header.add_theme_color_override("font_color", Color("#0284c7") if is_light else Color("#38bdf8"))
		dv.add_child(deg_header)

		for d_idx in range(PlayerData.degrees.size()):
			var deg_item: Dictionary = PlayerData.degrees[d_idx]
			var d_lbl := Label.new()
			d_lbl.text = "• Degree #%d: %s in %s @ %s (Graduated Age %d)" % [
				d_idx + 1,
				str(deg_item.get("degree", "Bachelor's Degree")),
				str(deg_item.get("major_title", "Major")),
				str(deg_item.get("university", "University")),
				int(deg_item.get("year_graduated", PlayerData.age))
			]
			d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			d_lbl.add_theme_font_size_override("font_size", 23)
			d_lbl.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
			dv.add_child(d_lbl)

		list.add_child(deg_card)

	# All Study Paths
	var institutions: Array = EducationCatalog.get_all_institutions()
	for inst in institutions:
		if not (inst is Dictionary):
			continue
		var raw_col := Color(str(inst.get("theme_color", "#38bdf8")))
		var col := raw_col.darkened(0.35) if (is_light and raw_col.get_luminance() > 0.45) else raw_col
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", load_style_box_cyber_card(col))

		var m := MarginContainer.new()
		m.add_theme_constant_override("margin_left", 22)
		m.add_theme_constant_override("margin_right", 22)
		m.add_theme_constant_override("margin_top", 18)
		m.add_theme_constant_override("margin_bottom", 18)
		card.add_child(m)

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 10)
		m.add_child(vb)

		var path_title := Label.new()
		path_title.text = "%s  %s Track" % [str(inst.get("icon", "📜")), str(inst.get("major_title", "Major"))]
		path_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_title.add_theme_font_size_override("font_size", 28)
		path_title.add_theme_color_override("font_color", col)
		vb.add_child(path_title)

		var path_deg := Label.new()
		path_deg.text = "📜 Conferred Degree: %s" % str(inst.get("degree_title", ""))
		path_deg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_deg.add_theme_font_size_override("font_size", 24)
		path_deg.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
		vb.add_child(path_deg)

		var path_inst := Label.new()
		path_inst.text = "🏛️ Offered by: %s (%s)" % [str(inst.get("name", "")), str(inst.get("tagline", ""))]
		path_inst.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_inst.add_theme_font_size_override("font_size", 22)
		path_inst.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color("#93c5fd"))
		vb.add_child(path_inst)

		var path_req := Label.new()
		path_req.text = "📋 Admission Prerequisites: %d%% Minimum GPA   •   %d Smarts" % [
			int(inst.get("min_grades", 60)),
			int(inst.get("min_smarts", 50))
		]
		path_req.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_req.add_theme_font_size_override("font_size", 22)
		path_req.add_theme_color_override("font_color", Color("#d97706") if is_light else Color("#fbbf24"))
		vb.add_child(path_req)

		var path_careers := Label.new()
		var c_list: Array = inst.get("unlocked_careers", [])
		path_careers.text = "🎯 Career Trajectory (Job Market Unlocks):\n  • " + "\n  • ".join(c_list)
		path_careers.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_careers.add_theme_font_size_override("font_size", 23)
		path_careers.add_theme_color_override("font_color", Color("#059669") if is_light else Color("#34d399"))
		vb.add_child(path_careers)

		var path_desc := Label.new()
		path_desc.text = str(inst.get("description", ""))
		path_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		path_desc.add_theme_font_size_override("font_size", 22)
		path_desc.add_theme_color_override("font_color", Color("#334155") if is_light else Color("#cbd5e1"))
		vb.add_child(path_desc)

		# Check completion status
		var is_deg_completed: bool = false
		for d in PlayerData.degrees:
			if str(d.get("major", "")).to_lower() == str(inst.get("major", "")).to_lower():
				is_deg_completed = true
				break

		var is_currently_studying_this: bool = (PlayerData.education_level == "University Student" and PlayerData.university_major.to_lower() == str(inst.get("major", "")).to_lower())
		var is_currently_enrolled: bool = (PlayerData.education_level == "University Student")

		if is_deg_completed:
			var btn_jobs := _create_cyber_button("✅ Degree Conferred • View Unlocked Careers in Job Market >", Color("#10b981"), func():
				if university_modal_overlay != null and is_instance_valid(university_modal_overlay):
					university_modal_overlay.queue_free()
					university_modal_overlay = null
				if education_modal_overlay != null and is_instance_valid(education_modal_overlay):
					education_modal_overlay.queue_free()
					education_modal_overlay = null
				_show_jobs_modal()
			)
			vb.add_child(btn_jobs)
		elif is_currently_studying_this:
			var btn_curr := _create_cyber_button("📖 Current Active Major Track (Year %d of 4) • Manage Enrollment >" % maxi(1, PlayerData.university_years + 1), Color("#00f0ff"), func():
				_show_university_modal("enrollment")
			)
			vb.add_child(btn_curr)
		elif is_currently_enrolled:
			var locked_btn := Button.new()
			locked_btn.set_meta("reference_part", true)
			locked_btn.set_meta("market_button", true)
			locked_btn.custom_minimum_size.y = 50
			locked_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			locked_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			locked_btn.text = "🔒 Currently Enrolled at %s (Must graduate or drop out before taking this study path)" % PlayerData.university_name
			locked_btn.disabled = true
			var lk_style := StyleBoxFlat.new()
			lk_style.bg_color = Color("#e2e8f0") if is_light else Color("#181f2f")
			lk_style.border_color = Color("#94a3b8") if is_light else Color("#475569")
			lk_style.set_border_width_all(2)
			lk_style.set_corner_radius_all(10)
			lk_style.content_margin_left = 16
			lk_style.content_margin_right = 16
			lk_style.content_margin_top = 10
			lk_style.content_margin_bottom = 10
			locked_btn.add_theme_stylebox_override("disabled", lk_style)
			locked_btn.add_theme_color_override("font_disabled_color", Color("#475569") if is_light else Color("#94a3b8"))
			locked_btn.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
			locked_btn.add_theme_font_size_override("font_size", 20)
			vb.add_child(locked_btn)
		else:
			var req_eval: Dictionary = EducationCatalog.can_enroll(inst, PlayerData.grades, PlayerData.smarts)
			var is_eligible: bool = bool(req_eval.get("allowed", false))
			if is_eligible:
				var btn_apply := _create_cyber_button("🏛️ View & Enroll in this Study Path at %s >" % str(inst.get("name", "")), col, func():
					_show_university_modal("enrollment")
				)
				vb.add_child(btn_apply)
			else:
				var locked_btn := Button.new()
				locked_btn.set_meta("reference_part", true)
				locked_btn.set_meta("market_button", true)
				locked_btn.custom_minimum_size.y = 50
				locked_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				locked_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				locked_btn.text = "🔒 LOCKED: " + str(req_eval.get("reason", "Ineligible"))
				locked_btn.disabled = true
				var lk_style := StyleBoxFlat.new()
				lk_style.bg_color = Color("#e2e8f0") if is_light else Color("#181f2f")
				lk_style.border_color = Color("#cbd5e1") if is_light else Color("#334155")
				lk_style.set_border_width_all(2)
				lk_style.set_corner_radius_all(10)
				lk_style.content_margin_left = 16
				lk_style.content_margin_right = 16
				lk_style.content_margin_top = 10
				lk_style.content_margin_bottom = 10
				locked_btn.add_theme_stylebox_override("disabled", lk_style)
				locked_btn.add_theme_color_override("font_disabled_color", Color("#64748b") if is_light else Color("#94a3b8"))
				locked_btn.add_theme_color_override("font_color", Color("#64748b") if is_light else Color("#94a3b8"))
				locked_btn.add_theme_font_size_override("font_size", 20)
				vb.add_child(locked_btn)

		list.add_child(card)


var education_minigame_overlay: ColorRect = null
var education_minigame_state: Dictionary = {}

const TRIVIA_QUESTIONS: Array[Dictionary] = [
	{"q": "Which planet in our solar system is known as the 'Red Planet'?", "options": ["Mars", "Venus", "Jupiter", "Saturn"]},
	{"q": "What is the capital city of Japan?", "options": ["Tokyo", "Kyoto", "Osaka", "Seoul"]},
	{"q": "What do bees collect from flowering plants to make honey?", "options": ["Nectar", "Sap", "Pollen", "Dew"]},
	{"q": "How many sides does a geometric hexagon have?", "options": ["6", "5", "8", "7"]},
	{"q": "What is the chemical formula for water?", "options": ["H2O", "CO2", "NaCl", "O2"]},
	{"q": "Which gas do plants absorb from the atmosphere for photosynthesis?", "options": ["Carbon Dioxide", "Oxygen", "Nitrogen", "Argon"]},
	{"q": "What is the freezing point of water in Celsius?", "options": ["0°C", "32°C", "-10°C", "100°C"]},
	{"q": "What is the largest living mammal on Earth?", "options": ["Blue Whale", "African Elephant", "Giraffe", "Hippopotamus"]},
	{"q": "Which continent contains the Amazon Rainforest?", "options": ["South America", "Africa", "Asia", "Australia"]},
	{"q": "Who formulated the law of universal gravitation?", "options": ["Isaac Newton", "Albert Einstein", "Galileo Galilei", "Nikola Tesla"]},
	{"q": "What is the primary currency used in Japan?", "options": ["Yen", "Won", "Euro", "Pound"]},
	{"q": "What instrument is used to measure earthquakes?", "options": ["Seismograph", "Barometer", "Thermometer", "Altimeter"]},
	{"q": "How many days are in a standard leap year?", "options": ["366", "365", "364", "360"]},
	{"q": "What color do you get when mixing Blue and Yellow pigments?", "options": ["Green", "Purple", "Orange", "Brown"]},
	{"q": "What is the hardest naturally occurring mineral on Earth?", "options": ["Diamond", "Quartz", "Topaz", "Corundum"]},
	{"q": "Which human internal organ is responsible for pumping blood?", "options": ["Heart", "Lungs", "Liver", "Kidneys"]},
	{"q": "What is the boiling temperature of water at sea level?", "options": ["100°C", "90°C", "120°C", "80°C"]},
	{"q": "How many continents are recognized on Earth?", "options": ["7", "5", "6", "8"]},
	{"q": "Which fundamental particle carries a negative electric charge?", "options": ["Electron", "Proton", "Neutron", "Photon"]},
	{"q": "What is the opposite (antonym) of the word 'Ancient'?", "options": ["Modern", "Historic", "Antique", "Elderly"]},
	{"q": "How many millimeters are there in one centimeter?", "options": ["10", "100", "1000", "5"]},
	{"q": "Which celestial body causes the ocean tides on Earth?", "options": ["The Moon", "The Sun", "Mars", "Jupiter"]},
	{"q": "What is the square root of 64?", "options": ["8", "6", "7", "9"]},
	{"q": "Which continent is the Sahara Desert located on?", "options": ["Africa", "Asia", "South America", "Australia"]},
	{"q": "What is the capital city of France?", "options": ["Paris", "Lyon", "Marseille", "Rome"]}
]


func _generate_math_question() -> Dictionary:
	var a: int = 0
	var b: int = 0
	var ans: int = 0
	var prompt: String = ""

	if PlayerData.age < 11:
		var mode := randi() % 3
		if mode == 0:
			a = randi_range(4, 25)
			b = randi_range(3, 20)
			ans = a + b
			prompt = "What is %d + %d ?" % [a, b]
		elif mode == 1:
			a = randi_range(12, 35)
			b = randi_range(3, a - 1)
			ans = a - b
			prompt = "What is %d - %d ?" % [a, b]
		else:
			a = randi_range(2, 9)
			b = randi_range(2, 6)
			ans = a * b
			prompt = "What is %d × %d ?" % [a, b]
	else:
		var mode := randi() % 4
		if mode == 0:
			a = randi_range(25, 75)
			b = randi_range(15, 65)
			ans = a + b
			prompt = "What is %d + %d ?" % [a, b]
		elif mode == 1:
			a = randi_range(45, 99)
			b = randi_range(12, 40)
			ans = a - b
			prompt = "What is %d - %d ?" % [a, b]
		elif mode == 2:
			a = randi_range(6, 12)
			b = randi_range(4, 9)
			ans = a * b
			prompt = "What is %d × %d ?" % [a, b]
		else:
			b = randi_range(3, 9)
			var quotient := randi_range(4, 12)
			a = b * quotient
			ans = quotient
			prompt = "What is %d ÷ %d ?" % [a, b]

	var wrong_offsets: Array = [-10, -5, -3, -2, -1, 1, 2, 3, 5, 10]
	wrong_offsets.shuffle()
	var options_set: Array[int] = [ans]
	for off in wrong_offsets:
		var candidate: int = ans + off
		if candidate != ans and candidate >= 0 and not (candidate in options_set):
			options_set.append(candidate)
		if options_set.size() >= 4:
			break
	while options_set.size() < 4:
		var candidate := ans + randi_range(11, 20)
		if not (candidate in options_set):
			options_set.append(candidate)

	options_set.shuffle()
	var correct_idx := options_set.find(ans)
	var str_options: Array[String] = []
	for opt in options_set:
		str_options.append(str(opt))

	return {
		"prompt": prompt,
		"options": str_options,
		"correct": correct_idx,
		"correct_answer": str(ans)
	}


func _generate_trivia_question(used_indices: Array = []) -> Dictionary:
	var available := []
	for i in range(TRIVIA_QUESTIONS.size()):
		if not (i in used_indices):
			available.append(i)
	if available.is_empty():
		available.append(randi() % TRIVIA_QUESTIONS.size())
	var idx: int = int(available.pick_random())
	used_indices.append(idx)
	var item: Dictionary = TRIVIA_QUESTIONS[idx]
	var orig_options: Array = item["options"].duplicate()
	var correct_text: String = str(orig_options[0])
	orig_options.shuffle()
	var correct_idx: int = orig_options.find(correct_text)
	return {
		"prompt": str(item["q"]),
		"options": orig_options,
		"correct": correct_idx,
		"correct_answer": correct_text
	}


func _start_refresher_course(cost: int) -> void:
	if cost > 0:
		if PlayerData.get_available_funds() >= cost:
			PlayerData.debit_funds(cost)
		elif PlayerData.bank_savings >= cost:
			PlayerData.bank_savings -= cost
		else:
			PlayerData.loan_balance += cost
			add_life_event("Academic Refresher Course ($%s) funded via student loan." % _format_number(cost), "finance")

	_start_education_minigame(["math", "trivia"].pick_random(), true)


func _start_education_minigame(game_type: String, is_course: bool = false) -> void:
	if education_minigame_overlay != null and is_instance_valid(education_minigame_overlay):
		education_minigame_overlay.queue_free()

	if education_modal_overlay != null and is_instance_valid(education_modal_overlay):
		education_modal_overlay.queue_free()
		education_modal_overlay = null

	var title_str: String = "📐 QUICK MATH CHALLENGE" if game_type == "math" else ("🧠 TRIVIA & GUESSING" if not is_course else "🎓 ACADEMIC REFRESHER COURSE")
	var subtitle_str: String = "Answer 3 questions accurately to directly raise your Grades & Smarts!"
	var border_col: Color = Color("#38bdf8") if game_type == "math" else Color("#a855f7")
	if is_course:
		border_col = Color("#10b981")

	var modal := _create_cyber_modal(title_str, subtitle_str, border_col)
	education_minigame_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var question_container := VBoxContainer.new()
	question_container.add_theme_constant_override("separation", 16)
	list.add_child(question_container)

	education_minigame_state = {
		"game_type": game_type,
		"is_course": is_course,
		"current_q": 0,
		"total_questions": 3,
		"score": 0,
		"used_indices": [] as Array[int],
		"border_col": border_col,
		"question_container": question_container
	}

	_render_education_minigame_step()


func _render_education_minigame_step() -> void:
	var qc: VBoxContainer = education_minigame_state.get("question_container", null)
	if qc == null or not is_instance_valid(qc):
		return

	for child in qc.get_children():
		qc.remove_child(child)
		child.queue_free()

	var game_type: String = str(education_minigame_state.get("game_type", "trivia"))
	var border_col: Color = education_minigame_state.get("border_col", Color("#38bdf8"))
	var current_q: int = int(education_minigame_state.get("current_q", 0))
	var total_questions: int = int(education_minigame_state.get("total_questions", 3))
	var score: int = int(education_minigame_state.get("score", 0))
	var used_indices: Array = education_minigame_state.get("used_indices", [])

	var q_data: Dictionary = _generate_math_question() if game_type == "math" else _generate_trivia_question(used_indices)

	var progress_lbl := Label.new()
	progress_lbl.text = "QUESTION %d OF %d  •  CURRENT SCORE: %d" % [current_q + 1, total_questions, score]
	progress_lbl.add_theme_font_size_override("font_size", 24)
	progress_lbl.add_theme_color_override("font_color", border_col)
	qc.add_child(progress_lbl)

	var q_card := PanelContainer.new()
	q_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_col))
	var qm := MarginContainer.new()
	qm.add_theme_constant_override("margin_left", 24)
	qm.add_theme_constant_override("margin_right", 24)
	qm.add_theme_constant_override("margin_top", 24)
	qm.add_theme_constant_override("margin_bottom", 24)
	q_card.add_child(qm)

	var qv := VBoxContainer.new()
	qv.add_theme_constant_override("separation", 16)
	qm.add_child(qv)

	var prompt_lbl := Label.new()
	prompt_lbl.text = str(q_data.prompt)
	prompt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_lbl.add_theme_font_size_override("font_size", 30)
	prompt_lbl.add_theme_color_override("font_color", Color("#ffffff"))
	qv.add_child(prompt_lbl)

	var feedback_lbl := Label.new()
	feedback_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_lbl.add_theme_font_size_override("font_size", 24)
	feedback_lbl.text = ""
	qv.add_child(feedback_lbl)

	var options_grid := GridContainer.new()
	options_grid.columns = 2
	options_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	options_grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	options_grid.add_theme_constant_override("h_separation", 14)
	options_grid.add_theme_constant_override("v_separation", 12)
	qv.add_child(options_grid)

	var is_last_q := (current_q + 1 >= total_questions)
	var next_btn_text := "Complete Exam ➔" if is_last_q else "Next Question ➔"
	var next_btn := _create_cyber_button(next_btn_text, border_col, func():
		_advance_education_minigame()
	)
	next_btn.visible = false
	qv.add_child(next_btn)

	var option_buttons: Array[Button] = []
	var opts: Array = q_data.options
	for idx in range(opts.size()):
		var opt_text := str(opts[idx])
		var btn := _create_cyber_button(opt_text, border_col, func(): pass)
		btn.custom_minimum_size = Vector2(100, 68)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		btn.add_theme_font_size_override("font_size", 24)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER

		btn.set_meta("quiz_correct", idx == int(q_data.correct))
		var chosen_idx := idx
		btn.pressed.connect(func():
			for b in option_buttons:
				preload("res://scripts/ui/quiz_button_style.gd").feedback(b, "neutral")

			if chosen_idx == int(q_data.correct):
				education_minigame_state["score"] = int(education_minigame_state["score"]) + 1
				feedback_lbl.text = "✅ Correct! (+5% Academic Marks earned)"
				feedback_lbl.add_theme_color_override("font_color", Color("#086449") if LifeLibrary.data.theme == "light" else Color("#6ee7b7"))
				preload("res://scripts/ui/quiz_button_style.gd").feedback(btn, "correct")
			else:
				feedback_lbl.text = "❌ Incorrect! The correct answer was: %s" % str(q_data.correct_answer)
				feedback_lbl.add_theme_color_override("font_color", Color("#a51d35") if LifeLibrary.data.theme == "light" else Color("#fda4af"))
				preload("res://scripts/ui/quiz_button_style.gd").feedback(btn, "incorrect")

				if int(q_data.correct) < option_buttons.size():
					var correct_btn: Button = option_buttons[int(q_data.correct)]
					preload("res://scripts/ui/quiz_button_style.gd").feedback(correct_btn, "correct")

			next_btn.visible = true
		)

		options_grid.add_child(btn)
		option_buttons.append(btn)

	qc.add_child(q_card)


func _advance_education_minigame() -> void:
	var current_q: int = int(education_minigame_state.get("current_q", 0)) + 1
	education_minigame_state["current_q"] = current_q
	var total_questions: int = int(education_minigame_state.get("total_questions", 3))

	if current_q < total_questions:
		_render_education_minigame_step()
	else:
		_show_education_minigame_results()


func _show_education_minigame_results() -> void:
	var qc: VBoxContainer = education_minigame_state.get("question_container", null)
	if qc == null or not is_instance_valid(qc):
		return

	for child in qc.get_children():
		qc.remove_child(child)
		child.queue_free()

	var border_col: Color = education_minigame_state.get("border_col", Color("#10b981"))
	var sc: int = int(education_minigame_state.get("score", 0))
	var total_questions: int = int(education_minigame_state.get("total_questions", 3))
	var is_course: bool = bool(education_minigame_state.get("is_course", false))
	var game_type: String = str(education_minigame_state.get("game_type", "trivia"))

	var res_card := PanelContainer.new()
	res_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_col))
	var rm := MarginContainer.new()
	rm.add_theme_constant_override("margin_left", 24)
	rm.add_theme_constant_override("margin_right", 24)
	rm.add_theme_constant_override("margin_top", 24)
	rm.add_theme_constant_override("margin_bottom", 24)
	res_card.add_child(rm)

	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 16)
	rm.add_child(rv)

	var rtitle := Label.new()
	rtitle.text = "🎉 EXAM COMPLETED! (%d/%d Correct)" % [sc, total_questions]
	rtitle.add_theme_font_size_override("font_size", 30)
	rtitle.add_theme_color_override("font_color", border_col)
	rv.add_child(rtitle)

	var g_boost: int = sc * 5
	var s_boost: int = mini(3, sc + 1)
	PlayerData.grades = clamp(PlayerData.grades + g_boost, 0, 100)
	PlayerData.smarts = mini(100, PlayerData.smarts + s_boost)
	PlayerData.happiness = mini(100, PlayerData.happiness + sc * 2)
	PlayerData.last_school_activity_age = PlayerData.age

	if is_course:
		PlayerData.grades = maxi(75, PlayerData.grades)
		add_life_event("🎓 REFRESHER COURSE COMPLETED: You passed the curriculum with %d/%d correct! Official credentials certified for career & university qualification." % [sc, total_questions], "education")
	else:
		var game_label := "Math Challenge" if game_type == "math" else "Trivia Guessing Challenge"
		add_life_event("🎓 %s: Completed with %d/%d correct! Academic credentials updated." % [game_label, sc, total_questions], "education")

	update_ui()
	SaveManager.save_game()

	var rdesc := Label.new()
	if is_course:
		rdesc.text = "Congratulations! Your course certification is complete.\n\n• Official credentials certified for career & university qualification"
	else:
		rdesc.text = "Great effort! Your test results have been registered into your academic transcript:\n\n• Annual academic maintenance fulfilled (grades protected from degradation)"
	rdesc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rdesc.add_theme_font_size_override("font_size", 24)
	rdesc.add_theme_color_override("font_color", Color("#cbd5e1"))
	rv.add_child(rdesc)

	var return_btn := _create_cyber_button("Finish & Return to Academy", border_col, func():
		if education_minigame_overlay != null and is_instance_valid(education_minigame_overlay):
			education_minigame_overlay.queue_free()
			education_minigame_overlay = null
		_show_education_modal()
	)
	rv.add_child(return_btn)
	qc.add_child(res_card)



# ==========================================
# MODAL OVERLAY SYSTEMS (Doctor, Crime, Casino, Death)
# ==========================================

var doctor_modal_overlay: ColorRect = null
var crime_modal_overlay: ColorRect = null
var casino_modal_overlay: ColorRect = null
var death_screen_overlay: ColorRect = null
var gym_modal_overlay: ColorRect = null
var meditation_modal_overlay: ColorRect = null
var dating_app_modal_overlay: ColorRect = null
var charity_modal_overlay: ColorRect = null
var romance_action_modal_overlay: ColorRect = null
var current_dating_candidate: Dictionary = {}


func _setup_all_translucent_scrollbars() -> void:
	# Configure root theme so all existing and future VScrollBar/HScrollBar nodes inherit translucent styling
	var t: Theme = theme
	if t == null:
		t = Theme.new()
		theme = t

	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.45, 0.75, 1.0, 0.18) # 18% opacity soft translucent glass
	grabber.set_corner_radius_all(4)
	grabber.content_margin_left = 2
	grabber.content_margin_right = 2
	grabber.content_margin_top = 4
	grabber.content_margin_bottom = 4

	var grabber_hl := StyleBoxFlat.new()
	grabber_hl.bg_color = Color(0.50, 0.85, 1.0, 0.40) # 40% opacity on hover
	grabber_hl.set_corner_radius_all(4)
	grabber_hl.content_margin_left = 2
	grabber_hl.content_margin_right = 2
	grabber_hl.content_margin_top = 4
	grabber_hl.content_margin_bottom = 4

	var grabber_pressed := StyleBoxFlat.new()
	grabber_pressed.bg_color = Color(0.30, 0.85, 1.0, 0.70) # 70% opacity when dragging
	grabber_pressed.set_corner_radius_all(4)
	grabber_pressed.content_margin_left = 2
	grabber_pressed.content_margin_right = 2
	grabber_pressed.content_margin_top = 4
	grabber_pressed.content_margin_bottom = 4

	var track := StyleBoxEmpty.new()

	t.set_stylebox("grabber", "VScrollBar", grabber)
	t.set_stylebox("grabber_highlight", "VScrollBar", grabber_hl)
	t.set_stylebox("grabber_pressed", "VScrollBar", grabber_pressed)
	t.set_stylebox("scroll", "VScrollBar", track)
	t.set_stylebox("scroll_focus", "VScrollBar", track)

	t.set_stylebox("grabber", "HScrollBar", grabber)
	t.set_stylebox("grabber_highlight", "HScrollBar", grabber_hl)
	t.set_stylebox("grabber_pressed", "HScrollBar", grabber_pressed)
	t.set_stylebox("scroll", "HScrollBar", track)
	t.set_stylebox("scroll_focus", "HScrollBar", track)

	_apply_translucent_scrollbars_recursive(self)


func _style_single_scrollbar(sb: ScrollBar) -> void:
	if sb == null:
		return

	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.45, 0.75, 1.0, 0.18)
	grabber.set_corner_radius_all(4)
	grabber.content_margin_left = 2
	grabber.content_margin_right = 2
	grabber.content_margin_top = 4
	grabber.content_margin_bottom = 4

	var grabber_hl := StyleBoxFlat.new()
	grabber_hl.bg_color = Color(0.50, 0.85, 1.0, 0.40)
	grabber_hl.set_corner_radius_all(4)
	grabber_hl.content_margin_left = 2
	grabber_hl.content_margin_right = 2
	grabber_hl.content_margin_top = 4
	grabber_hl.content_margin_bottom = 4

	var grabber_pressed := StyleBoxFlat.new()
	grabber_pressed.bg_color = Color(0.30, 0.85, 1.0, 0.70)
	grabber_pressed.set_corner_radius_all(4)
	grabber_pressed.content_margin_left = 2
	grabber_pressed.content_margin_right = 2
	grabber_pressed.content_margin_top = 4
	grabber_pressed.content_margin_bottom = 4

	var track := StyleBoxEmpty.new()

	sb.add_theme_stylebox_override("grabber", grabber)
	sb.add_theme_stylebox_override("grabber_highlight", grabber_hl)
	sb.add_theme_stylebox_override("grabber_pressed", grabber_pressed)
	sb.add_theme_stylebox_override("scroll", track)
	sb.add_theme_stylebox_override("scroll_focus", track)

	if sb is VScrollBar:
		sb.custom_minimum_size.x = 8
	elif sb is HScrollBar:
		sb.custom_minimum_size.y = 8


func _apply_translucent_scrollbar_to_node(control: Control) -> void:
	if control == null:
		return
	if control is ScrollContainer:
		var sc := control as ScrollContainer
		_style_single_scrollbar(sc.get_v_scroll_bar())
		_style_single_scrollbar(sc.get_h_scroll_bar())
	elif control is RichTextLabel:
		var rtl := control as RichTextLabel
		_style_single_scrollbar(rtl.get_v_scroll_bar())


func _apply_translucent_scrollbars_recursive(node: Node) -> void:
	if node is ScrollContainer or node is RichTextLabel:
		_apply_translucent_scrollbar_to_node(node as Control)
	for child in node.get_children():
		_apply_translucent_scrollbars_recursive(child)


func _create_activity_modal_base(title_text: String, subtitle_text: String = "", border_color: Color = Color("#38bdf8")) -> Dictionary:
	return _create_cyber_modal(title_text, subtitle_text, border_color)


## Refresh an open modal's contents without replacing its animated surface or scroll.
func _refresh_cyber_modal(existing: Variant, title_text: String, subtitle_text: String, border_color: Color) -> Dictionary:
	if is_instance_valid(existing) and not existing.is_queued_for_deletion() and existing.is_visible_in_tree() and not existing.has_meta("closing_panel") and existing.has_meta("modal_view"):
		var view: Dictionary = existing.get_meta("modal_view")
		for child in view.list.get_children():
			view.list.remove_child(child)
			child.queue_free()
		# Remove content-specific controls pinned outside the scroll area, such as tabs.
		for child in view.vbox.get_children():
			if child not in view.shell_children:
				view.vbox.remove_child(child)
				child.queue_free()
		view.title.text = title_text
		view.subtitle.text = subtitle_text
		return view
	return _create_cyber_modal(title_text, subtitle_text, border_color)


func _create_cyber_modal(title_text: String, subtitle_text: String, border_color: Color) -> Dictionary:
	var overlay := ColorRect.new()
	overlay.set_meta("theme_exempt", true)
	overlay.color = Color(0.012, 0.035, 0.07, 0.88)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.z_index = 80
	overlay.visible = true
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Responsive outer margin container to prevent clipping against any viewport bounds
	var margin_outer := MarginContainer.new()
	margin_outer.anchors_preset = Control.PRESET_FULL_RECT
	margin_outer.anchor_right = 1.0
	margin_outer.anchor_bottom = 1.0
	margin_outer.grow_horizontal = Control.GROW_DIRECTION_BOTH
	margin_outer.grow_vertical = Control.GROW_DIRECTION_BOTH
	margin_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top_m: int = 16
	var bottom_m: int = 16
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD) or OS.has_feature("mobile") or (OS.has_feature("web") and MobileKeyboardManager.is_mobile()):
		top_m = 48
		bottom_m = 40
	margin_outer.add_theme_constant_override("margin_left", 16)
	margin_outer.add_theme_constant_override("margin_right", 16)
	margin_outer.add_theme_constant_override("margin_top", top_m)
	margin_outer.add_theme_constant_override("margin_bottom", bottom_m)
	overlay.add_child(margin_outer)
	preload("res://scripts/ui/panel_pull_up.gd").watch(margin_outer, overlay)

	var is_light: bool = LifeLibrary.data.theme == "light"
	var modal_border: Color = border_color.darkened(0.35) if (is_light and border_color.get_luminance() > 0.45) else border_color
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.clip_contents = true
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#edf3fa") if is_light else Color("#090f1d")
	card_style.border_color = modal_border
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(14)
	card_style.shadow_color = Color(0, 0, 0, 0.15 if is_light else 0.85)
	card_style.shadow_size = 24
	card.add_theme_stylebox_override("panel", card_style)
	margin_outer.add_child(card)

	# Click outside card on dim backdrop to close
	overlay.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			preload("res://scripts/ui/panel_close.gd").dismiss(overlay, true, Callable(), card)
	)

	var margin := MarginContainer.new()
	margin.set_meta("reference_edge", true)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)

	var main_vbox := VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", 14)
	margin.add_child(main_vbox)

	# Header row
	var header_row := HBoxContainer.new()
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_theme_constant_override("separation", 12)
	main_vbox.add_child(header_row)

	var title_lbl := Label.new()
	title_lbl.set_meta("reference_part", true)
	title_lbl.text = title_text
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var title_col: Color = border_color.darkened(0.35) if (is_light and border_color.get_luminance() > 0.35) else border_color
	if is_light and title_col.get_luminance() > 0.35:
		title_col = Color("#0369a1")
	title_lbl.add_theme_color_override("font_color", title_col)
	title_lbl.add_theme_font_size_override("font_size", 26)
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_row.add_child(title_lbl)

	var close_btn := Button.new()
	close_btn.set_meta("reference_part", true)
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(56, 48)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#e2e8f0"))
	close_btn.add_theme_color_override("font_hover_color", Color("#f43f5e"))
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color("#edf3fa") if is_light else Color("#1e293b")
	close_style.border_color = modal_border
	close_style.set_border_width_all(2)
	close_style.set_corner_radius_all(10)
	close_style.shadow_color = Color(0, 0, 0, 0.22)
	close_style.shadow_size = 4
	close_style.shadow_offset = Vector2(0, 2)
	var close_hover := close_style.duplicate() as StyleBoxFlat
	close_hover.border_color = Color("#f43f5e")
	close_hover.shadow_size = 6
	var close_pressed := close_style.duplicate() as StyleBoxFlat
	close_pressed.shadow_size = 1
	close_pressed.shadow_offset = Vector2(0, 1)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_hover)
	close_btn.add_theme_stylebox_override("pressed", close_pressed)
	close_btn.pressed.connect(func(): preload("res://scripts/ui/panel_close.gd").dismiss(overlay, true, Callable(), card))
	header_row.add_child(close_btn)

	var sub_lbl := Label.new()
	sub_lbl.text = subtitle_text
	sub_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_lbl.add_theme_color_override("font_color", Color("#475569") if is_light else Color("#94a3b8"))
	sub_lbl.add_theme_font_size_override("font_size", 20)
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(sub_lbl)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.clip_contents = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_apply_translucent_scrollbar_to_node(scroll)
	main_vbox.add_child(scroll)

	var scroll_margin := MarginContainer.new()
	scroll_margin.set_meta("reference_edge", true)
	scroll_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_margin.add_theme_constant_override("margin_left", 4)
	scroll_margin.add_theme_constant_override("margin_right", 16)
	scroll_margin.add_theme_constant_override("margin_top", 4)
	scroll_margin.add_theme_constant_override("margin_bottom", 20)
	scroll.add_child(scroll_margin)

	var content_list := VBoxContainer.new()
	content_list.set_meta("reference_menu", true)
	content_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_list.add_theme_constant_override("separation", 20)
	scroll_margin.add_child(content_list)

	if has_node("ThemeController"):
		get_node("ThemeController").apply_subtree(overlay)

	var view := {
		"overlay": overlay,
		"card": card,
		"title": title_lbl,
		"subtitle": sub_lbl,
		"vbox": main_vbox,
		"scroll": scroll,
		"list": content_list,
		"close_button": close_btn,
		"shell_children": main_vbox.get_children()
	}
	overlay.set_meta("modal_view", view)
	return view


func _create_cyber_button(btn_text: String, border_col: Color, on_click: Callable = Callable(), center_align: bool = false) -> Button:
	var btn := Button.new()
	btn.set_meta("reference_part", true)
	btn.set_meta("market_button", true)
	btn.text = btn_text
	btn.custom_minimum_size.y = 56
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.add_theme_font_size_override("font_size", 22)
	if center_align:
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.set_meta("center_text", true)
	else:
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var is_light: bool = LifeLibrary.data.theme == "light"
	var normal_sb := StyleBoxFlat.new()
	normal_sb.bg_color = border_col.darkened(0.18) if is_light else border_col.darkened(0.42)
	normal_sb.border_color = border_col.lightened(0.2)
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
	hover_sb.bg_color = border_col.lightened(0.08) if is_light else border_col.darkened(0.2)
	hover_sb.border_color = Color.WHITE
	hover_sb.shadow_size = 6
	btn.add_theme_stylebox_override("hover", hover_sb)

	var pressed_sb := normal_sb.duplicate() as StyleBoxFlat
	pressed_sb.bg_color = border_col.darkened(0.4) if is_light else border_col.darkened(0.6)
	pressed_sb.shadow_size = 1
	pressed_sb.shadow_offset = Vector2(0, 1)
	btn.add_theme_stylebox_override("pressed", pressed_sb)

	var btn_font_col: Color = Color.WHITE
	btn.add_theme_color_override("font_color", btn_font_col)
	btn.add_theme_color_override("font_hover_color", btn_font_col)
	btn.add_theme_color_override("font_pressed_color", btn_font_col)
	btn.add_theme_color_override("font_focus_color", btn_font_col)

	if on_click.is_valid():
		btn.pressed.connect(on_click)
	return btn


func _create_disabled_cyber_button(btn_text: String, reason: String = "", center_align: bool = false) -> Button:
	var btn := Button.new()
	btn.set_meta("reference_part", true)
	var clean_btn := btn_text.strip_edges()
	var clean_reason := reason.strip_edges()
	while clean_btn.begins_with("🔒"):
		clean_btn = clean_btn.substr(1).strip_edges()
	while clean_reason.begins_with("🔒"):
		clean_reason = clean_reason.substr(1).strip_edges()

	if clean_reason == "" or clean_reason == clean_btn or clean_btn.contains(clean_reason):
		btn.text = "🔒 %s" % clean_btn
	else:
		btn.text = "🔒 %s\n%s" % [clean_btn, clean_reason]

	btn.custom_minimum_size.y = 52
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.add_theme_font_size_override("font_size", 21)
	btn.disabled = true

	var is_light: bool = LifeLibrary.data.theme == "light"
	var disabled_sb := StyleBoxFlat.new()
	disabled_sb.bg_color = Color("#94a3b8" if is_light else "#334155")
	disabled_sb.border_color = Color("#cbd5e1" if is_light else "#475569")
	disabled_sb.set_border_width_all(2)
	disabled_sb.set_corner_radius_all(10)
	disabled_sb.content_margin_left = 18
	disabled_sb.content_margin_right = 18
	disabled_sb.content_margin_top = 10
	disabled_sb.content_margin_bottom = 10
	btn.add_theme_stylebox_override("disabled", disabled_sb)
	btn.add_theme_stylebox_override("normal", disabled_sb)

	btn.add_theme_color_override("font_disabled_color", Color("#334155" if is_light else "#94a3b8"))
	btn.add_theme_color_override("font_color", Color("#334155" if is_light else "#94a3b8"))
	if center_align:
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.set_meta("center_text", true)
	else:
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return btn


func _close_education_modal_and_return_to_main() -> void:
	if university_modal_overlay != null and is_instance_valid(university_modal_overlay):
		university_modal_overlay.queue_free()
		university_modal_overlay = null
	if education_modal_overlay != null and is_instance_valid(education_modal_overlay):
		education_modal_overlay.queue_free()
		education_modal_overlay = null
	show_tab("timeline")


func _close_gym_modal_and_return_to_main() -> void:
	if gym_modal_overlay != null and is_instance_valid(gym_modal_overlay):
		gym_modal_overlay.queue_free()
		gym_modal_overlay = null
	show_tab("timeline")


func _close_meditation_modal_and_return_to_main() -> void:
	if meditation_modal_overlay != null and is_instance_valid(meditation_modal_overlay):
		meditation_modal_overlay.queue_free()
		meditation_modal_overlay = null
	show_tab("timeline")


func _close_charity_modal_and_return_to_main() -> void:
	if charity_modal_overlay != null and is_instance_valid(charity_modal_overlay):
		charity_modal_overlay.queue_free()
		charity_modal_overlay = null
	show_tab("timeline")


func _purchase_gym_membership() -> bool:
	var fee: int = PlayerData.gym_membership_annual_fee
	if PlayerData.bank_savings >= fee:
		PlayerData.bank_savings -= fee
	elif PlayerData.get_available_funds() >= fee:
		PlayerData.debit_funds(fee)
	else:
		add_life_event("❌ You need at least $%d to activate a Gym Membership." % fee, "finance")
		_close_gym_modal_and_return_to_main()
		return false
	PlayerData.has_gym_membership = true
	add_life_event("🏋️ Gym Membership ACTIVATED! ($%d/yr auto-debited annually). All gym workouts, classes, and athletic facilities are now 100%% FREE!" % fee, "activity")
	update_ui()
	SaveManager.save_game()
	_close_gym_modal_and_return_to_main()
	return true


func _cancel_gym_membership() -> void:
	PlayerData.has_gym_membership = false
	add_life_event("🚫 Gym Membership CANCELLED. You will no longer be billed annually, and gym workouts will now require day-pass fees.", "activity")
	update_ui()
	SaveManager.save_game()
	_close_gym_modal_and_return_to_main()


func _execute_gym_workout(w: Dictionary) -> bool:
	if PlayerData.last_gym_activity_age == PlayerData.age:
		_close_gym_modal_and_return_to_main()
		return false
	var effective_fee: int = 0 if PlayerData.has_gym_membership else int(w["cost"] if w.has("cost") else w.get("fee", 0))
	if effective_fee > 0 and PlayerData.get_available_funds() < effective_fee:
		add_life_event("You cannot afford the $%d day-pass fee for %s." % [effective_fee, str(w.get("name", w.get("title", "Workout")))], "finance")
		_close_gym_modal_and_return_to_main()
		return false
	if effective_fee > 0:
		PlayerData.debit_funds(effective_fee)
	PlayerData.last_gym_activity_age = PlayerData.age
	var h_gain: int = int(w.get("health", 0))
	if h_gain == 0 and w.has("health_min"):
		h_gain = randi_range(int(w["health_min"]), int(w["health_max"]))
	var l_gain: int = int(w.get("looks", 0))
	if l_gain == 0 and w.has("looks_min"):
		l_gain = randi_range(int(w["looks_min"]), int(w["looks_max"]))
	var hap_gain: int = int(w.get("happiness", 0))
	if hap_gain == 0 and w.has("hap_min"):
		hap_gain = randi_range(int(w["hap_min"]), int(w["hap_max"]))
	PlayerData.health = mini(100, PlayerData.health + h_gain)
	PlayerData.looks = mini(100, PlayerData.looks + l_gain)
	PlayerData.happiness = mini(100, PlayerData.happiness + hap_gain)
	var w_title: String = str(w.get("name", w.get("title", "Workout")))
	var w_msg: String = str(w.get("msg", "completed your training session."))
	if PlayerData.has_gym_membership:
		add_life_event("🏋️ [MEMBER PASS - FREE] You visited the gym for %s and %s." % [w_title, w_msg], "activity")
	else:
		add_life_event("🏋️ You paid a $%d day pass for %s and %s." % [effective_fee, w_title, w_msg], "activity")
	update_ui()
	SaveManager.save_game()
	_close_gym_modal_and_return_to_main()
	return true


func _execute_meditation(p: Dictionary) -> bool:
	if PlayerData.last_meditation_activity_age == PlayerData.age:
		_close_meditation_modal_and_return_to_main()
		return false
	var fee_val: int = int(p.get("cost", p.get("fee", 0)))
	if fee_val > 0 and PlayerData.get_available_funds() < fee_val:
		add_life_event("You cannot afford the $%d fee for %s." % [fee_val, str(p.get("name", p.get("title", "Meditation")))], "finance")
		_close_meditation_modal_and_return_to_main()
		return false
	if fee_val > 0:
		PlayerData.debit_funds(fee_val)
	PlayerData.last_meditation_activity_age = PlayerData.age
	var hap_gain: int = int(p.get("happiness", 0))
	if hap_gain == 0 and p.has("hap_min"):
		hap_gain = randi_range(int(p["hap_min"]), int(p["hap_max"]))
	var s_gain: int = int(p.get("smarts", 0))
	if s_gain == 0 and p.has("smarts_min"):
		s_gain = randi_range(int(p["smarts_min"]), int(p["smarts_max"]))
	var h_gain: int = int(p.get("health", 0))
	if h_gain == 0 and p.has("health_min"):
		h_gain = randi_range(int(p["health_min"]), int(p["health_max"]))
	var l_gain: int = int(p.get("looks", 0))
	if l_gain == 0 and p.has("looks_min"):
		l_gain = randi_range(int(p["looks_min"]), int(p["looks_max"]))
	var k_gain: int = int(p.get("karma", 0))
	if k_gain == 0 and p.has("karma_min"):
		k_gain = randi_range(int(p["karma_min"]), int(p["karma_max"]))
	PlayerData.happiness = mini(100, PlayerData.happiness + hap_gain)
	PlayerData.smarts = mini(100, PlayerData.smarts + s_gain)
	if h_gain > 0:
		PlayerData.health = mini(100, PlayerData.health + h_gain)
	if l_gain > 0:
		PlayerData.looks = mini(100, PlayerData.looks + l_gain)
	PlayerData.karma += k_gain
	var p_title: String = str(p.get("name", p.get("title", "Meditation")))
	if fee_val == 0:
		add_life_event("🧘 You engaged in %s. Serenity and peace wash over your mind." % p_title, "activity")
	else:
		add_life_event("🧘 You attended %s ($%d). Deep tranquility and spiritual rejuvenation achieved!" % [p_title, fee_val], "activity")
	update_ui()
	SaveManager.save_game()
	_close_meditation_modal_and_return_to_main()
	return true


func _show_gym_modal() -> void:
	if gym_modal_overlay != null and is_instance_valid(gym_modal_overlay):
		gym_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🏋️ TITAN CYBER GYM & FITNESS", "Strength Training, Athletics, Aquatics & Annual Memberships", Color("#10b981"))
	gym_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# 1. Physical Fitness & Health Summary Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 12)
	sm.add_child(sv)

	var stat_title := Label.new()
	stat_title.text = "💪 PHYSICAL PROFILE & HEALTH VITALS"
	stat_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_title.add_theme_font_size_override("font_size", 28)
	stat_title.add_theme_color_override("font_color", Color("#34d399"))
	sv.add_child(stat_title)

	var vitals_lbl := Label.new()
	vitals_lbl.text = "❤️ Health: %d%%   •   ✨ Looks: %d%%   •   😊 Happiness: %d%%" % [
		PlayerData.health,
		PlayerData.looks,
		PlayerData.happiness
	]
	vitals_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vitals_lbl.add_theme_font_size_override("font_size", 25)
	vitals_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
	sv.add_child(vitals_lbl)

	var bank_lbl := Label.new()
	bank_lbl.text = "💰 Bank Savings: $%d   •   💵 Cash in Hand: $%d" % [
		PlayerData.bank_savings,
		PlayerData.money
	]
	bank_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bank_lbl.add_theme_font_size_override("font_size", 23)
	bank_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	sv.add_child(bank_lbl)

	list.add_child(summary_card)

	# 2. Gym Membership Card
	var mem_card := PanelContainer.new()
	var mem_border := Color("#38bdf8") if PlayerData.has_gym_membership else Color("#f59e0b")
	mem_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(mem_border))
	var mm := MarginContainer.new()
	mm.add_theme_constant_override("margin_left", 24)
	mm.add_theme_constant_override("margin_right", 24)
	mm.add_theme_constant_override("margin_top", 18)
	mm.add_theme_constant_override("margin_bottom", 18)
	mem_card.add_child(mm)

	var mv := VBoxContainer.new()
	mv.add_theme_constant_override("separation", 14)
	mm.add_child(mv)

	var mem_title := Label.new()
	mem_title.text = "💳 ALL-INCLUSIVE ANNUAL GYM MEMBERSHIP"
	mem_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mem_title.add_theme_font_size_override("font_size", 28)
	mem_title.add_theme_color_override("font_color", Color("#38bdf8"))
	mv.add_child(mem_title)

	var mem_desc := Label.new()
	if PlayerData.has_gym_membership:
		mem_desc.text = "STATUS: ACTIVE MEMBER ✅\nAnnual Fee: $%d/year (automatically debited from your bank account every year).\nPERK: ALL gym visits, classes, weight rooms, and athletic tracks are 100%% FREE!" % PlayerData.gym_membership_annual_fee
		mem_desc.add_theme_color_override("font_color", Color("#34d399"))
	else:
		mem_desc.text = "STATUS: NON-MEMBER ❌\nAnnual Fee: $%d/year (debited directly from your bank account yearly).\nBENEFIT: Unlocks 100%% FREE unlimited access to all workouts, swimming laps, spin classes, and boxing. Never pay individual day passes again!" % PlayerData.gym_membership_annual_fee
		mem_desc.add_theme_color_override("font_color", Color("#e2e8f0"))
	mem_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mem_desc.add_theme_font_size_override("font_size", 23)
	mv.add_child(mem_desc)

	if not PlayerData.has_gym_membership:
		var buy_btn := _create_cyber_button("💳 ACTIVATE GYM MEMBERSHIP ($300/yr Auto-Debit)
Start enjoying 100% free visits across all facilities", Color("#10b981"), func():
			_purchase_gym_membership()
		)
		mv.add_child(buy_btn)
	else:
		var cancel_btn := _create_cyber_button("❌ CANCEL GYM MEMBERSHIP
Stop annual auto-debit payments (Visits will revert to standard day-pass fees)", Color("#ef4444"), func():
			_cancel_gym_membership()
		)
		mv.add_child(cancel_btn)

	list.add_child(mem_card)

	# 3. Annual Workout Anti-Spam Gating Banner
	var has_worked_out_this_year: bool = (PlayerData.last_gym_activity_age == PlayerData.age)
	if has_worked_out_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 18)
		lm.add_theme_constant_override("margin_right", 18)
		lm.add_theme_constant_override("margin_top", 12)
		lm.add_theme_constant_override("margin_bottom", 12)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL WORKOUT COMPLETED
You have already pushed your limits at the gym for Age %d.
To avoid muscle strain and allow adequate recovery, training options are locked until next year. Advance age (+1 Year) to train again!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 20)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

	# 4. Workout Options
	var workouts: Array = [
		{
			"title": "🏋️ Heavy Weight Training",
			"fee": 40,
			"health_min": 7, "health_max": 10,
			"looks_min": 6, "looks_max": 9,
			"hap_min": 4, "hap_max": 6,
			"desc": "Intense barbell squats, deadlifts, and bench presses. Builds substantial muscle and physical strength.",
			"msg": "pushed maximum reps on deadlifts and bench presses.",
			"color": Color("#34d399")
		},
		{
			"title": "🏃 Track Day & Sprint Intervals",
			"fee": 25,
			"health_min": 6, "health_max": 9,
			"looks_min": 4, "looks_max": 7,
			"hap_min": 5, "hap_max": 8,
			"desc": "High-octane sprint intervals, hurdles, and endurance laps on the Olympic synthetic track.",
			"msg": "burned rubber doing 400m sprint intervals on the track.",
			"color": Color("#38bdf8")
		},
		{
			"title": "🚴 HIIT Spin & Cardio Blast",
			"fee": 30,
			"health_min": 7, "health_max": 9,
			"looks_min": 5, "looks_max": 8,
			"hap_min": 6, "hap_max": 9,
			"desc": "High-intensity interval rhythm cycling class with motivating neon lights and pumping techno beats.",
			"msg": "sweated through an intense 45-minute HIIT spin blast.",
			"color": Color("#a855f7")
		},
		{
			"title": "🏊 Olympic Swimming & Laps",
			"fee": 50,
			"health_min": 8, "health_max": 11,
			"looks_min": 5, "looks_max": 7,
			"hap_min": 6, "hap_max": 8,
			"desc": "Low-impact, full-body cardiovascular workout swimming continuous freestyle laps in the heated pool.",
			"msg": "swam 40 continuous freestyle laps in the Olympic pool.",
			"color": Color("#06b6d4")
		},
		{
			"title": "🥊 Combat Boxing & Sparring",
			"fee": 60,
			"health_min": 8, "health_max": 12,
			"looks_min": 5, "looks_max": 8,
			"hap_min": 5, "hap_max": 8,
			"desc": "Heavy bag combos, speed bag agility, and controlled sparring with veteran pugilists.",
			"msg": "sharpened footwork and landed crisp combos in boxing sparring.",
			"color": Color("#f43f5e")
		},
		{
			"title": "💎 Elite VIP Personal Trainer",
			"fee": 120,
			"health_min": 11, "health_max": 15,
			"looks_min": 8, "looks_max": 12,
			"hap_min": 7, "hap_max": 10,
			"desc": "1-on-1 private conditioning, biomechanical analysis, and targeted aesthetic hypertrophy routine.",
			"msg": "trained with an elite master coach on a bespoke conditioning routine.",
			"color": Color("#eab308")
		}
	]

	for w in workouts:
		var fee_val: int = int(w["fee"])
		var price_str: String = "100% FREE (Membership Active)" if PlayerData.has_gym_membership else "$%d Day Pass" % fee_val
		var w_text: String = "%s (%s)
%s" % [str(w["title"]), price_str, str(w["desc"])]

		if has_worked_out_this_year:
			list.add_child(_create_disabled_cyber_button(w_text, "Completed for Age %d (Age up to workout next year)" % PlayerData.age))
		else:
			var btn := _create_cyber_button(w_text, w["color"], func():
				_execute_gym_workout(w)
			)
			list.add_child(btn)

	gym_modal_overlay.visible = true


func _show_meditation_modal() -> void:
	if meditation_modal_overlay != null and is_instance_valid(meditation_modal_overlay):
		meditation_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🧘 NIRVANA MINDFULNESS & MEDITATION", "Breathwork, Yoga, Acoustic Sound Baths & Spiritual Healing", Color("#a855f7"))
	meditation_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# 1. Mental Wellness & Inner Peace Summary Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#a855f7")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 12)
	sm.add_child(sv)

	var stat_title := Label.new()
	stat_title.text = "🧘 MENTAL WELLNESS & SPIRITUAL ALIGNMENT"
	stat_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_title.add_theme_font_size_override("font_size", 28)
	stat_title.add_theme_color_override("font_color", Color("#c084fc"))
	sv.add_child(stat_title)

	var mood_desc := "Serene & Blissful" if PlayerData.happiness >= 80 else ("Content" if PlayerData.happiness >= 60 else ("Stressed" if PlayerData.happiness >= 40 else "Depressed & Exhausted"))
	var vitals_lbl := Label.new()
	vitals_lbl.text = "😊 Happiness: %d%% (%s)   •   🧠 Smarts: %d%%" % [
		PlayerData.happiness,
		mood_desc,
		PlayerData.smarts
	]
	vitals_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vitals_lbl.add_theme_font_size_override("font_size", 25)
	vitals_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
	sv.add_child(vitals_lbl)

	var benefit_lbl := Label.new()
	benefit_lbl.text = "Mindfulness Impact: Regular meditation cleanses mental fatigue, sharpens focus, reduces existential anxiety, and brings deep spiritual clarity."
	benefit_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	benefit_lbl.add_theme_font_size_override("font_size", 23)
	benefit_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	sv.add_child(benefit_lbl)

	list.add_child(summary_card)

	# 2. Annual Meditation Anti-Spam Gating Banner
	var has_meditated_this_year: bool = (PlayerData.last_meditation_activity_age == PlayerData.age)
	if has_meditated_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 20)
		lm.add_theme_constant_override("margin_right", 20)
		lm.add_theme_constant_override("margin_top", 14)
		lm.add_theme_constant_override("margin_bottom", 14)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL MINDFULNESS SESSION COMPLETED\nYou have already completed your meditation session for Age %d.\nMindfulness and meditation sessions are complete for this year. Advance age (+1 Year) to meditate again!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 23)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

	# 3. Meditation Options
	var practices: Array = [
		{
			"title": "🍃 Zen Breathwork & Vipassana (Free)",
			"fee": 0,
			"min_age": 5,
			"hap_min": 10, "hap_max": 14,
			"smarts_min": 1, "smarts_max": 2,
			"health_min": 0, "health_max": 0,
			"looks_min": 0, "looks_max": 0,
			"karma_min": 2, "karma_max": 3,
			"desc": "Sit quietly in lotus posture, focus on diaphragmatic breathing, and ground your awareness in the present moment.",
			"color": Color("#34d399")
		},
		{
			"title": "🧘 Vinyasa Flow Yoga Class ($25)",
			"fee": 25,
			"min_age": 5,
			"hap_min": 14, "hap_max": 18,
			"smarts_min": 1, "smarts_max": 2,
			"health_min": 3, "health_max": 5,
			"looks_min": 3, "looks_max": 4,
			"karma_min": 2, "karma_max": 4,
			"desc": "An energizing flow of warrior postures, spinal stretches, and mindful deep breathing led by a certified yogi.",
			"color": Color("#38bdf8")
		},
		{
			"title": "🔔 Tibetan Singing Bowls & Sound Bath ($50)",
			"fee": 50,
			"min_age": 5,
			"hap_min": 18, "hap_max": 24,
			"smarts_min": 3, "smarts_max": 5,
			"health_min": 1, "health_max": 3,
			"looks_min": 0, "looks_max": 0,
			"karma_min": 4, "karma_max": 6,
			"desc": "Harmonic vibrational acoustic therapy with hammered bronze bowls and quartz gongs to calm your central nervous system.",
			"color": Color("#f59e0b")
		},
		{
			"title": "✨ Spiritual Healing & Chakra Alignment ($90)",
			"fee": 90,
			"min_age": 10,
			"hap_min": 24, "hap_max": 30,
			"smarts_min": 2, "smarts_max": 3,
			"health_min": 2, "health_max": 4,
			"looks_min": 0, "looks_max": 0,
			"karma_min": 10, "karma_max": 14,
			"desc": "Realign your bio-energetic chakras, cleanse residual emotional trauma, and restore karmic purity with an ordained spiritual master.",
			"color": Color("#ec4899")
		},
		{
			"title": "🌌 Transcendental Sanctuary Retreat ($180)",
			"fee": 180,
			"min_age": 14,
			"hap_min": 32, "hap_max": 42,
			"smarts_min": 4, "smarts_max": 6,
			"health_min": 4, "health_max": 6,
			"looks_min": 2, "looks_max": 4,
			"karma_min": 16, "karma_max": 20,
			"desc": "An immersive all-day luxury digital detox retreat with botanical tea ceremonies, sensory rest, and profound guided enlightenment.",
			"color": Color("#a855f7")
		}
	]

	for p in practices:
		var fee_val: int = int(p["fee"])
		var fee_text: String = "Free" if fee_val == 0 else "$%d Cash" % fee_val
		var p_text: String = "%s (%s)
%s" % [str(p["title"]), fee_text, str(p["desc"])]
		var min_age_req: int = int(p["min_age"])

		if PlayerData.age < min_age_req:
			list.add_child(_create_disabled_cyber_button(p_text, "Requires Age %d+ (Current: %d)" % [min_age_req, PlayerData.age]))
		elif has_meditated_this_year:
			list.add_child(_create_disabled_cyber_button(p_text, "Completed for Age %d (Age up to meditate next year)" % PlayerData.age))
		else:
			var btn := _create_cyber_button(p_text, p["color"], func():
				_execute_meditation(p)
			)
			list.add_child(btn)

	meditation_modal_overlay.visible = true


func _show_mind_and_body_modal() -> void:
	if mind_body_modal_overlay != null and is_instance_valid(mind_body_modal_overlay):
		mind_body_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🧘 MIND & BODY WELLNESS", "Fitness, Grooming, Spa Rejuvenation & Mental Serenity", Color("#10b981"))
	mind_body_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 12)
	sm.add_child(sv)

	var stat_title := Label.new()
	stat_title.text = "✨ WELLNESS & VITALITY PROFILE"
	stat_title.add_theme_font_size_override("font_size", 28)
	stat_title.add_theme_color_override("font_color", Color("#34d399"))
	sv.add_child(stat_title)

	var vitals_lbl := Label.new()
	vitals_lbl.text = "❤️ Health: %d%%   •   ✨ Looks: %d%%   •   😊 Happiness: %d%%   •   🧠 Smarts: %d%%" % [
		PlayerData.health,
		PlayerData.looks,
		PlayerData.happiness,
		PlayerData.smarts
	]
	vitals_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vitals_lbl.add_theme_font_size_override("font_size", 24)
	vitals_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
	sv.add_child(vitals_lbl)

	list.add_child(summary_card)

	var gym_btn := _create_cyber_button("🏋️ Titan Cyber Gym & Athletic Fitness\nStrength training, cardio tracks, aquatic laps, combat boxing and all-inclusive annual memberships.", Color("#38bdf8"), func():
		mind_body_modal_overlay.queue_free()
		_show_gym_modal()
	)
	gym_btn.custom_minimum_size.y = 80
	gym_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(gym_btn)

	var salon_btn := _create_cyber_button("💇 Luxe Hair & Beauty Salon\nStyling, designer haircuts, beard grooming, manicures, and aesthetic beauty pampering.", Color("#ec4899"), func():
		mind_body_modal_overlay.queue_free()
		_show_salon_modal()
	)
	salon_btn.custom_minimum_size.y = 80
	salon_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(salon_btn)

	var spa_btn := _create_cyber_button("🧖 Oasis Luxury Day Spa & Thermal Baths\nVolcanic hot springs, deep tissue massages, eucalyptus saunas, mud facials, and VIP retreats.", Color("#06b6d4"), func():
		mind_body_modal_overlay.queue_free()
		_show_spa_modal()
	)
	spa_btn.custom_minimum_size.y = 80
	spa_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(spa_btn)

	var med_btn := _create_cyber_button("🧘 Nirvana Mindfulness & Meditation\nBreathwork, hatha yoga, singing sound baths, chakra balancing, and transcendental retreats.", Color("#a855f7"), func():
		mind_body_modal_overlay.queue_free()
		_show_meditation_modal()
	)
	med_btn.custom_minimum_size.y = 80
	med_btn.add_theme_font_size_override("font_size", 24)
	list.add_child(med_btn)

	mind_body_modal_overlay.visible = true


func _show_salon_modal() -> void:
	if salon_modal_overlay != null and is_instance_valid(salon_modal_overlay):
		salon_modal_overlay.queue_free()

	var modal := _create_cyber_modal("💇 LUXE HAIR & BEAUTY SALON", "Professional Stylists, Precision Trims & Aesthetic Makeovers", Color("#ec4899"))
	salon_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#ec4899")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var profile_lbl := Label.new()
	profile_lbl.text = "✨ Current Looks: %d%%   •   😊 Happiness: %d%%   •   💵 Funds: $%s" % [
		PlayerData.looks,
		PlayerData.happiness,
		_format_number(PlayerData.money + PlayerData.bank_savings)
	]
	profile_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_lbl.add_theme_font_size_override("font_size", 24)
	profile_lbl.add_theme_color_override("font_color", Color("#fdf2f8"))
	sv.add_child(profile_lbl)
	list.add_child(summary_card)

	var has_salon_this_year: bool = (PlayerData.last_salon_activity_age == PlayerData.age)
	if has_salon_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 20)
		lm.add_theme_constant_override("margin_right", 20)
		lm.add_theme_constant_override("margin_top", 14)
		lm.add_theme_constant_override("margin_bottom", 14)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL SALON VISIT COMPLETED\nYou have already received styling and grooming services for Age %d.\nStyling and aesthetic pampering are complete for this year. Advance age (+1 Year) to visit the salon again!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 23)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

	var services := [
		{"name": "✂️ Quick Trim & Clean Up", "cost": 40, "looks": 5, "hap": 4, "desc": "Clean up split ends and neckline for a neat, fresh look."},
		{"name": "💇 Designer Haircut & Blowout", "cost": 120, "looks": 12, "hap": 8, "desc": "A custom haircut crafted by senior stylists with premium blow-dry."},
		{"name": "🎨 Balayage Color & Highlights", "cost": 260, "looks": 18, "hap": 14, "desc": "Luminous hand-painted highlights and nourishing gloss treatment."},
		{"name": "🧔 Deluxe Hot Towel Beard Grooming", "cost": 65, "looks": 8, "hap": 6, "desc": "Straight-razor edge detailing, essential oils, and hot towel facial compress."},
		{"name": "💅 Luxury Gel Manicure & Pedicure", "cost": 95, "looks": 9, "hap": 9, "desc": "Exfoliating foot soak, cuticles, hand massage, and resilient gel finish."}
	]

	for s in services:
		var cost: int = int(s["cost"])
		var btn_text := "%s ($%d)\n%s" % [s["name"], cost, s["desc"]]
		if has_salon_this_year:
			list.add_child(_create_disabled_cyber_button(btn_text, "Completed for Age %d (Age up to visit next year)" % PlayerData.age))
		else:
			var btn := _create_cyber_button(btn_text, Color("#ec4899"), func():
				if PlayerData.last_salon_activity_age == PlayerData.age:
					return
				var total_funds: int = PlayerData.money + PlayerData.bank_savings
				if total_funds < cost:
					add_life_event("💸 INSUFFICIENT FUNDS: The salon service costs $%d, but you only have $%d." % [cost, total_funds], "finance")
					show_tab("timeline")
					salon_modal_overlay.queue_free()
					return
				PlayerData.debit_funds(cost)
				PlayerData.last_salon_activity_age = PlayerData.age
				PlayerData.looks = mini(100, PlayerData.looks + int(s["looks"]))
				PlayerData.happiness = mini(100, PlayerData.happiness + int(s["hap"]))
				add_life_event("💇 SALON MAKEOVER: You treated yourself to %s ($%d)!" % [s["name"], cost], "lifestyle")
				update_ui()
				SaveManager.save_game()
				salon_modal_overlay.queue_free()
			)
			btn.custom_minimum_size.y = 74
			btn.add_theme_font_size_override("font_size", 23)
			list.add_child(btn)

	salon_modal_overlay.visible = true


func _show_spa_modal() -> void:
	if spa_modal_overlay != null and is_instance_valid(spa_modal_overlay):
		spa_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🧖 OASIS LUXURY DAY SPA", "Hydrotherapy, Swedish Massages & Deep Thermal Rejuvenation", Color("#06b6d4"))
	spa_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#06b6d4")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var profile_lbl := Label.new()
	profile_lbl.text = "❤️ Health: %d%%   •   😊 Happiness: %d%%   •   💵 Funds: $%s" % [
		PlayerData.health,
		PlayerData.happiness,
		_format_number(PlayerData.money + PlayerData.bank_savings)
	]
	profile_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profile_lbl.add_theme_font_size_override("font_size", 24)
	profile_lbl.add_theme_color_override("font_color", Color("#ecfeff"))
	sv.add_child(profile_lbl)
	list.add_child(summary_card)

	var has_spa_this_year: bool = (PlayerData.last_spa_activity_age == PlayerData.age)
	if has_spa_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 20)
		lm.add_theme_constant_override("margin_right", 20)
		lm.add_theme_constant_override("margin_top", 14)
		lm.add_theme_constant_override("margin_bottom", 14)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL SPA RETREAT COMPLETED\nYou have already enjoyed luxury spa therapy for Age %d.\nHydrotherapy, thermal soaks, and massages are complete for this year. Advance age (+1 Year) to visit the spa again!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 23)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

	var services := [
		{"name": "♨️ Volcanic Mineral Hot Springs", "cost": 90, "health": 6, "hap": 8, "looks": 2, "desc": "Immerse in geothermal sulfur-rich hot springs to alleviate muscular soreness."},
		{"name": "💆 90-Minute Swedish Massage", "cost": 180, "health": 10, "hap": 15, "looks": 3, "desc": "Targeted acupressure and long fluid strokes melting chronic tension away."},
		{"name": "🧴 Dead Sea Botanical Mud Facial", "cost": 140, "health": 4, "hap": 10, "looks": 12, "desc": "Mineral-rich therapeutic mud mask cleansing pores and restoring radiant skin."},
		{"name": "🌿 Eucalyptus Herbal Sauna & Cold Plunge", "cost": 110, "health": 8, "hap": 10, "looks": 3, "desc": "Cardiovascular heat conditioning combined with energizing ice immersion."},
		{"name": "👑 Royal Imperial VIP Day Retreat", "cost": 500, "health": 18, "hap": 25, "looks": 16, "desc": "Full private cabana, champagne aromatherapy, four-hand massage, and whole-body exfoliation."}
	]

	for s in services:
		var cost: int = int(s["cost"])
		var btn_text := "%s ($%d)\n%s" % [s["name"], cost, s["desc"]]
		if has_spa_this_year:
			list.add_child(_create_disabled_cyber_button(btn_text, "Completed for Age %d (Age up to visit next year)" % PlayerData.age))
		else:
			var btn := _create_cyber_button(btn_text, Color("#06b6d4"), func():
				if PlayerData.last_spa_activity_age == PlayerData.age:
					return
				var total_funds: int = PlayerData.money + PlayerData.bank_savings
				if total_funds < cost:
					add_life_event("💸 INSUFFICIENT FUNDS: The spa treatment costs $%d, but you only have $%d." % [cost, total_funds], "finance")
					show_tab("timeline")
					spa_modal_overlay.queue_free()
					return
				PlayerData.debit_funds(cost)
				PlayerData.last_spa_activity_age = PlayerData.age
				PlayerData.health = mini(100, PlayerData.health + int(s["health"]))
				PlayerData.happiness = mini(100, PlayerData.happiness + int(s["hap"]))
				PlayerData.looks = mini(100, PlayerData.looks + int(s["looks"]))
				add_life_event("🧖 LUXURY SPA REJUVENATION: You enjoyed %s ($%d)!" % [s["name"], cost], "lifestyle")
				update_ui()
				SaveManager.save_game()
				spa_modal_overlay.queue_free()
			)
			btn.custom_minimum_size.y = 74
			btn.add_theme_font_size_override("font_size", 23)
			list.add_child(btn)

	spa_modal_overlay.visible = true



func _show_shopping_modal() -> void:
	if shopping_modal_overlay != null and is_instance_valid(shopping_modal_overlay):
		shopping_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🛍️ COMMERCIAL SHOPPING & DEALERSHIPS", "Vehicles, Properties, Aircraft, Yachts & Luxury Valuables", Color("#38bdf8"))
	shopping_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var funds_lbl := Label.new()
	var total_avail: int = PlayerData.money + PlayerData.bank_savings
	funds_lbl.text = "💳 Capital Available: Cash $%s   •   Bank Savings: $%s   (Total: $%s)" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		_format_number(total_avail)
	]
	funds_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	funds_lbl.add_theme_font_size_override("font_size", 24)
	funds_lbl.add_theme_color_override("font_color", Color("#f0f9ff"))
	sv.add_child(funds_lbl)
	list.add_child(summary_card)

	var shopping_categories := [
		{
			"category": AssetCatalog.CATEGORY_BICYCLES,
			"title": "🚲 Velocity Eco-Cycles (Bicycles)",
			"desc": "Commuter cruisers, electric ebikes, gravel racers, and carbon performance bicycles.",
			"color": Color("#06b6d4")
		},
		{
			"category": AssetCatalog.CATEGORY_CARS,
			"title": "🚗 Apex Motors Showroom (Car Dealerships)",
			"desc": "Compact hatchbacks, executive electric sedans, muscle roadsters, and hypercars.",
			"color": Color("#0284c7")
		},
		{
			"category": AssetCatalog.CATEGORY_MOTORCYCLES,
			"title": "🏍️ Thunder Cycles (Motorcycle Dealers)",
			"desc": "City scooters, bobbers, cafe racers, adventure tourers, and superbikes.",
			"color": Color("#8b5cf6")
		},
		{
			"category": AssetCatalog.CATEGORY_JEWELRY,
			"title": "💎 Aurelia Haute Jewelers & Gemologists",
			"desc": "Chronographs, diamond solitaires, sapphire necklaces, and prestige gold timepieces.",
			"color": Color("#f59e0b")
		},
		{
			"category": AssetCatalog.CATEGORY_INSTRUMENTS,
			"title": "🎸 Virtuoso Instruments & Pro Audio",
			"desc": "Acoustic concert guitars, electronic synthesizers, violins, and Steinway grand pianos.",
			"color": Color("#ec4899")
		},
		{
			"category": AssetCatalog.CATEGORY_PROPERTIES,
			"title": "🏢 Pinnacle Real Estate & Property Brokers",
			"desc": "Modern condos, suburban family estates, penthouse lofts, and oceanfront mega mansions.",
			"color": Color("#10b981")
		},
		{
			"category": AssetCatalog.CATEGORY_AIRCRAFT,
			"title": "✈️ Skylink Aviation & Rotorcraft Dealerships",
			"desc": "Aerobatic light aircraft, turbine helicopters, and intercontinental private business jets.",
			"color": Color("#38bdf8")
		},
		{
			"category": AssetCatalog.CATEGORY_YACHTS,
			"title": "🛥️ Oceanking Marine & Luxury Yacht Dealers",
			"desc": "High-performance jet skis, catamaran cruisers, offshore yachts, and mega superyachts.",
			"color": Color("#2563eb")
		},
		{
			"category": AssetCatalog.CATEGORY_FIREARMS,
			"title": "🎯 Ironclad Defense & Tactical Armory (Gun Store)",
			"desc": "Licensed concealed pistols, home defense shotguns, tactical carbines, and precision marksman rifles.",
			"color": Color("#ef4444")
		}
	]

	for item in shopping_categories:
		var cat_id: String = item["category"]
		var btn_text: String = "%s\n%s" % [item["title"], item["desc"]]
		var btn := _create_cyber_button(btn_text, item["color"], func():
			shopping_modal_overlay.queue_free()
			_open_asset_marketplace_modal(cat_id)
		)
		btn.custom_minimum_size.y = 80
		btn.add_theme_font_size_override("font_size", 24)
		list.add_child(btn)

	shopping_modal_overlay.visible = true


func _show_social_media_modal() -> void:
	if social_media_modal_overlay != null and is_instance_valid(social_media_modal_overlay):
		social_media_modal_overlay.queue_free()

	var modal := _create_cyber_modal("📱 SOCIAL MEDIA & CONTENT CREATION", "Manage Online Presence, Go Viral, Build Fanbases & Monetize", Color("#38bdf8"))
	social_media_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var total_followers: int = 0
	var active_accounts_count: int = 0
	if PlayerData.get("social_media") is Dictionary:
		for p_key in PlayerData.social_media:
			var acc: Dictionary = PlayerData.social_media[p_key]
			total_followers += int(acc.get("followers", 0))
			active_accounts_count += 1

	var stat_lbl := Label.new()
	stat_lbl.text = "🌐 Active Platforms: %d/5   •   👥 Global Audience: %s followers   •   Age: %d" % [
		active_accounts_count,
		_format_number(total_followers),
		PlayerData.age
	]
	stat_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_lbl.add_theme_font_size_override("font_size", 24)
	stat_lbl.add_theme_color_override("font_color", Color("#f0f9ff"))
	sv.add_child(stat_lbl)
	list.add_child(summary_card)

	var platforms: Dictionary = SocialMediaManager.get_platforms()
	for p_key in platforms:
		var p_info: Dictionary = platforms[p_key]
		var p_name: String = str(p_info["name"])
		var p_icon: String = str(p_info["icon"])
		var p_color: Color = Color(str(p_info["color"]))
		var metric: String = str(p_info["metric"])
		var p_desc: String = str(p_info["desc"])
		var has_acc: bool = SocialMediaManager.has_account(PlayerData, p_key)

		var p_card := PanelContainer.new()
		p_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(p_color))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		p_card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 12)
		cm.add_child(cv)

		if not has_acc:
			var head_lbl := Label.new()
			head_lbl.text = "%s %s" % [p_icon, p_name]
			head_lbl.add_theme_font_size_override("font_size", 26)
			head_lbl.add_theme_color_override("font_color", p_color)
			cv.add_child(head_lbl)

			var d_lbl := Label.new()
			d_lbl.text = "%s (Tracks %s)" % [p_desc, metric]
			d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			d_lbl.add_theme_font_size_override("font_size", 20)
			d_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
			cv.add_child(d_lbl)

			var btn_create := _create_cyber_button("Launch New %s Account" % p_name, p_color, func():
				var res := SocialMediaManager.create_account(PlayerData, p_key)
				if res["success"]:
					add_life_event(res["message"], "lifestyle")
					update_ui()
					_show_social_media_modal()
				else:
					add_life_event(res["message"], "lifestyle")
					show_tab("timeline")
			)
			btn_create.icon = preload("res://scripts/ui/social_platform_icons.gd").icon(p_key)
			btn_create.set_meta("action_emoji", "")
			btn_create.custom_minimum_size.y = 56
			btn_create.add_theme_font_size_override("font_size", 22)
			cv.add_child(btn_create)
		else:
			var acc_data: Dictionary = SocialMediaManager.get_account(PlayerData, p_key)
			var handle: String = str(acc_data.get("handle", ""))
			var followers: int = int(acc_data.get("followers", 0))
			var is_verif: bool = bool(acc_data.get("is_verified", false))
			var verif_badge := " ☑️ [VERIFIED]" if is_verif else ""

			var head_h := HBoxContainer.new()
			cv.add_child(head_h)

			var title_lbl := Label.new()
			title_lbl.text = "%s %s • %s%s" % [p_icon, p_name, handle, verif_badge]
			title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			title_lbl.add_theme_font_size_override("font_size", 26)
			title_lbl.add_theme_color_override("font_color", p_color)
			head_h.add_child(title_lbl)

			var stats_lbl := Label.new()
			stats_lbl.text = "📈 %s: %s   •   Total Posts: %d" % [
				metric,
				_format_number(followers),
				int(acc_data.get("posts_count", 0))
			]
			stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			stats_lbl.add_theme_font_size_override("font_size", 22)
			stats_lbl.add_theme_color_override("font_color", Color("#4ade80"))
			cv.add_child(stats_lbl)

			var act_grid := GridContainer.new()
			act_grid.columns = 2
			act_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			act_grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
			act_grid.add_theme_constant_override("h_separation", 12)
			act_grid.add_theme_constant_override("v_separation", 10)
			cv.add_child(act_grid)

			var has_posted_this_year: bool = int(acc_data.get("last_post_age", -1)) == PlayerData.age
			var post_text: String = "📝 Post Shared (Age %d)" % PlayerData.age if has_posted_this_year else "📝 Create New Post"
			var btn_post := _create_cyber_button(post_text, Color("#38bdf8"), func():
				if int(acc_data.get("last_post_age", -1)) == PlayerData.age:
					return
				var res := SocialMediaManager.create_post(PlayerData, p_key)
				add_life_event(res["message"], "lifestyle")
				update_ui()
				_show_social_media_modal()
			)
			btn_post.custom_minimum_size = Vector2(100, 52)
			btn_post.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_post.add_theme_font_size_override("font_size", 20)
			if has_posted_this_year:
				btn_post.disabled = true
				btn_post.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_post.tooltip_text = "Completed for Age %d (Age up to post again next year)" % PlayerData.age
			act_grid.add_child(btn_post)

			var verif_text := "☑️ Verified" if is_verif else "☑️ Apply for Blue Tick"
			var btn_verif := _create_cyber_button(verif_text, Color("#60a5fa"), func():
				var res := SocialMediaManager.apply_verification(PlayerData, p_key)
				add_life_event(res["message"], "lifestyle")
				update_ui()
				_show_social_media_modal()
			)
			btn_verif.custom_minimum_size = Vector2(100, 52)
			btn_verif.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_verif.add_theme_font_size_override("font_size", 20)
			if is_verif:
				btn_verif.disabled = true
				btn_verif.modulate = Color(0.6, 0.6, 0.6, 0.7)
			act_grid.add_child(btn_verif)

			var has_ad_this_year: bool = int(acc_data.get("last_ad_age", -1)) == PlayerData.age
			var ad_text: String = "📈 Campaign Run (Age %d)" % PlayerData.age if has_ad_this_year else "📈 Buy Followers / Ads ($150)"
			var btn_buy_foll := _create_cyber_button(ad_text, Color("#f59e0b"), func():
				if int(acc_data.get("last_ad_age", -1)) == PlayerData.age:
					return
				var res := SocialMediaManager.buy_followers(PlayerData, p_key, 0)
				add_life_event(res["message"], "lifestyle")
				update_ui()
				_show_social_media_modal()
			)
			btn_buy_foll.custom_minimum_size = Vector2(100, 52)
			btn_buy_foll.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_buy_foll.add_theme_font_size_override("font_size", 20)
			if has_ad_this_year:
				btn_buy_foll.disabled = true
				btn_buy_foll.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_buy_foll.tooltip_text = "Completed for Age %d (Age up to run campaign next year)" % PlayerData.age
			act_grid.add_child(btn_buy_foll)

			var has_trolled_this_year: bool = int(acc_data.get("last_troll_age", -1)) == PlayerData.age
			var troll_text: String = "😈 Trolled (Age %d)" % PlayerData.age if has_trolled_this_year else "😈 Troll Someone Online"
			var btn_troll := _create_cyber_button(troll_text, Color("#a855f7"), func():
				if int(acc_data.get("last_troll_age", -1)) == PlayerData.age:
					return
				var res := SocialMediaManager.troll_someone(PlayerData, p_key)
				add_life_event(res["message"], "lifestyle")
				update_ui()
				_show_social_media_modal()
			)
			btn_troll.custom_minimum_size = Vector2(100, 52)
			btn_troll.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_troll.add_theme_font_size_override("font_size", 20)
			if has_trolled_this_year:
				btn_troll.disabled = true
				btn_troll.modulate = Color(0.6, 0.6, 0.6, 0.7)
				btn_troll.tooltip_text = "Completed for Age %d (Age up to troll next year)" % PlayerData.age
			act_grid.add_child(btn_troll)

			var btn_delete := _create_cyber_button("🗑️ Delete %s Account" % p_name, Color("#f43f5e"), func():
				var res := SocialMediaManager.delete_account(PlayerData, p_key)
				add_life_event(res["message"], "lifestyle")
				update_ui()
				_show_social_media_modal()
			)
			btn_delete.custom_minimum_size = Vector2(100, 52)
			btn_delete.alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn_delete.add_theme_font_size_override("font_size", 20)
			cv.add_child(btn_delete)

		list.add_child(p_card)

	social_media_modal_overlay.visible = true


func _show_pet_adoption_modal() -> void:
	if pet_adoption_modal_overlay != null and is_instance_valid(pet_adoption_modal_overlay):
		pet_adoption_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🐾 COMPANION PET ADOPTION & RANCH", "Rescue Shelters, Certified Breeders, Pet Stores & Equestrian Ranches", Color("#10b981"))
	pet_adoption_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var funds_lbl := Label.new()
	var total_funds: int = PlayerData.money + PlayerData.bank_savings
	var pets_count: int = PlayerData.pets.size() if PlayerData.get("pets") is Array else 0
	funds_lbl.text = "🐾 Current Household Pets: %d   •   Available Capital: $%s" % [
		pets_count,
		_format_number(total_funds)
	]
	funds_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	funds_lbl.add_theme_font_size_override("font_size", 24)
	funds_lbl.add_theme_color_override("font_color", Color("#f0fdf4"))
	sv.add_child(funds_lbl)
	list.add_child(summary_card)

	var has_adopted_this_year: bool = (PlayerData.last_pet_adoption_age == PlayerData.age)
	if has_adopted_this_year:
		var lock_banner := PanelContainer.new()
		lock_banner.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var lm := MarginContainer.new()
		lm.add_theme_constant_override("margin_left", 20)
		lm.add_theme_constant_override("margin_right", 20)
		lm.add_theme_constant_override("margin_top", 14)
		lm.add_theme_constant_override("margin_bottom", 14)
		lock_banner.add_child(lm)

		var ll := Label.new()
		ll.text = "⏳ ANNUAL PET ADOPTION COMPLETED\nYou have already adopted a companion pet for Age %d.\nGive your new companion time to settle into their home. Advance age (+1 Year) to adopt another pet!" % PlayerData.age
		ll.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ll.add_theme_font_size_override("font_size", 23)
		ll.add_theme_color_override("font_color", Color("#fbbf24"))
		lm.add_child(ll)
		list.add_child(lock_banner)

	var adoption_centers := [
		{
			"type": "dog_shelter",
			"title": "🐕 Canine Rescue Shelter (Free Adoption)",
			"desc": "Loving rescued dogs and crossbreeds of varying ages looking for a forever home.",
			"color": Color("#10b981")
		},
		{
			"type": "cat_shelter",
			"title": "🐈 Feline Haven Rescue Shelter (Free Adoption)",
			"desc": "Affectionate rescue cats and playful kittens eager for cozy companionship.",
			"color": Color("#06b6d4")
		},
		{
			"type": "dog_breeder",
			"title": "🐶 Certified Canine Breeders (Puppies <= 1 y.o.)",
			"desc": "Purebred puppies with registered pedigrees, health certifications, and lineage records.",
			"color": Color("#f59e0b")
		},
		{
			"type": "cat_breeder",
			"title": "🐱 Certified Feline Breeders (Kittens <= 1 y.o.)",
			"desc": "Championship bloodline kittens including Persians, Bengals, Ragdolls, and Maine Coons.",
			"color": Color("#ec4899")
		},
		{
			"type": "pet_store",
			"title": "🐢 Critter Corner Exotic Pet Store",
			"desc": "Turtles, rabbits, birds, ornamental fish, ball pythons, and fancy hooded rats.",
			"color": Color("#8b5cf6")
		},
		{
			"type": "ranch",
			"title": "🐎 Heritage Equestrian Ranch & Stables",
			"desc": "Purebred thoroughbreds, desert Arabians, Friesians, and quarter horses for purchase.",
			"color": Color("#38bdf8")
		}
	]

	for c in adoption_centers:
		var c_type: String = str(c["type"])
		var btn_text: String = "%s\n%s" % [c["title"], c["desc"]]
		if has_adopted_this_year:
			list.add_child(_create_disabled_cyber_button(btn_text, "Completed for Age %d (Age up to adopt next year)" % PlayerData.age))
		else:
			var btn := _create_cyber_button(btn_text, c["color"], func():
				pet_adoption_modal_overlay.queue_free()
				match c_type:
					"dog_shelter":
						_show_pet_shelter_modal(PetManager.SOURCE_DOG_SHELTER)
					"cat_shelter":
						_show_pet_shelter_modal(PetManager.SOURCE_CAT_SHELTER)
					"dog_breeder":
						_show_pet_breeder_modal(PetManager.SOURCE_DOG_BREEDER)
					"cat_breeder":
						_show_pet_breeder_modal(PetManager.SOURCE_CAT_BREEDER)
					"pet_store":
						_show_pet_store_modal()
					"ranch":
						_show_pet_ranch_modal()
			)
			btn.custom_minimum_size.y = 80
			btn.add_theme_font_size_override("font_size", 24)
			list.add_child(btn)

	pet_adoption_modal_overlay.visible = true


func _show_pet_shelter_modal(shelter_type: String) -> void:
	if pet_adoption_modal_overlay != null and is_instance_valid(pet_adoption_modal_overlay):
		pet_adoption_modal_overlay.queue_free()

	var is_dog: bool = (shelter_type == PetManager.SOURCE_DOG_SHELTER)
	var title: String = "🐕 CANINE RESCUE SHELTER" if is_dog else "🐈 FELINE HAVEN RESCUE SHELTER"
	var subtitle: String = "Free Adoptions • Give Rescued Animals a Loving Forever Home"
	var border_color: Color = Color("#10b981") if is_dog else Color("#06b6d4")

	var modal := _create_cyber_modal(title, subtitle, border_color)
	pet_adoption_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var animals := PetManager.get_shelter_animals(shelter_type)
	for a in animals:
		var p_card := PanelContainer.new()
		p_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_color))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		p_card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var head_lbl := Label.new()
		head_lbl.text = "%s %s • %s" % [a["icon"], a["breed"], a["age_str"]]
		head_lbl.add_theme_font_size_override("font_size", 24)
		head_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
		cv.add_child(head_lbl)

		var stats_lbl := Label.new()
		stats_lbl.text = "❤️ Health: %d%%   •   😊 Happiness: %d%%   •   🥩 Upkeep: $%d/yr   •   Fee: FREE" % [
			a["health"],
			a["happiness"],
			a["upkeep"]
		]
		stats_lbl.add_theme_font_size_override("font_size", 20)
		stats_lbl.add_theme_color_override("font_color", Color("#4ade80"))
		cv.add_child(stats_lbl)

		var pet_spec: Dictionary = a
		var has_adopted_this_year: bool = (PlayerData.last_pet_adoption_age == PlayerData.age)
		var btn_adopt := _create_cyber_button("🐾 Adopt for Free!", border_color, func():
			var res := PetManager.adopt_pet(PlayerData, pet_spec, "", true)
			if res["success"]:
				add_life_event(res["message"], "relationship")
				pet_adoption_modal_overlay.queue_free()
				update_ui()
				update_assets_panel()
			else:
				add_life_event(res["message"], "relationship")
				show_tab("timeline")
		)
		btn_adopt.custom_minimum_size.y = 52
		btn_adopt.add_theme_font_size_override("font_size", 22)
		if has_adopted_this_year:
			btn_adopt.disabled = true
			btn_adopt.modulate = Color(0.6, 0.6, 0.6, 0.7)
			btn_adopt.text = "🐾 Adoption Completed for Age %d" % PlayerData.age
		cv.add_child(btn_adopt)

		list.add_child(p_card)

	pet_adoption_modal_overlay.visible = true


func _show_pet_breeder_modal(breeder_type: String) -> void:
	if pet_adoption_modal_overlay != null and is_instance_valid(pet_adoption_modal_overlay):
		pet_adoption_modal_overlay.queue_free()

	var is_dog: bool = (breeder_type == PetManager.SOURCE_DOG_BREEDER)
	var title: String = "🐶 CERTIFIED CANINE BREEDER" if is_dog else "🐱 CERTIFIED FELINE BREEDER"
	var subtitle: String = "Registered Purebred Puppies & Kittens (Kitten/Puppy -> 1 y.o. Max)"
	var border_color: Color = Color("#f59e0b") if is_dog else Color("#ec4899")

	var modal := _create_cyber_modal(title, subtitle, border_color)
	pet_adoption_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var animals := PetManager.get_breeder_animals(breeder_type)
	for a in animals:
		var p_card := PanelContainer.new()
		p_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(border_color))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		p_card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var head_lbl := Label.new()
		head_lbl.text = "%s Purebred %s • %s" % [a["icon"], a["breed"], a["age_str"]]
		head_lbl.add_theme_font_size_override("font_size", 24)
		head_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
		cv.add_child(head_lbl)

		var price: int = int(a["price"])
		var upkeep: int = int(a["upkeep"])
		var stats_lbl := Label.new()
		stats_lbl.text = "💰 Price: $%s   •   🥩 Upkeep: $%s/yr   •   ❤️ Health: %d%%" % [
			_format_number(price),
			_format_number(upkeep),
			a["health"]
		]
		stats_lbl.add_theme_font_size_override("font_size", 20)
		stats_lbl.add_theme_color_override("font_color", Color("#4ade80"))
		cv.add_child(stats_lbl)

		var pet_spec: Dictionary = a
		var has_adopted_this_year: bool = (PlayerData.last_pet_adoption_age == PlayerData.age)
		var can_afford: bool = (PlayerData.money + PlayerData.bank_savings) >= price
		var btn_buy := _create_cyber_button("🐾 Purchase for $%s" % _format_number(price), border_color, func():
			var res := PetManager.adopt_pet(PlayerData, pet_spec, "", true)
			if res["success"]:
				add_life_event(res["message"], "relationship")
				pet_adoption_modal_overlay.queue_free()
				update_ui()
				update_assets_panel()
			else:
				add_life_event(res["message"], "relationship")
				show_tab("timeline")
		)
		btn_buy.custom_minimum_size.y = 52
		btn_buy.add_theme_font_size_override("font_size", 22)
		if has_adopted_this_year:
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.7)
			btn_buy.text = "🐾 Adoption Completed for Age %d" % PlayerData.age
		elif not can_afford:
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_buy.text = "🔒 Requires $%s (Insufficient Funds)" % _format_number(price)
		cv.add_child(btn_buy)

		list.add_child(p_card)

	pet_adoption_modal_overlay.visible = true


func _show_pet_store_modal() -> void:
	if pet_adoption_modal_overlay != null and is_instance_valid(pet_adoption_modal_overlay):
		pet_adoption_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🐢 CRITTER CORNER EXOTIC PET STORE", "Turtles, Rats, Snakes, Rabbits, Birds & Ornamental Fish", Color("#8b5cf6"))
	pet_adoption_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var animals := PetManager.get_pet_store_animals()
	for a in animals:
		var p_card := PanelContainer.new()
		p_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#8b5cf6")))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		p_card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var head_lbl := Label.new()
		head_lbl.text = "%s %s • %s" % [a["icon"], a["species"], a["age_str"]]
		head_lbl.add_theme_font_size_override("font_size", 24)
		head_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
		cv.add_child(head_lbl)

		var price: int = int(a["price"])
		var upkeep: int = int(a["upkeep"])
		var stats_lbl := Label.new()
		stats_lbl.text = "💰 Price: $%s   •   🥩 Upkeep: $%s/yr   •   ⏳ Lifespan: ~%d yrs" % [
			_format_number(price),
			_format_number(upkeep),
			a["lifespan"]
		]
		stats_lbl.add_theme_font_size_override("font_size", 20)
		stats_lbl.add_theme_color_override("font_color", Color("#4ade80"))
		cv.add_child(stats_lbl)

		var pet_spec: Dictionary = a
		var has_adopted_this_year: bool = (PlayerData.last_pet_adoption_age == PlayerData.age)
		var can_afford: bool = (PlayerData.money + PlayerData.bank_savings) >= price
		var btn_buy := _create_cyber_button("🐾 Purchase for $%s" % _format_number(price), Color("#8b5cf6"), func():
			var res := PetManager.adopt_pet(PlayerData, pet_spec, "", true)
			if res["success"]:
				add_life_event(res["message"], "relationship")
				pet_adoption_modal_overlay.queue_free()
				update_ui()
				update_assets_panel()
			else:
				add_life_event(res["message"], "relationship")
				show_tab("timeline")
		)
		btn_buy.custom_minimum_size.y = 52
		btn_buy.add_theme_font_size_override("font_size", 22)
		if has_adopted_this_year:
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.7)
			btn_buy.text = "🐾 Adoption Completed for Age %d" % PlayerData.age
		elif not can_afford:
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_buy.text = "🔒 Requires $%s (Insufficient Funds)" % _format_number(price)
		cv.add_child(btn_buy)

		list.add_child(p_card)

	pet_adoption_modal_overlay.visible = true


func _show_pet_ranch_modal() -> void:
	if pet_adoption_modal_overlay != null and is_instance_valid(pet_adoption_modal_overlay):
		pet_adoption_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🐎 HERITAGE EQUESTRIAN RANCH & STABLES", "Equestrian Purchases: Purebred Horses, Desert Arabians & Thoroughbreds", Color("#38bdf8"))
	pet_adoption_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var horses := PetManager.get_ranch_horses()
	for h in horses:
		var p_card := PanelContainer.new()
		p_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		p_card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 10)
		cm.add_child(cv)

		var head_lbl := Label.new()
		head_lbl.text = "%s %s • %s" % [h["icon"], h["breed"], h["age_str"]]
		head_lbl.add_theme_font_size_override("font_size", 24)
		head_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
		cv.add_child(head_lbl)

		var price: int = int(h["price"])
		var upkeep: int = int(h["upkeep"])
		var stats_lbl := Label.new()
		stats_lbl.text = "💰 Price: $%s   •   🥩 Upkeep: $%s/yr   •   ❤️ Health: %d%%" % [
			_format_number(price),
			_format_number(upkeep),
			h["health"]
		]
		stats_lbl.add_theme_font_size_override("font_size", 20)
		stats_lbl.add_theme_color_override("font_color", Color("#4ade80"))
		cv.add_child(stats_lbl)

		var pet_spec: Dictionary = h
		var has_adopted_this_year: bool = (PlayerData.last_pet_adoption_age == PlayerData.age)
		var can_afford: bool = (PlayerData.money + PlayerData.bank_savings) >= price
		var btn_buy := _create_cyber_button("🐎 Purchase Horse ($%s)" % _format_number(price), Color("#38bdf8"), func():
			var res := PetManager.adopt_pet(PlayerData, pet_spec, "", true)
			if res["success"]:
				add_life_event(res["message"], "relationship")
				pet_adoption_modal_overlay.queue_free()
				update_ui()
				update_assets_panel()
			else:
				add_life_event(res["message"], "relationship")
				show_tab("timeline")
		)
		btn_buy.custom_minimum_size.y = 52
		btn_buy.add_theme_font_size_override("font_size", 22)
		if has_adopted_this_year:
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.7)
			btn_buy.text = "🐎 Purchase Completed for Age %d" % PlayerData.age
		elif not can_afford:
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_buy.text = "🔒 Requires $%s (Insufficient Funds)" % _format_number(price)
		cv.add_child(btn_buy)

		list.add_child(p_card)

	pet_adoption_modal_overlay.visible = true


func _show_will_modal() -> void:
	if will_modal_overlay != null and is_instance_valid(will_modal_overlay):
		will_modal_overlay.queue_free()

	var modal := _create_cyber_modal("⚖️ LAST WILL & TESTAMENT", "Estate Planning, Asset Distribution & Inheritance Beneficiaries", Color("#f59e0b"))
	will_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 24)
	sm.add_theme_constant_override("margin_right", 24)
	sm.add_theme_constant_override("margin_top", 18)
	sm.add_theme_constant_override("margin_bottom", 18)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	sm.add_child(sv)

	var total_assets_val: int = 0
	for a in PlayerData.owned_assets:
		total_assets_val += int(a.get("current_value", a.get("purchase_price", 0)))
	var total_estate: int = PlayerData.money + PlayerData.bank_savings + total_assets_val

	var val_lbl := Label.new()
	val_lbl.text = "🏛️ TOTAL ESTIMATED ESTATE VALUE: $%s\n💵 Liquid Funds: $%s Cash + $%s Bank (Converts to Bank Balance upon inheritance)   •   🏰 Asset Portfolio: $%s (%d Assets)" % [
		_format_number(total_estate),
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		_format_number(total_assets_val),
		PlayerData.owned_assets.size()
	]
	val_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	val_lbl.add_theme_font_size_override("font_size", 24)
	val_lbl.add_theme_color_override("font_color", Color("#fef3c7"))
	sv.add_child(val_lbl)

	var cur_beneficiary: String = PlayerData.get("will_recipient")
	if cur_beneficiary == "":
		cur_beneficiary = "CHILDREN"
	var cur_name := "Surviving Children"
	match cur_beneficiary:
		"CHARITY": cur_name = "Philanthropic Charities"
		"SPOUSE": cur_name = "Surviving Spouse / Partner"
		"SPLIT": cur_name = "Equal Split Across Family"
		_: cur_name = "Surviving Children"

	var cur_lbl := Label.new()
	cur_lbl.text = "📜 Current Active Beneficiary: %s" % cur_name
	cur_lbl.add_theme_font_size_override("font_size", 24)
	cur_lbl.add_theme_color_override("font_color", Color("#34d399"))
	sv.add_child(cur_lbl)
	list.add_child(summary_card)

	var options := [
		{
			"id": "CHILDREN",
			"title": "👶 All to Surviving Children",
			"desc": "Bequeath 100% of all cash (converted to bank balance), bank savings, vehicles, and real property equally among your surviving children.",
			"color": Color("#38bdf8")
		},
		{
			"id": "SPOUSE",
			"title": "💍 All to Surviving Spouse / Partner",
			"desc": "Designate your beloved husband or wife as the sole heir to your entire financial and real estate fortune.",
			"color": Color("#ec4899")
		},
		{
			"id": "CHARITY",
			"title": "🏛️ Donate Entire Estate to Charity",
			"desc": "Dedicate all accumulated wealth and properties to global humanitarian charities. Leaves a saintly karmic legacy!",
			"color": Color("#10b981")
		},
		{
			"id": "SPLIT",
			"title": "⚖️ Equal Split Across Family",
			"desc": "Distribute equal shares of the estate across your surviving spouse and all children without favoritism.",
			"color": Color("#f59e0b")
		}
	]

	for opt in options:
		var opt_id: String = str(opt["id"])
		var is_selected: bool = (cur_beneficiary == opt_id)
		var badge: String = " [SELECTED ACTIVE HEIR]" if is_selected else ""
		var btn_text: String = "%s%s\n%s" % [opt["title"], badge, opt["desc"]]
		var btn := _create_cyber_button(btn_text, opt["color"], func():
			PlayerData.will_recipient = opt_id
			add_life_event("⚖️ NOTARIZED WILL: You updated your estate beneficiary to '%s'!" % opt["title"], "milestone")
			SaveManager.save_game()
			update_ui()
			_show_will_modal()
		)
		btn.custom_minimum_size.y = 80
		btn.add_theme_font_size_override("font_size", 24)
		if is_selected:
			btn.modulate = Color(0.8, 1.0, 0.8, 1.0)
		list.add_child(btn)

	will_modal_overlay.visible = true


func _show_charity_modal() -> void:
	if charity_modal_overlay != null and is_instance_valid(charity_modal_overlay):
		charity_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🤝 PHILANTHROPY & CHARITY", "Donate to Worthy Causes • Purify Your Soul & Unlock Permanent Blessings", Color("#10b981"))
	charity_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# 1. Summary & Spiritual State Card
	var summary_card := PanelContainer.new()
	summary_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#10b981")))
	var sm := MarginContainer.new()
	sm.add_theme_constant_override("margin_left", 20)
	sm.add_theme_constant_override("margin_right", 20)
	sm.add_theme_constant_override("margin_top", 16)
	sm.add_theme_constant_override("margin_bottom", 16)
	summary_card.add_child(sm)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 8)
	sm.add_child(sv)

	var funds_lbl := Label.new()
	var total_avail: int = PlayerData.money + PlayerData.bank_savings
	funds_lbl.text = "💳 Available Funds: Cash $%s   •   Bank Savings: $%s   (Total: $%s)" % [
		_format_number(PlayerData.money),
		_format_number(PlayerData.bank_savings),
		_format_number(total_avail)
	]
	funds_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	funds_lbl.add_theme_font_size_override("font_size", 24)
	funds_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
	sv.add_child(funds_lbl)

	# Vitals and Spiritual State (Karma numbers are strictly HIDDEN)
	var vitals_lbl := Label.new()
	var spiritual_state: String = "Neutral Spirit"
	if PlayerData.karma >= 80:
		spiritual_state = "🌟 Seraphic & Luminescent (Greatly Blessed)"
	elif PlayerData.karma >= 50:
		spiritual_state = "✨ Pure, Virtuous & Compassionate"
	elif PlayerData.karma >= 25:
		spiritual_state = "🌱 Kind Hearted & Generous"
	elif PlayerData.karma < 0:
		spiritual_state = "🌑 Heavy Karmic Burden"

	vitals_lbl.text = "😊 Happiness: %d%%   •   Spiritual State: %s" % [
		PlayerData.happiness,
		spiritual_state
	]
	vitals_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vitals_lbl.add_theme_font_size_override("font_size", 23)
	vitals_lbl.add_theme_color_override("font_color", Color("#a7f3d0"))
	sv.add_child(vitals_lbl)

	if PlayerData.total_donated_charity > 0:
		var stat_lbl := Label.new()
		stat_lbl.text = "💖 Lifetime Philanthropy: $%s donated across %d contributions" % [
			_format_number(PlayerData.total_donated_charity),
			PlayerData.charity_donations_count
		]
		stat_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		stat_lbl.add_theme_font_size_override("font_size", 21)
		stat_lbl.add_theme_color_override("font_color", Color("#fde047"))
		sv.add_child(stat_lbl)

	list.add_child(summary_card)

	# 2. Active Blessings Card (if any)
	var active_charity_buff_count: int = 0
	for c in CharityManager.get_all_charities():
		if PlayerData.has_buff(str(c.get("buff_id", ""))):
			active_charity_buff_count += 1

	if active_charity_buff_count > 0:
		var buff_card := PanelContainer.new()
		buff_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
		var bm := MarginContainer.new()
		bm.add_theme_constant_override("margin_left", 20)
		bm.add_theme_constant_override("margin_right", 20)
		bm.add_theme_constant_override("margin_top", 14)
		bm.add_theme_constant_override("margin_bottom", 14)
		buff_card.add_child(bm)

		var bv := VBoxContainer.new()
		bv.add_theme_constant_override("separation", 6)
		bm.add_child(bv)

		var buff_title := Label.new()
		buff_title.text = "✨ ACTIVE PERMANENT PHILANTHROPIC BLESSINGS (%d Unlocked):" % active_charity_buff_count
		buff_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		buff_title.add_theme_font_size_override("font_size", 22)
		buff_title.add_theme_color_override("font_color", Color("#fbbf24"))
		bv.add_child(buff_title)

		for c in CharityManager.get_all_charities():
			var b_id: String = str(c.get("buff_id", ""))
			if PlayerData.has_buff(b_id):
				var b_lbl := Label.new()
				b_lbl.text = "  • %s: %s" % [str(c.get("buff_name", "")), str(c.get("buff_desc", ""))]
				b_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				b_lbl.add_theme_font_size_override("font_size", 19)
				b_lbl.add_theme_color_override("font_color", Color("#fef08a"))
				bv.add_child(b_lbl)

		list.add_child(buff_card)

	# 3. Charity Options List
	var charities: Array[Dictionary] = CharityManager.get_all_charities()
	for c in charities:
		var c_id: String = str(c.get("id", ""))
		var c_name: String = str(c.get("name", "Charity"))
		var c_icon: String = str(c.get("icon", "🤝"))
		var amount: int = int(c.get("donation_amount", 100))
		var min_age: int = int(c.get("min_age", 6))
		var b_id: String = str(c.get("buff_id", ""))
		var b_name: String = str(c.get("buff_name", ""))
		var b_desc: String = str(c.get("buff_desc", ""))
		var desc: String = str(c.get("description", ""))
		var is_blessed: bool = PlayerData.has_buff(b_id)

		var card := PanelContainer.new()
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color("#071318")
		card_style.border_color = Color("#10b981") if is_blessed else Color("#059669")
		card_style.set_border_width_all(2)
		card_style.set_corner_radius_all(14)
		card_style.shadow_color = Color(0, 0, 0, 0.45)
		card_style.shadow_size = 6
		card.add_theme_stylebox_override("panel", card_style)
		list.add_child(card)

		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 22)
		cm.add_theme_constant_override("margin_right", 22)
		cm.add_theme_constant_override("margin_top", 18)
		cm.add_theme_constant_override("margin_bottom", 18)
		card.add_child(cm)

		var cv := VBoxContainer.new()
		cv.add_theme_constant_override("separation", 12)
		cm.add_child(cv)

		# Top Header Row: Icon + Name ... Amount
		var top_row := HBoxContainer.new()
		top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.add_child(top_row)

		var name_lbl := Label.new()
		name_lbl.text = "%s %s" % [c_icon, c_name]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 25)
		name_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		top_row.add_child(name_lbl)

		var amt_lbl := Label.new()
		amt_lbl.text = "$%s" % _format_number(amount)
		amt_lbl.add_theme_font_size_override("font_size", 28)
		amt_lbl.add_theme_color_override("font_color", Color("#34d399"))
		amt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		top_row.add_child(amt_lbl)

		# Description
		var desc_lbl := Label.new()
		desc_lbl.text = desc
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 20)
		desc_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
		cv.add_child(desc_lbl)

		# Buff & Spiritual Impact row (NO numerical karma!)
		var perk_box := VBoxContainer.new()
		perk_box.add_theme_constant_override("separation", 4)
		cv.add_child(perk_box)

		var buff_lbl := Label.new()
		var buff_status_prefix := "✨ [Unlocked] " if is_blessed else "🔒 [Cosmic Blessing] "
		buff_lbl.text = "%s%s: %s" % [buff_status_prefix, b_name, b_desc]
		buff_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		buff_lbl.add_theme_font_size_override("font_size", 20)
		buff_lbl.add_theme_color_override("font_color", Color("#38bdf8") if is_blessed else Color("#67e8f9"))
		perk_box.add_child(buff_lbl)

		var karma_lbl := Label.new()
		karma_lbl.text = "💫 Spiritual Impact: Profoundly purifies your soul, elevates your karma, and brings deep joy."
		karma_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		karma_lbl.add_theme_font_size_override("font_size", 19)
		karma_lbl.add_theme_color_override("font_color", Color("#a7f3d0"))
		perk_box.add_child(karma_lbl)

		# Button / Gating
		var eval := CharityManager.can_donate(PlayerData, c_id)
		var is_allowed: bool = bool(eval.get("allowed", false))
		var reason: String = str(eval.get("reason", ""))

		if not is_allowed:
			var dis_btn := _create_disabled_cyber_button("Contribute $%s" % _format_number(amount), reason)
			cv.add_child(dis_btn)
		else:
			var btn_text: String = "💖 Donate $%s" % _format_number(amount)
			if is_blessed:
				btn_text = "💖 Re-Donate $%s (Continue Blessing)" % _format_number(amount)
			var donate_btn := _create_cyber_button(btn_text, Color("#10b981"), func():
				_execute_charity_donation(c_id)
			)
			cv.add_child(donate_btn)

	charity_modal_overlay.visible = true


func _execute_charity_donation(charity_id: String) -> void:
	var res: Dictionary = CharityManager.donate(PlayerData, charity_id)
	if not bool(res.get("success", false)):
		add_life_event(str(res.get("reason", "Unable to donate.")), "finance")
		return

	var msg: String = str(res.get("message", "Donation made."))
	add_life_event("🤝 CHARITY DONATION: %s" % msg, "finance")
	update_ui()
	SaveManager.save_game()
	_show_charity_modal()


# --- 1. DOCTOR MODAL ---
func _show_doctor_modal() -> void:
	if doctor_modal_overlay != null and is_instance_valid(doctor_modal_overlay):
		doctor_modal_overlay.queue_free()

	var modal := _create_cyber_modal("🩺 ST. JUDE MEDICAL CLINIC", "Advanced Diagnostics, Surgeries, Oncology & Insurance", Color("#38bdf8"))
	doctor_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	var is_light: bool = LifeLibrary.data.theme == "light"

	var get_disc_cost = func(base_cost: int) -> int:
		var disc: float = PlayerData.get_insurance_discount()
		return maxi(1, int(round(float(base_cost) * (1.0 - disc))))

	var get_tag = func() -> String:
		match PlayerData.health_insurance:
			"bronze": return " [-5% Insured]"
			"gold": return " [-10% Insured]"
			"platinum": return " [-25% Insured]"
			_: return ""

	# Status Card
	var stat_card := PanelContainer.new()
	stat_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#38bdf8")))
	var stat_m := MarginContainer.new()
	stat_m.add_theme_constant_override("margin_left", 24)
	stat_m.add_theme_constant_override("margin_right", 24)
	stat_m.add_theme_constant_override("margin_top", 18)
	stat_m.add_theme_constant_override("margin_bottom", 18)
	stat_card.add_child(stat_m)

	var stat_v := VBoxContainer.new()
	stat_v.add_theme_constant_override("separation", 10)
	stat_m.add_child(stat_v)

	var health_lbl := Label.new()
	health_lbl.text = "Current Health: %d%%   •   Cash: $%s   •   Bank: $%s" % [PlayerData.health, _format_number(PlayerData.money), _format_number(PlayerData.bank_savings)]
	health_lbl.add_theme_font_size_override("font_size", 28)
	health_lbl.add_theme_color_override("font_color", Color("#22c55e") if PlayerData.health > 40 else Color("#f87171"))
	stat_v.add_child(health_lbl)

	var illness_lbl := Label.new()
	if PlayerData.has_illness("cancer"):
		var cancer_info := PlayerData.get_illness("cancer")
		illness_lbl.text = "⚠️ ACTIVE SICKNESS: Stage %d Lymphoma Cancer (Urgent: Seek Chemotherapy!)" % int(cancer_info.get("stage", 1))
		illness_lbl.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		illness_lbl.text = "Medical Status: No active malignant illnesses detected."
		illness_lbl.add_theme_color_override("font_color", Color("#1e293b") if is_light else Color("#94a3b8"))
	illness_lbl.add_theme_font_size_override("font_size", 24)
	stat_v.add_child(illness_lbl)

	list.add_child(stat_card)

	# Health Insurance Policy Card
	var ins_card := PanelContainer.new()
	ins_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#6366f1")))
	var ins_m := MarginContainer.new()
	ins_m.add_theme_constant_override("margin_left", 24)
	ins_m.add_theme_constant_override("margin_right", 24)
	ins_m.add_theme_constant_override("margin_top", 18)
	ins_m.add_theme_constant_override("margin_bottom", 18)
	ins_card.add_child(ins_m)

	var ins_v := VBoxContainer.new()
	ins_v.add_theme_constant_override("separation", 12)
	ins_m.add_child(ins_v)

	var ins_head := Label.new()
	ins_head.text = "🛡️ HEALTH INSURANCE POLICY"
	ins_head.add_theme_font_size_override("font_size", 26)
	ins_head.add_theme_color_override("font_color", Color("#312e81") if is_light else Color("#a5b4fc"))
	ins_v.add_child(ins_head)

	var ins_status := Label.new()
	ins_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ins_status.add_theme_font_size_override("font_size", 22)

	match PlayerData.health_insurance:
		"platinum":
			ins_status.text = "Active Coverage: 👑 Platinum Tier (Lifetime Policy)\nBenefit: 25% discount applied across all clinic procedures."
			ins_status.add_theme_color_override("font_color", Color("#581c87") if is_light else Color("#c084fc"))
			ins_v.add_child(ins_status)
		"gold":
			ins_status.text = "Active Coverage: 🏅 Gold Tier\nBenefit: 10% discount applied across all clinic procedures."
			ins_status.add_theme_color_override("font_color", Color("#78350f") if is_light else Color("#fbbf24"))
			ins_v.add_child(ins_status)

			var plat_diff := 25000 # 75k - 50k
			var btn_up_plat := _create_cyber_button("👑 Upgrade to Platinum Tier • $%s (+15%% Discount)" % _format_number(plat_diff), Color("#7c3aed"), func():
				if PlayerData.can_afford(plat_diff):
					PlayerData.debit_funds(plat_diff)
					PlayerData.health_insurance = "platinum"
					add_life_event("🛡️ INSURANCE UPGRADE: Upgraded to Platinum Health Insurance ($%s)! You now receive 25%% off all medical procedures." % _format_number(plat_diff), "health")
					update_ui()
					SaveManager.save_game()
					_show_doctor_modal()
				else:
					add_life_event("You cannot afford the Platinum insurance upgrade ($%s required)." % _format_number(plat_diff), "finance")
			)
			btn_up_plat.disabled = not PlayerData.can_afford(plat_diff)
			ins_v.add_child(btn_up_plat)
		"bronze":
			ins_status.text = "Active Coverage: 🛡️ Bronze Tier\nBenefit: 5% discount applied across all clinic procedures."
			ins_status.add_theme_color_override("font_color", Color("#9a3412") if is_light else Color("#fdba74"))
			ins_v.add_child(ins_status)

			var gold_diff := 30000 # 50k - 20k
			var btn_up_gold := _create_cyber_button("🏅 Upgrade to Gold Tier • $%s (+5%% Discount)" % _format_number(gold_diff), Color("#b45309"), func():
				if PlayerData.can_afford(gold_diff):
					PlayerData.debit_funds(gold_diff)
					PlayerData.health_insurance = "gold"
					add_life_event("🛡️ INSURANCE UPGRADE: Upgraded to Gold Health Insurance ($%s)! You now receive 10%% off all medical procedures." % _format_number(gold_diff), "health")
					update_ui()
					SaveManager.save_game()
					_show_doctor_modal()
				else:
					add_life_event("You cannot afford the Gold insurance upgrade ($%s required)." % _format_number(gold_diff), "finance")
			)
			btn_up_gold.disabled = not PlayerData.can_afford(gold_diff)
			ins_v.add_child(btn_up_gold)

			var plat_diff_from_bronze := 55000 # 75k - 20k
			var btn_up_plat := _create_cyber_button("👑 Upgrade to Platinum Tier • $%s (+20%% Discount)" % _format_number(plat_diff_from_bronze), Color("#7c3aed"), func():
				if PlayerData.can_afford(plat_diff_from_bronze):
					PlayerData.debit_funds(plat_diff_from_bronze)
					PlayerData.health_insurance = "platinum"
					add_life_event("🛡️ INSURANCE UPGRADE: Upgraded to Platinum Health Insurance ($%s)! You now receive 25%% off all medical procedures." % _format_number(plat_diff_from_bronze), "health")
					update_ui()
					SaveManager.save_game()
					_show_doctor_modal()
				else:
					add_life_event("You cannot afford the Platinum insurance upgrade ($%s required)." % _format_number(plat_diff_from_bronze), "finance")
			)
			btn_up_plat.disabled = not PlayerData.can_afford(plat_diff_from_bronze)
			ins_v.add_child(btn_up_plat)
		_: # none
			ins_status.text = "Status: Uninsured\nEnroll in a lifetime health insurance policy to receive permanent discounts on all medical treatments."
			ins_status.add_theme_color_override("font_color", Color("#1e293b") if is_light else Color("#cbd5e1"))
			ins_v.add_child(ins_status)

			var btn_bronze := _create_cyber_button("🛡️ Bronze Plan • $20,000 (5% Medical Discount)", Color("#c2410c"), func():
				var cost := 20000
				if PlayerData.can_afford(cost):
					PlayerData.debit_funds(cost)
					PlayerData.health_insurance = "bronze"
					add_life_event("🛡️ HEALTH INSURANCE: Enrolled in Bronze Health Insurance ($20,000)! 5% discount active on all clinic procedures.", "health")
					update_ui()
					SaveManager.save_game()
					_show_doctor_modal()
				else:
					add_life_event("You cannot afford Bronze Health Insurance ($20,000 required).", "finance")
			)
			btn_bronze.disabled = not PlayerData.can_afford(20000)
			ins_v.add_child(btn_bronze)

			var btn_gold := _create_cyber_button("🏅 Gold Plan • $50,000 (10% Medical Discount)", Color("#b45309"), func():
				var cost := 50000
				if PlayerData.can_afford(cost):
					PlayerData.debit_funds(cost)
					PlayerData.health_insurance = "gold"
					add_life_event("🛡️ HEALTH INSURANCE: Enrolled in Gold Health Insurance ($50,000)! 10% discount active on all clinic procedures.", "health")
					update_ui()
					SaveManager.save_game()
					_show_doctor_modal()
				else:
					add_life_event("You cannot afford Gold Health Insurance ($50,000 required).", "finance")
			)
			btn_gold.disabled = not PlayerData.can_afford(50000)
			ins_v.add_child(btn_gold)

			var btn_plat := _create_cyber_button("👑 Platinum Plan • $75,000 (25% Medical Discount)", Color("#7c3aed"), func():
				var cost := 75000
				if PlayerData.can_afford(cost):
					PlayerData.debit_funds(cost)
					PlayerData.health_insurance = "platinum"
					add_life_event("🛡️ HEALTH INSURANCE: Enrolled in Platinum Health Insurance ($75,000)! 25% discount active on all clinic procedures.", "health")
					update_ui()
					SaveManager.save_game()
					_show_doctor_modal()
				else:
					add_life_event("You cannot afford Platinum Health Insurance ($75,000 required).", "finance")
			)
			btn_plat.disabled = not PlayerData.can_afford(75000)
			ins_v.add_child(btn_plat)

	list.add_child(ins_card)

	# Procedures:
	# 1. Vitamin Shot
	var vit_used: bool = PlayerData.last_doctor_vitamin_age == PlayerData.age
	var vit_cost: int = get_disc_cost.call(150)
	var vit_text := "💉 Vitamin & Bio-Booster Shot ($%s%s)%s" % [_format_number(vit_cost), get_tag.call(), " (Used)" if vit_used else ""]
	var btn_vit := _create_cyber_button(vit_text, Color("#38bdf8"), func():
		if PlayerData.last_doctor_vitamin_age == PlayerData.age:
			return
		if PlayerData.can_afford(vit_cost):
			PlayerData.debit_funds(vit_cost)
			PlayerData.last_doctor_vitamin_age = PlayerData.age
			PlayerData.health = mini(100, PlayerData.health + 8)
			add_life_event("You received a potent Vitamin & Bio-Booster injection ($%s)." % _format_number(vit_cost), "health")
			update_ui()
			SaveManager.save_game()
			_show_doctor_modal()
		else:
			add_life_event("You couldn't afford a Vitamin Shot ($%s required)." % _format_number(vit_cost), "health")
	)
	if vit_used:
		btn_vit.disabled = true
		btn_vit.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_vit.tooltip_text = "Annual treatment completed for Age %d (Age up to receive next year)." % PlayerData.age
	list.add_child(btn_vit)

	# 2. General Checkup
	var checkup_used: bool = PlayerData.last_doctor_checkup_age == PlayerData.age
	var checkup_cost: int = get_disc_cost.call(300)
	var checkup_text := "🩺 Full Diagnostic Checkup ($%s%s)%s" % [_format_number(checkup_cost), get_tag.call(), " (Used)" if checkup_used else ""]
	var btn_checkup := _create_cyber_button(checkup_text, Color("#38bdf8"), func():
		if PlayerData.last_doctor_checkup_age == PlayerData.age:
			return
		if PlayerData.can_afford(checkup_cost):
			PlayerData.debit_funds(checkup_cost)
			PlayerData.last_doctor_checkup_age = PlayerData.age
			PlayerData.health = mini(100, PlayerData.health + 10)
			if PlayerData.has_illness("cancer"):
				var c: Dictionary = PlayerData.get_illness("cancer")
				add_life_event("Diagnostics warning: Physician confirmed Stage %d Cancer! Chemotherapy is urgently advised." % int(c.get("stage", 1)), "health")
			else:
				add_life_event("Physician examination concluded ($%s). Clean bill of health!" % _format_number(checkup_cost), "health")
			update_ui()
			SaveManager.save_game()
			_show_doctor_modal()
		else:
			add_life_event("You couldn't afford a Diagnostic Checkup ($%s required)." % _format_number(checkup_cost), "health")
	)
	if checkup_used:
		btn_checkup.disabled = true
		btn_checkup.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_checkup.tooltip_text = "Annual checkup completed for Age %d (Age up to examine next year)." % PlayerData.age
	list.add_child(btn_checkup)

	# 3. Plastic Surgery ($250,000 base, MAXIMIZES LOOKS to 100 on success)
	var surgery_used: bool = PlayerData.last_plastic_surgery_age == PlayerData.age
	var surgery_cost: int = get_disc_cost.call(250000)
	var surgery_text := "✨ Aesthetic Plastic Surgery ($%s%s)%s" % [_format_number(surgery_cost), get_tag.call(), " (Used)" if surgery_used else ""]
	var btn_surgery := _create_cyber_button(surgery_text, Color("#ec4899"), func():
		if PlayerData.last_plastic_surgery_age == PlayerData.age:
			return
		if PlayerData.can_afford(surgery_cost):
			PlayerData.debit_funds(surgery_cost)
			PlayerData.last_plastic_surgery_age = PlayerData.age
			if randf() < 0.10: # 10% risk of botched surgery
				PlayerData.looks = maxi(0, PlayerData.looks - 12)
				PlayerData.health = maxi(0, PlayerData.health - 25)
				PlayerData.happiness = maxi(0, PlayerData.happiness - 20)
				add_life_event("⚠️ BOTCHED SURGERY: Surgical complications resulted in severe facial scarring and agony!", "health")
			else:
				PlayerData.looks = 100 # Plastic surgery MAXIMIZES looks!
				PlayerData.health = maxi(0, PlayerData.health - 5)
				PlayerData.happiness = mini(100, PlayerData.happiness + 25)
				add_life_event("✨ PERFECT SURGERY: Premier plastic surgery maximized your looks to absolute perfection (100%)!", "health")

			update_ui()
			SaveManager.save_game()
			if PlayerData.health <= 0:
				doctor_modal_overlay.visible = false
				trigger_death("Complications from Botched Surgery")
			else:
				_show_doctor_modal()
		else:
			add_life_event("You couldn't afford Plastic Surgery ($%s required)." % _format_number(surgery_cost), "health")
	)
	if surgery_used:
		btn_surgery.disabled = true
		btn_surgery.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_surgery.tooltip_text = "Annual cosmetic surgery completed for Age %d. Allow your body time to heal." % PlayerData.age
	list.add_child(btn_surgery)

	# 4. Chemotherapy Treatment ($200,000 base)
	var chemo_used: bool = PlayerData.last_chemo_age == PlayerData.age
	var chemo_cost: int = get_disc_cost.call(200000)
	var chemo_text := "🧬 Chemotherapy Treatment ($%s%s)%s" % [_format_number(chemo_cost), get_tag.call(), " (Used)" if chemo_used else ""]
	var btn_chemo := _create_cyber_button(chemo_text, Color("#f43f5e"), func():
		if PlayerData.last_chemo_age == PlayerData.age:
			return
		if PlayerData.can_afford(chemo_cost):
			PlayerData.debit_funds(chemo_cost)
			PlayerData.last_chemo_age = PlayerData.age
			if PlayerData.has_illness("cancer"):
				if randf() < 0.60:
					PlayerData.cure_illness("cancer")
					PlayerData.health = mini(100, PlayerData.health + 15)
					PlayerData.happiness = mini(100, PlayerData.happiness + 25)
					add_life_event("🎉 REMISSION ACHIEVED: Intensive chemotherapy eradicated all cancer cells! You are officially CANCER-FREE!", "health")
				else:
					var c := PlayerData.get_illness("cancer")
					c["stage"] = maxi(1, int(c.get("stage", 1)) - 1)
					PlayerData.happiness = mini(100, PlayerData.happiness + 10)
					add_life_event("Chemotherapy stabilized your tumor growth and reduced metastasis. Continued vigilance recommended.", "health")
			else:
				add_life_event("The oncologist ran full scans ($%s). No malignant tumors detected! Chemotherapy was not administered." % _format_number(chemo_cost), "health")
			update_ui()
			SaveManager.save_game()
			_show_doctor_modal()
		else:
			add_life_event("You couldn't afford Chemotherapy Treatment ($%s required)." % _format_number(chemo_cost), "health")
	)
	if chemo_used:
		btn_chemo.disabled = true
		btn_chemo.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_chemo.tooltip_text = "Annual chemotherapy cycle completed for Age %d." % PlayerData.age
	list.add_child(btn_chemo)

	# 5. Psychotherapy & Grief Counseling
	var therapy_used: bool = PlayerData.last_therapy_age == PlayerData.age
	var therapy_cost: int = get_disc_cost.call(250)
	var therapy_text := "🧠 Psychotherapy & Grief Counseling ($%s%s)%s" % [_format_number(therapy_cost), get_tag.call(), " (Used)" if therapy_used else ""]
	var btn_therapy := _create_cyber_button(therapy_text, Color("#8b5cf6"), func():
		if PlayerData.last_therapy_age == PlayerData.age:
			return
		if PlayerData.can_afford(therapy_cost):
			PlayerData.debit_funds(therapy_cost)
			PlayerData.last_therapy_age = PlayerData.age
			PlayerData.happiness = mini(100, PlayerData.happiness + 20)
			add_life_event("You attended an enlightening psychotherapy session ($%s). Grief and emotional weight lifted." % _format_number(therapy_cost), "health")
			update_ui()
			SaveManager.save_game()
			_show_doctor_modal()
		else:
			add_life_event("You couldn't afford Psychotherapy ($%s required)." % _format_number(therapy_cost), "health")
	)
	if therapy_used:
		btn_therapy.disabled = true
		btn_therapy.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_therapy.tooltip_text = "Annual psychotherapy completed for Age %d." % PlayerData.age
	list.add_child(btn_therapy)

	# 6. Emergency Trauma Care
	var er_used: bool = PlayerData.last_er_age == PlayerData.age
	var er_cost: int = get_disc_cost.call(1500)
	var er_text := "🚨 Emergency ER Resuscitation ($%s%s)%s" % [_format_number(er_cost), get_tag.call(), " (Used)" if er_used else ""]
	var btn_er := _create_cyber_button(er_text, Color("#eab308"), func():
		if PlayerData.last_er_age == PlayerData.age:
			return
		if PlayerData.can_afford(er_cost):
			PlayerData.debit_funds(er_cost)
			PlayerData.last_er_age = PlayerData.age
			PlayerData.health = mini(100, PlayerData.health + 40)
			add_life_event("ER medical trauma team stabilized your critical vitals ($%s)." % _format_number(er_cost), "health")
			update_ui()
			SaveManager.save_game()
			_show_doctor_modal()
		else:
			add_life_event("You couldn't afford Emergency ER care ($%s required)." % _format_number(er_cost), "health")
	)
	if er_used:
		btn_er.disabled = true
		btn_er.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_er.tooltip_text = "Emergency resuscitation already utilized for Age %d." % PlayerData.age
	list.add_child(btn_er)

	doctor_modal_overlay.visible = true


# --- 2. CRIME & PRISON MODAL ---
func _show_crime_modal() -> void:
	if crime_modal_overlay != null and is_instance_valid(crime_modal_overlay):
		crime_modal_overlay.queue_free()

	if PlayerData.is_in_prison:
		var prison_modal := _create_cyber_modal("🔒 STATE PENITENTIARY", "Inmate Profile • Sentence Remaining: %d years" % PlayerData.prison_sentence_years, Color("#ef4444"))
		crime_modal_overlay = prison_modal.overlay
		var p_list: VBoxContainer = prison_modal.list

		var info_lbl := Label.new()
		info_lbl.text = "You are currently incarcerated. Your criminal record stripped your job and credentials.\nAge up to advance your sentence years."
		info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_lbl.add_theme_font_size_override("font_size", 22)
		info_lbl.add_theme_color_override("font_color", Color("#f87171"))
		p_list.add_child(info_lbl)

		var prison_used: bool = PlayerData.last_prison_activity_age == PlayerData.age

		var yard_text := "🏋️ Hit the Prison Yard Weights (Used)" if prison_used else "🏋️ Hit the Prison Yard Weights"
		var btn_yard := _create_cyber_button(yard_text, Color("#ef4444"), func():
			if PlayerData.last_prison_activity_age == PlayerData.age:
				return
			PlayerData.last_prison_activity_age = PlayerData.age
			PlayerData.health = mini(100, PlayerData.health + 6)
			PlayerData.looks = mini(100, PlayerData.looks + 3)
			PlayerData.happiness = mini(100, PlayerData.happiness + 5)
			add_life_event("You pumped iron in the prison yard. Fellow inmates respect your discipline.", "crime")
			update_ui()
			SaveManager.save_game()
			_show_crime_modal()
		)
		if prison_used:
			btn_yard.disabled = true
			btn_yard.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_yard.tooltip_text = "Annual prison activity completed for Age %d (Age up to perform another)." % PlayerData.age
		p_list.add_child(btn_yard)

		var read_text := "📖 Read in Prison Library (Used)" if prison_used else "📖 Read in Prison Library"
		var btn_read := _create_cyber_button(read_text, Color("#38bdf8"), func():
			if PlayerData.last_prison_activity_age == PlayerData.age:
				return
			PlayerData.last_prison_activity_age = PlayerData.age
			PlayerData.smarts = mini(100, PlayerData.smarts + 5)
			PlayerData.happiness = mini(100, PlayerData.happiness + 4)
			add_life_event("You immersed yourself in law and literature in the penitentiary library.", "crime")
			update_ui()
			SaveManager.save_game()
			_show_crime_modal()
		)
		if prison_used:
			btn_read.disabled = true
			btn_read.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_read.tooltip_text = "Annual prison activity completed for Age %d (Age up to perform another)." % PlayerData.age
		p_list.add_child(btn_read)

		var sleep_text := "💤 Rest in Cell / Keep Low Profile (Used)" if prison_used else "💤 Rest in Cell / Keep Low Profile"
		var btn_sleep := _create_cyber_button(sleep_text, Color("#94a3b8"), func():
			if PlayerData.last_prison_activity_age == PlayerData.age:
				return
			PlayerData.last_prison_activity_age = PlayerData.age
			PlayerData.health = mini(100, PlayerData.health + 2)
			add_life_event("You kept to yourself and avoided penitentiary gang disputes.", "crime")
			update_ui()
			SaveManager.save_game()
			_show_crime_modal()
		)
		if prison_used:
			btn_sleep.disabled = true
			btn_sleep.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_sleep.tooltip_text = "Annual prison activity completed for Age %d (Age up to perform another)." % PlayerData.age
		p_list.add_child(btn_sleep)

		crime_modal_overlay.visible = true
		return

	# Fictional activity outcomes use shared progression rules; prison UI stays above.
	UndergroundProgression.normalize(PlayerData)
	var modal := _create_cyber_modal("UNDERGROUND SYNDICATE", "Cash: $%s • High-risk activities" % [_format_number(PlayerData.money)], Color("#a855f7"))
	crime_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list
	var status := Label.new()
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 26)
	status.add_theme_color_override("font_color", Color("#c4b5fd"))
	var joined := bool(PlayerData.underground_progress.get("joined", false))
	status.text = UndergroundProgression.summary(PlayerData) if joined else "UNAFFILIATED\nJoin the underground as an Alley Ghost. Successful activities build your rank and unlock new opportunities."
	list.add_child(status)
	if not joined:
		var join_button := _create_cyber_button("Join the Underground • Alley Ghost", Color("#a855f7"), func():
			if UndergroundProgression.join(PlayerData):
				add_life_event("You entered the underground as an Alley Ghost. Your reputation starts here.", "crime")
				update_ui()
				SaveManager.save_game()
				_show_crime_modal()
		)
		join_button.disabled = PlayerData.age < 17 or PlayerData.is_dead
		list.add_child(join_button)
	var warning := Label.new()
	warning.text = "Only successful activities count toward rank. Each attempt uses one of your %d yearly opportunities. Arrest ends your job and resets its tenure; underground reputation remains. Job seniority and syndicate rank are separate." % int(UndergroundProgression.catalog().attempts_per_year)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.add_theme_font_size_override("font_size", 22)
	warning.add_theme_color_override("font_color", Color("#fbbf24"))
	list.add_child(warning)
	var ranks: Array = UndergroundProgression.catalog().ranks
	for activity in UndergroundProgression.catalog().activities:
		var requirement := UndergroundProgression.requirement(PlayerData, activity)
		var caption := "%s\nRisk: %d%% • $%s–$%s • Prison: %d years\nRank: %s" % [activity.name, int(round(float(activity.risk) * 100)), _format_number(int(activity.min_reward)), _format_number(int(activity.max_reward)), int(activity.sentence), ranks[int(activity.rank)].name]
		if not requirement.is_empty():
			caption += "\n" + requirement
		var activity_id := str(activity.id)
		var button := _create_cyber_button(caption, Color("#a855f7"), func():
			var result := UndergroundProgression.attempt(PlayerData, activity_id, randf(), randf())
			if result.is_empty():
				return
			add_life_event(result, "crime")
			update_ui()
			SaveManager.save_game()
			_show_crime_modal()
		)
		button.disabled = not requirement.is_empty()
		list.add_child(button)


# --- 3. CASINO & GAMBLING MODAL ---
var casino_scratch_result_lbl: Label = null
var casino_slots_display_lbl: Label = null
var casino_slots_result_lbl: Label = null
var casino_dice_display_lbl: Label = null
var casino_dice_result_lbl: Label = null
var current_dice_bet_amount: int = 100

func _show_casino_modal() -> void:
	if casino_modal_overlay != null and is_instance_valid(casino_modal_overlay):
		casino_modal_overlay.queue_free()

	if PlayerData.last_casino_age != PlayerData.age:
		PlayerData.last_casino_age = PlayerData.age
		PlayerData.casino_plays_this_year = 0

	var max_plays := 1
	var plays_left := maxi(0, max_plays - PlayerData.casino_plays_this_year)
	var casino_locked: bool = plays_left <= 0

	var modal := _create_cyber_modal("🎰 THE NEON PALACE CASINO", "Cash: $%s  •  Dice, Slots & Scratchcards (Plays left: %d/%d)" % [_format_number(PlayerData.money), plays_left, max_plays], Color("#f59e0b"))
	casino_modal_overlay = modal.overlay
	var list: VBoxContainer = modal.list

	# GAME 1: Cyber Scratchcard ($25)
	var card_scratch := PanelContainer.new()
	card_scratch.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var m_scratch := MarginContainer.new()
	m_scratch.add_theme_constant_override("margin_left", 20)
	m_scratch.add_theme_constant_override("margin_right", 20)
	m_scratch.add_theme_constant_override("margin_top", 16)
	m_scratch.add_theme_constant_override("margin_bottom", 16)
	card_scratch.add_child(m_scratch)

	var v_scratch := VBoxContainer.new()
	v_scratch.add_theme_constant_override("separation", 10)
	m_scratch.add_child(v_scratch)

	var scratch_title := Label.new()
	scratch_title.text = "🎟️ LUCKY CYBER SCRATCHCARD ($25)"
	scratch_title.add_theme_font_size_override("font_size", 26)
	scratch_title.add_theme_color_override("font_color", Color("#fbbf24"))
	v_scratch.add_child(scratch_title)

	casino_scratch_result_lbl = Label.new()
	casino_scratch_result_lbl.text = "Reveal 3 matching symbols to win up to $500!"
	casino_scratch_result_lbl.add_theme_font_size_override("font_size", 22)
	casino_scratch_result_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	v_scratch.add_child(casino_scratch_result_lbl)

	var scratch_btn_text := "Scratch Ticket ($25) (Limit Reached)" if casino_locked else "Scratch Ticket ($25)"
	var btn_scratch := _create_cyber_button(scratch_btn_text, Color("#f59e0b"), func():
		if PlayerData.casino_plays_this_year >= 1:
			return
		if PlayerData.get_available_funds() >= 25:
			PlayerData.debit_funds(25)
			PlayerData.casino_plays_this_year += 1
			# 18% winning chance; expected gross return $23.76 on a $25 ticket.
			if randf() < 0.18:
				var roll := randf()
				var win := 50
				var sym := "💎"
				if roll < 0.12:
					win = 500
					sym = "7️⃣"
				elif roll < 0.40:
					win = 150
					sym = "🔔"

				PlayerData.money += win
				casino_scratch_result_lbl.text = "[ %s | %s | %s ] -> WINNER! You won $%d!" % [sym, sym, sym, win]
				casino_scratch_result_lbl.add_theme_color_override("font_color", Color("#22c55e"))
				add_life_event("You scratched a winning lottery ticket and cashed out $%d!" % win, "finance")
			else:
				var symbols := ["🍒", "🔔", "💀", "⭐", "🍋"]
				symbols.shuffle()
				casino_scratch_result_lbl.text = "[ %s | %s | %s ] -> No match. Better luck next time!" % [symbols[0], symbols[1], symbols[2]]
				casino_scratch_result_lbl.add_theme_color_override("font_color", Color("#f87171"))
			update_ui()
			SaveManager.save_game()
			_show_casino_modal()
		else:
			casino_scratch_result_lbl.text = "Insufficient funds for $25 scratchcard."
			casino_scratch_result_lbl.add_theme_color_override("font_color", Color("#ef4444"))
	)
	if casino_locked:
		btn_scratch.disabled = true
		btn_scratch.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_scratch.tooltip_text = "Annual gaming limit reached (1 play per year). Come back next year!"
	v_scratch.add_child(btn_scratch)
	list.add_child(card_scratch)

	# GAME 2: Neon 3-Reel Slots ($50)
	var card_slots := PanelContainer.new()
	card_slots.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var m_slots := MarginContainer.new()
	m_slots.add_theme_constant_override("margin_left", 20)
	m_slots.add_theme_constant_override("margin_right", 20)
	m_slots.add_theme_constant_override("margin_top", 16)
	m_slots.add_theme_constant_override("margin_bottom", 16)
	card_slots.add_child(m_slots)

	var v_slots := VBoxContainer.new()
	v_slots.add_theme_constant_override("separation", 10)
	m_slots.add_child(v_slots)

	var slots_title := Label.new()
	slots_title.text = "🎰 NEON 3-REEL SLOT MACHINE ($50 / SPIN)"
	slots_title.add_theme_font_size_override("font_size", 26)
	slots_title.add_theme_color_override("font_color", Color("#fbbf24"))
	v_slots.add_child(slots_title)

	casino_slots_display_lbl = Label.new()
	casino_slots_display_lbl.text = "[ 🎰 | 🎰 | 🎰 ]"
	casino_slots_display_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	casino_slots_display_lbl.add_theme_font_size_override("font_size", 42)
	casino_slots_display_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
	v_slots.add_child(casino_slots_display_lbl)

	casino_slots_result_lbl = Label.new()
	casino_slots_result_lbl.text = "Payouts: 7️⃣7️⃣7️⃣ = $5,000  •  💎💎💎 = $1,200  •  🔔🔔🔔 = $450  •  🍒🍒🍒 = $180"
	casino_slots_result_lbl.add_theme_font_size_override("font_size", 20)
	casino_slots_result_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	v_slots.add_child(casino_slots_result_lbl)

	var spin_btn_text := "Spin Reels ($50) (Limit Reached)" if casino_locked else "Spin Reels ($50)"
	var btn_spin := _create_cyber_button(spin_btn_text, Color("#f59e0b"), func():
		if PlayerData.casino_plays_this_year >= 1:
			return
		if PlayerData.get_available_funds() >= 50:
			PlayerData.debit_funds(50)
			PlayerData.casino_plays_this_year += 1
			var syms := ["🍒", "🔔", "💎", "7️⃣", "💀"]
			# 4% chance of 3-match; expected gross return $46 on a $50 spin.
			if randf() < 0.04:
				var r := randf()
				var win_sym := "🍒"
				var payout := 180
				if r < 0.08:
					win_sym = "7️⃣"
					payout = 5000
				elif r < 0.28:
					win_sym = "💎"
					payout = 1200
				elif r < 0.60:
					win_sym = "🔔"
					payout = 450
				elif r < 0.70:
					win_sym = "💀"
					payout = 0

				PlayerData.money += payout
				casino_slots_display_lbl.text = "[ %s | %s | %s ]" % [win_sym, win_sym, win_sym]
				if payout > 0:
					casino_slots_result_lbl.text = "JACKPOT! Three matching %s pays $%d!" % [win_sym, payout]
					casino_slots_result_lbl.add_theme_color_override("font_color", Color("#22c55e"))
					add_life_event("You hit 3 %s on the slot machine and won $%d!" % [win_sym, payout], "finance")
				else:
					casino_slots_result_lbl.text = "Cursed Skull Spin! No payout."
					casino_slots_result_lbl.add_theme_color_override("font_color", Color("#f87171"))
			else:
				var s1: String = str(syms.pick_random())
				var s2: String = str(syms.pick_random())
				var s3: String = str(syms.pick_random())
				if s1 == s2 and s2 == s3:
					s3 = "🍒" if s1 != "🍒" else "🔔"
				casino_slots_display_lbl.text = "[ %s | %s | %s ]" % [s1, s2, s3]
				if s1 == s2 or s2 == s3 or s1 == s3:
					PlayerData.money += 25
					casino_slots_result_lbl.text = "Pair match! Consolation prize: $25."
					casino_slots_result_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
				else:
					casino_slots_result_lbl.text = "No match. Spin again!"
					casino_slots_result_lbl.add_theme_color_override("font_color", Color("#94a3b8"))

			update_ui()
			SaveManager.save_game()
			_show_casino_modal()
		else:
			casino_slots_result_lbl.text = "Insufficient funds for $50 spin."
			casino_slots_result_lbl.add_theme_color_override("font_color", Color("#ef4444"))
	)
	if casino_locked:
		btn_spin.disabled = true
		btn_spin.modulate = Color(0.6, 0.6, 0.6, 0.65)
		btn_spin.tooltip_text = "Annual gaming limit reached (1 play per year). Come back next year!"
	v_slots.add_child(btn_spin)
	list.add_child(card_slots)

	# GAME 3: High-Stakes Craps (Dice Roll)
	var card_dice := PanelContainer.new()
	card_dice.add_theme_stylebox_override("panel", load_style_box_cyber_card(Color("#f59e0b")))
	var m_dice := MarginContainer.new()
	m_dice.add_theme_constant_override("margin_left", 20)
	m_dice.add_theme_constant_override("margin_right", 20)
	m_dice.add_theme_constant_override("margin_top", 16)
	m_dice.add_theme_constant_override("margin_bottom", 16)
	card_dice.add_child(m_dice)

	var v_dice := VBoxContainer.new()
	v_dice.add_theme_constant_override("separation", 10)
	m_dice.add_child(v_dice)

	var dice_title := Label.new()
	dice_title.text = "🎲 HIGH-STAKES CRAPS & DICE ROLL"
	dice_title.add_theme_font_size_override("font_size", 26)
	dice_title.add_theme_color_override("font_color", Color("#fbbf24"))
	v_dice.add_child(dice_title)

	casino_dice_display_lbl = Label.new()
	casino_dice_display_lbl.text = "🎲 [ ? ] + 🎲 [ ? ] = ?"
	casino_dice_display_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	casino_dice_display_lbl.add_theme_font_size_override("font_size", 38)
	casino_dice_display_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
	v_dice.add_child(casino_dice_display_lbl)

	casino_dice_result_lbl = Label.new()
	casino_dice_result_lbl.text = "Choose your wager amount and place your prediction:"
	casino_dice_result_lbl.add_theme_font_size_override("font_size", 21)
	casino_dice_result_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	v_dice.add_child(casino_dice_result_lbl)

	# Bet Amount Selector Row
	var bet_row := HBoxContainer.new()
	bet_row.add_theme_constant_override("separation", 10)
	v_dice.add_child(bet_row)

	var bet_amounts := [100, 500, 2000]
	for amt in bet_amounts:
		var btn_b := Button.new()
		btn_b.text = "Wager $%d" % amt
		btn_b.set_meta("reference_part", true)
		btn_b.set_meta("market_button", true)
		btn_b.custom_minimum_size.y = 52
		btn_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_b.add_theme_font_size_override("font_size", 20)
		var b_style := StyleBoxFlat.new()
		b_style.bg_color = Color("#1e293b")
		b_style.border_color = Color("#f59e0b")
		b_style.set_border_width_all(2)
		b_style.set_corner_radius_all(6)
		btn_b.add_theme_stylebox_override("normal", b_style)
		btn_b.add_theme_color_override("font_color", Color("#f8fafc"))
		btn_b.pressed.connect(func():
			current_dice_bet_amount = amt
			casino_dice_result_lbl.text = "Active Wager Set: $%d. Pick your prediction below!" % amt
			casino_dice_result_lbl.add_theme_color_override("font_color", Color("#38bdf8"))
		)
		bet_row.add_child(btn_b)

	# Prediction Roll Buttons
	var roll_options := [
		["Under 7 (Roll 2 - 6 • 2x Payout)", "under"],
		["Over 7 (Roll 8 - 12 • 2x Payout)", "over"],
		["Lucky Seven (Roll exactly 7 • 4x Payout)", "seven"],
		["Snake Eyes or Boxcars (Roll 2 or 12 • 15x Payout)", "extreme"]
	]

	for opt in roll_options:
		var opt_text: String = opt[0] if not casino_locked else opt[0] + " (Limit Reached)"
		var opt_key: String = opt[1]
		var btn_opt := _create_cyber_button(opt_text, Color("#f59e0b"), func():
			_play_dice_roll(opt_key, modal)
		)
		if casino_locked:
			btn_opt.disabled = true
			btn_opt.modulate = Color(0.6, 0.6, 0.6, 0.65)
			btn_opt.tooltip_text = "Annual gaming limit reached (1 play per year). Come back next year!"
		v_dice.add_child(btn_opt)

	list.add_child(card_dice)
	casino_modal_overlay.visible = true


func _play_dice_roll(prediction: String, _modal: Dictionary = {}) -> void:
	if PlayerData.casino_plays_this_year >= 1:
		return
	if PlayerData.get_available_funds() < current_dice_bet_amount:
		casino_dice_result_lbl.text = "Insufficient funds for $%d wager!" % current_dice_bet_amount
		casino_dice_result_lbl.add_theme_color_override("font_color", Color("#ef4444"))
		return

	PlayerData.debit_funds(current_dice_bet_amount)
	PlayerData.casino_plays_this_year += 1
	var d1: int = randi_range(1, 6)
	var d2: int = randi_range(1, 6)
	var sum: int = d1 + d2
	casino_dice_display_lbl.text = "🎲 [ %d ] + 🎲 [ %d ] = %d" % [d1, d2, sum]

	var won: bool = false
	var multiplier: int = 0

	match prediction:
		"under":
			if sum < 7:
				won = true
				multiplier = 2
		"over":
			if sum > 7:
				won = true
				multiplier = 2
		"seven":
			if sum == 7:
				won = true
				multiplier = 4
		"extreme":
			if sum == 2 or sum == 12:
				won = true
				multiplier = 15

	if won:
		var win_amount: int = current_dice_bet_amount * multiplier
		PlayerData.money += win_amount
		casino_dice_result_lbl.text = "WINNER! The dice landed on %d! You won $%s!" % [sum, _format_number(win_amount)]
		casino_dice_result_lbl.add_theme_color_override("font_color", Color("#22c55e"))
		add_life_event("You rolled a %d in craps and won $%s!" % [sum, _format_number(win_amount)], "finance")
	else:
		casino_dice_result_lbl.text = "LOST: The dice landed on %d. Lost $%d wager." % [sum, current_dice_bet_amount]
		casino_dice_result_lbl.add_theme_color_override("font_color", Color("#f87171"))

	update_ui()
	SaveManager.save_game()
	_show_casino_modal()


# --- 4. DEATH SCREEN SYSTEM ---
func _show_death_screen(cause: String) -> void:
	if action_bar != null:
		action_bar.visible = false
	if age_button != null:
		age_button.visible = false
	if death_screen_overlay != null and is_instance_valid(death_screen_overlay):
		if death_screen_overlay.get_parent() != null:
			death_screen_overlay.get_parent().remove_child(death_screen_overlay)
		death_screen_overlay.queue_free()
		death_screen_overlay = null

	death_screen_overlay = ColorRect.new()
	death_screen_overlay.name = "DeathScreenOverlay"
	death_screen_overlay.set_meta("theme_exempt", true)
	death_screen_overlay.color = Color(0.012, 0.003, 0.006, 1.0) # pure opaque somber void
	death_screen_overlay.anchors_preset = Control.PRESET_FULL_RECT
	death_screen_overlay.anchor_right = 1.0
	death_screen_overlay.anchor_bottom = 1.0
	death_screen_overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	death_screen_overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	death_screen_overlay.z_index = 80
	add_child(death_screen_overlay)

	var screen_margin := MarginContainer.new()
	screen_margin.set_meta("theme_exempt", true)
	screen_margin.anchors_preset = Control.PRESET_FULL_RECT
	screen_margin.anchor_right = 1.0
	screen_margin.anchor_bottom = 1.0
	screen_margin.grow_horizontal = Control.GROW_DIRECTION_BOTH
	screen_margin.grow_vertical = Control.GROW_DIRECTION_BOTH
	screen_margin.add_theme_constant_override("margin_left", 32)
	screen_margin.add_theme_constant_override("margin_right", 32)
	screen_margin.add_theme_constant_override("margin_top", 40)
	screen_margin.add_theme_constant_override("margin_bottom", 40)
	death_screen_overlay.add_child(screen_margin)
	preload("res://scripts/ui/panel_pull_up.gd").watch(screen_margin, death_screen_overlay)

	var card := PanelContainer.new()
	card.set_meta("theme_exempt", true)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#070204") # Abyssal void black
	card_style.border_color = Color("#7f1d1d") # Dark somber blood red
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(16)
	card_style.shadow_color = Color(0.18, 0.01, 0.02, 0.95)
	card_style.shadow_size = 32
	card.add_theme_stylebox_override("panel", card_style)
	screen_margin.add_child(card)

	var margin := MarginContainer.new()
	margin.set_meta("theme_exempt", true)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	card.add_child(margin)

	var main_v := VBoxContainer.new()
	main_v.set_meta("theme_exempt", true)
	main_v.add_theme_constant_override("separation", 16)
	margin.add_child(main_v)

	# Heartbeat flatline indicator
	var flatline_lbl := Label.new()
	flatline_lbl.set_meta("reference_part", true)
	flatline_lbl.text = "─────── 💔 FLATLINED • PULSE CEASED ───────"
	flatline_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flatline_lbl.add_theme_font_size_override("font_size", 20)
	flatline_lbl.add_theme_color_override("font_color", Color("#b91c1c"))
	main_v.add_child(flatline_lbl)

	var title_lbl := Label.new()
	title_lbl.set_meta("reference_part", true)
	title_lbl.text = "IN MEMORIAM • PASSING INTO SILENCE"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 34)
	title_lbl.add_theme_color_override("font_color", Color("#ef4444"))
	main_v.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.set_meta("reference_part", true)
	sub_lbl.text = "\"The heartbeat has stilled. All worldly triumphs and regrets fade into the quiet void.\""
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub_lbl.add_theme_font_size_override("font_size", 19)
	sub_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	main_v.add_child(sub_lbl)

	var scroll := ScrollContainer.new()
	scroll.name = "DeathScrollContainer"
	scroll.set_meta("theme_exempt", true)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_v.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.set_meta("theme_exempt", true)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 18)
	scroll.add_child(vbox)

	# 1. Memorial Record of the Deceased
	var stats_p := PanelContainer.new()
	stats_p.set_meta("theme_exempt", true)
	var sp_style := StyleBoxFlat.new()
	sp_style.bg_color = Color("#0b0407")
	sp_style.border_color = Color("#991b1b")
	sp_style.set_border_width_all(2)
	sp_style.set_corner_radius_all(10)
	stats_p.add_theme_stylebox_override("panel", sp_style)

	var sp_m := MarginContainer.new()
	sp_m.set_meta("theme_exempt", true)
	sp_m.add_theme_constant_override("margin_left", 24)
	sp_m.add_theme_constant_override("margin_right", 24)
	sp_m.add_theme_constant_override("margin_top", 18)
	sp_m.add_theme_constant_override("margin_bottom", 18)
	stats_p.add_child(sp_m)

	var stats_v := VBoxContainer.new()
	stats_v.set_meta("theme_exempt", true)
	stats_v.add_theme_constant_override("separation", 8)
	sp_m.add_child(stats_v)

	var rec_header := Label.new()
	rec_header.set_meta("reference_part", true)
	rec_header.text = "🪦 MEMORIAL RECORD OF THE DECEASED"
	rec_header.add_theme_font_size_override("font_size", 20)
	rec_header.add_theme_color_override("font_color", Color("#ef4444"))
	stats_v.add_child(rec_header)

	var name_lbl := Label.new()
	name_lbl.set_meta("reference_part", true)
	name_lbl.text = "Identity: %s   •   Birthplace: %s" % [PlayerData.first_name, PlayerData.birthplace]
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.add_theme_font_size_override("font_size", 26)
	name_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
	stats_v.add_child(name_lbl)

	var clean_cause: String = cause.strip_edges()
	if clean_cause == "":
		clean_cause = "Acute Medical Complications"

	var age_cause_lbl := Label.new()
	age_cause_lbl.set_meta("reference_part", true)
	age_cause_lbl.text = "Age of Demise: %d years\nCause of Death: %s" % [PlayerData.age, clean_cause]
	age_cause_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	age_cause_lbl.add_theme_font_size_override("font_size", 24)
	age_cause_lbl.add_theme_color_override("font_color", Color("#f87171"))
	stats_v.add_child(age_cause_lbl)

	var net_worth: int = PlayerData.get_net_worth()
	var total_assets: int = PlayerData.money + PlayerData.bank_savings
	var total_debt: int = PlayerData.get_total_debt()
	var wealth_lbl := Label.new()
	wealth_lbl.set_meta("reference_part", true)
	if net_worth < 0:
		wealth_lbl.text = "Final Net Worth: -$%s (Assets: $%s  •  Unpaid Debt: $%s)" % [
			_format_number(absi(net_worth)),
			_format_number(total_assets),
			_format_number(total_debt)
		]
		wealth_lbl.add_theme_color_override("font_color", Color("#ef4444"))
	else:
		wealth_lbl.text = "Final Worldly Wealth: $%s" % _format_number(net_worth)
		wealth_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	wealth_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	wealth_lbl.add_theme_font_size_override("font_size", 24)
	stats_v.add_child(wealth_lbl)

	var career_str := "%s at %s" % [PlayerData.job_title, PlayerData.job_company] if PlayerData.job_title != "" else "Unemployed"
	var career_lbl := Label.new()
	career_lbl.set_meta("reference_part", true)
	career_lbl.text = "Last Worldly Calling: %s" % career_str
	career_lbl.add_theme_font_size_override("font_size", 24)
	career_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
	stats_v.add_child(career_lbl)

	vbox.add_child(stats_p)

	# 2. Official Coroner Certificate Card
	var coroner_p := PanelContainer.new()
	coroner_p.set_meta("theme_exempt", true)
	var coroner_style := StyleBoxFlat.new()
	coroner_style.bg_color = Color("#0a0306")
	coroner_style.border_color = Color("#7f1d1d")
	coroner_style.set_border_width_all(2)
	coroner_style.set_corner_radius_all(10)
	coroner_p.add_theme_stylebox_override("panel", coroner_style)

	var cp_m := MarginContainer.new()
	cp_m.set_meta("theme_exempt", true)
	cp_m.add_theme_constant_override("margin_left", 22)
	cp_m.add_theme_constant_override("margin_right", 22)
	cp_m.add_theme_constant_override("margin_top", 18)
	cp_m.add_theme_constant_override("margin_bottom", 18)
	coroner_p.add_child(cp_m)

	var cp_v := VBoxContainer.new()
	cp_v.set_meta("theme_exempt", true)
	cp_v.add_theme_constant_override("separation", 10)
	cp_m.add_child(cp_v)

	var coroner_header := Label.new()
	coroner_header.set_meta("reference_part", true)
	coroner_header.text = "📋 OFFICIAL CORONER'S CERTIFICATE"
	coroner_header.add_theme_font_size_override("font_size", 20)
	coroner_header.add_theme_color_override("font_color", Color("#ef4444"))
	cp_v.add_child(coroner_header)

	var death_desc_lbl := Label.new()
	death_desc_lbl.set_meta("reference_part", true)
	death_desc_lbl.text = _generate_death_narrative(clean_cause)
	death_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	death_desc_lbl.add_theme_font_size_override("font_size", 21)
	death_desc_lbl.add_theme_color_override("font_color", Color("#e2e8f0"))
	cp_v.add_child(death_desc_lbl)

	var eulogy_header := Label.new()
	eulogy_header.set_meta("reference_part", true)
	eulogy_header.text = "MEMORIAL EPITAPH:"
	eulogy_header.add_theme_font_size_override("font_size", 18)
	eulogy_header.add_theme_color_override("font_color", Color("#f87171"))
	cp_v.add_child(eulogy_header)

	var epitaph_lbl := Label.new()
	epitaph_lbl.set_meta("reference_part", true)
	var eulogy: String = ""
	if PlayerData.age >= 75:
		eulogy = "\"Having walked a long, weary journey through youth, adulthood, and twilight years, %s slipped into the stillness of the earth. Their deeds echo only in memory.\"" % PlayerData.first_name
	elif PlayerData.age >= 40:
		eulogy = "\"Cut down in the prime of their years, %s left behind silence, unfinished dreams, and grieving loved ones. May they find peace.\"" % PlayerData.first_name
	else:
		eulogy = "\"Taken far too soon at age %d by tragic misfortune, %s's life was a fragile ember extinguished before its dawn.\"" % [PlayerData.age, PlayerData.first_name]
	epitaph_lbl.text = eulogy
	epitaph_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	epitaph_lbl.add_theme_font_size_override("font_size", 20)
	epitaph_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
	cp_v.add_child(epitaph_lbl)

	vbox.add_child(coroner_p)

	# 3. Dispersal of Earthly Remains Card
	var will_exec_p := PanelContainer.new()
	will_exec_p.set_meta("theme_exempt", true)
	var wp_style := StyleBoxFlat.new()
	wp_style.bg_color = Color("#080204")
	wp_style.border_color = Color("#7f1d1d")
	wp_style.set_border_width_all(2)
	wp_style.set_corner_radius_all(10)
	will_exec_p.add_theme_stylebox_override("panel", wp_style)

	var wp_m := MarginContainer.new()
	wp_m.set_meta("theme_exempt", true)
	wp_m.add_theme_constant_override("margin_left", 24)
	wp_m.add_theme_constant_override("margin_right", 24)
	wp_m.add_theme_constant_override("margin_top", 18)
	wp_m.add_theme_constant_override("margin_bottom", 18)
	will_exec_p.add_child(wp_m)

	var wp_v := VBoxContainer.new()
	wp_v.set_meta("theme_exempt", true)
	wp_v.add_theme_constant_override("separation", 10)
	wp_m.add_child(wp_v)

	var will_exec_header := Label.new()
	will_exec_header.set_meta("reference_part", true)
	will_exec_header.text = "⚖️ LAST WILL & TESTAMENT ESTATE EXECUTION"
	will_exec_header.add_theme_font_size_override("font_size", 22)
	will_exec_header.add_theme_color_override("font_color", Color("#ef4444"))
	wp_v.add_child(will_exec_header)

	var total_estate_val: int = PlayerData.money + PlayerData.bank_savings
	for a in PlayerData.owned_assets:
		total_estate_val += int(a.get("current_value", a.get("purchase_price", 0)))

	var will_recip_str: String = "Your Surviving Children"
	match PlayerData.get("will_recipient"):
		"CHARITY":
			will_recip_str = "Global Humanitarian Charities"
		"SPOUSE":
			will_recip_str = "Your Surviving Spouse & Partner"
		"SPLIT":
			will_recip_str = "Your Surviving Spouse and Children (Divided Equally)"
		_:
			will_recip_str = "Your Surviving Children"

	var will_exec_desc := Label.new()
	will_exec_desc.set_meta("reference_part", true)
	will_exec_desc.text = "In accordance with your legally notarized testament, your total estate valued at $%s (including $%s liquid capital and %d registered assets) has been formally transferred to %s. You carry nothing into the stillness beyond." % [
		_format_number(total_estate_val),
		_format_number(PlayerData.money + PlayerData.bank_savings),
		PlayerData.owned_assets.size(),
		will_recip_str
	]
	will_exec_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	will_exec_desc.add_theme_font_size_override("font_size", 20)
	will_exec_desc.add_theme_color_override("font_color", Color("#cbd5e1"))
	wp_v.add_child(will_exec_desc)

	vbox.add_child(will_exec_p)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# 4. Destiny & The Parting Crossing
	if PlayerData.karma < 0:
		var bad_karma_card := PanelContainer.new()
		bad_karma_card.set_meta("theme_exempt", true)
		var bkc_style := StyleBoxFlat.new()
		bkc_style.bg_color = Color("#140307")
		bkc_style.border_color = Color("#dc2626")
		bkc_style.set_border_width_all(2)
		bkc_style.set_corner_radius_all(10)
		bad_karma_card.add_theme_stylebox_override("panel", bkc_style)

		var bm := MarginContainer.new()
		bm.set_meta("theme_exempt", true)
		bm.add_theme_constant_override("margin_left", 20)
		bm.add_theme_constant_override("margin_right", 20)
		bm.add_theme_constant_override("margin_top", 16)
		bm.add_theme_constant_override("margin_bottom", 16)
		bad_karma_card.add_child(bm)

		var bv := VBoxContainer.new()
		bv.set_meta("theme_exempt", true)
		bv.add_theme_constant_override("separation", 8)
		bm.add_child(bv)

		var bad_header := Label.new()
		bad_header.set_meta("reference_part", true)
		bad_header.text = "⛓️ KUKURUDU • TRIBUNAL SUMMONS"
		bad_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bad_header.add_theme_font_size_override("font_size", 22)
		bad_header.add_theme_color_override("font_color", Color("#ef4444"))
		bv.add_child(bad_header)

		var bad_desc := Label.new()
		bad_desc.set_meta("reference_part", true)
		bad_desc.text = "Your mortal lifetime was burdened by heavy karmic debt and unforgiven deeds. The cosmic scales cannot be avoided. Worldly succession is denied; the Astral Arbiter demands your immediate presence for judgment."
		bad_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bad_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bad_desc.add_theme_font_size_override("font_size", 19)
		bad_desc.add_theme_color_override("font_color", Color("#fca5a5"))
		bv.add_child(bad_desc)

		vbox.add_child(bad_karma_card)

		var btn_afterlife := Button.new()
		btn_afterlife.set_meta("theme_exempt", true)
		btn_afterlife.text = "⚖️ DESCEND TO THE AFTERLIFE FOR JUDGMENT"
		btn_afterlife.custom_minimum_size.y = 86
		btn_afterlife.add_theme_font_size_override("font_size", 26)
		var afterlife_style := StyleBoxFlat.new()
		afterlife_style.bg_color = Color("#7f1d1d")
		afterlife_style.border_color = Color("#ef4444")
		afterlife_style.set_border_width_all(3)
		afterlife_style.set_corner_radius_all(10)
		btn_afterlife.add_theme_stylebox_override("normal", afterlife_style)
		var afterlife_hover := afterlife_style.duplicate() as StyleBoxFlat
		afterlife_hover.bg_color = Color("#991b1b")
		btn_afterlife.add_theme_stylebox_override("hover", afterlife_hover)
		btn_afterlife.add_theme_color_override("font_color", Color("#ffffff"))
		btn_afterlife.pressed.connect(_open_afterlife_minigame)
		vbox.add_child(btn_afterlife)
	else:
		var good_karma_card := PanelContainer.new()
		good_karma_card.set_meta("theme_exempt", true)
		var gkc_style := StyleBoxFlat.new()
		gkc_style.bg_color = Color("#080305")
		gkc_style.border_color = Color("#991b1b")
		gkc_style.set_border_width_all(2)
		gkc_style.set_corner_radius_all(10)
		good_karma_card.add_theme_stylebox_override("panel", gkc_style)

		var gm := MarginContainer.new()
		gm.set_meta("theme_exempt", true)
		gm.add_theme_constant_override("margin_left", 20)
		gm.add_theme_constant_override("margin_right", 20)
		gm.add_theme_constant_override("margin_top", 16)
		gm.add_theme_constant_override("margin_bottom", 16)
		good_karma_card.add_child(gm)

		var gv := VBoxContainer.new()
		gv.set_meta("theme_exempt", true)
		gv.add_theme_constant_override("separation", 8)
		gm.add_child(gv)

		var g_header := Label.new()
		g_header.set_meta("reference_part", true)
		g_header.text = "🕯️ THE PARTING CROSSING • REST IN PEACE"
		g_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		g_header.add_theme_font_size_override("font_size", 22)
		g_header.add_theme_color_override("font_color", Color("#ef4444"))
		gv.add_child(g_header)

		var g_desc := Label.new()
		g_desc.set_meta("reference_part", true)
		g_desc.text = "Your earthly days have come to an end. Even as grief echoes in the silence left behind, you may choose how your legacy or spirit shall journey onward."
		g_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		g_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		g_desc.add_theme_font_size_override("font_size", 19)
		g_desc.add_theme_color_override("font_color", Color("#cbd5e1"))
		gv.add_child(g_desc)

		vbox.add_child(good_karma_card)

		var opts_v := VBoxContainer.new()
		opts_v.set_meta("theme_exempt", true)
		opts_v.add_theme_constant_override("separation", 12)
		vbox.add_child(opts_v)

		# Option 1: Pass Inheritance (only enabled if player has living children)
		var has_kids := PlayerData.has_living_children()
		var btn_inherit := Button.new()
		btn_inherit.set_meta("theme_exempt", true)
		btn_inherit.custom_minimum_size.y = 76
		btn_inherit.add_theme_font_size_override("font_size", 23)
		var inh_style := StyleBoxFlat.new()
		inh_style.bg_color = Color("#18060a") if has_kids else Color("#0f0709")
		inh_style.border_color = Color("#b91c1c") if has_kids else Color("#450a0a")
		inh_style.set_border_width_all(2)
		inh_style.set_corner_radius_all(10)
		btn_inherit.add_theme_stylebox_override("normal", inh_style)
		var inh_hover := inh_style.duplicate() as StyleBoxFlat
		inh_hover.bg_color = Color("#2d0a12") if has_kids else Color("#0f0709")
		btn_inherit.add_theme_stylebox_override("hover", inh_hover)
		btn_inherit.add_theme_color_override("font_color", Color("#ffffff"))

		if has_kids:
			btn_inherit.text = "📜 CARRY ON LINEAGE (CONTINUE AS CHILD)"
			btn_inherit.pressed.connect(_show_inheritance_selection_modal)
		else:
			btn_inherit.text = "📜 PASS INHERITANCE (No Living Children)"
			btn_inherit.disabled = true
			btn_inherit.modulate = Color(0.7, 0.7, 0.7, 0.6)
		opts_v.add_child(btn_inherit)

		# Option 2: Continue to Afterlife with Buffs
		var btn_afterlife := Button.new()
		btn_afterlife.set_meta("theme_exempt", true)
		btn_afterlife.text = "🌟 ASCEND TO THE CELESTIAL AFTERLIFE"
		btn_afterlife.custom_minimum_size.y = 76
		btn_afterlife.add_theme_font_size_override("font_size", 23)
		var alt_style := StyleBoxFlat.new()
		alt_style.bg_color = Color("#15050b")
		alt_style.border_color = Color("#dc2626")
		alt_style.set_border_width_all(2)
		alt_style.set_corner_radius_all(10)
		btn_afterlife.add_theme_stylebox_override("normal", alt_style)
		var alt_hover := alt_style.duplicate() as StyleBoxFlat
		alt_hover.bg_color = Color("#280914")
		btn_afterlife.add_theme_stylebox_override("hover", alt_hover)
		btn_afterlife.add_theme_color_override("font_color", Color("#ffffff"))
		btn_afterlife.pressed.connect(_open_afterlife_minigame)
		opts_v.add_child(btn_afterlife)

		# Option 3: Start Fresh Playthrough
		var btn_new_life := Button.new()
		btn_new_life.set_meta("theme_exempt", true)
		btn_new_life.text = "🕊️ BEGIN A NEW MORTAL STORY"
		btn_new_life.custom_minimum_size.y = 76
		btn_new_life.add_theme_font_size_override("font_size", 23)
		var new_life_style := StyleBoxFlat.new()
		new_life_style.bg_color = Color("#0b0305")
		new_life_style.border_color = Color("#991b1b")
		new_life_style.set_border_width_all(2)
		new_life_style.set_corner_radius_all(10)
		btn_new_life.add_theme_stylebox_override("normal", new_life_style)
		var new_life_hover := new_life_style.duplicate() as StyleBoxFlat
		new_life_hover.bg_color = Color("#1e070c")
		btn_new_life.add_theme_stylebox_override("hover", new_life_hover)
		btn_new_life.add_theme_color_override("font_color", Color("#ffffff"))
		btn_new_life.pressed.connect(_on_start_new_life_pressed)
		opts_v.add_child(btn_new_life)


func _on_start_new_life_pressed() -> void:
	if death_screen_overlay != null and is_instance_valid(death_screen_overlay):
		death_screen_overlay.queue_free()
		death_screen_overlay = null

	SaveManager.delete_save()
	PlayerData.reset_player()

	current_event = null
	current_event_choices.clear()
	hide_event_popup()

	life_feed.clear()
	update_history_panel()
	update_character_panel()
	show_tab("timeline")
	show_new_game_screen()


func _open_afterlife_minigame() -> void:
	if death_screen_overlay != null and is_instance_valid(death_screen_overlay):
		death_screen_overlay.queue_free()
		death_screen_overlay = null

	var afterlife_script = preload("res://scripts/minigames/afterlife_minigame.gd")
	var mg = afterlife_script.new()
	mg.name = "AfterlifeMinigame"
	add_child(mg)
	mg.setup(PlayerData.karma, Callable(self, "_on_afterlife_rebirth_complete"))


func _on_afterlife_rebirth_complete() -> void:
	current_event = null
	current_event_choices.clear()
	hide_event_popup()

	life_feed.clear()
	rebuild_life_feed()
	update_history_panel()
	update_character_panel()
	update_relationships_panel()
	update_ui()
	show_tab("timeline")
	SaveManager.save_game()


func _show_inheritance_selection_modal() -> void:
	if death_screen_overlay != null and is_instance_valid(death_screen_overlay):
		death_screen_overlay.queue_free()
		death_screen_overlay = null

	var modal := _create_cyber_modal("📜 ESTATE INHERITANCE & SUCCESSION", "Net Worth: $%s  •  Select an heir to continue lineage" % _format_number(PlayerData.get_net_worth()), Color("#eab308"))
	var list: VBoxContainer = modal.list

	var heirs: Array = []
	# 1. Living Partner/Spouse
	if PlayerData.has_partner():
		var p_candidate: Dictionary = PlayerData.partner.duplicate(true)
		p_candidate["_is_partner_heir"] = true
		heirs.append(p_candidate)

	# 2. Living Children
	for child in PlayerData.get_living_children():
		var c_candidate: Dictionary = (child as Dictionary).duplicate(true) if child is Dictionary else {}
		c_candidate["_is_partner_heir"] = false
		heirs.append(c_candidate)

	for heir in heirs:
		NpcLifeProgress.ensure(heir)
		var h_name: String = str(heir.get("name", "Heir"))
		var h_age: int = int(heir.get("age", 0))
		var h_gender: String = str(heir.get("gender", "MALE"))
		var h_rel: int = int(heir.get("relationship", 80))
		var is_partner: bool = bool(heir.get("_is_partner_heir", false))

		var p_card := PanelContainer.new()
		var card_color := Color("#f43f5e") if is_partner else Color("#eab308")
		p_card.add_theme_stylebox_override("panel", load_style_box_cyber_card(card_color))
		var cm := MarginContainer.new()
		cm.add_theme_constant_override("margin_left", 20)
		cm.add_theme_constant_override("margin_right", 20)
		cm.add_theme_constant_override("margin_top", 16)
		cm.add_theme_constant_override("margin_bottom", 16)
		p_card.add_child(cm)

		var ch := HBoxContainer.new()
		ch.add_theme_constant_override("separation", 18)
		cm.add_child(ch)

		# Avatar
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(96, 96)
		icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = PortraitCatalog.texture(h_age, h_gender, int(heir.get("portrait_variant", 0)), str(heir.get("ethnicity", PlayerData.ethnicity)))
		icon.material = PortraitCatalog.cutout_material()
		ch.add_child(icon)

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 6)
		ch.add_child(info_v)

		var name_lbl := Label.new()
		if is_partner:
			name_lbl.text = "%s (%s, Age %d)" % [h_name, PlayerData.get_partner_status(), h_age]
			name_lbl.add_theme_color_override("font_color", Color("#f43f5e"))
		else:
			name_lbl.text = "%s (%s, Age %d)" % [h_name, "Daughter" if h_gender == "FEMALE" else "Son", h_age]
			name_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
		name_lbl.add_theme_font_size_override("font_size", 24)
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(name_lbl)

		var occ_lbl := Label.new()
		occ_lbl.text = NpcLifeProgress.get_occupation_display(heir)
		occ_lbl.add_theme_font_size_override("font_size", 20)
		occ_lbl.add_theme_color_override("font_color", Color("#f8fafc"))
		occ_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(occ_lbl)

		var edu_lbl := Label.new()
		edu_lbl.text = NpcLifeProgress.get_education_display(heir)
		edu_lbl.add_theme_font_size_override("font_size", 19)
		edu_lbl.add_theme_color_override("font_color", Color("#cbd5e1"))
		edu_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(edu_lbl)

		var biz_str := NpcLifeProgress.get_business_display(heir)
		if not biz_str.is_empty():
			var biz_lbl := Label.new()
			biz_lbl.text = biz_str
			biz_lbl.add_theme_font_size_override("font_size", 19)
			biz_lbl.add_theme_color_override("font_color", Color("#fbbf24"))
			biz_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info_v.add_child(biz_lbl)

		var wealth_lbl := Label.new()
		wealth_lbl.text = NpcLifeProgress.get_finances_display(heir)
		wealth_lbl.add_theme_font_size_override("font_size", 19)
		wealth_lbl.add_theme_color_override("font_color", Color("#34d399"))
		wealth_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(wealth_lbl)

		var rel_lbl := Label.new()
		var rel_target := "partner" if is_partner else "parent"
		rel_lbl.text = "Relationship with late %s: %d%%" % [rel_target, h_rel]
		rel_lbl.add_theme_font_size_override("font_size", 18)
		rel_lbl.add_theme_color_override("font_color", Color("#94a3b8"))
		info_v.add_child(rel_lbl)

		var pick_btn := Button.new()
		pick_btn.text = "👑 Bequeath Estate & Continue as %s" % h_name
		pick_btn.custom_minimum_size.y = 56
		pick_btn.add_theme_font_size_override("font_size", 22)
		var bs := StyleBoxFlat.new()
		bs.bg_color = Color("#854d0e") if not is_partner else Color("#9f1239")
		bs.border_color = Color("#facc15") if not is_partner else Color("#f43f5e")
		bs.set_border_width_all(2)
		bs.set_corner_radius_all(8)
		pick_btn.add_theme_stylebox_override("normal", bs)
		var bsh := bs.duplicate() as StyleBoxFlat
		bsh.bg_color = bs.bg_color.lightened(0.2)
		pick_btn.add_theme_stylebox_override("hover", bsh)

		var target_heir = heir
		var target_is_partner = is_partner
		pick_btn.pressed.connect(func():
			_execute_inheritance_takeover(target_heir, modal.overlay, target_is_partner)
		)
		info_v.add_child(pick_btn)

		list.add_child(p_card)


func _execute_inheritance_takeover(heir: Dictionary, overlay_to_free: Control, is_partner: bool = false) -> void:
	if overlay_to_free != null and is_instance_valid(overlay_to_free):
		overlay_to_free.queue_free()

	var net_worth: int = maxi(500, PlayerData.get_net_worth())
	var roll := randf()
	var final_amount := net_worth
	var inheritance_msg := ""

	if roll < 0.50:
		final_amount = net_worth
		inheritance_msg = "✨ Seamless Succession: 100%% of the estate ($%s) was transferred without dispute into your bank balance." % _format_number(final_amount)
	elif roll < 0.75:
		final_amount = int(net_worth * 0.85)
		inheritance_msg = "🏛️ Estate Tax Levy: State tax authorities collected 15%% inheritance tax. $%s was deposited into your bank balance." % _format_number(final_amount)
	else:
		final_amount = maxi(250, net_worth - 5000)
		inheritance_msg = "⚖️ Probate Legal Settlement: Estate filing and attorney fees cost $5,000. $%s was secured into your bank balance." % _format_number(final_amount)

	# Transfer businesses, shares and physical assets intact, not also as cash.
	var estate_fees := maxi(0, net_worth - final_amount)
	var liquid_estate := PlayerData.money + PlayerData.bank_savings - PlayerData.get_total_debt()
	var bank_inheritance := maxi(0, liquid_estate - estate_fees)
	var remaining_liability := maxi(0, estate_fees - liquid_estate)
	PlayerData.takeover_as_heir(heir, bank_inheritance, PlayerData.owned_assets, "partner" if is_partner else "child")
	PlayerData.debt = remaining_liability
	PlayerData.add_life_log_entry(inheritance_msg, "finance")

	current_event = null
	current_event_choices.clear()
	hide_event_popup()

	life_feed.clear()
	rebuild_life_feed()
	update_history_panel()
	update_character_panel()
	update_relationships_panel()
	update_ui()
	show_tab("timeline")
	SaveManager.save_game()


func _generate_death_narrative(cause: String) -> String:
	var c_lower := cause.to_lower()
	var char_name := PlayerData.first_name
	var age := PlayerData.age

	if "cancer" in c_lower or "lymphoma" in c_lower:
		return "At the fragile age of %d, %s drew their final agonizing breath, succumbing to %s. Despite endless exhausting treatments and quiet prayers, the warmth slowly departed from their weary body." % [age, char_name, cause]
	elif "collision" in c_lower or "crash" in c_lower or "accident" in c_lower:
		return "At the age of %d, %s was torn violently from this world in a tragic %s. In a single cruel instant, a lifetime of memories, laughter, and tomorrow vanished into cold, hollow silence." % [age, char_name, cause]
	elif "surgery" in c_lower or "botched" in c_lower:
		return "At the age of %d, %s never woke from the freezing stillness of the operating table, claimed by %s. Loved ones waited in trembling hope outside, only to be met with inconsolable grief." % [age, char_name, cause]
	elif "cardiac" in c_lower or "heart" in c_lower:
		return "At the age of %d, %s suffered sudden, excruciating heart failure caused by %s. As their chest seized and their vision faded to black, their pulse fell forever still." % [age, char_name, cause]
	elif "old age" in c_lower:
		return "Surrounded by quiet shadows, %s closed their eyes for the last time at age %d, carried away by %s. A weary soul, tired of carrying the weight of a long lifetime, finally surrendered to eternal sleep." % [char_name, age, cause]
	elif "exhaustion" in c_lower or "stress" in c_lower or "debt" in c_lower:
		return "Crushed beneath unbearable burdens and sleepless despair, %s collapsed at age %d from %s. Broken in body and spirit, the cold earth offered the only release from their unending torment." % [age, char_name, cause]
	else:
		return "At the age of %d, %s slipped into the quiet abyss, claimed by %s. The mortal struggle ceased, leaving behind only hollow silence, cold memories, and an empty chair that will never be filled." % [age, char_name, cause]


func _configure_creation() -> void:
	name_input.max_length = 40
	name_input.virtual_keyboard_enabled = true
	name_input.focus_mode = Control.FOCUS_ALL
	name_input.set_meta("is_name_input", true)
	name_input.set_meta("mobile_kb_prompt_title", "What is your name?")
	name_input.placeholder_text = "Tap to enter custom name"
	name_input.focus_exited.connect(func(): name_input.text = CreationOptions.normalize_name(name_input.text))
	var MobileKeyboardManagerRef = load("res://scripts/ui/mobile_keyboard_manager.gd")
	if MobileKeyboardManagerRef != null:
		MobileKeyboardManagerRef.attach_to_input(name_input, "What is your name?")
	birthplace_input.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	birthplace_input.add_theme_constant_override("icon_max_width", 64)
	var popup := birthplace_input.get_popup()
	popup.max_size = Vector2i(760, 700)
	popup.add_theme_constant_override("icon_max_width", 64)
	popup.add_theme_constant_override("v_separation", 16)
	popup.add_theme_font_size_override("font_size", 28)
	for country in CreationOptions.COUNTRIES:
		birthplace_input.add_icon_item(CreationOptions.flag_texture(country[1], country[2]), country[0])
	birthplace_input.select(8)
	var content := name_input.get_parent()
	var name_kb_btn := MobileKeyboardManager.create_keyboard_trigger_button(name_input, "⌨️ Enter Custom Name", "What is your character's name?", Color("#00f0ff"))
	name_kb_btn.name = "CustomNameKeyboardButton"
	content.add_child(name_kb_btn)
	content.move_child(name_kb_btn, name_input.get_index() + 1)

	var gender_label := Label.new()
	gender_label.name = "GenderLabel"
	gender_label.text = "GENDER"
	gender_label.add_theme_font_size_override("font_size", 24)
	content.add_child(gender_label)
	content.move_child(gender_label, birthplace_input.get_index() + 1)

	gender_input = OptionButton.new()
	gender_input.name = "GenderInput"
	gender_input.add_item("MALE")
	gender_input.add_item("FEMALE")
	gender_input.custom_minimum_size.y = 76
	content.add_child(gender_input)
	content.move_child(gender_input, gender_label.get_index() + 1)

	var avatar_title := Label.new()
	avatar_title.name = "AvatarSectionLabel"
	avatar_title.text = "APPEARANCE"
	avatar_title.add_theme_font_size_override("font_size", 24)
	content.add_child(avatar_title)
	content.move_child(avatar_title, gender_input.get_index() + 1)

	var avatar_row := HBoxContainer.new()
	avatar_row.name = "AvatarRow"
	avatar_row.alignment = BoxContainer.ALIGNMENT_CENTER
	avatar_row.add_theme_constant_override("separation", 20)
	content.add_child(avatar_row)
	content.move_child(avatar_row, avatar_title.get_index() + 1)

	var prev_avatar_btn := Button.new()
	prev_avatar_btn.name = "PrevAvatarButton"
	prev_avatar_btn.text = " ◀ "
	prev_avatar_btn.custom_minimum_size = Vector2(80, 80)
	prev_avatar_btn.add_theme_font_override("font", preload("res://assets/fonts/app_font_bold.tres"))
	prev_avatar_btn.add_theme_font_size_override("font_size", 28)
	var arrow_style := StyleBoxFlat.new()
	arrow_style.bg_color = Color("#1e293b")
	arrow_style.border_color = Color("#38bdf8")
	arrow_style.set_border_width_all(2)
	arrow_style.set_corner_radius_all(8)
	var arrow_hover := arrow_style.duplicate() as StyleBoxFlat
	arrow_hover.bg_color = Color("#0284c7")
	prev_avatar_btn.add_theme_stylebox_override("normal", arrow_style)
	prev_avatar_btn.add_theme_stylebox_override("hover", arrow_hover)
	prev_avatar_btn.add_theme_stylebox_override("pressed", arrow_hover)
	prev_avatar_btn.add_theme_color_override("font_color", Color("#ffffff"))
	prev_avatar_btn.pressed.connect(func(): _cycle_creation_avatar(-1))
	avatar_row.add_child(prev_avatar_btn)

	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(104, 104)
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color("#0f172a")
	preview_style.border_color = Color("#00f0ff")
	preview_style.set_border_width_all(2)
	preview_style.set_corner_radius_all(10)
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	avatar_row.add_child(preview_panel)

	creation_avatar_rect = TextureRect.new()
	creation_avatar_rect.name = "CreationAvatarRect"
	creation_avatar_rect.custom_minimum_size = Vector2(96, 96)
	creation_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	creation_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	creation_avatar_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview_panel.add_child(creation_avatar_rect)

	var next_avatar_btn := Button.new()
	next_avatar_btn.name = "NextAvatarButton"
	next_avatar_btn.text = " ▶ "
	next_avatar_btn.custom_minimum_size = Vector2(80, 80)
	next_avatar_btn.add_theme_font_override("font", preload("res://assets/fonts/app_font_bold.tres"))
	next_avatar_btn.add_theme_font_size_override("font_size", 28)
	next_avatar_btn.add_theme_stylebox_override("normal", arrow_style)
	next_avatar_btn.add_theme_stylebox_override("hover", arrow_hover)
	next_avatar_btn.add_theme_stylebox_override("pressed", arrow_hover)
	next_avatar_btn.add_theme_color_override("font_color", Color("#ffffff"))
	next_avatar_btn.pressed.connect(func(): _cycle_creation_avatar(1))
	avatar_row.add_child(next_avatar_btn)

	creation_avatar_desc = Label.new()
	creation_avatar_desc.name = "AvatarDescLabel"
	creation_avatar_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	creation_avatar_desc.add_theme_color_override("font_color", Color("#bae6fd"))
	creation_avatar_desc.add_theme_font_size_override("font_size", 22)
	content.add_child(creation_avatar_desc)
	content.move_child(creation_avatar_desc, avatar_row.get_index() + 1)

	var random_button := Button.new()
	random_button.name = "RandomizeButton"
	random_button.text = "🎲 Randomize Name, Country & Avatar"
	random_button.custom_minimum_size.y = 76
	random_button.pressed.connect(_randomize_identity)
	content.add_child(random_button)
	content.move_child(random_button, creation_avatar_desc.get_index() + 1)

	birthplace_input.item_selected.connect(func(idx: int):
		var c_name := birthplace_input.get_item_text(idx)
		var allowed := PortraitCatalog.get_country_ethnicities(c_name)
		if not allowed.has(creation_selected_ethnicity):
			creation_selected_ethnicity = allowed[0]
			creation_selected_track = 0
			_update_creation_avatar_preview()
	)

	_update_creation_avatar_preview()

	# Card Styling: High-contrast Dark Cyber Card with Responsive Anti-Clipping ScrollContainer
	var card := content.get_parent() as PanelContainer
	if not content.get_parent() is ScrollContainer:
		var scroll := ScrollContainer.new()
		scroll.name = "CreationScroll"
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		_apply_translucent_scrollbar_to_node(scroll)
		card.remove_child(content)
		card.add_child(scroll)
		scroll.add_child(content)
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var update_card_bounds = func():
		if is_instance_valid(card):
			var vp_size: Vector2 = get_viewport_rect().size
			var max_w: float = minf(980.0, maxf(640.0, vp_size.x * 0.94))
			var max_h: float = minf(1600.0, maxf(560.0, vp_size.y * 0.92))
			card.custom_minimum_size = Vector2(max_w, max_h)

	update_card_bounds.call()
	get_viewport().size_changed.connect(update_card_bounds)

	_update_creation_theme()


func _update_creation_theme() -> void:
	if new_game_panel == null or not is_instance_valid(new_game_panel):
		return
	var is_light: bool = LifeLibrary.data.theme == "light"
	var card := new_game_panel.get_node_or_null("CenterContainer/CreationCard") as PanelContainer
	if card != null:
		var card_style := StyleBoxFlat.new()
		card_style.bg_color = Color("#ffffff") if is_light else Color("#090f1d")
		card_style.border_color = Color("#0284c7") if is_light else Color("#38bdf8")
		card_style.set_border_width_all(3)
		card_style.set_corner_radius_all(12)
		card_style.shadow_color = Color(0, 0, 0, 0.15 if is_light else 0.85)
		card_style.shadow_size = 20
		card_style.content_margin_left = 32
		card_style.content_margin_right = 32
		card_style.content_margin_top = 28
		card_style.content_margin_bottom = 28
		card.add_theme_stylebox_override("panel", card_style)

	var content: Node = null
	if card != null:
		var scroll := card.get_node_or_null("CreationScroll")
		if scroll != null:
			content = scroll.get_node_or_null("NewGameContent")
		if content == null:
			content = card.get_node_or_null("NewGameContent")

	if content != null:
		for child in content.get_children():
			if child is Label:
				if child.name == "NewGameTitle":
					child.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color("#00f0ff"))
					child.add_theme_font_size_override("font_size", 38)
				elif child == validation_label:
					child.add_theme_color_override("font_color", Color("#dc2626") if is_light else Color("#f87171"))
					child.add_theme_font_size_override("font_size", 22)
				else:
					child.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#bae6fd"))
					child.add_theme_font_size_override("font_size", 24)

		if creation_avatar_desc != null and is_instance_valid(creation_avatar_desc):
			creation_avatar_desc.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#bae6fd"))

		var name_kb_btn := content.get_node_or_null("CustomNameKeyboardButton") as Button
		if name_kb_btn != null:
			var kb_sb := StyleBoxFlat.new()
			kb_sb.bg_color = Color("#e0f2fe") if is_light else Color("#082f49")
			kb_sb.border_color = Color("#0284c7") if is_light else Color("#00f0ff")
			kb_sb.set_border_width_all(2)
			kb_sb.set_corner_radius_all(10)
			kb_sb.content_margin_left = 16
			kb_sb.content_margin_right = 16
			var kb_sb_h := kb_sb.duplicate() as StyleBoxFlat
			kb_sb_h.bg_color = Color("#bae6fd") if is_light else Color("#0369a1")
			name_kb_btn.add_theme_stylebox_override("normal", kb_sb)
			name_kb_btn.add_theme_stylebox_override("hover", kb_sb_h)
			name_kb_btn.add_theme_stylebox_override("pressed", kb_sb_h)
			name_kb_btn.add_theme_color_override("font_color", Color("#0369a1") if is_light else Color.WHITE)
			name_kb_btn.add_theme_color_override("font_hover_color", Color("#0c4a6e") if is_light else Color.WHITE)

		var avatar_row := content.get_node_or_null("AvatarRow")
		if avatar_row != null:
			for arrow_name in ["PrevAvatarButton", "NextAvatarButton"]:
				var arrow_btn := avatar_row.get_node_or_null(arrow_name) as Button
				if arrow_btn != null:
					var arrow_style := StyleBoxFlat.new()
					arrow_style.bg_color = Color("#edf3fa") if is_light else Color("#1e293b")
					arrow_style.border_color = Color("#0284c7") if is_light else Color("#38bdf8")
					arrow_style.set_border_width_all(2)
					arrow_style.set_corner_radius_all(8)
					var arrow_hover := arrow_style.duplicate() as StyleBoxFlat
					arrow_hover.bg_color = Color("#bfdbfe") if is_light else Color("#0284c7")
					arrow_btn.add_theme_stylebox_override("normal", arrow_style)
					arrow_btn.add_theme_stylebox_override("hover", arrow_hover)
					arrow_btn.add_theme_stylebox_override("pressed", arrow_hover)
					arrow_btn.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color.WHITE)

		var rand_btn := content.get_node_or_null("RandomizeButton") as Button
		if rand_btn != null:
			var rand_style := StyleBoxFlat.new()
			rand_style.bg_color = Color("#e0e7ff") if is_light else Color("#1e293b")
			rand_style.border_color = Color("#4338ca") if is_light else Color("#6366f1")
			rand_style.set_border_width_all(2)
			rand_style.set_corner_radius_all(10)
			rand_style.shadow_color = Color(0, 0, 0, 0.10 if is_light else 0.25)
			rand_style.shadow_size = 4
			rand_style.shadow_offset = Vector2(0, 3)
			var rand_hover := rand_style.duplicate() as StyleBoxFlat
			rand_hover.bg_color = Color("#c7d2fe") if is_light else Color("#312e81")
			rand_hover.border_color = Color("#312e81") if is_light else Color.WHITE
			var rand_pressed := rand_style.duplicate() as StyleBoxFlat
			rand_pressed.bg_color = Color("#a5b4fc") if is_light else Color("#1e1b4b")
			rand_btn.add_theme_stylebox_override("normal", rand_style)
			rand_btn.add_theme_stylebox_override("hover", rand_hover)
			rand_btn.add_theme_stylebox_override("pressed", rand_pressed)
			rand_btn.add_theme_color_override("font_color", Color("#1e1b4b") if is_light else Color.WHITE)
			rand_btn.add_theme_color_override("font_hover_color", Color("#0f172a") if is_light else Color("#c7d2fe"))

		var start_btn := content.get_node_or_null("StartGameButton") as Button
		if start_btn != null:
			var start_style := StyleBoxFlat.new()
			start_style.bg_color = Color("#16a34a") if is_light else Color("#22c55e")
			start_style.border_color = Color("#15803d")
			start_style.set_border_width_all(2)
			start_style.set_corner_radius_all(10)
			start_style.shadow_color = Color(0, 0, 0, 0.15 if is_light else 0.28)
			start_style.shadow_size = 4
			start_style.shadow_offset = Vector2(0, 3)
			var start_hover := start_style.duplicate() as StyleBoxFlat
			start_hover.bg_color = Color("#22c55e") if is_light else Color("#4ade80")
			start_hover.border_color = Color.WHITE
			var start_pressed := start_style.duplicate() as StyleBoxFlat
			start_pressed.bg_color = Color("#15803d")
			start_btn.add_theme_stylebox_override("normal", start_style)
			start_btn.add_theme_stylebox_override("hover", start_hover)
			start_btn.add_theme_stylebox_override("pressed", start_pressed)
			start_btn.add_theme_color_override("font_color", Color.WHITE)
			start_btn.add_theme_color_override("font_hover_color", Color.WHITE)
			start_btn.add_theme_color_override("font_pressed_color", Color.WHITE)
			start_btn.add_theme_font_size_override("font_size", 30)

	# Input field styling
	var field_style := StyleBoxFlat.new()
	field_style.bg_color = Color("#edf3fa") if is_light else Color("#111827")
	field_style.border_color = Color("#0284c7") if is_light else Color("#2563eb")
	field_style.set_border_width_all(2)
	field_style.set_corner_radius_all(10)
	field_style.content_margin_left = 18
	field_style.content_margin_right = 18

	var field_hover := field_style.duplicate() as StyleBoxFlat
	field_hover.bg_color = Color("#dbeafe") if is_light else Color("#1e293b")
	field_hover.border_color = Color("#0284c7") if is_light else Color("#38bdf8")

	var field_focus := field_style.duplicate() as StyleBoxFlat
	field_focus.border_color = Color("#0369a1") if is_light else Color("#00f0ff")
	field_focus.set_border_width_all(3)

	for field in [name_input, birthplace_input, gender_input]:
		if field != null and is_instance_valid(field):
			field.add_theme_stylebox_override("normal", field_style)
			field.add_theme_stylebox_override("hover", field_hover)
			field.add_theme_stylebox_override("focus", field_focus)
			field.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color.WHITE)
			field.add_theme_color_override("font_hover_color", Color("#0f172a") if is_light else Color.WHITE)
			field.add_theme_font_size_override("font_size", 26)

	if name_input != null and is_instance_valid(name_input):
		name_input.add_theme_color_override("font_placeholder_color", Color("#64748b") if is_light else Color("#94a3b8"))

	if birthplace_input != null and is_instance_valid(birthplace_input):
		var bp_popup := birthplace_input.get_popup()
		if bp_popup != null:
			var popup_style := StyleBoxFlat.new()
			popup_style.bg_color = Color("#ffffff") if is_light else Color("#0f172a")
			popup_style.border_color = Color("#0284c7") if is_light else Color("#38bdf8")
			popup_style.set_border_width_all(2)
			popup_style.set_corner_radius_all(10)
			bp_popup.add_theme_stylebox_override("panel", popup_style)
			bp_popup.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#f8fafc"))
			bp_popup.add_theme_color_override("font_hover_color", Color("#0284c7") if is_light else Color("#38bdf8"))

	if gender_input != null and is_instance_valid(gender_input):
		gender_input.add_theme_stylebox_override("pressed", field_hover)
		gender_input.add_theme_stylebox_override("hover_pressed", field_hover)
		gender_input.add_theme_color_override("font_pressed_color", Color("#0284c7") if is_light else Color("#64e6ff"))
		gender_input.add_theme_color_override("arrow_normal_color", Color("#0284c7") if is_light else Color("#64e6ff"))
		gender_input.add_theme_color_override("arrow_hover_color", Color("#0369a1") if is_light else Color.WHITE)
		var gp := gender_input.get_popup()
		if gp != null:
			var g_panel := StyleBoxFlat.new()
			g_panel.bg_color = Color("#ffffff") if is_light else Color("#0f172a")
			g_panel.border_color = Color("#0284c7") if is_light else Color("#38bdf8")
			g_panel.set_border_width_all(2)
			g_panel.set_corner_radius_all(10)
			g_panel.set_content_margin_all(12)
			gp.add_theme_stylebox_override("panel", g_panel)
			var g_hi := StyleBoxFlat.new()
			g_hi.bg_color = Color("#e0f2fe") if is_light else Color("#1d3353")
			g_hi.border_color = Color("#0284c7") if is_light else Color("#64e6ff")
			g_hi.set_border_width_all(2)
			g_hi.set_corner_radius_all(10)
			gp.add_theme_stylebox_override("hover", g_hi)
			gp.add_theme_font_override("font", gender_input.get_theme_font("font"))
			gp.add_theme_font_size_override("font_size", 26)
			gp.add_theme_color_override("font_color", Color("#0f172a") if is_light else Color("#d9efff"))
			gp.add_theme_color_override("font_hover_color", Color("#0284c7") if is_light else Color("#64e6ff"))
			gp.add_theme_color_override("font_focus_color", Color("#0284c7") if is_light else Color("#64e6ff"))


func _cycle_creation_avatar(direction: int) -> void:
	var eth_list := PortraitCatalog.ETHNICITIES
	var eth_idx := eth_list.find(creation_selected_ethnicity)
	if eth_idx == -1:
		eth_idx = 0
	var total_index := eth_idx * 4 + creation_selected_track
	total_index = posmod(total_index + direction, eth_list.size() * 4)
	creation_selected_ethnicity = eth_list[floori(float(total_index) / 4)]
	creation_selected_track = total_index % 4
	_update_creation_avatar_preview()


func _update_creation_avatar_preview() -> void:
	if creation_avatar_rect != null:
		creation_avatar_rect.texture = PortraitCatalog.get_baby_texture(creation_selected_ethnicity, creation_selected_track)
	if creation_avatar_desc != null:
		var eth_title := creation_selected_ethnicity.capitalize()
		creation_avatar_desc.text = "%s Baby • Style %d of 4" % [eth_title, creation_selected_track + 1]


func _randomize_identity() -> void:
	gender_input.select(randi_range(0, 1))
	birthplace_input.select(randi_range(0, birthplace_input.item_count - 1))
	var country := birthplace_input.get_item_text(birthplace_input.selected)
	name_input.text = NameCatalog.random_name(country, gender_input.selected == 1)
	creation_selected_ethnicity = PortraitCatalog.random_ethnicity_for_country(country)
	creation_selected_track = randi_range(0, 3)
	_update_creation_avatar_preview()
	validation_label.text = ""


func _configure_age_art() -> void:
	age_button.text = ""
	age_button.tooltip_text = "Age up one year"
	for state in ["normal", "hover", "pressed", "disabled"]:
		age_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())

	var existing_art := age_button.get_node_or_null("AgeArtwork")
	if existing_art != null:
		existing_art.queue_free()

	var artwork := TextureRect.new()
	artwork.name = "AgeArtwork"
	artwork.texture = preload("res://scripts/ui/modern_navigation.gd").icon("age")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork.pivot_offset = Vector2(115, 115)
	age_button.add_child(artwork)
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Additive Age-only splash; the existing artwork tweens stay unchanged.
	if age_button.get_node_or_null("AgePixelBurst") == null:
		var splash := preload("res://scripts/ui/age_pixel_burst.gd").new()
		splash.name = "AgePixelBurst"
		age_button.add_child(splash)

	# Micro-interactions for tactile responsiveness
	if not age_button.mouse_entered.is_connected(_on_age_btn_hover):
		age_button.mouse_entered.connect(_on_age_btn_hover)
	if not age_button.mouse_exited.is_connected(_on_age_btn_exit):
		age_button.mouse_exited.connect(_on_age_btn_exit)
	if not age_button.button_down.is_connected(_on_age_btn_down):
		age_button.button_down.connect(_on_age_btn_down)
	if not age_button.button_up.is_connected(_on_age_btn_up):
		age_button.button_up.connect(_on_age_btn_up)


func _on_age_btn_hover() -> void:
	var art := age_button.get_node_or_null("AgeArtwork") as TextureRect
	if art != null:
		var tween := create_tween()
		tween.tween_property(art, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_age_btn_exit() -> void:
	var art := age_button.get_node_or_null("AgeArtwork") as TextureRect
	if art != null:
		var tween := create_tween()
		tween.tween_property(art, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_age_btn_down() -> void:
	var art := age_button.get_node_or_null("AgeArtwork") as TextureRect
	if art != null:
		var tween := create_tween()
		tween.tween_property(art, "scale", Vector2(0.95, 0.95), 0.06).set_trans(Tween.TRANS_QUAD)


func _on_age_btn_up() -> void:
	var art := age_button.get_node_or_null("AgeArtwork") as TextureRect
	if art != null:
		var tween := create_tween()
		tween.tween_property(art, "scale", Vector2(1.05, 1.05), 0.08).set_trans(Tween.TRANS_QUAD)


var _stat_gradient_cache: Dictionary = {}


func _get_or_create_stat_gradient(c1: Color, c2: Color) -> GradientTexture2D:
	var key: int = int(c1.to_rgba32()) ^ (int(c2.to_rgba32()) << 1)
	if _stat_gradient_cache.has(key):
		return _stat_gradient_cache[key]
	var tex := _create_stat_gradient_texture(c1, c2)
	_stat_gradient_cache[key] = tex
	return tex


func _create_stat_gradient_texture(c1: Color, c2: Color) -> GradientTexture2D:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([c1, c2])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 256
	tex.height = 28
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.0, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex


func _configure_stat_bars() -> void:
	var stats_panel_node := get_node_or_null("SafeArea/MainColumn/StatsPanel") as PanelContainer
	if stats_panel_node != null:
		var stats_box := StyleBoxFlat.new()
		stats_box.bg_color = Color("#080e1c")
		stats_box.border_color = Color("#1e3a5f")
		stats_box.set_border_width_all(2)
		stats_box.set_corner_radius_all(10)
		stats_box.shadow_color = Color(0, 0, 0, 0.6)
		stats_box.shadow_size = 10
		stats_panel_node.add_theme_stylebox_override("panel", stats_box)

	var bars := [
		{"node": health_bar, "label": "Health", "c1": Color("#10b981"), "c2": Color("#047857"), "label_color": Color("#34d399")},
		{"node": happiness_bar, "label": "Happiness", "c1": Color("#f59e0b"), "c2": Color("#b45309"), "label_color": Color("#fbbf24")},
		{"node": smarts_bar, "label": "Smarts", "c1": Color("#0284c7"), "c2": Color("#1e3a8a"), "label_color": Color("#38bdf8")},
		{"node": looks_bar, "label": "Looks", "c1": Color("#db2777"), "c2": Color("#7e22ce"), "label_color": Color("#f472b6")}
	]

	# Track Style: Deep cyber inset casing with clean pixel bevel
	var track_style := StyleBoxFlat.new()
	track_style.bg_color = Color("#060b17")
	track_style.border_color = Color("#1e3a5f")
	track_style.set_border_width_all(2)
	track_style.set_corner_radius_all(4)
	track_style.content_margin_left = 3
	track_style.content_margin_right = 3
	track_style.content_margin_top = 3
	track_style.content_margin_bottom = 3

	for entry in bars:
		var bar: ProgressBar = entry["node"]
		if bar == null:
			continue

		bar.custom_minimum_size.y = 30
		bar.show_percentage = true
		bar.add_theme_font_size_override("font_size", 20)
		bar.add_theme_color_override("font_color", Color("#ffffff"))
		bar.add_theme_color_override("font_outline_color", Color("#000000"))
		bar.add_theme_constant_override("outline_size", 4)
		bar.add_theme_stylebox_override("background", track_style)

		var fill_style := StyleBoxTexture.new()
		fill_style.texture = _create_stat_gradient_texture(entry["c1"], entry["c2"])
		bar.add_theme_stylebox_override("fill", fill_style)

		var label := get_node_or_null("SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer/" + entry["label"] + "Label") as Label
		if label != null:
			label.add_theme_color_override("font_color", entry["label_color"])
			label.add_theme_font_size_override("font_size", 22)

	if grades_progress_bar != null:
		grades_progress_bar.custom_minimum_size.y = 26
		grades_progress_bar.show_percentage = true
		grades_progress_bar.add_theme_font_size_override("font_size", 18)
		grades_progress_bar.add_theme_color_override("font_color", Color("#ffffff"))
		grades_progress_bar.add_theme_color_override("font_outline_color", Color("#000000"))
		grades_progress_bar.add_theme_constant_override("outline_size", 4)
		grades_progress_bar.add_theme_stylebox_override("background", track_style)
		var fill_style := StyleBoxTexture.new()
		fill_style.texture = _get_or_create_stat_gradient(Color("#10b981"), Color("#047857"))
		grades_progress_bar.add_theme_stylebox_override("fill", fill_style)


func _update_stat_bar_color(bar: ProgressBar, value: int, col_left: Color, col_right: Color) -> void:
	if bar == null:
		return
	var fill := bar.get_theme_stylebox("fill") as StyleBoxTexture
	if fill == null:
		fill = StyleBoxTexture.new()
		bar.add_theme_stylebox_override("fill", fill)

	var target_tex: GradientTexture2D
	if value < 25:
		target_tex = _get_or_create_stat_gradient(Color("#ef4444"), Color("#991b1b"))
	else:
		target_tex = _get_or_create_stat_gradient(col_left, col_right)

	if fill.texture != target_tex:
		fill.texture = target_tex


func _configure_custom_icons() -> void:
	var sheet: Texture2D = load("res://assets/sheets/emojis.jpg")
	if sheet != null:
		var factor := float(sheet.get_width()) / 2048.0
		var regions := {
			"Health": Rect2(185, 590, 178, 151),
			"Happiness": Rect2(184, 189, 180, 177),
			"Smarts": Rect2(1067, 588, 170, 151),
			"Looks": Rect2(1318, 188, 181, 179)
		}
		var cutout_shader := Shader.new()
		cutout_shader.code = "shader_type canvas_item; void fragment(){vec4 c=texture(TEXTURE,UV); bool backing=c.b>c.r*1.13 && c.b>0.07 && c.b<0.46 && c.r<0.29 && c.g<c.b; if(backing){discard;} COLOR=c;}"
		for stat in regions:
			var label := get_node_or_null("SafeArea/MainColumn/StatsPanel/StatsMargin/StatsContainer/" + stat + "Label") as Label
			if label != null:
				label.text = stat.to_upper()
				var icon := TextureRect.new()
				icon.name = stat + "Icon"
				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				var region: Rect2 = regions[stat]
				atlas.region = Rect2(region.position * factor, region.size * factor)
				atlas.filter_clip = true
				icon.texture = atlas
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
				var cutout := ShaderMaterial.new()
				cutout.shader = cutout_shader
				icon.material = cutout
				label.add_child(icon)
				icon.position = Vector2(145, 1)
				icon.size = Vector2(20, 20)


func _configure_portrait() -> void:
	var holder := $ProfileStrip/ProfileMargin/ProfileRow/AvatarButton/Avatar
	portrait = TextureRect.new()
	portrait.name = "Portrait"
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.material = PortraitCatalog.cutout_material()
	holder.add_child(portrait)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 10
	portrait.offset_right = -10
	portrait.offset_top = 10
	portrait.offset_bottom = -10


func _update_portrait() -> void:
	var stage := PortraitCatalog.stage_index(PlayerData.age)
	var key := "%d/%s/%s/%d" % [stage, PlayerData.gender, PlayerData.ethnicity, PlayerData.portrait_track]
	if key != portrait_key:
		portrait.texture = PortraitCatalog.get_portrait(PlayerData.age, PlayerData.gender, PlayerData.portrait_track, PlayerData.ethnicity)
		portrait_key = key
	portrait.tooltip_text = "%s %s" % [PlayerData.get_stage_icon(), PlayerData.get_stage_name()]
	if isometric_room != null and isometric_room.has_method("update_character"):
		isometric_room.update_character()

var is_disclaimer_fading: bool = false


func _start_game_initialization_sequence() -> void:
	if loading_screen == null or loading_progress_label == null:
		return

	is_disclaimer_fading = false
	if disclaimer_screen != null:
		# Decorative children must not intercept taps intended for the splash.
		for child in disclaimer_screen.find_children("*", "Control", true, false):
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loading_progress_label.text = "0 %"

	# BACKGROUND LOADING STARTS CONCURRENTLY AT T = 0 WHILE DISCLAIMER IS SHOWN
	var loading_tween := create_tween()
	loading_tween.tween_method(func(val: float) -> void:
		if loading_progress_label != null:
			loading_progress_label.text = "%d %%" % int(val)
	, 0.0, 100.0, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	loading_tween.tween_interval(0.2)
	# Silky-smooth cinematic dissolve/fade out transition from loading screen into main game
	loading_tween.set_parallel(true)
	loading_tween.tween_property(loading_screen, "modulate:a", 0.0, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	loading_tween.tween_property(loading_screen, "scale", Vector2(1.03, 1.03), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	loading_tween.chain().tween_callback(func() -> void:
		if loading_screen != null:
			loading_screen.visible = false
			loading_screen.scale = Vector2(1.0, 1.0)
	)

	# Auto-dismiss after two real seconds; a tap can start the fade immediately.
	if disclaimer_screen != null:
		await RenderingServer.frame_post_draw
		var visible_until := Time.get_ticks_msec() + 2000
		while Time.get_ticks_msec() < visible_until:
			var remaining_seconds := float(visible_until - Time.get_ticks_msec()) / 1000.0
			await get_tree().create_timer(maxf(remaining_seconds, 0.001), true, false, true).timeout
		_fade_out_disclaimer()


func _fade_out_disclaimer() -> void:
	if disclaimer_screen == null or is_disclaimer_fading:
		return
	is_disclaimer_fading = true
	var fade_tween := create_tween()
	fade_tween.tween_property(disclaimer_screen, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_callback(func() -> void:
		if disclaimer_screen != null:
			disclaimer_screen.visible = false
	)


func _on_disclaimer_screen_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_fade_out_disclaimer()
	elif event is InputEventScreenTouch and event.pressed:
		_fade_out_disclaimer()


func _start_loading_animation() -> void:
	if loading_screen == null or loading_progress_label == null:
		return
	loading_progress_label.text = "0 %"
	var tween := create_tween()
	tween.tween_method(func(val: float) -> void:
		if loading_progress_label != null:
			loading_progress_label.text = "%d %%" % int(val)
	, 0.0, 100.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.2)
	# Silky-smooth cinematic dissolve/fade out transition into main game screen
	tween.set_parallel(true)
	tween.tween_property(loading_screen, "modulate:a", 0.0, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(loading_screen, "scale", Vector2(1.03, 1.03), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(func() -> void:
		if loading_screen != null:
			loading_screen.visible = false
			loading_screen.scale = Vector2(1.0, 1.0)
	)


# ==========================================
# BUTTON MICRO-INTERACTIONS (Settings & Action Bar)
# ==========================================

func _on_menu_btn_hover() -> void:
	var menu_btn := get_node_or_null("TopBar/Row/MenuButton") as Button
	if menu_btn != null:
		menu_btn.pivot_offset = menu_btn.size / 2.0
		var tween := create_tween().set_parallel(true)
		tween.tween_property(menu_btn, "scale", Vector2(1.16, 1.16), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(menu_btn, "modulate", Color(1.2, 1.3, 1.5, 1.0), 0.2)


func _on_menu_btn_exit() -> void:
	var menu_btn := get_node_or_null("TopBar/Row/MenuButton") as Button
	if menu_btn != null:
		var tween := create_tween().set_parallel(true)
		tween.tween_property(menu_btn, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(menu_btn, "modulate", Color.WHITE, 0.18)


func _on_menu_btn_down() -> void:
	var menu_btn := get_node_or_null("TopBar/Row/MenuButton") as Button
	if menu_btn != null:
		var tween := create_tween()
		tween.tween_property(menu_btn, "scale", Vector2(0.9, 0.9), 0.06).set_trans(Tween.TRANS_QUAD)


func _on_menu_btn_up() -> void:
	var menu_btn := get_node_or_null("TopBar/Row/MenuButton") as Button
	if menu_btn != null:
		var tween := create_tween()
		tween.tween_property(menu_btn, "scale", Vector2(1.16, 1.16), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_action_bar_btn_hover(btn: Button) -> void:
	if btn == null:
		return
	btn.pivot_offset = btn.size / 2.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "modulate", Color(1.15, 1.25, 1.4, 1.0), 0.12)


func _on_action_bar_btn_exit(btn: Button) -> void:
	if btn == null:
		return
	var tween := create_tween().set_parallel(true)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "modulate", Color.WHITE, 0.12)


func _on_action_bar_btn_down(btn: Button) -> void:
	if btn == null:
		return
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(0.94, 0.94), 0.06).set_trans(Tween.TRANS_QUAD)


func _on_action_bar_btn_up(btn: Button) -> void:
	if btn == null:
		return
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
