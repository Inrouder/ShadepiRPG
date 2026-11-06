shader_type canvas_item;
render_mode unshaded;

uniform float clock = 0.0;
uniform float strength = 1.0;
uniform float gust = 0.0;

void vertex() {
	// The mesh has enough vertices to bend the free hair and scarf tips while
	// keeping Raven's face, Shadepi's mask and both pairs of boots anchored.
	float hair = smoothstep(0.75, 0.88, UV.x) * smoothstep(0.19, 0.30, UV.y)
		* (1.0 - smoothstep(0.48, 0.57, UV.y));
	float scarf = (1.0 - smoothstep(0.23, 0.36, UV.x)) * smoothstep(0.25, 0.35, UV.y)
		* (1.0 - smoothstep(0.49, 0.58, UV.y));
	float cloth = (1.0 - smoothstep(0.29, 0.39, UV.x)) * smoothstep(0.53, 0.60, UV.y)
		* (1.0 - smoothstep(0.68, 0.74, UV.y)) * smoothstep(0.14, 0.22, UV.x);
	float wave = sin(clock * 2.9 + UV.x * 17.0 - UV.y * 7.0);
	float flutter = sin(clock * 5.1 + UV.x * 28.0);
	float wind = strength * (0.75 + 0.25 * sin(clock * 0.7) + gust * 0.3);
	VERTEX.y += (hair * (wave * 5.0 + flutter * 1.1) + scarf * wave * 3.2 + cloth * wave * 2.0) * wind;
	VERTEX.x += (hair * sin(clock * 2.2 + UV.y * 12.0) * 2.1 - scarf * flutter * 1.3) * wind;
}
