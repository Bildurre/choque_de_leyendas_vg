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

var _tween: Tween
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

	resized.connect(_update_pivot)
	_update_pivot()

	mouse_entered.connect(_on_hover_entered)
	mouse_exited.connect(_on_hover_exited)


func _setup_styles() -> void:
	var radius := int(button_diameter / 2.0)
	var pad := int(icon_padding)

	# Estado normal: fondo gris oscuro, sin sombra
	_normal_style = StyleBoxFlat.new()
	_normal_style.bg_color = GameColors.COLOR_BG_DARK_TERTIARY
	_normal_style.set_corner_radius_all(radius)
	_normal_style.content_margin_left = pad
	_normal_style.content_margin_top = pad
	_normal_style.content_margin_right = pad
	_normal_style.content_margin_bottom = pad

	# Estado hover: color intermedio + sombra
	_hover_style = StyleBoxFlat.new()
	_hover_style.bg_color = hover_color
	_hover_style.set_corner_radius_all(radius)
	_hover_style.content_margin_left = pad
	_hover_style.content_margin_top = pad
	_hover_style.content_margin_right = pad
	_hover_style.content_margin_bottom = pad
	_hover_style.shadow_size = 4
	_hover_style.shadow_color = Color(hover_color, 0.2)
	_hover_style.shadow_offset = Vector2(0, 0)

	# Estado presionado: color intermedio mas oscuro
	_pressed_style = StyleBoxFlat.new()
	_pressed_style.bg_color = hover_color.darkened(0.2)
	_pressed_style.set_corner_radius_all(radius)
	_pressed_style.content_margin_left = pad
	_pressed_style.content_margin_top = pad
	_pressed_style.content_margin_right = pad
	_pressed_style.content_margin_bottom = pad

	# Aplicar estilos
	add_theme_stylebox_override("normal", _normal_style)
	add_theme_stylebox_override("hover", _hover_style)
	add_theme_stylebox_override("pressed", _pressed_style)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	# Cursor de mano
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _update_pivot() -> void:
	pivot_offset = size / 2.0


func _on_hover_entered() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.5)


func _on_hover_exited() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.5)
