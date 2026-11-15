extends CanvasLayer
## v0.62.0 · CodexAI. Explicit LAN hosting/joining; no internet service or automatic publication.
const UiSkin = preload("res://scripts/ui_skin.gd")
var session: Node
var status_label: Label
var address: LineEdit
var code: LineEdit
var quality: OptionButton
func _ready():
	set_meta("root_only",true)
	layer = 970; session = get_node("/root/NetworkSession")
	var root := Control.new(); root.size = Vector2(640,360); root.mouse_filter = Control.MOUSE_FILTER_STOP; add_child(root)
	var shade := ColorRect.new(); shade.size = root.size; shade.color = Color(0,0,0,0.85); root.add_child(shade)
	var panel := Panel.new(); panel.position = Vector2(100,16); panel.size = Vector2(440,328); panel.add_theme_stylebox_override("panel",UiSkin.panel("raven")); root.add_child(panel)
	_text(panel,"WLAN · GEMEINSAME PARTIE",Vector2(18,12),Vector2(406,28),24)
	_text(panel,"Gleiches WLAN. Ein Gerät eröffnet die Partie.\nSpieler 2 gibt dessen IP-Adresse und Code ein.",Vector2(18,44),Vector2(404,40),16)
	address = LineEdit.new(); address.position = Vector2(18,94); address.size = Vector2(242,32); address.placeholder_text = "Host-IP · z. B. 192.168.1.23"; address.max_length = 45; panel.add_child(address)
	code = LineEdit.new(); code.position = Vector2(272,94); code.size = Vector2(148,32); code.placeholder_text = "6-stelliger Code"; code.max_length = 6; code.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER; panel.add_child(code)
	_button(panel,"Partie eröffnen",Vector2(18,140),Vector2(202,32),func(): session.host())
	_button(panel,"Beitreten",Vector2(232,140),Vector2(188,32),func(): session.join(address.text.strip_edges(),code.text.strip_edges()))
	status_label = _text(panel,"",Vector2(18,183),Vector2(404,46),14); status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; status_label.max_lines_visible = 3
	_button(panel,"WLAN beenden",Vector2(18,266),Vector2(202,32),func(): session.close())
	_button(panel,"Zurück",Vector2(232,266),Vector2(188,32),hide)
	quality = OptionButton.new(); quality.position = Vector2(18,232); quality.size = Vector2(402,28)
	quality.add_item("Host-Bild · 960 × 540 / 15 FPS"); quality.add_item("Host-Bild · 640 × 360 / 12 FPS · sparsam")
	quality.select(session.profile); quality.item_selected.connect(func(i): session.profile = i)
	UiSkin.apply_button(quality,"raven",16); panel.add_child(quality)
	_text(panel,"Host führt Story und Spielstand · F8 öffnet WLAN",Vector2(18,306),Vector2(404,16),12)
	for field in [address,code]:
		UiSkin.apply_button(field,"raven",14)
		field.add_theme_stylebox_override("focus",UiSkin.button("raven","focus"))
	quality.tooltip_text = "Bildprofil am Host wählen. Die lokale HQ-Anzeige bleibt erhalten."
	quality.get_popup().add_theme_font_override("font",UiSkin.font())
	quality.get_popup().add_theme_font_size_override("font_size",16)
	quality.get_popup().add_theme_stylebox_override("panel",UiSkin.panel("raven"))
	_tag(root); session.changed.connect(_refresh); _refresh()
	visibility_changed.connect(func(): if visible: _refresh())
func _text(parent: Node, text: String, pos: Vector2, size: Vector2, font_size: int) -> Label:
	var label := Label.new(); label.text = text; label.position = pos; label.size = size
	label.add_theme_font_override("font",UiSkin.font()); label.add_theme_font_size_override("font_size",font_size); parent.add_child(label); return label
func _button(parent: Node, text: String, pos: Vector2, size: Vector2, callback: Callable):
	var b := Button.new(); b.text = text; b.position = pos; b.size = size; UiSkin.apply_button(b,"raven"); b.pressed.connect(callback); parent.add_child(b)
func _tag(node: Node):
	if node is CanvasItem: node.visibility_layer = 1 << 20
	for child in node.get_children(): _tag(child)
func _refresh():
	if is_instance_valid(status_label): status_label.text = session.status
	if is_instance_valid(quality): quality.disabled = session.is_client()
func _input(event: InputEvent):
	if not visible: return
	if event is InputEventKey and event.is_pressed() and event.physical_keycode in [KEY_ESCAPE,KEY_F8]: hide(); get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion: get_viewport().set_input_as_handled()
