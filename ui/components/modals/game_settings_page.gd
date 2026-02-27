## Pagina de opciones de Juego.
## Muestra opciones de configuracion del juego en formato tabla (clave-valor).
## Se abre desde el SettingsModal al pulsar "Juego".
class_name GameSettingsPage
extends CanvasLayer

const BLUR_SHADER_PATH := "res://ui/shaders/blur_overlay.gdshader"
const FONT_PATH := "res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf"
const FADE_DURATION := 0.25

signal closed

var _backdrop: ColorRect
var _panel: PanelContainer
var _tween: Tween
var _font: Font


func _ready() -> void:
	layer = 51
	_font = load(FONT_PATH) as Font
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
	_panel.custom_minimum_size.x = 480.0
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

	# --- Columna principal ---
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	_panel.add_child(vbox)

	# --- Titulo ---
	var title := Label.new()
	title.text = "Juego"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font:
		title.add_theme_font_override("font", _font)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 10)
	vbox.add_child(title)

	# Separador bajo titulo
	var title_spacer := Control.new()
	title_spacer.custom_minimum_size.y = 28.0
	vbox.add_child(title_spacer)

	# --- Seccion: General ---
	_add_section(vbox)

	# Opcion: Idioma
	var lang_row := _create_option_row("Idioma", _create_language_selector())
	vbox.add_child(lang_row)

	# Espacio antes del boton volver
	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size.y = 32.0
	vbox.add_child(bottom_spacer)

	# --- Boton Volver ---
	var back_btn := Button.new()
	back_btn.text = "Volver"
	back_btn.script = load("res://ui/components/buttons/menu_option_button.gd")
	back_btn.pressed.connect(_close)
	vbox.add_child(back_btn)


func _add_section(parent: VBoxContainer) -> void:
	# Linea separadora sutil entre secciones
	var sep := HSeparator.new()
	var sep_style := StyleBoxFlat.new()
	sep_style.bg_color = Color(GameColors.COLOR_PURPLE, 0.3)
	sep_style.content_margin_top = 1.0
	sep_style.content_margin_bottom = 1.0
	sep.add_theme_stylebox_override("separator", sep_style)
	parent.add_child(sep)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 20.0
	parent.add_child(spacer)


func _create_option_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER

	# Label izquierda
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font:
		label.add_theme_font_override("font", _font)
	label.add_theme_font_size_override("font_size", 26)
	label.add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT_DIM)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	row.add_child(label)

	# Control derecha
	control.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(control)

	return row


func _create_language_selector() -> OptionButton:
	var selector := OptionButton.new()
	selector.custom_minimum_size.x = 180.0
	selector.add_item("Castellano", 0)
	selector.add_item("English", 1)
	selector.selected = 0

	# Estilo del selector
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.12, 0.12, 0.12, 0.7)
	normal_style.set_corner_radius_all(8)
	normal_style.border_color = Color(0.3, 0.3, 0.3, 0.4)
	normal_style.set_border_width_all(2)
	normal_style.content_margin_left = 16.0
	normal_style.content_margin_right = 16.0
	normal_style.content_margin_top = 10.0
	normal_style.content_margin_bottom = 10.0
	selector.add_theme_stylebox_override("normal", normal_style)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(0.478, 0.392, 0.784, 0.3)
	hover_style.set_corner_radius_all(8)
	hover_style.border_color = Color(0.478, 0.392, 0.784, 0.6)
	hover_style.set_border_width_all(2)
	hover_style.content_margin_left = 16.0
	hover_style.content_margin_right = 16.0
	hover_style.content_margin_top = 10.0
	hover_style.content_margin_bottom = 10.0
	selector.add_theme_stylebox_override("hover", hover_style)

	if _font:
		selector.add_theme_font_override("font", _font)
	selector.add_theme_font_size_override("font_size", 22)
	selector.add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT)
	selector.add_theme_color_override("font_hover_color", Color.WHITE)
	selector.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	selector.item_selected.connect(_on_language_changed)
	return selector


func _on_language_changed(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("es")
			print("[GameSettings] Idioma: Castellano")
		1:
			TranslationServer.set_locale("en")
			print("[GameSettings] Idioma: English")


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
