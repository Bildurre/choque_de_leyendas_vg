## Botón rectangular tipo tarjeta con imagen de fondo en blanco y negro tintada.
## Mantiene aspect ratio 5:7 (ancho:alto) de forma responsiva.
## En hover solo se hace zoom en la imagen de fondo.
class_name MenuCardButton
extends Button

## Color del borde, tinte de la imagen y outline del texto.
@export var accent_color: Color = GameColors.COLOR_GREEN

## Textura de fondo (se muestra en escala de grises con el tinte del accent_color).
@export var background_texture: Texture2D

## Grosor del borde.
@export var border_width: int = 3

## Radio de las esquinas redondeadas.
@export var corner_radius: int = 12

## Tamanio de fuente del label.
@export var label_font_size: int = 48

## Mantener aspect ratio 5:7. Desactivar para layouts libres.
@export var keep_aspect_ratio: bool = true

const ASPECT_RATIO := 5.0 / 7.0
const FONT_PATH := "res://assets/fonts/imfellenglish/IMFellEnglish-Regular.ttf"
const SHADER_PATH := "res://ui/shaders/grayscale_tint.gdshader"
const ZOOM_NORMAL := 1.0
const ZOOM_HOVER := 1.08

var _bg: TextureRect
var _shader_mat: ShaderMaterial
var _tween: Tween


func _ready() -> void:
	expand_icon = false
	alignment = HORIZONTAL_ALIGNMENT_CENTER

	var font := load(FONT_PATH) as Font
	if font:
		add_theme_font_override("font", font)
	add_theme_font_size_override("font_size", label_font_size)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 12)

	_setup_styles()
	_setup_background()
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(_on_resized)
	mouse_entered.connect(_on_hover_entered)
	mouse_exited.connect(_on_hover_exited)
	call_deferred("_on_resized")


func _setup_styles() -> void:
	var style := _make_style(Color(0.08, 0.08, 0.08, 0.5), accent_color, border_width)

	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _setup_background() -> void:
	if not background_texture:
		return

	var shader := load(SHADER_PATH) as Shader
	if not shader:
		return

	_shader_mat = ShaderMaterial.new()
	_shader_mat.shader = shader
	_shader_mat.set_shader_parameter("tint_color", accent_color)
	_shader_mat.set_shader_parameter("corner_radius", float(corner_radius))
	_shader_mat.set_shader_parameter("zoom", ZOOM_NORMAL)

	_bg = TextureRect.new()
	_bg.texture = background_texture
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.material = _shader_mat
	_bg.show_behind_parent = true
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)


func _make_style(bg: Color, border: Color, bw: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(corner_radius)
	s.border_color = border
	s.set_border_width_all(bw)
	return s


func _on_resized() -> void:
	if keep_aspect_ratio:
		var target_w := size.y * ASPECT_RATIO
		if abs(custom_minimum_size.x - target_w) > 1.0:
			custom_minimum_size.x = target_w

	if _shader_mat:
		_shader_mat.set_shader_parameter("rect_size", size)


func _on_hover_entered() -> void:
	if not _shader_mat:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(_set_zoom, _get_zoom(), ZOOM_HOVER, 0.3)


func _on_hover_exited() -> void:
	if not _shader_mat:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(_set_zoom, _get_zoom(), ZOOM_NORMAL, 0.3)


func _set_zoom(value: float) -> void:
	_shader_mat.set_shader_parameter("zoom", value)


func _get_zoom() -> float:
	return _shader_mat.get_shader_parameter("zoom")
