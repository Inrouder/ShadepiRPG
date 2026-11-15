extends Node
## v0.62.0 · CodexAI. Two-device LAN remote co-op: one authoritative story simulation.
## Native client presents the host image/audio; only player-2 controller state travels back.
signal changed
signal frame_received
const PROTOCOL := 2
const PORT := 26562
const REMOTE_DEVICE := 101
const MAX_PACKET := 180000
const VIDEO_SIZE := Vector2i(960, 540)
const ALLOWED_BUTTONS := [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_START, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN]
var connection_generation := 0
var peer: ENetMultiplayerPeer
var role := "offline"
var status := "Gleiches WLAN · Host erstellen oder per IP beitreten."
var pin := ""
var remote := 0
var clock := 0.0
var deadline := 0.0
var last_input := 0.0
var last_frame := 0.0
var frame_clock := 0.0
var input_clock := 0.0
var last_buttons := 0
var last_axes := Vector2.ZERO
var pending_buttons := 0
var pending_axes := Vector2.ZERO
var pending_aim := Vector2.ZERO
var remote_aim := Vector2.ZERO
var remote_context := "menu"
var sent_context := ""
var pending_triggers := Vector2(-1, -1)
var remote_triggers := Vector2(-1, -1)
var world: Node
var client_world: Node
var saved_mode := Node.PROCESS_MODE_INHERIT
var hidden_nodes: Array = []
var paused_audio: Array = []
var previous_coop := false
var capture: AudioEffectCapture
var audio_player: AudioStreamPlayer
var audio_stream: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var audio_rate := 44100.0
var display: CanvasLayer
var picture: TextureRect
var image_texture: ImageTexture
var lobby: CanvasLayer
var dropped_frames := 0
var received_frames := 0
var audio_on := true
var profile := 1 if OS.has_feature("android") else 0
var sent_sequence := 0
var received_sequence := -1
var outgoing_frame := 0
var assembling_frame := -1
var displayed_frame := -1
var expected_parts := 0
var video_parts := {}
var in_flight := -1
var stream_picture: Node
var capture_ms := 0.0
var encode_ms := 0.0
var frame_bytes := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -200
	RenderingServer.frame_post_draw.connect(_capture_frame)
	get_window().close_requested.connect(close)
	get_node("/root/AudioSettings").changed.connect(_apply_audio_setting)
	_apply_audio_setting()
	_build_display()
	var args := OS.get_cmdline_user_args()
	if "--lan-panel" in args: show_lobby.call_deferred()

func version() -> String: return str(ProjectSettings.get_setting("application/config/version"))
func is_host() -> bool: return role == "host"
func is_client() -> bool: return role in ["joining", "client"]
func connected() -> bool: return remote > 0
func _message(text: String): status = text; changed.emit()

func host(port: int = PORT) -> Error:
	close()
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(port, 2, 3)
	if err != OK: peer = null; _message("Port belegt oder WLAN nicht verfügbar (%s)." % err); return err
	role = "host"; pin = "%06d" % randi_range(100000, 999999)
	previous_coop = get_tree().get_meta("shadepi_coop_session", false)
	peer.peer_disconnected.connect(_peer_disconnected.bind(connection_generation), CONNECT_DEFERRED)
	_message("Host bereit · Code %s\nIP %s · UDP %d" % [pin, addresses(), port])
	return OK

func join(address: String, code: String, port: int = PORT) -> Error:
	if not address.is_valid_ip_address() or code.length() != 6 or not code.is_valid_int():
		_message("IPv4-Adresse und sechsstelligen Code vom Host eingeben."); return ERR_INVALID_PARAMETER
	close()
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port, 3)
	if err != OK: peer = null; _message("Verbindung konnte nicht gestartet werden (%s)." % err); return err
	role = "joining"; pin = code; deadline = clock + 10.0
	peer.peer_disconnected.connect(_peer_disconnected.bind(connection_generation), CONNECT_DEFERRED)
	_message("Verbinde mit %s …" % address)
	return OK

