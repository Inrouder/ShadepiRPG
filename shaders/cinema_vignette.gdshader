shader_type canvas_item;
render_mode unshaded;
// v0.52.0 · ClaudeHelper: Kino-Vignette für Filmszenen. Dunkelt die Bildränder weich ab und
// lenkt den Blick auf die Figuren; `amount` folgt den Filmbalken (0 = Spiel, 1 = Szene).
uniform float amount : hint_range(0.0, 1.0) = 0.0;
void fragment() {
	vec2 p = (UV - 0.5) * vec2(1.0, 0.72);
	float edge = smoothstep(0.26, 0.62, length(p));
	COLOR = vec4(0.01, 0.015, 0.04, edge * 0.62 * amount);
}
