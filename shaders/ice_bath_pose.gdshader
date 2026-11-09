shader_type canvas_item;
// v0.38.0 · CodexAI. Registered contact poses and local water/mist response.
uniform sampler2D sheet : source_color, filter_linear, repeat_disable;
uniform vec4 region_a = vec4(0.0,0.0,384.0,512.0);
uniform vec4 region_b = vec4(0.0,0.0,384.0,512.0);
uniform vec2 anchor_a = vec2(183.0,294.0);
uniform vec2 anchor_b = vec2(183.0,294.0);
uniform vec2 offset_a = vec2(0.0);
uniform vec2 offset_b = vec2(0.0);
uniform float blend = 0.0;
uniform float clock = 0.0;
uniform float immersed = 0.0;
uniform float breath_a = 0.0;
uniform float breath_b = 0.0;
uniform float spray = 0.0;
varying vec4 tint;
void vertex() { tint = COLOR; }
vec4 sample_pose(vec2 pixel, vec4 region, vec2 anchor, vec2 offset, float breathing) {
	vec2 p = pixel-vec2(400.0,480.0)+anchor-offset*8.0;
	float chest = smoothstep(140.0,210.0,p.y)*(1.0-smoothstep(285.0,335.0,p.y));
	p.y += sin(clock*4.2)*1.6*breathing*chest;
	if (p.x<0.0 || p.y<0.0 || p.x>=region.z || p.y>=region.w) return vec4(0.0);
	vec4 color = texture(sheet,(region.xy+p)/vec2(1536.0,1024.0));
	if (spray>0.0 && region.x>700.0 && region.x<1000.0 && p.x>212.0 && p.x<275.0 && p.y>204.0 && p.y<244.0 && color.r>0.42 && color.g>0.5) {
		color.a *= 0.72+0.28*sin(clock*14.0+p.x*0.18);
	}
	return vec4(color.rgb*color.a,color.a);
}
void fragment() {
	vec2 pixel = UV*vec2(896.0,768.0);
	vec4 color = mix(sample_pose(pixel,region_a,anchor_a,offset_a,breath_a),sample_pose(pixel,region_b,anchor_b,offset_b,breath_b),blend);
	vec3 rgb = color.rgb/max(color.a,0.0001);
	float below = smoothstep(343.0,355.0,361.0+(pixel.y-480.0)*0.125)*immersed;
	rgb = mix(rgb,rgb*vec3(0.55,0.88,1.05),below*0.7);
	COLOR = vec4(rgb,color.a*(1.0-below*0.4))*tint;
}
