## Gestiona los cursores personalizados del juego.
## Usa un cursor por software (CanvasLayer) para que los tooltips
## se rendericen por encima del cursor. Cuando hay un popup abierto
## (sub-window embebida) cambia a cursor por hardware para que se
## vea por encima del desplegable.
## Oculta el cursor mientras un tooltip es visible.
extends Node

const CURSOR_DEFAULT := preload("res://assets/cursors/sword_default.svg")
const CURSOR_POINTER := preload("res://assets/cursors/sword_pointer.svg")

## Hotspot en la punta de la espada (esquina superior izquierda tras el flip).
const HOTSPOT := Vector2(1, 1)

var _canvas_layer: CanvasLayer
var _cursor_sprite: TextureRect
var _current_shape: int = -1
var _empty_cursor: ImageTexture
var _popup_open := false

## Tooltip tracking.
var _tooltip_hover_time := 0.0
var _tooltip_showing := false
var _tooltip_control: Control = null


func _ready() -> void:
	# Cursor OS invisible (1x1 transparente) — el visible es por software.
	var empty := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	_empty_cursor = ImageTexture.create_from_image(empty)
	Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
	Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_POINTING_HAND, Vector2.ZERO)

	# Crear cursor por software en capa alta (tooltips se renderizan por encima).
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	add_child(_canvas_layer)

	_cursor_sprite = TextureRect.new()
	_cursor_sprite.texture = CURSOR_DEFAULT
	_cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_layer.add_child(_cursor_sprite)


func _process(delta: float) -> void:
	_cursor_sprite.position = get_viewport().get_mouse_position() - HOTSPOT

	# --- Tooltip: ocultar cursor mientras el tooltip es visible ---
	if not _popup_open:
		var hovered := get_viewport().gui_get_hovered_control()
		var has_tooltip := hovered != null and _control_has_tooltip(hovered)

		if has_tooltip:
			if hovered != _tooltip_control:
				_tooltip_control = hovered
				_tooltip_hover_time = 0.0
			_tooltip_hover_time += delta
			var delay: float = ProjectSettings.get_setting(
				"gui/timers/tooltip_delay_sec", 0.5
			)
			if _tooltip_hover_time >= delay and not _tooltip_showing:
				_tooltip_showing = true
				_cursor_sprite.visible = false
		else:
			if _tooltip_showing:
				_tooltip_showing = false
				_cursor_sprite.visible = true
			_tooltip_control = null
			_tooltip_hover_time = 0.0

	# --- Detectar popups (sub-windows embebidas) para cambiar a cursor hardware ---
	var has_popup := get_viewport().get_embedded_subwindows().size() > 0
	if has_popup != _popup_open:
		_popup_open = has_popup
		if has_popup:
			_cursor_sprite.visible = false
			Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CURSOR_ARROW, HOTSPOT)
			Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND, HOTSPOT)
		else:
			_cursor_sprite.visible = not _tooltip_showing
			Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
			Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_POINTING_HAND, Vector2.ZERO)

	# --- Forma del cursor ---
	var shape := DisplayServer.cursor_get_shape()
	if shape != _current_shape:
		_current_shape = shape
		if shape == DisplayServer.CURSOR_POINTING_HAND:
			_cursor_sprite.texture = CURSOR_POINTER
		else:
			_cursor_sprite.texture = CURSOR_DEFAULT


## Comprueba si un control (o alguno de sus ancestros) tiene tooltip.
func _control_has_tooltip(control: Control) -> bool:
	var current := control
	while current:
		if current.tooltip_text != "":
			return true
		current = current.get_parent() as Control
	return false
