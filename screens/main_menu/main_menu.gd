## Logica compartida del menu principal. Se usa tanto en la version desktop como mobile.
## Conecta las senales de los botones de la barra inferior y gestiona la navegacion.
extends Control

const SETTINGS_MODAL_PATH := "res://ui/components/modals/settings_modal.gd"

var _settings_modal: SettingsModal


func _ready() -> void:
	_connect_button("CollectionButton", _on_collection_pressed)
	_connect_button("PlayButton", _on_play_pressed)
	_connect_button("DecksButton", _on_decks_pressed)
	_connect_button("ShopButton", _on_shop_pressed)
	_connect_button("MissionsButton", _on_missions_pressed)
	_connect_button("SocialButton", _on_social_pressed)
	_connect_button("FriendsButton", _on_friends_pressed)
	%BottomBar.settings_pressed.connect(_on_settings_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not _settings_modal:
		_open_settings()
		get_viewport().set_input_as_handled()


func _connect_button(button_name: String, callback: Callable) -> void:
	var button := get_node_or_null("%" + button_name) as BaseButton
	if button:
		button.pressed.connect(callback)


func _on_collection_pressed() -> void:
	print("[MainMenu] Collection pressed")


func _on_play_pressed() -> void:
	print("[MainMenu] Play pressed")


func _on_decks_pressed() -> void:
	print("[MainMenu] Decks pressed")


func _on_shop_pressed() -> void:
	print("[MainMenu] Shop pressed")


func _on_missions_pressed() -> void:
	print("[MainMenu] Missions pressed")


func _on_social_pressed() -> void:
	print("[MainMenu] Social pressed")


func _on_friends_pressed() -> void:
	print("[MainMenu] Friends pressed")


func _on_settings_pressed() -> void:
	_open_settings()


func _open_settings() -> void:
	if _settings_modal:
		return
	_settings_modal = SettingsModal.new()
	_settings_modal.closed.connect(_on_settings_closed)
	add_child(_settings_modal)


func _on_settings_closed() -> void:
	_settings_modal = null
