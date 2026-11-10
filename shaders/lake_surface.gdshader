shader_type canvas_item;
render_mode unshaded;
// v0.49.0 · CodexAI. Moon-axis shimmer and reflected source pixels on clipped water.
uniform float clock = 0.0;
uniform float strength = 0.65;
varying vec2 world_point;
void vertex() { world_point = VERTEX; }
void fragment() {
	float row = floor(world_point.y);
	float wave = sin(row*0.21-clock*1.1)+sin(row*0.071+clock*0.6);
	vec2 shift = vec2(floor(wave*strength*2.2),0.0)*TEXTURE_PIXEL_SIZE;
	vec4 source = texture(TEXTURE,UV+shift);
	float depth = max(0.0,world_point.y-207.0);
	float axis = 727.0+sin(row*0.13-clock*0.7)*(2.0+depth*0.035);
	float corridor = exp(-pow((world_point.x-axis)/(9.0+depth*0.23),2.0));
	float bands = pow(max(0.0,sin(row*0.65-clock*1.25+sin(world_point.x*0.07))),10.0);
	float gleam = corridor*bands*exp(-depth/235.0);
	source.rgb += vec3(0.32,0.38,0.47)*gleam*strength;
	source.rgb += vec3(0.015,0.03,0.045)*(0.5+0.5*sin(row*0.11-clock*0.6))*strength;
	COLOR = source;
}
