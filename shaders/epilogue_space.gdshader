shader_type canvas_item;
render_mode unshaded;
// v0.69.0 · CodexAI. Travel through the authored starfield into the unknown swarm.
uniform float travel : hint_range(0.0,1.0) = 0.0;
uniform float clock = 0.0;
varying vec4 canvas_tint;
void vertex() { canvas_tint = COLOR; }
void fragment() {
 float t = smoothstep(0.0,1.0,travel);
 float zoom = mix(3.0,1.4,t);
 vec2 center = mix(vec2(0.20,0.43),vec2(0.62,0.49),t);
 vec2 uv = (UV-0.5)/zoom+center;
 uv += vec2(sin(clock*0.07),cos(clock*0.06))*0.0007;
 vec4 source = texture(TEXTURE,uv);
 float bright = smoothstep(0.45,0.95,max(source.r,max(source.g,source.b)));
 float shimmer = 1.0+bright*sin(clock*0.8+uv.x*47.0+uv.y*31.0)*0.055;
 COLOR = vec4(source.rgb*shimmer,source.a)*canvas_tint;
}
