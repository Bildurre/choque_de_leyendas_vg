## Barra superior con informacion del perfil del jugador.
## Muestra nombre de usuario, barra de XP, boton hexagonal de perfil y nivel.
## Incluye boton de retroceso (oculto por defecto) en la parte izquierda.
extends PanelContainer

signal back_pressed

## Mostrar u ocultar el boton de retroceso. Oculto en el menu principal.
@export var show_back_button: bool = false:
	set(value):
		show_back_button = value
		if is_node_ready():
			%BackArrow.visible = value


func _ready() -> void:
	%BackArrow.visible = show_back_button
	%BackArrow.pressed.connect(func(): back_pressed.emit())
	%BackArrow.mouse_entered.connect(func(): %BackArrow.modulate = Color.WHITE)
	%BackArrow.mouse_exited.connect(func(): %BackArrow.modulate = Color(1, 1, 1, 0.7))
