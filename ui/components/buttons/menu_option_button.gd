## Boton horizontal para menus de opciones (pausa, settings, etc.).
## Estilo clasico de juego: fondo semi-transparente, texto centrado, hover con color.
class_name MenuOptionButton
extends Button

const FONT_PATH := "res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf"
const CORNER_RADIUS := 8
const FONT_SIZE := 32
const MIN_WIDTH := 360.0
const PADDING_H := 32.0
const PADDING_V := 16.0

var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _pressed_style: StyleBoxFlat


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	custom_minimum_size.x = MIN_WIDTH

	var font := load(FONT_PATH) as Font
	if font:
		add_theme_font_override("font", font)
	add_theme_font_size_override("font_size", FONT_SIZE)
	add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", GameColors.COLOR_TEXT_LIGHT_DIM)
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 8)

	_setup_styles()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _setup_styles() -> void:
	_normal_style = _make_style(Color(0.12, 0.12, 0.12, 0.7), Color(0.3, 0.3, 0.3, 0.4))
	_hover_style = _make_style(Color(0.478, 0.392, 0.784, 0.5), Color(0.478, 0.392, 0.784, 0.8))
	_pressed_style = _make_style(Color(0.478, 0.392, 0.784, 0.7), Color(0.478, 0.392, 0.784, 1.0))

	add_theme_stylebox_override("normal", _normal_style)
	add_theme_stylebox_override("hover", _hover_style)
	add_theme_stylebox_override("pressed", _pressed_style)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _make_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(CORNER_RADIUS)
	s.border_color = border
	s.set_border_width_all(2)
	s.content_margin_left = PADDING_H
	s.content_margin_right = PADDING_H
	s.content_margin_top = PADDING_V
	s.content_margin_bottom = PADDING_V
	return s
