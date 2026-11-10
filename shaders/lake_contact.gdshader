shader_type canvas_item;
// v0.49.0 · CodexAI. COLOR already contains the sampled atlas and node tint.
uniform float warmth = 0.0;
void fragment() {
	COLOR.rgb *= mix(vec3(0.88,0.94,1.04),vec3(0.99,0.97,1.06),warmth);
}
