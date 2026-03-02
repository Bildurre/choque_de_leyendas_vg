## Modal de opciones del juego.
## Muestra un overlay oscuro con blur sobre el contenido actual y un menu central
## con botones clasicos de opciones: Juego, Graficos, Audio, Volver, Salir.
class_name SettingsModal
extends CanvasLayer

const BLUR_SHADER_PATH := "res://ui/shaders/blur_overlay.gdshader"
const GAME_SETTINGS_SCENE := "res://screens/settings/game_settings/game_settings_desktop.tscn"
const GRAPHICS_SETTINGS_SCENE := "res://screens/settings/graphics_settings/graphics_settings_desktop.tscn"
const FADE_DURATION := 0.25
const BUTTON_SEPARATION := 12

## Se emite al pulsar "Volver" o hacer click fuera del panel.
signal closed

var _backdrop: ColorRect
var _panel: PanelContainer
var _tween: Tween

## Claves de traduccion de los botones del menu.
var _button_keys := ["MODAL_SWITCH", "MODAL_GAME", "MODAL_GRAPHICS", "MODAL_AUDIO", "MODAL_BACK", "MODAL_EXIT"]


func _ready() -> void:
	layer = 50
	_build_ui()
	_fade_in()


func _build_ui() -> void:
	# --- Backdrop con blur ---
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP

	var shader := load(BLUR_SHADER_PATH) as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("blur_amount", 1.0)
		mat.set_shader_parameter("overlay_color", Color(0.0, 0.0, 0.0, 0.7))
		_backdrop.material = mat
	else:
		_backdrop.color = Color(0.0, 0.0, 0.0, 0.7)

	_backdrop.gui_input.connect(_on_backdrop_input)
	add_child(_backdrop)

	# --- Contenedor centrado ---
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.add_child(center)

	# --- Panel principal ---
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.08, 1.0)
	panel_style.set_corner_radius_all(16)
	panel_style.border_color = GameColors.COLOR_PURPLE
	panel_style.set_border_width_all(2)
	panel_style.shadow_color = Color(GameColors.COLOR_PURPLE, 0.4)
	panel_style.shadow_size = 12
	panel_style.content_margin_left = 48.0
	panel_style.content_margin_right = 48.0
	panel_style.content_margin_top = 40.0
	panel_style.content_margin_bottom = 40.0
	_panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(_panel)

	# --- Columna de botones ---
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", BUTTON_SEPARATION)
	_panel.add_child(vbox)

	# --- Titulo ---
	var title := Label.new()
	title.text = "MODAL_TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font := load("res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf") as Font
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	vbox.add_child(title)

	# Separador visual
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 16.0
	vbox.add_child(spacer)

	# --- Botones ---
	for key in _button_keys:
		if key == "MODAL_EXIT":
			var spacer_salir := Control.new()
			spacer_salir.custom_minimum_size.y = 12.0
			vbox.add_child(spacer_salir)
		var btn := Button.new()
		btn.text = key
		btn.script = load("res://ui/components/buttons/menu_option_button.gd")
		btn.pressed.connect(_on_button_pressed.bind(key))
		vbox.add_child(btn)


func _on_button_pressed(key: String) -> void:
	match key:
		"MODAL_SWITCH":
			DisplayMode.switch_mode()
		"MODAL_GAME":
			get_tree().change_scene_to_file(GAME_SETTINGS_SCENE)
		"MODAL_GRAPHICS":
			get_tree().change_scene_to_file(GRAPHICS_SETTINGS_SCENE)
		"MODAL_BACK":
			_close()
		"MODAL_EXIT":
			get_tree().quit()
		_:
			pass


func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	if _tween and _tween.is_running():
		return
	_fade_out()


func _fade_in() -> void:
	_backdrop.modulate = Color(1, 1, 1, 0)
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_backdrop, "modulate:a", 1.0, FADE_DURATION)


func _fade_out() -> void:
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_backdrop, "modulate:a", 0.0, FADE_DURATION)
	_tween.tween_callback(_on_fade_out_done)


func _on_fade_out_done() -> void:
	closed.emit()
	queue_free()
