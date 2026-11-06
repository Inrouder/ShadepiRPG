shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float clock = 0.0;
uniform float strength = 1.0;
uniform float pulse = 0.0;
uniform vec2 focus = vec2(0.5);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 base = texture(screen_texture, uv).rgb;
	vec2 step_uv = SCREEN_PIXEL_SIZE * 2.0;
	vec3 halo = texture(screen_texture, uv + vec2(step_uv.x, 0.0)).rgb
		+ texture(screen_texture, uv - vec2(step_uv.x, 0.0)).rgb
		+ texture(screen_texture, uv + vec2(0.0, step_uv.y)).rgb
		+ texture(screen_texture, uv - vec2(0.0, step_uv.y)).rgb;
	base += max(halo * 0.25 - vec3(0.42), vec3(0.0)) * 0.22 * strength;
	float clouds = noise(uv * vec2(6.0, 3.0) + vec2(clock * 0.035, 0.0));
	float mist = smoothstep(0.4, 0.9, clouds) * smoothstep(0.42, 0.96, uv.y);
	base = mix(base, vec3(0.19, 0.33, 0.42), mist * 0.16 * strength);
	float lantern = exp(-length((uv - focus) * vec2(1.0, 0.65)) * 5.0);
	base += vec3(0.03, 0.12, 0.14) * lantern * pulse * strength;
	float vignette = smoothstep(0.28, 0.78, length((uv - vec2(0.48, 0.48)) * vec2(0.9, 1.1)));
	base *= 1.0 - vignette * 0.24;
	float grain = (hash(uv * vec2(640.0, 360.0) + floor(clock * 12.0)) - 0.5) * 0.012;
	base += grain * strength;
	COLOR = vec4(base, 1.0);
}
