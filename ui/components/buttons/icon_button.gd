## Boton redondo reutilizable con icono. Muestra un icono centrado sobre un fondo
## circular oscuro. En hover: cambia color de fondo y muestra sombra.
## Uso: asignar icon (Texture2D) y tooltip_text desde el editor o .tscn.
class_name IconButton
extends Button

## Color de fondo en hover (usar colores intermedios de GameColors).
@export var hover_color: Color = GameColors.COLOR_TEAL

## Tamanio total del boton (diametro).
@export var button_diameter: float = 96.0

## Padding interior entre el borde del boton y el icono.
@export var icon_padding: float = 24.0

var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _pressed_style: StyleBoxFlat


func _ready() -> void:
	flat = false
	expand_icon = true
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	custom_minimum_size = Vector2(button_diameter, button_diameter)
	text = ""

	_setup_styles()


func _setup_styles() -> void:
	var radius := int(button_diameter / 2.0)
	var pad := int(icon_padding)

	# Estado normal: fondo gris oscuro + borde sutil
	_normal_style = _create_base_style(GameColors.COLOR_BG_DARK_TERTIARY, radius, pad)
	_normal_style.border_color = Color(GameColors.COLOR_TEXT_LIGHT, 0.15)

	# Estado hover: color intermedio + borde mas visible + sombra
	_hover_style = _create_base_style(hover_color, radius, pad)
	_hover_style.border_color = Color(GameColors.COLOR_TEXT_LIGHT, 0.3)
	_hover_style.shadow_size = 4
	_hover_style.shadow_color = Color(hover_color, 0.2)
	_hover_style.shadow_offset = Vector2(0, 0)

	# Estado presionado: color intermedio mas oscuro + borde
	_pressed_style = _create_base_style(hover_color.darkened(0.2), radius, pad)
	_pressed_style.border_color = Color(GameColors.COLOR_TEXT_LIGHT, 0.2)

	# Aplicar estilos
	add_theme_stylebox_override("normal", _normal_style)
	add_theme_stylebox_override("hover", _hover_style)
	add_theme_stylebox_override("pressed", _pressed_style)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	# Cursor de mano
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _create_base_style(bg: Color, radius: int, pad: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(radius)
	style.content_margin_left = pad
	style.content_margin_top = pad
	style.content_margin_right = pad
	style.content_margin_bottom = pad
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.anti_aliasing = true
	style.anti_aliasing_size = 2.0
	return style
