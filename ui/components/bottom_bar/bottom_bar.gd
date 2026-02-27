## Barra inferior con boton de ajustes y monedas del jugador.
## El engranaje abre directamente el modal de opciones sobre cualquier pantalla.
extends PanelContainer

var _settings_modal: SettingsModal


func _ready() -> void:
	%SettingsButton.pressed.connect(open_settings)


func has_modal_open() -> bool:
	return _settings_modal != null


func open_settings() -> void:
	if _settings_modal:
		return
	_settings_modal = SettingsModal.new()
	_settings_modal.closed.connect(_on_settings_closed)
	add_child(_settings_modal)


func _on_settings_closed() -> void:
	_settings_modal = null
