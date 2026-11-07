shader_type canvas_item;
// Pixelated, tinted copy of the live scene behind Raven's terminals, so every
// interface sits visibly inside the place where it is used. Whole-pixel mosaic
// and ordered dithering keep it in the game's pixel-art style (no soft blur).
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec4 tint : source_color = vec4(0.02, 0.05, 0.09, 0.78);
uniform vec4 glow : source_color = vec4(0.38, 0.89, 0.93, 1.0);
uniform float block = 4.0;
uniform float scanlines = 0.18;
uniform float time_scale = 1.0;

float bayer4(vec2 p) {
	ivec2 i = ivec2(mod(p, 4.0));
	int index = i.x + i.y * 4;
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return (float(m[index]) + 0.5) / 16.0;
}

void fragment() {
	vec2 pixel = floor(FRAGCOORD.xy);
	vec2 cell = (floor(pixel / block) + 0.5) * block;
	vec3 scene = texture(screen_texture, cell * SCREEN_PIXEL_SIZE).rgb;
	// Posterise the scene into a few steps, dithered, then tint.
	float steps = 5.0;
	scene = floor(scene * steps + bayer4(pixel)) / steps;
	vec3 color = mix(scene, tint.rgb, tint.a);
	color *= 1.0 - scanlines * step(1.0, mod(pixel.y, 2.0));
	// A slow scan bar of the target's colour, stepped in 2 px rows.
	float bar = abs(fract(floor(UV.y * 180.0) / 180.0 - TIME * 0.05 * time_scale) - 0.5);
	color += glow.rgb * (bar > 0.485 ? 0.06 : 0.0);
	vec2 centered = UV - 0.5;
	float vignette = dot(centered, centered) * 1.1;
	color *= 1.0 - (vignette > bayer4(pixel + 1.0) * 0.5 + 0.2 ? 0.25 : 0.0) - vignette * 0.4;
	COLOR = vec4(color, 1.0);
}
