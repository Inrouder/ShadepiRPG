extends CanvasLayer
## v0.62.0 · CodexAI. Explicit LAN hosting/joining; no internet service or automatic publication.
const UiSkin = preload("res://scripts/ui_skin.gd")
var session: Node
var status_label: Label
var address: LineEdit
var code: LineEdit
var quality: OptionButton
var focus_items: Array[Control]=[]
var previous_focus: Control
var host_button: Button
var local_audio: Button
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
	host_button = _button(panel,"Partie eröffnen",Vector2(18,140),Vector2(202,32),func(): session.host())
	_button(panel,"Beitreten",Vector2(232,140),Vector2(188,32),func(): session.join(address.text.strip_edges(),code.text.strip_edges()))
	status_label = _text(panel,"",Vector2(18,183),Vector2(404,46),14); status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; status_label.max_lines_visible = 3
	_button(panel,"WLAN beenden",Vector2(18,266),Vector2(202,32),func(): session.close())
	_button(panel,"Zurück",Vector2(232,266),Vector2(188,32),hide)
	quality = OptionButton.new(); quality.position = Vector2(18,232); quality.size = Vector2(268,28)
	quality.add_item("Bild · 960 × 540 / 15 FPS"); quality.add_item("Bild · 640 × 360 / 12 FPS")
	quality.select(session.profile); quality.item_selected.connect(func(i): session.profile = i)
	UiSkin.apply_button(quality,"raven",16); panel.add_child(quality)
	local_audio=_button(panel,"",Vector2(296,232),Vector2(124,28),func():
		var audio=get_node("/root/AudioSettings"); audio.set_enabled(not audio.enabled))
	UiSkin.apply_button(local_audio,"raven",16)
	get_node("/root/AudioSettings").changed.connect(_refresh)
	_text(panel,"Host führt Story und Spielstand · F8 öffnet WLAN",Vector2(18,306),Vector2(404,16),12)
	for field in [address,code]:
		UiSkin.apply_button(field,"raven",14)
		field.add_theme_stylebox_override("focus",UiSkin.button("raven","focus"))
	quality.tooltip_text = "Bildprofil am Host wählen. Die lokale HQ-Anzeige bleibt erhalten."
	quality.get_popup().add_theme_font_override("font",UiSkin.font())
	quality.get_popup().add_theme_font_size_override("font_size",16)
	quality.get_popup().add_theme_stylebox_override("panel",UiSkin.panel("raven"))
	_tag(root); session.changed.connect(_refresh); _refresh()
	focus_items.insert(0,code); focus_items.insert(0,address); focus_items.insert(4,quality); focus_items.erase(local_audio); focus_items.insert(5,local_audio)
	for i in focus_items.size():
		var item:=focus_items[i]
		item.focus_next=item.get_path_to(focus_items[(i+1)%focus_items.size()])
		item.focus_previous=item.get_path_to(focus_items[posmod(i-1,focus_items.size())])
		item.focus_neighbor_bottom=item.focus_next; item.focus_neighbor_top=item.focus_previous
	visibility_changed.connect(_visibility)
	_visibility()
func _text(parent: Node, text: String, pos: Vector2, size: Vector2, font_size: int) -> Label:
	var label := Label.new(); label.text = text; label.position = pos; label.size = size
	label.add_theme_font_override("font",UiSkin.font()); label.add_theme_font_size_override("font_size",font_size); parent.add_child(label); return label
func _button(parent: Node, text: String, pos: Vector2, size: Vector2, callback: Callable):
	var b := Button.new(); b.text = text; b.position = pos; b.size = size; UiSkin.apply_button(b,"raven"); b.pressed.connect(callback); parent.add_child(b); focus_items.append(b); return b
func _tag(node: Node):
	if node is CanvasItem: node.visibility_layer = 1 << 20
	for child in node.get_children(): _tag(child)
func _refresh():
	if is_instance_valid(local_audio): local_audio.text="Ton: An" if get_node("/root/AudioSettings").enabled else "Ton: Aus"
	if is_instance_valid(status_label): status_label.text = session.status
	if is_instance_valid(quality): quality.disabled = session.is_client()
func _visibility():
	if visible:
		previous_focus=get_viewport().gui_get_focus_owner(); _refresh(); host_button.grab_focus()
	else:
		quality.get_popup().hide()
		if is_instance_valid(previous_focus) and previous_focus.is_visible_in_tree(): previous_focus.grab_focus()
func _input(event: InputEvent):
	if not visible or quality.get_popup().visible: return
	var cancel: bool=event is InputEventKey and event.is_pressed() and event.physical_keycode in [KEY_ESCAPE,KEY_F8]
	if event is InputEventJoypadButton: cancel=event.pressed and event.button_index in [JOY_BUTTON_B,JOY_BUTTON_START]
	if cancel: hide(); get_viewport().set_input_as_handled()
