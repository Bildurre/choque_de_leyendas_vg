shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float corner_radius = 12.0;
uniform vec2 rect_size = vec2(200.0, 280.0);
uniform float zoom = 1.0;

void fragment() {
	vec2 zoomed_uv = (UV - 0.5) / zoom + 0.5;
	vec4 tex = texture(TEXTURE, zoomed_uv);
	float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));

	COLOR = vec4(vec3(gray) * tint_color.rgb, tex.a);

	// Round corner masking
	vec2 pixel = UV * rect_size;
	vec2 from_corner = min(pixel, rect_size - pixel);
	if (from_corner.x < corner_radius && from_corner.y < corner_radius) {
		float dist = length(vec2(corner_radius) - from_corner);
		COLOR.a *= 1.0 - smoothstep(corner_radius - 1.0, corner_radius, dist);
	}
}
