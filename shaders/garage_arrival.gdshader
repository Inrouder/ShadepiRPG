shader_type canvas_item;
render_mode unshaded;
// v0.66.0 CodexAI: the outside motorcycle is visible only through the real door opening.
uniform vec4 doorway = vec4(238.0,104.0,390.0,240.0);
uniform float opening_top = 240.0;
uniform bool outside_only = false;
varying vec2 world_pixel;
void vertex() { world_pixel=(MODEL_MATRIX*vec4(VERTEX,0.0,1.0)).xy; }
void fragment() {
	vec4 pixel=texture(TEXTURE,UV)*COLOR;
	if(outside_only && world_pixel.y>doorway.w) pixel.a=0.0;
	if((outside_only || world_pixel.y<doorway.w) && (world_pixel.y<opening_top || world_pixel.x<doorway.x || world_pixel.x>doorway.z)) pixel.a=0.0;
	COLOR=pixel;
}
