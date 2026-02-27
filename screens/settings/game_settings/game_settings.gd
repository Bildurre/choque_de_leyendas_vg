## Pantalla de opciones de Juego.
## Muestra opciones de configuracion del juego en formato tabla.
extends Control

const HOME_SCENE := "res://screens/home/home_desktop.tscn"

var _chevron: TextureRect


func _ready() -> void:
	%LanguageSelector.item_selected.connect(_on_language_changed)
	%TopBar.back_pressed.connect(_on_back_pressed)

	_sync_language_selector()
	_style_option_button(%LanguageSelector)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not %BottomBar.has_modal_open():
		get_viewport().set_input_as_handled()
		_on_back_pressed()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)


func _sync_language_selector() -> void:
	var locale := TranslationServer.get_locale()
	match locale:
		"es":
			%LanguageSelector.selected = 0
		"en":
			%LanguageSelector.selected = 1


func _on_language_changed(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("es")
		1:
			TranslationServer.set_locale("en")


func _style_option_button(btn: OptionButton) -> void:
	var chevron_size := 20.0
	var chevron_pad := 4.0
	var extra_right := chevron_size + chevron_pad * 2

	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = 8.0
	empty.content_margin_right = extra_right
	empty.content_margin_top = 6.0
	empty.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 1.0, 1.0, 0.06)
	hover.set_corner_radius_all(4)
	hover.content_margin_left = 8.0
	hover.content_margin_right = extra_right
	hover.content_margin_top = 6.0
	hover.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("hover", hover)

	# Ocultar flecha nativa del OptionButton.
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	btn.add_theme_icon_override("arrow", ImageTexture.create_from_image(img))
	btn.add_theme_constant_override("arrow_margin", 0)

	# Chevron animado como hijo del boton.
	_chevron = TextureRect.new()
	_chevron.texture = load("res://assets/icons/placeholder/chevron_down.svg")
	_chevron.custom_minimum_size = Vector2(chevron_size, chevron_size)
	_chevron.size = Vector2(chevron_size, chevron_size)
	_chevron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chevron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chevron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chevron.modulate = Color(0.85, 0.85, 0.85, 1)
	_chevron.pivot_offset = Vector2(chevron_size / 2.0, chevron_size / 2.0)
	btn.add_child(_chevron)
	_chevron.anchor_left = 1.0
	_chevron.anchor_right = 1.0
	_chevron.anchor_top = 0.5
	_chevron.anchor_bottom = 0.5
	_chevron.offset_left = -(chevron_size + chevron_pad)
	_chevron.offset_right = -chevron_pad
	_chevron.offset_top = -(chevron_size / 2.0)
	_chevron.offset_bottom = chevron_size / 2.0

	# Style the popup dropdown.
	var popup := btn.get_popup()
	_strip_popup_checks(popup)
	popup.about_to_popup.connect(_strip_popup_checks.bind(popup))
	popup.about_to_popup.connect(_on_selector_opened)
	popup.popup_hide.connect(_on_selector_closed)

	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	panel.set_corner_radius_all(6)
	panel.border_color = Color(0.3, 0.3, 0.3, 0.3)
	panel.set_border_width_all(1)
	panel.content_margin_left = 4.0
	panel.content_margin_right = 4.0
	panel.content_margin_top = 4.0
	panel.content_margin_bottom = 4.0
	popup.add_theme_stylebox_override("panel", panel)

	var popup_normal := StyleBoxEmpty.new()
	popup_normal.content_margin_left = 12.0
	popup_normal.content_margin_right = 12.0
	popup_normal.content_margin_top = 8.0
	popup_normal.content_margin_bottom = 8.0
	popup.add_theme_stylebox_override("normal", popup_normal)

	var popup_hover := StyleBoxFlat.new()
	popup_hover.bg_color = Color(0.478, 0.392, 0.784, 0.3)
	popup_hover.set_corner_radius_all(4)
	popup_hover.content_margin_left = 12.0
	popup_hover.content_margin_right = 12.0
	popup_hover.content_margin_top = 8.0
	popup_hover.content_margin_bottom = 8.0
	popup.add_theme_stylebox_override("hover", popup_hover)

	var font := load("res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf")
	if font:
		popup.add_theme_font_override("font", font)
	popup.add_theme_font_size_override("font_size", 22)
	popup.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	popup.add_theme_color_override("font_hover_color", Color.WHITE)


func _on_selector_opened() -> void:
	var tween := create_tween()
	tween.tween_property(_chevron, "rotation", PI, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_selector_closed() -> void:
	var tween := create_tween()
	tween.tween_property(_chevron, "rotation", 0.0, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _strip_popup_checks(popup: PopupMenu) -> void:
	for i in popup.item_count:
		popup.set_item_as_radio_checkable(i, false)
