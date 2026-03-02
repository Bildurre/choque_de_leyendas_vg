## Pantalla de opciones de Gráficos.
## Permite cambiar la resolución de la ventana con confirmación temporal.
extends Control

const HOME_SCENE := "res://screens/home/home_desktop.tscn"

## Resoluciones disponibles (ancho × alto).
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

## Segundos para confirmar antes de revertir.
const CONFIRM_TIMEOUT := 10

var _chevron: TextureRect
var _previous_size: Vector2i
var _previous_index: int = -1

## Overlay de confirmacion.
var _confirm_layer: CanvasLayer
var _confirm_backdrop: ColorRect
var _confirm_panel: PanelContainer
var _countdown_label: Label
var _seconds_left: int = CONFIRM_TIMEOUT
var _timer: Timer


func _ready() -> void:
	%ResolutionSelector.item_selected.connect(_on_resolution_selected)
	%TopBar.back_pressed.connect(_on_back_pressed)

	_populate_resolutions()
	_style_option_button(%ResolutionSelector)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not %BottomBar.has_modal_open():
		get_viewport().set_input_as_handled()
		_on_back_pressed()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)


# ── Resolución ────────────────────────────────────────────────────────────────

func _populate_resolutions() -> void:
	var btn := %ResolutionSelector as OptionButton
	btn.clear()
	var current_size := DisplayServer.window_get_size()
	var selected_idx := 0

	for i in RESOLUTIONS.size():
		var res := RESOLUTIONS[i]
		btn.add_item("%d × %d" % [res.x, res.y], i)
		if res == current_size:
			selected_idx = i

	btn.selected = selected_idx
	_previous_index = selected_idx
	_previous_size = current_size


func _on_resolution_selected(index: int) -> void:
	if index == _previous_index:
		return

	var res := RESOLUTIONS[index]
	_apply_resolution(res)
	_show_confirm_dialog(index)


func _apply_resolution(res: Vector2i) -> void:
	var win := get_window()
	# Forzar modo ventana (no maximizado/fullscreen) para poder redimensionar.
	if win.mode != Window.MODE_WINDOWED:
		win.mode = Window.MODE_WINDOWED
	win.size = res
	# Centrar la ventana en la pantalla.
	var screen_size := DisplayServer.screen_get_size()
	win.position = (screen_size - res) / 2


# ── Dialogo de confirmación ───────────────────────────────────────────────────

func _show_confirm_dialog(new_index: int) -> void:
	_seconds_left = CONFIRM_TIMEOUT

	if _confirm_layer:
		_update_countdown_text()
		return

	# CanvasLayer para estar encima de todo.
	_confirm_layer = CanvasLayer.new()
	_confirm_layer.layer = 50
	add_child(_confirm_layer)

	# Backdrop oscuro.
	_confirm_backdrop = ColorRect.new()
	_confirm_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_confirm_backdrop.color = Color(0.0, 0.0, 0.0, 0.7)
	_confirm_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_confirm_layer.add_child(_confirm_backdrop)

	# Centrado.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_confirm_backdrop.add_child(center)

	# Panel.
	_confirm_panel = PanelContainer.new()
	_confirm_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.08, 1.0)
	style.set_corner_radius_all(16)
	style.border_color = GameColors.COLOR_PURPLE
	style.set_border_width_all(2)
	style.shadow_color = Color(GameColors.COLOR_PURPLE, 0.4)
	style.shadow_size = 12
	style.content_margin_left = 48.0
	style.content_margin_right = 48.0
	style.content_margin_top = 40.0
	style.content_margin_bottom = 40.0
	_confirm_panel.add_theme_stylebox_override("panel", style)
	center.add_child(_confirm_panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	_confirm_panel.add_child(vbox)

	# Titulo.
	var font := load("res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf") as Font
	var title := Label.new()
	title.text = "GRAPHICS_CONFIRM_TITLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font:
		title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 8)
	vbox.add_child(title)

	# Cuenta atrás.
	_countdown_label = Label.new()
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if font:
		_countdown_label.add_theme_font_override("font", font)
	_countdown_label.add_theme_font_size_override("font_size", 24)
	_countdown_label.add_theme_color_override("font_color", GameColors.COLOR_TEXT_LIGHT_DIM)
	_countdown_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_countdown_label.add_theme_constant_override("outline_size", 4)
	_update_countdown_text()
	vbox.add_child(_countdown_label)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8.0
	vbox.add_child(spacer)

	# Botones.
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 24)
	vbox.add_child(hbox)

	var keep_btn := Button.new()
	keep_btn.text = "GRAPHICS_KEEP"
	keep_btn.script = load("res://ui/components/buttons/menu_option_button.gd")
	keep_btn.pressed.connect(_on_keep_pressed)
	hbox.add_child(keep_btn)

	var revert_btn := Button.new()
	revert_btn.text = "GRAPHICS_REVERT"
	revert_btn.script = load("res://ui/components/buttons/menu_option_button.gd")
	revert_btn.pressed.connect(_on_revert_pressed)
	hbox.add_child(revert_btn)

	# Timer de cuenta atrás.
	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.timeout.connect(_on_countdown_tick)
	add_child(_timer)
	_timer.start()


