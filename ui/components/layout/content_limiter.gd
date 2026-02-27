## MarginContainer responsivo con ancho maximo de contenido.
## Reduce los margenes laterales hasta un minimo, despues el contenido se encoge.
## Equivalente a CSS: max-width + margin:auto + min-padding.
class_name ContentLimiter
extends MarginContainer

## Ancho maximo del contenido (3/5 de 1920 ≈ 1152).
@export var max_content_width: float = 1152.0

## Margen lateral minimo (mismo que TopBar/BottomBar).
@export var min_margin: float = 32.0

## Margen superior.
@export var margin_top: float = 24.0

## Margen inferior.
@export var margin_bottom: float = 24.0


func _ready() -> void:
	resized.connect(_update_margins)
	_update_margins()


func _update_margins() -> void:
	var available := size.x
	var ideal_margin := (available - max_content_width) / 2.0
	var margin := maxf(ideal_margin, min_margin)
	add_theme_constant_override("margin_left", int(margin))
	add_theme_constant_override("margin_right", int(margin))
	add_theme_constant_override("margin_top", int(margin_top))
	add_theme_constant_override("margin_bottom", int(margin_bottom))
