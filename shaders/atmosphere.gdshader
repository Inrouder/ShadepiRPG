shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float pixel_scale = 1.0;
uniform float strength = 1.0;
uniform float bloom = 0.3;
uniform bool detailed = true;
uniform vec3 grade_tint = vec3(0.98, 1.01, 1.055);

vec3 bright(vec2 p) {
	vec3 c = texture(screen_texture, p).rgb;
	return c * smoothstep(0.52, 0.95, max(c.r, max(c.g, c.b)));
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 source = texture(screen_texture, uv).rgb;
	vec3 color = source;
	if (strength > 0.0) {
		vec2 step_uv = SCREEN_PIXEL_SIZE * 2.0 * pixel_scale;
		vec3 glow = bright(uv + vec2(step_uv.x, 0.0));
		glow += bright(uv - vec2(step_uv.x, 0.0));
		glow += bright(uv + vec2(0.0, step_uv.y));
		glow += bright(uv - vec2(0.0, step_uv.y));
		if (detailed) {
			glow += bright(uv + step_uv * 2.0);
			glow += bright(uv - step_uv * 2.0);
			glow /= 6.0;
		} else {
			glow /= 4.0;
		}
		color += glow * bloom;
		float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
		color = mix(vec3(luminance), color, 1.10);
		color = (color - 0.4) * 1.05 + 0.4;
		color *= grade_tint;
		vec2 edge = (uv - 0.5) * vec2(1.0, 0.82);
		float vignette = smoothstep(0.25, 0.68, length(edge));
		color *= 1.0 - vignette * 0.28;
		color = mix(source, color, strength);
	}
	COLOR = vec4(max(color, vec3(0.0)), 1.0);
}