func addresses() -> String:
	var result: Array[String] = []
	for address in IP.get_local_addresses():
		if address.contains(":") or address.begins_with("127.") or address.begins_with("169.254."): continue
		result.append(address)
	return ", ".join(result) if not result.is_empty() else "WLAN-Adresse in Geräteeinstellungen"

func _send(packet: Dictionary, target: int, channel: int = 0, reliable: bool = true):
	if peer == null or peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED: return
	var data := var_to_bytes(packet)
	if data.size() > MAX_PACKET: return
	peer.set_target_peer(target); peer.transfer_channel = channel
	peer.transfer_mode = MultiplayerPeer.TRANSFER_MODE_RELIABLE if reliable else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE if channel == 1 else MultiplayerPeer.TRANSFER_MODE_UNRELIABLE_ORDERED
	peer.put_packet(data)

func _process(delta: float):
	clock += delta
	if peer == null: return
	peer.poll()
	if peer == null: return
	if role == "joining" and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED and remote == 0:
		remote = 1; _send({"type":"hello", "protocol":PROTOCOL, "version":version(), "pin":pin}, 1)
	while peer != null and peer.get_available_packet_count() > 0:
		var sender := peer.get_packet_peer()
		var raw := peer.get_packet()
		if raw.size() > MAX_PACKET or raw.is_empty(): continue
		var packet: Variant = bytes_to_var(raw)
		if packet is Dictionary: _receive(sender, packet)
	if peer == null: return
	if role == "joining" and clock > deadline: close(); _message("Host nicht erreichbar. IP, WLAN und Firewall prüfen.")
	if role == "client":
		input_clock += delta
		if input_clock >= 1.0 / 30.0:
			input_clock = 0.0
			send_controls()
		if clock - last_frame > 8.0: close(); _message("Bildverbindung unterbrochen. Der Host behält den Spielstand.")
	elif role == "host" and connected():
		var context := preload("res://scripts/input_context.gd").for_world(get_tree().current_scene, true)
		if context != sent_context:
			sent_context = context; _send({"type":"context", "context":context}, remote)
		if clock - last_input > 0.4: _apply_input(0, Vector2.ZERO, Vector2(-1,-1))
		var next := get_tree().current_scene
		if world != next: world = next; _configure_coop()

