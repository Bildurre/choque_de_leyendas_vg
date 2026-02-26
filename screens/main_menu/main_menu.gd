## Logica compartida del menu principal. Se usa tanto en la version desktop como mobile.
## Conecta las senales de los botones de la barra inferior y gestiona la navegacion.
extends Control


func _ready() -> void:
	_connect_button("ShopButton", _on_shop_pressed)
	_connect_button("MissionsButton", _on_missions_pressed)
	_connect_button("SocialButton", _on_social_pressed)
	_connect_button("FriendsButton", _on_friends_pressed)
	_connect_button("SettingsButton", _on_settings_pressed)


func _connect_button(button_name: String, callback: Callable) -> void:
	var button := get_node_or_null("%" + button_name) as BaseButton
	if button:
		button.pressed.connect(callback)


func _on_shop_pressed() -> void:
	print("[MainMenu] Shop pressed")


func _on_missions_pressed() -> void:
	print("[MainMenu] Missions pressed")


func _on_social_pressed() -> void:
	print("[MainMenu] Social pressed")


func _on_friends_pressed() -> void:
	print("[MainMenu] Friends pressed")


func _on_settings_pressed() -> void:
	print("[MainMenu] Settings pressed")
