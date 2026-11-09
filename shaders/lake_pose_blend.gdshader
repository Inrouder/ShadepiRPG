shader_type canvas_item;
// v0.36.0 · CodexAI. Blend only the four approved, face-obscured source poses.
uniform sampler2D sheet : source_color, filter_linear, repeat_disable;
uniform vec2 pose_a = vec2(0.0);
uniform vec2 pose_b = vec2(0.0);
uniform float blend = 0.0;
uniform float warmth = 0.0;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	vec2 local = UV*2.0;
	vec4 a = texture(sheet,(pose_a+local)*0.5);
	vec4 b = texture(sheet,(pose_b+local)*0.5);
	vec4 premultiplied = mix(vec4(a.rgb*a.a,a.a),vec4(b.rgb*b.a,b.a),blend);
	vec3 color = premultiplied.rgb/max(premultiplied.a,0.0001);
	color *= mix(vec3(1.0),vec3(1.14,1.06,1.02),warmth);
	COLOR = vec4(color,premultiplied.a)*tint;
}
