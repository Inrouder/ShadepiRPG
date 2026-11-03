shader_type canvas_item;
render_mode unshaded;
uniform float opacity = 0.45;
void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	COLOR = vec4(0.015, 0.025, 0.055, alpha * opacity);
}
