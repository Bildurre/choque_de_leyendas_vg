## Boton de ajustes con icono de engranaje. Sin fondo, solo el icono.
## En hover: rotacion continua del engranaje.
class_name SettingsButton
extends TextureButton

## Tamanio del icono (ancho y alto).
@export var icon_size: float = 32.0

var _tween: Tween


func _ready() -> void:
	stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = Vector2(icon_size, icon_size)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	resized.connect(_update_pivot)
	_update_pivot()

	mouse_entered.connect(_on_hover_entered)
	mouse_exited.connect(_on_hover_exited)

	# Ligeramente transparente en estado normal
	modulate = Color(1, 1, 1, 0.7)


func _update_pivot() -> void:
	pivot_offset = size / 2.0


func _on_hover_entered() -> void:
	if _tween:
		_tween.kill()
	modulate = Color.WHITE
	_tween = create_tween().set_loops()
	_tween.tween_property(self, "rotation", rotation + TAU, 3.0)


func _on_hover_exited() -> void:
	if _tween:
		_tween.kill()
	modulate = Color(1, 1, 1, 0.7)
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "rotation", 0.0, 0.3)
