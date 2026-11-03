shader_type canvas_item;
uniform float cloak : hint_range(0.0, 1.0) = 0.0;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
void fragment() {
 vec4 col = COLOR;
 float scan = step(0.86, fract(UV.y * 24.0 - TIME * 2.0));
 col.rgb = mix(col.rgb, vec3(0.15, 0.72, 0.85), cloak * 0.75);
 col.a *= mix(1.0, 0.16 + scan * 0.5, cloak);
 col.rgb = mix(col.rgb, vec3(1.0, 0.83, 0.85), flash);
 COLOR = col;
}
