## Barra inferior con boton de ajustes y monedas del jugador.
extends PanelContainer

signal settings_pressed


func _ready() -> void:
	%SettingsButton.pressed.connect(func(): settings_pressed.emit())
