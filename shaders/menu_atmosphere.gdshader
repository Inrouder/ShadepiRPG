shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float clock = 0.0;
uniform float strength = 1.0;
uniform float pulse = 0.0;
uniform vec2 focus = vec2(0.5);
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p); f = f*f*(3.0-2.0*f);
	return mix(mix(hash(i), hash(i+vec2(1,0)), f.x), mix(hash(i+vec2(0,1)), hash(i+vec2(1)), f.x), f.y);
}
void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 base = texture(screen_texture, uv).rgb;
	vec2 px = SCREEN_PIXEL_SIZE * 3.0;
	vec3 halo = texture(screen_texture, uv+vec2(px.x,0)).rgb + texture(screen_texture, uv-vec2(px.x,0)).rgb
		+ texture(screen_texture, uv+vec2(0,px.y)).rgb + texture(screen_texture, uv-vec2(0,px.y)).rgb;
	base += max(halo * 0.25 - vec3(0.48), vec3(0)) * 0.23 * strength;
	float scene = 1.0 - smoothstep(0.48, 0.62, uv.x);
	float clouds = noise(uv*vec2(5,3) + vec2(clock*0.028, -clock*0.008));
	clouds += noise(uv*vec2(14,8) - vec2(clock*0.05, 0)) * 0.35;
	float mist = smoothstep(0.45, 1.1, clouds) * smoothstep(0.57, 0.96, uv.y);
	base = mix(base, vec3(0.14, 0.28, 0.36), mist * 0.19 * strength * scene);
	// Faint moving neon shafts passing through rain, under the menu typography.
	float beam = pow(max(0.0, sin(uv.x*21.0 + uv.y*4.0 + clock*0.07)), 16.0);
	base += vec3(0.025, 0.07, 0.09) * beam * clouds * scene * strength;
	// Sparse glass trails, moving down independently of the world rain.
	vec2 grid = vec2(uv.x*37.0, uv.y*8.0 - clock*0.18);
	vec2 cell = floor(grid); vec2 local = fract(grid);
	float seed = hash(cell);
	float trail = exp(-abs(local.x - 0.5) * 110.0) * smoothstep(0.1, 0.9, local.y) * step(0.89, seed);
	base += vec3(0.12, 0.23, 0.29) * trail * scene * strength * 0.32;
	float lantern = exp(-length((uv-focus)*vec2(1,0.65))*5.0);
	base += vec3(0.03,0.12,0.14) * lantern * pulse * strength;
	float vignette = smoothstep(0.3,0.82,length((uv-vec2(0.46,0.48))*vec2(0.9,1.1)));
	base *= 1.0-vignette*0.25;
	float grain = hash(uv*vec2(1920,1080)+floor(clock*12.0))-0.5;
	base += grain*0.007*strength;
	COLOR = vec4(base,1);
}
