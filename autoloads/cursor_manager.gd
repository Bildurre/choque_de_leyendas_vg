## Gestiona los cursores personalizados del juego.
## Reemplaza el cursor por defecto y el de mano con espadas custom.
extends Node

const CURSOR_DEFAULT := preload("res://assets/cursors/sword_default.svg")
const CURSOR_POINTER := preload("res://assets/cursors/sword_pointer.svg")

## Hotspot en la punta de la espada (esquina superior izquierda tras el flip).
const HOTSPOT := Vector2(1, 1)


func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR_DEFAULT, Input.CURSOR_ARROW, HOTSPOT)
	Input.set_custom_mouse_cursor(CURSOR_POINTER, Input.CURSOR_POINTING_HAND, HOTSPOT)
