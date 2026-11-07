shader_type canvas_item;
render_mode unshaded;
uniform float clock = 0.0;
uniform float strength = 1.0;
void fragment() {
	vec2 uv = UV;
	// Only wet rooftop reflections ripple. Architecture and roof edges stay fixed.
	float roof = smoothstep(0.78, 0.84, uv.y) * (1.0 - smoothstep(0.43, 0.48, uv.x));
	float edge = 1.0 - smoothstep(0.91 - uv.x * 0.14, 0.95 - uv.x * 0.14, uv.y);
	float ripple = sin(uv.y * 470.0 + clock * 3.1) * sin(uv.x * 210.0 - clock * 1.8);
	vec2 wet_uv = uv + vec2(ripple * 0.00075 * roof * edge * strength, 0.0);
	vec4 base = texture(TEXTURE, wet_uv);
	float neon = max(base.b, base.r) - base.g * 0.65;
	float shimmer = 0.96 + 0.04 * sin(clock * 1.7 + uv.y * 23.0);
	base.rgb += base.rgb * max(neon - 0.15, 0.0) * roof * shimmer * strength * 0.18;
	// Slow atmospheric glow around the white dragon; no geometry warping.
	float sky = (1.0 - smoothstep(0.28, 0.44, uv.y)) * (1.0 - smoothstep(0.50, 0.6, uv.x));
	float bright = smoothstep(0.55, 0.92, max(base.r, max(base.g, base.b)));
	base.rgb += vec3(0.045, 0.075, 0.10) * sky * bright * (0.5 + 0.5 * sin(clock * 0.65)) * strength;
	COLOR = base;
}
