shader_type canvas_item;
render_mode unshaded;
// v0.36.0 · CodexAI. Applied only to polygons clipped to the real water edge.
uniform sampler2D dragon : filter_linear, repeat_disable;
uniform float clock = 0.0;
uniform float glow = 0.0;
uniform float passage = -1.0;
varying vec2 world_point;
void vertex() { world_point = VERTEX; }
void fragment() {
	vec4 source = texture(TEXTURE,UV);
	float rows = floor(world_point.y);
	float gleam = pow(max(0.0,sin(rows*0.31-clock*1.3+sin(world_point.x*0.03))),8.0);
	float shore = exp(-distance(world_point,vec2(735.0,382.0))/180.0);
	float current = 0.60+0.4*sin(world_point.x*0.024-clock*0.8);
	vec3 light = vec3(0.08,0.38,0.40)*(0.12+gleam*current)*glow*shore;
	float shadow = 0.0;
	if (passage>=0.0 && passage<=1.0) {
		vec2 center = mix(vec2(955.0,270.0),vec2(420.0,273.0),passage);
		vec2 d = (world_point-center)/vec2(300.0,112.0)+vec2(0.5);
		d.x = 1.0-d.x;
		d.y += sin(d.x*9.0-clock*1.5)*0.014*(1.0-d.x);
		if (d.x>0.0 && d.x<1.0 && d.y>0.0 && d.y<1.0) {
			shadow = smoothstep(0.12,0.8,texture(dragon,d).a)*sin(passage*3.14159265)*0.52;
		}
	}
	vec3 color = (source.rgb+light)*(1.0-shadow);
	COLOR = vec4(color,max(glow*0.8,shadow));
}
