## Gestiona los cursores personalizados del juego.
## Usa un cursor por software (CanvasLayer) para que los tooltips
## se rendericen por encima del cursor. Cuando hay un popup abierto
## (sub-window embebida) cambia a cursor por hardware para que se
## vea por encima del desplegable.
## Gestiona también un tooltip propio para controlar su posición.
extends Node

const CURSOR_DEFAULT := preload("res://assets/cursors/sword_default.svg")
const CURSOR_POINTER := preload("res://assets/cursors/sword_pointer.svg")

## Hotspot en la punta de la espada (esquina superior izquierda tras el flip).
const HOTSPOT := Vector2(1, 1)

## Retardo antes de mostrar el tooltip (segundos).
const TOOLTIP_DELAY := 0.5

## Margen entre el tooltip y el cursor.
const TOOLTIP_GAP := 6.0

var _canvas_layer: CanvasLayer
var _cursor_sprite: TextureRect
var _current_shape: int = -1
var _empty_cursor: ImageTexture
var _popup_open := false

# Tooltip propio.
var _tooltip_layer: CanvasLayer
var _tooltip_panel: PanelContainer
var _tooltip_label: Label
var _tooltip_hover_time: float = 0.0
var _tooltip_control: Control = null
var _tooltip_visible := false


func _ready() -> void:
	# Cursor OS invisible (1x1 transparente) — el visible es por software.
	var empty := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	_empty_cursor = ImageTexture.create_from_image(empty)
	Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
	Input.set_custom_mouse_cursor(_empty_cursor, Input.CURSOR_POINTING_HAND, Vector2.ZERO)

	# Suprimir el tooltip nativo de Godot (delay infinito).
	ProjectSettings.set_setting("gui/timers/tooltip_delay_sec", 9999.0)

	# Crear cursor por software en capa alta.
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	add_child(_canvas_layer)

	_cursor_sprite = TextureRect.new()
	_cursor_sprite.texture = CURSOR_DEFAULT
	_cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_layer.add_child(_cursor_sprite)

	# Tooltip propio en capa justo debajo del cursor.
	_tooltip_layer = CanvasLayer.new()
	_tooltip_layer.layer = 99
	add_child(_tooltip_layer)

	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.theme = preload("res://assets/theme/game_theme.tres")
	_tooltip_panel.theme_type_variation = &"TooltipPanel"
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.visible = false
	_tooltip_layer.add_child(_tooltip_panel)

	_tooltip_label = Label.new()
	_tooltip_label.theme_type_variation = &"TooltipLabel"
	_tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.add_child(_tooltip_label)


func _process(delta: float) -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	_cursor_sprite.position = mouse_pos - HOTSPOT

	# --- Tooltip propio ---
	_update_tooltip(delta, mouse_pos)

	# --- Detectar popups (sub-windows embebidas) para cambiar a cursor hardware ---
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

	# --- Forma del cursor ---
	var shape := DisplayServer.cursor_get_shape()
	if shape != _current_shape:
		_current_shape = shape
		if shape == DisplayServer.CURSOR_POINTING_HAND:
			_cursor_sprite.texture = CURSOR_POINTER
		else:
			_cursor_sprite.texture = CURSOR_DEFAULT


## Actualiza el estado del tooltip propio: delay, texto, visibilidad y posición.
func _update_tooltip(delta: float, mouse_pos: Vector2) -> void:
	if _popup_open:
		_hide_tooltip()
		return

	var hovered := get_viewport().gui_get_hovered_control()
	var text := _get_tooltip_text(hovered)

	if text == "":
		_hide_tooltip()
		return

	# Nuevo control → reiniciar delay.
	if hovered != _tooltip_control:
		_tooltip_control = hovered
		_tooltip_hover_time = 0.0
		_tooltip_visible = false
		_tooltip_panel.visible = false

	_tooltip_hover_time += delta

	if _tooltip_hover_time >= TOOLTIP_DELAY:
		if not _tooltip_visible:
			_tooltip_visible = true
			_tooltip_label.text = tr(text)
			_tooltip_panel.reset_size()
			_tooltip_panel.visible = true
		_position_tooltip(mouse_pos)


func _hide_tooltip() -> void:
	if _tooltip_visible:
		_tooltip_visible = false
		_tooltip_panel.visible = false
	_tooltip_control = null
	_tooltip_hover_time = 0.0


## Posiciona el tooltip: arriba del cursor por defecto;
## si no cabe, debajo con offset completo del cursor.
func _position_tooltip(mouse_pos: Vector2) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var cursor_h: float = 52.0
	if _cursor_sprite.texture:
		cursor_h = float(_cursor_sprite.texture.get_height())
	var tp_size := _tooltip_panel.get_combined_minimum_size()

	# Intentar arriba del cursor.
	var y: float = mouse_pos.y - tp_size.y - TOOLTIP_GAP
	if y < 0.0:
		# No cabe arriba → colocar debajo del cursor.
		y = mouse_pos.y + cursor_h + TOOLTIP_GAP

	# Horizontal: centrado respecto al ratón, clampeado al viewport.
	var x: float = mouse_pos.x - tp_size.x * 0.5
	x = clampf(x, 0.0, vp_size.x - tp_size.x)
	y = clampf(y, 0.0, vp_size.y - tp_size.y)

	_tooltip_panel.position = Vector2(x, y)


## Devuelve el tooltip_text del control o de su ancestro más cercano.
func _get_tooltip_text(control: Control) -> String:
	if control == null:
		return ""
	var current := control
	while current:
		if current.tooltip_text != "":
			return current.tooltip_text
		current = current.get_parent() as Control
	return ""
