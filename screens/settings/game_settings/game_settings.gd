## Pantalla de opciones de Juego.
## Muestra opciones de configuracion del juego en formato tabla.
extends Control

const HOME_SCENE := "res://screens/home/home_desktop.tscn"


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
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.12, 0.12, 0.7)
	normal.set_corner_radius_all(8)
	normal.border_color = Color(0.3, 0.3, 0.3, 0.4)
	normal.set_border_width_all(2)
	normal.content_margin_left = 16.0
	normal.content_margin_right = 16.0
	normal.content_margin_top = 10.0
	normal.content_margin_bottom = 10.0
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.478, 0.392, 0.784, 0.3)
	hover.set_corner_radius_all(8)
	hover.border_color = Color(0.478, 0.392, 0.784, 0.6)
	hover.set_border_width_all(2)
	hover.content_margin_left = 16.0
	hover.content_margin_right = 16.0
	hover.content_margin_top = 10.0
	hover.content_margin_bottom = 10.0
	btn.add_theme_stylebox_override("hover", hover)