func _receive(sender: int, data: Dictionary):
	var kind: Variant = data.get("type", "")
	if not kind is String: return
	if role == "host" and kind == "hello":
		if (remote != 0 and remote != sender) or data.get("protocol") != PROTOCOL or data.get("version") != version() or data.get("pin") != pin:
			_send({"type":"reject", "reason":"Code, Spielversion oder freie Spielerposition stimmt nicht."}, sender); return
		remote = sender; sent_context = ""; in_flight = -1; last_input = clock; received_sequence = -1; world = get_tree().current_scene
		audio_rate = AudioServer.get_mix_rate()
		_send({"type":"welcome", "rate":audio_rate, "protocol":PROTOCOL}, sender)
		_configure_coop(); _start_capture()
		_message("Spieler 2 verbunden · gemeinsame Partie läuft auf diesem Gerät.")
		if is_instance_valid(lobby): lobby.hide()
	elif role == "joining" and sender == 1 and kind == "reject":
		close(); _message(str(data.get("reason", "Beitritt abgelehnt.")))
	elif role == "joining" and sender == 1 and kind == "welcome":
		var rate: Variant = data.get("rate", 44100.0)
		if not (rate is float or rate is int) or rate < 8000 or rate > 192000: return
		role = "client"; last_frame = clock; audio_rate = rate
		_pause_client_world(); _start_playback(); display.show()
		if is_instance_valid(lobby): lobby.hide()
		_message("Verbunden · du steuerst Spieler 2. Der Host führt Partie und Spielstand.")
	elif role == "host" and sender == remote and kind == "input":
		var buttons: Variant = data.get("buttons"); var axes: Variant = data.get("axes"); var triggers: Variant = data.get("triggers")
		var aim: Variant = data.get("aim", Vector2.ZERO)
		var sequence: Variant = data.get("sequence")
		if not sequence is int or sequence <= received_sequence or sequence > 2147483647: return
		if not buttons is int or not axes is Vector2 or not triggers is Vector2 or not aim is Vector2: return
		if not axes.is_finite() or not triggers.is_finite() or not aim.is_finite() or buttons < 0 or buttons > 65535: return
		received_sequence = sequence; last_input = clock; _apply_input(buttons, axes.limit_length(1.0), triggers.clamp(Vector2(-1,-1),Vector2.ONE), aim.limit_length(1.0))
	elif role == "client" and sender == 1 and kind == "context":
		var context: Variant = data.get("context")
		if context is String and context in preload("res://scripts/input_context.gd").CONTEXTS: remote_context = context
	elif role == "client" and sender == 1 and kind == "video":
		var id: Variant = data.get("id"); var part: Variant = data.get("part"); var count: Variant = data.get("count"); var payload: Variant = data.get("payload")
		if not id is int or not part is int or not count is int or not payload is PackedByteArray: return
		if id <= displayed_frame or count < 1 or count > 150 or part < 0 or part >= count or payload.size() > 1100: return
		if id > assembling_frame: assembling_frame = id; expected_parts = count; video_parts.clear()
		if id != assembling_frame or count != expected_parts: return
		video_parts[part] = payload
		if video_parts.size() == expected_parts:
			var jpg := PackedByteArray()
			for i in expected_parts: jpg.append_array(video_parts[i])
			video_parts.clear()
			if _present_image(jpg):
				displayed_frame = id
				_send({"type":"video_ack", "id":id},1)
	elif role == "host" and sender == remote and kind == "video_ack":
		if data.get("id") is int and data.id == in_flight: in_flight = -1
	elif role == "client" and sender == 1 and kind == "audio":
		var pcm: Variant = data.get("pcm")
		if not pcm is PackedByteArray or pcm.size() > 8192 or pcm.size() % 4 != 0 or playback == null: return
		var frames := PackedVector2Array(); frames.resize(pcm.size() / 4)
		for i in frames.size(): frames[i] = Vector2(pcm.decode_s16(i*4), pcm.decode_s16(i*4+2)) / 32768.0
		if playback.get_frames_available() >= frames.size(): playback.push_buffer(frames)

func _configure_coop():
	var saved_buttons := last_buttons; var saved_axes := last_axes; var saved_triggers := remote_triggers; var saved_aim := remote_aim
	_apply_input(0,Vector2.ZERO,Vector2(-1,-1))
	get_tree().set_meta("shadepi_coop_session", true)
	if is_instance_valid(world) and world.has_method("set_coop"):
		if world.get("chapter_coop") != null: world.chapter_coop = true
		world.restore_coop_session()
		if world.ui != null: world.ui.requested_coop = true
	Input.joy_connection_changed.emit(REMOTE_DEVICE, true)
	_apply_input(saved_buttons,saved_axes,saved_triggers,saved_aim)

func _apply_input(buttons: int, axes: Vector2, triggers: Vector2, aim: Vector2 = Vector2.ZERO):
	for button in ALLOWED_BUTTONS:
		var mask: int = 1 << button
		if (buttons & mask) == (last_buttons & mask): continue
		var e := InputEventJoypadButton.new(); e.device = REMOTE_DEVICE; e.button_index = button; e.pressed = (buttons & mask) != 0
		Input.parse_input_event(e)
	for i in 6:
		var value: float = [axes.x, axes.y, triggers.x, triggers.y, aim.x, aim.y][i]
		var previous: float = [last_axes.x, last_axes.y, remote_triggers.x, remote_triggers.y, remote_aim.x, remote_aim.y][i]
		if is_equal_approx(value, previous): continue
		var e := InputEventJoypadMotion.new(); e.device = REMOTE_DEVICE
		e.axis = [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y][i]; e.axis_value = value
		Input.parse_input_event(e)
	last_buttons = buttons; last_axes = axes; remote_triggers = triggers; remote_aim = aim

