shader_type canvas_item;
render_mode unshaded;

uniform sampler2D alley_art : source_color, filter_linear;
uniform float west_height_offset = 12.0;

void fragment() {
	// Cover the 640px western street plus a 64px overlap into the alley.
	float world_x = UV.x * 704.0 - 640.0;
	vec2 market_uv = vec2(1.0 - abs(world_x) / 640.0,
		clamp(UV.y - west_height_offset / 640.0, 0.0, 1.0));
	vec2 alley_uv = vec2(abs(world_x) / 1024.0, UV.y);
	vec4 market = texture(TEXTURE, market_uv);
	vec4 alley = texture(alley_art, alley_uv);
	COLOR = mix(market, alley, smoothstep(-48.0, 48.0, world_x));
}
