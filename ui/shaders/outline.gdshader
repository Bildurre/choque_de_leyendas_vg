shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.05, 0.05, 0.1, 0.9);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (col.a < 0.5) {
		vec2 ps = TEXTURE_PIXEL_SIZE * outline_width;
		float a = 0.0;
		a = max(a, texture(TEXTURE, UV + vec2(-ps.x, 0)).a);
		a = max(a, texture(TEXTURE, UV + vec2(ps.x, 0)).a);
		a = max(a, texture(TEXTURE, UV + vec2(0, -ps.y)).a);
		a = max(a, texture(TEXTURE, UV + vec2(0, ps.y)).a);
		a = max(a, texture(TEXTURE, UV + vec2(-ps.x, -ps.y)).a);
		a = max(a, texture(TEXTURE, UV + vec2(ps.x, -ps.y)).a);
		a = max(a, texture(TEXTURE, UV + vec2(-ps.x, ps.y)).a);
		a = max(a, texture(TEXTURE, UV + vec2(ps.x, ps.y)).a);
		col = vec4(outline_color.rgb, a * outline_color.a);
	}
	COLOR = col;
}