func _input(event: InputEvent):
	if not is_client(): return
	if is_instance_valid(lobby) and lobby.visible: return
	if event is InputEventJoypadButton and event.button_index in ALLOWED_BUTTONS:
		var mask: int = 1 << event.button_index
		pending_buttons = pending_buttons | mask if event.pressed else pending_buttons & ~mask
		send_controls(true)
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion:
		match event.axis:
			JOY_AXIS_LEFT_X: pending_axes.x = event.axis_value
			JOY_AXIS_LEFT_Y: pending_axes.y = event.axis_value
			JOY_AXIS_RIGHT_X: pending_aim.x = event.axis_value
			JOY_AXIS_RIGHT_Y: pending_aim.y = event.axis_value
			JOY_AXIS_TRIGGER_LEFT: pending_triggers.x = event.axis_value
			JOY_AXIS_TRIGGER_RIGHT: pending_triggers.y = event.axis_value
		send_controls()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and not event.echo:
		var map := {KEY_UP:JOY_BUTTON_DPAD_UP, KEY_W:JOY_BUTTON_DPAD_UP, KEY_DOWN:JOY_BUTTON_DPAD_DOWN, KEY_S:JOY_BUTTON_DPAD_DOWN, KEY_LEFT:JOY_BUTTON_DPAD_LEFT, KEY_A:JOY_BUTTON_DPAD_LEFT, KEY_RIGHT:JOY_BUTTON_DPAD_RIGHT, KEY_D:JOY_BUTTON_DPAD_RIGHT, KEY_U:JOY_BUTTON_X, KEY_J:JOY_BUTTON_X, KEY_ENTER:JOY_BUTTON_A, KEY_E:JOY_BUTTON_A, KEY_SPACE:JOY_BUTTON_B, KEY_O:JOY_BUTTON_Y, KEY_Q:JOY_BUTTON_Y, KEY_P:JOY_BUTTON_B, KEY_ESCAPE:JOY_BUTTON_START, KEY_BACKSPACE:JOY_BUTTON_B}
		if map.has(event.physical_keycode):
			var mask: int = 1 << int(map[event.physical_keycode])
			pending_buttons = pending_buttons | mask if event.pressed else pending_buttons & ~mask
			send_controls(true)
			get_viewport().set_input_as_handled()
		elif event.physical_keycode in [KEY_K,KEY_I,KEY_L]:
			pending_triggers[0 if event.physical_keycode == KEY_L else 1] = 1.0 if event.pressed else -1.0
			send_controls(true); get_viewport().set_input_as_handled()

func send_controls(reliable: bool = false):
	if role != "client": return
	sent_sequence += 1
	_send({"type":"input", "buttons":pending_buttons, "axes":pending_axes, "aim":pending_aim, "triggers":pending_triggers, "sequence":sent_sequence}, 1, 0, reliable)

func send_video(jpg: PackedByteArray):
	if jpg.size() > 160000 or remote == 0: return
	outgoing_frame += 1
	in_flight = outgoing_frame
	var count := ceili(jpg.size() / 1100.0)
	for i in count:
		_send({"type":"video", "id":outgoing_frame, "part":i, "count":count, "payload":jpg.slice(i*1100,mini((i+1)*1100,jpg.size()))},remote,1,true)

static func jpeg_size(jpg: PackedByteArray) -> Vector2i:
	if jpg.size() < 10 or jpg[0] != 255 or jpg[1] != 216: return Vector2i.ZERO
	var p := 2
	while p + 8 < jpg.size():
		if jpg[p] != 255: return Vector2i.ZERO
		while p < jpg.size() and jpg[p] == 255: p += 1
		if p + 2 >= jpg.size(): return Vector2i.ZERO
		var marker := jpg[p]; p += 1
		var length := jpg[p]*256 + jpg[p+1]
		if length < 2 or p+length > jpg.size(): return Vector2i.ZERO
		if marker in [192,193,194]: return Vector2i(jpg[p+5]*256+jpg[p+6],jpg[p+3]*256+jpg[p+4])
		p += length
	return Vector2i.ZERO

