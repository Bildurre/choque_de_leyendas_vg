shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 3.0;
uniform vec4 overlay_color : source_color = vec4(0.0, 0.0, 0.0, 0.7);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE * blur_amount;
	vec4 col = vec4(0.0);

	// Kernel 9-tap (horizontal + vertical en una sola pasada)
	float w0 = 0.2270270;
	float w1 = 0.1945946;
	float w2 = 0.1216216;
	float w3 = 0.0540540;
	float w4 = 0.0162162;

	col += texture(screen_texture, SCREEN_UV) * w0;

	for (int i = 1; i <= 4; i++) {
		float w = (i == 1) ? w1 : (i == 2) ? w2 : (i == 3) ? w3 : w4;
		vec2 off_h = vec2(ps.x * float(i), 0.0);
		vec2 off_v = vec2(0.0, ps.y * float(i));
		col += texture(screen_texture, SCREEN_UV + off_h) * w;
		col += texture(screen_texture, SCREEN_UV - off_h) * w;
		col += texture(screen_texture, SCREEN_UV + off_v) * w;
		col += texture(screen_texture, SCREEN_UV - off_v) * w;
	}

	// Mezclar con oscurecimiento
	COLOR = mix(col, overlay_color, overlay_color.a);
}
