## Logica compartida de la pantalla principal (Home).
## Se usa tanto en la version desktop como mobile.
## Conecta las senales de los botones y gestiona la navegacion.
extends Control

const LOGO_PATH := "res://assets/logos/%s/logo_full_light.svg"


func _ready() -> void:
	_connect_button("CollectionButton", _on_collection_pressed)
	_connect_button("PlayButton", _on_play_pressed)
	_connect_button("DecksButton", _on_decks_pressed)
	_connect_button("ShopButton", _on_shop_pressed)
	_connect_button("MissionsButton", _on_missions_pressed)
	_connect_button("SocialButton", _on_social_pressed)
	_connect_button("FriendsButton", _on_friends_pressed)
	_update_logo()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_logo()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not %BottomBar.has_modal_open():
		%BottomBar.open_settings()
		get_viewport().set_input_as_handled()


func _connect_button(button_name: String, callback: Callable) -> void:
	var button := get_node_or_null("%" + button_name) as BaseButton
	if button:
		button.pressed.connect(callback)


func _update_logo() -> void:
	var locale := TranslationServer.get_locale()
	var tex := load(LOGO_PATH % locale)
	if tex:
		%Logo.texture = tex


func _on_collection_pressed() -> void:
	print("[Home] Collection pressed")


func _on_play_pressed() -> void:
	print("[Home] Play pressed")


func _on_decks_pressed() -> void:
	print("[Home] Decks pressed")


func _on_shop_pressed() -> void:
	print("[Home] Shop pressed")


func _on_missions_pressed() -> void:
	print("[Home] Missions pressed")


func _on_social_pressed() -> void:
	print("[Home] Social pressed")


func _on_friends_pressed() -> void:
	print("[Home] Friends pressed")
