shader_type canvas_item;
render_mode unshaded;
// v0.50.1 · CodexAI. Source-pixel silhouette, foot-anchored world-pixel lattice.
uniform float clock = 0.0;
uniform float cloak = 0.0;
uniform float flash = 0.0;
uniform vec2 actor_origin = vec2(0.0);
uniform vec2 cell_min = vec2(0.0);
uniform vec2 cell_max = vec2(1.0);
uniform vec2 source_step = vec2(1.0);
varying vec2 avatar_pixel;
void vertex() {
	avatar_pixel = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy - actor_origin;
}
float inside_cell(vec2 uv) {
	// Never read another animation cell when tracing the silhouette edge.
	float inside = step(cell_min.x, uv.x) * step(cell_min.y, uv.y)
		* step(uv.x, cell_max.x) * step(uv.y, cell_max.y);
	return inside;
}
void fragment() {
	vec4 source = COLOR;
	vec2 offset = TEXTURE_PIXEL_SIZE * source_step;
	float a = texture(TEXTURE, UV).a;
	vec2 left = UV - vec2(offset.x, 0.0);
	vec2 right = UV + vec2(offset.x, 0.0);
	vec2 up = UV - vec2(0.0, offset.y);
	vec2 down = UV + vec2(0.0, offset.y);
	float neighbour = min(min(texture(TEXTURE, clamp(left, cell_min, cell_max)).a * inside_cell(left),
		texture(TEXTURE, clamp(right, cell_min, cell_max)).a * inside_cell(right)),
		min(texture(TEXTURE, clamp(up, cell_min, cell_max)).a * inside_cell(up),
		texture(TEXTURE, clamp(down, cell_min, cell_max)).a * inside_cell(down)));
	float edge = smoothstep(0.03, 0.32, a - neighbour);
	vec2 pixel = floor(avatar_pixel);
	vec2 grid = vec2(1.0) - step(vec2(1.0), mod(pixel, vec2(4.0)));
	float wire = max(grid.x, grid.y);
	float scan = 1.0 - step(1.0, abs(pixel.y - (mod(clock * 19.0, 78.0) - 76.0)));
	float detail = dot(source.rgb, vec3(0.21, 0.72, 0.07));
	vec3 cyan = mix(vec3(0.03, 0.20, 0.31), vec3(0.16, 0.90, 1.14), wire);
	cyan *= 0.83 + detail * 0.42;
	cyan = mix(cyan, vec3(0.40, 1.10, 1.30), max(edge * 0.9, scan * 0.75));
	cyan = mix(cyan, vec3(1.0, 0.68, 0.88), flash);
	float coverage = max(max(wire * 0.80, edge * 0.94), scan * 0.65);
	// The open cells are translucent; no lines can escape the actual sprite alpha.
	COLOR = vec4(cyan, source.a * (0.065 + coverage) * mix(1.0, 0.45, cloak));
}
