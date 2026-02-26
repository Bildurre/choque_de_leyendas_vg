## Boton de perfil con forma hexagonal. Muestra el icono de usuario dentro
## de un hexagono con borde. Hover cambia el color de fondo y borde.
class_name HexProfileButton
extends Control

@export var bg_color: Color = GameColors.COLOR_BG_DARK_TERTIARY
@export var border_color: Color = GameColors.COLOR_PURPLE
@export var hover_border_color: Color = GameColors.COLOR_PURPLE_LIGHT
@export var border_width: float = 2.0

var _hovered := false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "Perfil de usuario"


func _draw() -> void:
	var center := size / 2.0
	var radius: float = minf(size.x, size.y) / 2.0 - border_width
	var points := _hex_points(center, radius)

	# Fondo
	var fill := bg_color.lightened(0.15) if _hovered else bg_color
	draw_colored_polygon(points, fill)

	# Borde
	var border := points.duplicate()
	border.append(points[0])
	var b_color := hover_border_color if _hovered else border_color
	draw_polyline(border, b_color, border_width, true)


func _hex_points(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 6:
		var angle := deg_to_rad(60.0 * i - 90.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		# TODO: Navegar a pantalla de perfil


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		_hovered = true
		queue_redraw()
	elif what == NOTIFICATION_MOUSE_EXIT:
		_hovered = false
		queue_redraw()
