## Botón rectangular tipo tarjeta con borde de color y texto IMFellEnglish.
## Mantiene aspect ratio 5:7 (ancho:alto) de forma responsiva.
class_name MenuCardButton
extends Button

## Color del borde y del outline del texto.
@export var accent_color: Color = GameColors.COLOR_GREEN

## Grosor del borde.
@export var border_width: int = 3

## Radio de las esquinas redondeadas.
@export var corner_radius: int = 12

const ASPECT_RATIO := 5.0 / 7.0
const FONT_PATH := "res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf"


func _ready() -> void:
	expand_icon = false
	alignment = HORIZONTAL_ALIGNMENT_CENTER

	var font := load(FONT_PATH) as Font
	if font:
		add_theme_font_override("font", font)
	add_theme_font_size_override("font_size", 48)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)
	add_theme_color_override("font_outline_color", accent_color)
	add_theme_constant_override("outline_size", 8)

	_setup_styles()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(_update_aspect_ratio)
	call_deferred("_update_aspect_ratio")


func _setup_styles() -> void:
	var bg := Color(0.08, 0.08, 0.08, 0.6)

	var normal := _make_style(bg, accent_color, border_width)

	var hover := _make_style(Color(0.12, 0.12, 0.12, 0.7), accent_color.lightened(0.2), border_width + 1)
	hover.shadow_size = 8
	hover.shadow_color = Color(accent_color, 0.3)

	var pressed := _make_style(Color(0.05, 0.05, 0.05, 0.8), accent_color.darkened(0.2), border_width)

	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _make_style(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(corner_radius)
	s.border_color = border
	s.set_border_width_all(bw)
	return s


func _update_aspect_ratio() -> void:
	var target_w := size.y * ASPECT_RATIO
	if abs(custom_minimum_size.x - target_w) > 1.0:
		custom_minimum_size.x = target_w
