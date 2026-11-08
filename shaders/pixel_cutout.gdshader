shader_type canvas_item;
// v0.30.0 · CodexAI: reject soft atlas backdrop alpha at display time.
uniform float alpha_threshold = 0.60;
void fragment() {
	if (COLOR.a < alpha_threshold) { discard; }
	COLOR.a = 1.0;
}