func _present_image(jpg: PackedByteArray) -> bool:
	var size := jpeg_size(jpg)
	if size.x < 1 or size.y < 1 or size.x > 1920 or size.y > 1080: return false
	var img := Image.new()
	if img.load_jpg_from_buffer(jpg) != OK: return false
	if image_texture == null: image_texture = ImageTexture.create_from_image(img); picture.texture = image_texture
	elif Vector2i(image_texture.get_size()) == img.get_size(): image_texture.update(img)
	else: image_texture.set_image(img)
	last_frame = clock; received_frames += 1; frame_received.emit(); return true

func _capture_frame():
	if not is_host() or not connected() or DisplayServer.get_name() == "headless": return
	_capture_audio()
	# Keep at most one frame in transit; slow clients cannot accumulate seconds of video.
	if in_flight >= 0: return
	var interval := 1.0 / (15.0 if profile == 0 else 12.0)
	if clock - frame_clock < interval: return
	if not is_instance_valid(stream_picture):
		stream_picture=preload("res://scripts/network_picture.gd").new(); add_child(stream_picture); return
	if not stream_picture.armed: return
	stream_picture.armed=false; frame_clock=clock
	var began:=Time.get_ticks_usec()
	var img: Image=stream_picture.target.get_texture().get_image()
	capture_ms=(Time.get_ticks_usec()-began)/1000.0
	if img==null or img.is_empty(): return
	began=Time.get_ticks_usec()
	var jpg := img.save_jpg_to_buffer(0.78)
	encode_ms=(Time.get_ticks_usec()-began)/1000.0; frame_bytes=jpg.size()
	if jpg.size() <= 160000: send_video(jpg)
	else: dropped_frames += 1
func _capture_audio():
	if capture != null:
		while capture.can_get_buffer(256):
			var frames := capture.get_buffer(256); var pcm := PackedByteArray(); pcm.resize(frames.size()*4)
			for i in frames.size():
				pcm.encode_s16(i*4, int(clampf(frames[i].x, -1.0, 0.9999)*32768))
				pcm.encode_s16(i*4+2, int(clampf(frames[i].y, -1.0, 0.9999)*32768))
			_send({"type":"audio", "pcm":pcm}, remote, 2, false)

func _start_capture():
	if capture != null:
		capture.clear_buffer(); return
	capture = AudioEffectCapture.new(); capture.buffer_length = 0.25
	AudioServer.add_bus_effect(0, capture)
func _apply_audio_setting():
	audio_on=get_node("/root/AudioSettings").enabled
	if is_instance_valid(audio_player): audio_player.volume_db=0.0 if audio_on else -80.0

func _start_playback():
	audio_stream = AudioStreamGenerator.new(); audio_stream.mix_rate = audio_rate; audio_stream.buffer_length = 0.25
	audio_player = AudioStreamPlayer.new(); audio_player.stream = audio_stream; add_child(audio_player); audio_player.play()
	playback = audio_player.get_stream_playback()
	_apply_audio_setting()

func _pause_client_world():
	client_world = get_tree().current_scene
	if not is_instance_valid(client_world): return
	saved_mode = client_world.process_mode; client_world.process_mode = Node.PROCESS_MODE_DISABLED
	for node in _descendants(client_world):
		if node is CanvasLayer or node == client_world:
			if node is CanvasItem or node is CanvasLayer: hidden_nodes.append([node,node.visible]); node.hide()
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
			paused_audio.append([node,node.stream_paused]); node.stream_paused = true
func _descendants(node: Node) -> Array:
	var result: Array = [node]
	for child in node.get_children(): result.append_array(_descendants(child))
	return result

# v0.64.0 · CodexAI: never destroy an ENet peer from inside its poll callback.
func _peer_disconnected(id: int, generation: int):
	if generation == connection_generation: _disconnected(id)

