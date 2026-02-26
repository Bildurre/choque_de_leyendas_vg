## MarginContainer que limita el ancho del contenido a un maximo,
## centrando horizontalmente con margenes dinamicos.
class_name MaxWidthContainer
extends MarginContainer

## Ancho maximo del contenido en pixeles.
@export var max_content_width: int = 1200


func _ready() -> void:
	resized.connect(_update_margins)
	_update_margins()


func _update_margins() -> void:
	var margin := maxi(0, int((size.x - max_content_width) / 2.0))
	add_theme_constant_override("margin_left", margin)
	add_theme_constant_override("margin_right", margin)