func _update_countdown_text() -> void:
	_countdown_label.text = tr("GRAPHICS_CONFIRM_MSG") % _seconds_left


func _on_countdown_tick() -> void:
	_seconds_left -= 1
	if _seconds_left <= 0:
		_on_revert_pressed()
		return
	_update_countdown_text()


func _on_keep_pressed() -> void:
	_previous_index = %ResolutionSelector.selected
	_previous_size = RESOLUTIONS[_previous_index]
	_close_confirm_dialog()


func _on_revert_pressed() -> void:
	_apply_resolution(_previous_size)
	%ResolutionSelector.selected = _previous_index
	_close_confirm_dialog()


func _close_confirm_dialog() -> void:
	if _timer:
		_timer.stop()
		_timer.queue_free()
		_timer = null
	if _confirm_layer:
		_confirm_layer.queue_free()
		_confirm_layer = null


# ── Estilo del OptionButton (mismo que game_settings) ─────────────────────────

func _style_option_button(btn: OptionButton) -> void:
	var chevron_size := 20.0
	var chevron_pad := 4.0
	var extra_right := chevron_size + chevron_pad * 2

	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = 8.0
	empty.content_margin_right = extra_right
	empty.content_margin_top = 6.0
	empty.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 1.0, 1.0, 0.06)
	hover.set_corner_radius_all(4)
	hover.content_margin_left = 8.0
	hover.content_margin_right = extra_right
	hover.content_margin_top = 6.0
	hover.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("hover", hover)

	# Ocultar flecha nativa del OptionButton.
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	btn.add_theme_icon_override("arrow", ImageTexture.create_from_image(img))
	btn.add_theme_constant_override("arrow_margin", 0)

	# Chevron animado como hijo del boton.
	_chevron = TextureRect.new()
	_chevron.texture = load("res://assets/icons/placeholder/chevron_down.svg")
	_chevron.custom_minimum_size = Vector2(chevron_size, chevron_size)
	_chevron.size = Vector2(chevron_size, chevron_size)
	_chevron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_chevron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_chevron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chevron.modulate = Color(0.85, 0.85, 0.85, 1)
	_chevron.pivot_offset = Vector2(chevron_size / 2.0, chevron_size / 2.0)
	btn.add_child(_chevron)
	_chevron.anchor_left = 1.0
	_chevron.anchor_right = 1.0
	_chevron.anchor_top = 0.5
	_chevron.anchor_bottom = 0.5
	_chevron.offset_left = -(chevron_size + chevron_pad)
	_chevron.offset_right = -chevron_pad
	_chevron.offset_top = -(chevron_size / 2.0)
	_chevron.offset_bottom = chevron_size / 2.0

	# Style the popup dropdown.
	var popup := btn.get_popup()
	_strip_popup_checks(popup)
	popup.about_to_popup.connect(_strip_popup_checks.bind(popup))
	popup.about_to_popup.connect(_on_selector_opened)
	popup.popup_hide.connect(_on_selector_closed)

	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	panel.set_corner_radius_all(6)
	panel.border_color = Color(0.3, 0.3, 0.3, 0.3)
	panel.set_border_width_all(1)
	panel.content_margin_left = 4.0
	panel.content_margin_right = 4.0
	panel.content_margin_top = 4.0
	panel.content_margin_bottom = 4.0
	popup.add_theme_stylebox_override("panel", panel)

	var popup_normal := StyleBoxEmpty.new()
	popup_normal.content_margin_left = 12.0
	popup_normal.content_margin_right = 12.0
	popup_normal.content_margin_top = 8.0
	popup_normal.content_margin_bottom = 8.0
	popup.add_theme_stylebox_override("normal", popup_normal)

	var popup_hover := StyleBoxFlat.new()
	popup_hover.bg_color = Color(0.478, 0.392, 0.784, 0.3)
	popup_hover.set_corner_radius_all(4)
	popup_hover.content_margin_left = 12.0
	popup_hover.content_margin_right = 12.0
	popup_hover.content_margin_top = 8.0
	popup_hover.content_margin_bottom = 8.0
	popup.add_theme_stylebox_override("hover", popup_hover)

	var font := load("res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf")
	if font:
		popup.add_theme_font_override("font", font)
	popup.add_theme_font_size_override("font_size", 22)
	popup.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	popup.add_theme_color_override("font_hover_color", Color.WHITE)


func _on_selector_opened() -> void:
	var tween := create_tween()
	tween.tween_property(_chevron, "rotation", PI, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_selector_closed() -> void:
	var tween := create_tween()
	tween.tween_property(_chevron, "rotation", 0.0, 0.2) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _strip_popup_checks(popup: PopupMenu) -> void:
	for i in popup.item_count:
		popup.set_item_as_radio_checkable(i, false)
