shader_type canvas_item;
render_mode unshaded;
// v0.31.0 · CodexAI: only the clipped water surface samples moving source pixels.
uniform float clock = 0.0;
uniform float strength = 0.65;
void fragment() {
	float row = floor(UV.y / TEXTURE_PIXEL_SIZE.y);
	float wave = sin(row * 0.21 - clock * 1.1) + sin(row * 0.071 + clock * 0.6);
	vec2 shift = vec2(floor(wave * strength), 0.0) * TEXTURE_PIXEL_SIZE;
	vec4 source = texture(TEXTURE, UV + shift);
	float gleam = pow(max(0.0, sin(row * 0.16 - clock * 0.9)), 8.0);
	source.rgb += vec3(0.07, 0.14, 0.16) * gleam * strength * 0.13;
	COLOR = source;
}
