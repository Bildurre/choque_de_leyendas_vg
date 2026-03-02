## Gestiona el modo de visualización (desktop / móvil).
## Permite alternar entre ambos modos redimensionando la ventana
## y el viewport, y cargando la escena home correspondiente.
extends Node

enum Mode { DESKTOP, MOBILE }

const DESKTOP_VIEWPORT := Vector2i(1920, 1080)
const MOBILE_VIEWPORT := Vector2i(330, 800)
const MOBILE_WINDOW := Vector2i(412, 890)

const HOME_DESKTOP := "res://screens/home/home_desktop.tscn"
const HOME_MOBILE := "res://screens/home/home_mobile.tscn"

var current_mode := Mode.DESKTOP


## Devuelve la ruta de la escena home según el modo actual.
func get_home_scene() -> String:
	if current_mode == Mode.MOBILE:
		return HOME_MOBILE
	return HOME_DESKTOP


## Alterna entre desktop y móvil, recargando la escena home.
func switch_mode() -> void:
	if current_mode == Mode.DESKTOP:
		_activate_mobile()
	else:
		_activate_desktop()


func _activate_mobile() -> void:
	current_mode = Mode.MOBILE
	get_viewport().content_scale_size = MOBILE_VIEWPORT
	var win := get_window()
	if win.mode != Window.MODE_WINDOWED:
		win.mode = Window.MODE_WINDOWED
	win.size = MOBILE_WINDOW
	var screen_size := DisplayServer.screen_get_size()
	win.position = (screen_size - MOBILE_WINDOW) / 2
	get_tree().change_scene_to_file(HOME_MOBILE)


func _activate_desktop() -> void:
	current_mode = Mode.DESKTOP
	get_viewport().content_scale_size = DESKTOP_VIEWPORT
	get_window().mode = Window.MODE_MAXIMIZED
	get_tree().change_scene_to_file(HOME_DESKTOP)
