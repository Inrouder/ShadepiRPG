shader_type canvas_item;
render_mode unshaded;
uniform float clock = 0.0;
uniform float strength = 1.0;
// v0.44.1 · CodexAI. The painted wet-floor highlight cannot pass through boots.
uniform vec4 boot_contacts[4];
uniform float contact_reflections = 1.0;

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
	// City TextureRect is enlarged/offset; feet are registered in menu coordinates.
	vec2 p = floor((UV * vec2(660.0, 372.0) - vec2(10.0, 6.0)) * 2.0) * 0.5;
	float blocked = 0.0;
	for (int i = 0; i < 4; i++) {
		vec2 local = p - boot_contacts[i].xy - vec2(0.0, -1.5);
		float distance_to_sole = length(local / vec2(boot_contacts[i].z * 1.9, 10.0));
		blocked = max(blocked, 1.0 - smoothstep(0.32, 1.0, distance_to_sole));
	}
	float floor_mask = 1.0 - smoothstep(337.0 - p.x * 0.10, 339.0 - p.x * 0.10, p.y);
	// Cap the local highlight, preserving the source's material texture/colour.
	float peak = max(base.r, max(base.g, base.b));
	float diffuse_gain = min(1.0, 0.14 / max(peak, 0.001));
	base.rgb *= mix(1.0, diffuse_gain, blocked * floor_mask * contact_reflections);
	COLOR = base;
}
