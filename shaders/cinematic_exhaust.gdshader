shader_type canvas_item;
render_mode unshaded;
// v0.35.0 · CodexAI. Isolate existing textured flames; no timber or atlas matte.
uniform sampler2D flame_atlas : filter_linear, repeat_disable;
uniform float clock = 0.0;
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float seed = 0.0;

vec4 flame(float frame, vec2 uv) {
	// 384×256 cells. Crop above the burning wood; base attaches to the nozzle.
	vec2 source = vec2(frame*384.0 + 120.0 + uv.x*170.0, 310.0 + (1.0-uv.y)*128.0);
	return texture(flame_atlas, source/vec2(1536.0,1024.0));
}

void fragment() {
	float cycle = clock*7.0+seed;
	float index = mod(floor(cycle),4.0);
	vec4 sample_color = mix(flame(index,UV), flame(mod(index+1.0,4.0),UV), smoothstep(0.0,1.0,fract(cycle)));
	float heat = max(sample_color.r,max(sample_color.g,sample_color.b));
	float alpha = min(1.0,sample_color.a*3.5) * smoothstep(0.20,0.65,heat);
	alpha *= smoothstep(0.0,0.09,UV.x)*smoothstep(0.0,0.09,1.0-UV.x);
	alpha *= smoothstep(0.0,0.06,UV.y)*pow(1.0-UV.y,0.45)*strength;
	vec3 ion = mix(vec3(0.10,0.48,0.96),vec3(0.78,0.97,1.0),smoothstep(0.45,0.95,heat));
	COLOR = vec4(ion,alpha);
}
