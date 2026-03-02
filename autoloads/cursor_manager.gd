## Gestiona los cursores personalizados del juego.
## Usa un cursor por software (CanvasLayer) para que los tooltips
## se rendericen por encima del cursor. Cuando hay un popup abierto
## (sub-window embebida) cambia a cursor por hardware para que se
## vea por encima del desplegable.
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


func _process(_delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	_cursor_sprite.position = mouse_pos - HOTSPOT

	# Reposicionar tooltip para que no solape con el cursor espada.
	_adjust_tooltip(mouse_pos)

	# Detectar popups (sub-windows embebidas) para cambiar a cursor hardware.
	var has_popup := get_viewport().get_embedded_subwindows().size() > 0
	if has_popup != _popup_open:
		_popup_open = has_popup
		if has_popup:
			_cursor_sprite.visible = false
			Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CURSOR_ARROW, HOTSPOT)
			Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND, HOTSPOT)
		else:
			_cursor_sprite.visible = true
			Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
			Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_POINTING_HAND, Vector2.ZERO)

	var shape := DisplayServer.cursor_get_shape()
	if shape != _current_shape:
		_current_shape = shape
		if shape == DisplayServer.CURSOR_POINTING_HAND:
			_cursor_sprite.texture = CURSOR_POINTER
		else:
			_cursor_sprite.texture = CURSOR_DEFAULT


## Busca el TooltipPanel interno de Godot y lo reposiciona para que
## no solape con el cursor software. Si aparece abajo, lo empuja debajo
## del cursor; si se sale de pantalla, lo sube por encima.
func _adjust_tooltip(mouse_pos: Vector2) -> void:
	var vp := get_viewport()
	var vp_size := vp.get_visible_rect().size
	var cursor_h: float = float(_cursor_sprite.texture.get_height()) if _cursor_sprite.texture else 52.0

	for child in vp.get_children(true):
		if not (child is Control and child.visible):
			continue
		if not child.is_class("TooltipPanel"):
			continue

		var tp := child as Control
		var tp_h: float = tp.size.y

		# Tooltip debajo del cursor → empujar más abajo.
		if tp.position.y >= mouse_pos.y:
			var desired_y: float = mouse_pos.y + cursor_h
			if desired_y + tp_h <= vp_size.y:
				tp.position.y = desired_y
			else:
				# No cabe debajo → mover arriba del cursor.
				tp.position.y = mouse_pos.y - tp_h - 4.0
		else:
			# Tooltip arriba del cursor — asegurar que no se sale por arriba.
			if tp.position.y < 0.0:
				tp.position.y = mouse_pos.y + cursor_h
		break