func _disconnected(id: int):
	if id != remote: return
	if is_host():
		_apply_input(0,Vector2.ZERO,Vector2(-1,-1)); remote = 0; in_flight = -1
		Input.joy_connection_changed.emit(REMOTE_DEVICE,false)
		if is_instance_valid(world) and world.ui != null:
			if is_instance_valid(world.get("arcade")): world.arcade.pause_game("Spieler 2 getrennt · erneut verbinden oder lokal fortsetzen.")
			else: world.menu_open = true; world.ui.show_menu()
		_message("Spieler 2 getrennt. Partie pausiert; erneuter Beitritt mit gleichem Code möglich.")
	else: close(); _message("Verbindung beendet. Dein lokaler Spielstand bleibt erhalten.")

func close():
	connection_generation += 1
	var touch := get_node_or_null("/root/MobileControls")
	if touch != null and touch.enabled: touch.release_all()
	if is_instance_valid(stream_picture): stream_picture.free()
	stream_picture=null
	var hosting := is_host()
	if hosting: _apply_input(0, Vector2.ZERO, Vector2(-1,-1))
	if peer != null: peer.close(); peer = null
	role = "offline"; remote = 0; remote_context = "menu"; sent_context = ""; pin = ""; pending_buttons = 0; pending_axes = Vector2.ZERO; pending_aim = Vector2.ZERO; pending_triggers = Vector2(-1,-1)
	sent_sequence = 0; received_sequence = -1
	video_parts.clear(); assembling_frame = -1; displayed_frame = -1; expected_parts = 0; received_frames = 0
	in_flight = -1
	if hosting:
		get_tree().set_meta("shadepi_coop_session",previous_coop)
		if is_instance_valid(world) and world.has_method("set_coop"):
			if world.get("chapter_coop") != null: world.chapter_coop = previous_coop
			world.set_coop(previous_coop)
			if world.ui != null: world.ui.requested_coop = previous_coop
		Input.joy_connection_changed.emit(REMOTE_DEVICE,false)
	for pair in hidden_nodes:
		if is_instance_valid(pair[0]): pair[0].visible = pair[1]
	for pair in paused_audio:
		if is_instance_valid(pair[0]): pair[0].stream_paused = pair[1]
	if is_instance_valid(client_world): client_world.process_mode = saved_mode
	client_world = null; hidden_nodes.clear(); paused_audio.clear()
	if is_instance_valid(audio_player): audio_player.stop(); audio_player.stream=null; audio_player.queue_free()
	playback = null; audio_player = null; audio_stream = null
	if capture != null:
		for i in range(AudioServer.get_bus_effect_count(0)-1,-1,-1):
			if AudioServer.get_bus_effect(0,i) == capture: AudioServer.remove_bus_effect(0,i)
		capture = null
	if is_instance_valid(display): display.hide()
	_message("WLAN-Partie beendet.")

func _build_display():
	display = CanvasLayer.new(); display.layer = 800; display.set_meta("root_only",true); add_child(display)
	picture = TextureRect.new(); picture.size = Vector2(640,360); picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.visibility_layer = 1 << 20; display.add_child(picture); display.hide()

func show_lobby():
	pending_buttons = 0; pending_axes = Vector2.ZERO; pending_aim = Vector2.ZERO; pending_triggers = Vector2(-1,-1)
	var scene := get_tree().current_scene
	if not is_client() and scene != null and scene.get("ui") != null:
		if is_instance_valid(scene.get("arcade")): scene.arcade.pause_game()
		else:
			scene.menu_open = true
			if not scene.ui.menu.visible: scene.ui.show_menu()
	if not is_instance_valid(lobby): lobby = load("res://scripts/network_lobby.gd").new(); add_child(lobby)
	lobby.show()

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		pending_buttons = 0; pending_axes = Vector2.ZERO; pending_aim = Vector2.ZERO; pending_triggers = Vector2(-1,-1)
		if is_client(): send_controls(true)
