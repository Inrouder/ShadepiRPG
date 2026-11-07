shader_type canvas_item;
render_mode unshaded;

uniform float clock = 0.0;
uniform float strength = 1.0;
void vertex() {
	// Vertex colors contain authored hair/cloth weights, not a color tint.
	float hair = COLOR.r;
	float cloth = COLOR.g;
	COLOR = vec4(1.0);
	float breeze = 0.72 + 0.28 * sin(clock * 0.65);
	float wave = sin(clock * 2.1 - UV.y * 13.0 + UV.x * 7.0);
	float flutter = sin(clock * 3.7 - UV.y * 21.0);
	float wind = strength * breeze;
	VERTEX.x += wind * (hair * (-1.4 + 2.8 * wave) + cloth * (-0.8 + 1.9 * wave));
	VERTEX.y += wind * (hair * (0.7 * wave + 0.3 * flutter) + cloth * (0.75 * wave));
}

void fragment() {
	COLOR = texture(TEXTURE, UV) * vec4(0.93, 0.97, 1.0, 1.0);
}
