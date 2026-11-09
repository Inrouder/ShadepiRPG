shader_type canvas_item;
render_mode unshaded;
// v0.44.0 · CodexAI. Anchored boot occlusion on the existing wet roof pixels.
uniform vec4 feet[4]; // centre in menu pixels, half width, half height
void fragment() {
	vec2 p = floor(UV * vec2(640.0, 360.0) * 2.0) * 0.5;
	float opacity = 0.0;
	for (int i = 0; i < 4; i++) {
		vec2 local = p - feet[i].xy;
		float soft = length(local / (feet[i].zw * vec2(1.9, 2.3)));
		float sole = length(local / feet[i].zw);
		float penumbra = (1.0 - smoothstep(0.24, 1.0, soft)) * 0.35;
		float contact = (1.0 - smoothstep(0.58, 1.05, sole)) * 0.72;
		float value = 1.0 - (1.0 - penumbra) * (1.0 - contact);
		opacity = 1.0 - (1.0 - opacity) * (1.0 - value);
	}
	// Front lip must remain illuminated: no shadow hanging down the facade.
	float roof = 1.0 - smoothstep(337.0 - p.x * 0.10, 339.0 - p.x * 0.10, p.y);
	COLOR = vec4(0.006, 0.011, 0.025, opacity * roof);
}
