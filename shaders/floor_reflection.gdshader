shader_type canvas_item;
render_mode unshaded;
// v0.52.0 · ClaudeHelper: Spiegelbild einer Figur auf nassem/poliertem Boden.
// Nutzt die unveränderten Figurenpixel; an den Füßen kräftig, zum Kopf hin auslaufend,
// mit leichter waagerechter Wellenverschiebung in ganzen Quellpixeln.
uniform vec4 frame_rect = vec4(0.0, 0.0, 1.0, 1.0); // uv-Ausschnitt der aktuellen Pose
uniform float foot = 0.95;                           // Fußlinie innerhalb der Pose (0..1)
uniform float strength = 0.3;
uniform float ripple = 1.0;
uniform vec3 tint : source_color = vec3(0.55, 0.75, 0.95);

void fragment() {
	float v = (UV.y - frame_rect.y) / frame_rect.w;
	float depth = clamp((foot - v) / foot, 0.0, 1.0);   // 0 an den Füßen, 1 am Kopf
	float wave = sin(depth * 34.0 + TIME * 2.6) * depth * ripple;
	vec2 uv = UV + vec2(round(wave * 2.0) * TEXTURE_PIXEL_SIZE.x, 0.0);
	uv.x = clamp(uv.x, frame_rect.x + TEXTURE_PIXEL_SIZE.x, frame_rect.x + frame_rect.z - TEXTURE_PIXEL_SIZE.x);
	vec4 source = texture(TEXTURE, uv);
	float fade = pow(1.0 - depth, 1.1) * step(v, foot + 0.02);
	// Farbtreues Spiegelbild, leicht kühl getönt: dunkle Rüstung dunkelt den hellen nassen
	// Boden ab, Lichter (Visier, Klinge, Neon) bleiben als Glanz erhalten.
	vec3 colour = source.rgb * mix(vec3(1.0), tint * 1.25, 0.3);
	COLOR = vec4(colour, source.a * strength * fade);
}
