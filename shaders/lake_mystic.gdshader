shader_type canvas_item;
render_mode unshaded;
// v0.49.0 · CodexAI. Six real flight phases; water-only shadow and silver eddies.
uniform sampler2D dragon : filter_linear, repeat_disable;
uniform float clock = 0.0;
uniform float glow = 0.0;
uniform float passage = -1.0;
uniform float detail = 1.0;
varying vec2 world_point;
void vertex() { world_point = VERTEX; }
void fragment() {
	vec4 source = texture(TEXTURE,UV);
	float rows = floor(world_point.y);
	float ripples = sin(rows*0.27-clock*1.0+sin(world_point.x*0.026));
	float gleam = pow(max(0.0,ripples),9.0);
	float shore = exp(-distance(world_point,vec2(735.0,382.0))/210.0);
	vec3 light = vec3(0.09,0.25,0.32)*(0.10+gleam*0.72)*glow*shore;
	float shadow = 0.0;
	if (passage>=0.0 && passage<=1.0) {
		vec2 center = mix(vec2(1045.0,263.0),vec2(360.0,280.0),passage);
		vec2 d = (world_point-center)/vec2(360.0,130.0)+vec2(0.5);
		d.x = 1.0-d.x;
		d.y += sin(d.x*9.0-clock*2.1)*0.015*(1.0-d.x);
		d.x += sin(rows*0.24-clock*1.4)*0.007;
		if (d.x>0.0 && d.x<1.0 && d.y>0.0 && d.y<1.0) {
			float frame = mod(floor(clock*(3.0+detail)),6.0);
			vec2 cell = vec2(mod(frame,3.0),floor(frame/3.0));
			vec4 sample_dragon = texture(dragon,(cell+d)/vec2(3.0,2.0));
			float shape = smoothstep(0.74,0.96,sample_dragon.a);
			shape *= smoothstep(0.13,0.30,dot(sample_dragon.rgb,vec3(0.3,0.59,0.11)));
			float envelope = sin(passage*3.14159265);
			shadow = shape*envelope*0.62;
			light += vec3(0.10,0.18,0.23)*shape*gleam*envelope*0.5;
		}
	}
	vec3 color = (source.rgb+light)*(1.0-shadow);
	COLOR = vec4(color,max(glow*0.65,shadow));
}
