extends CanvasLayer
## v0.57.0 · ClaudeHelper (Nutzerauftrag vom 11. November 2026): Arcade-Automat „NEON KOMBAT“.
## Seitliches Kampfspiel mit den Figuren des Spiels – 1 Spieler gegen CPU oder 2 Spieler im Duell.
## v0.61.0 · CodexAI: eigene registrierte Arcade-Posen, Faust/Kick und Treffer-Kombos.
## v0.67.0 · CodexAI: LMHS, motion/charge parser, fixed jumps and directional guards.
signal closed

const FighterInput = preload("res://scripts/arcade/fighter_input.gd")
const UiSkin = preload("res://scripts/ui_skin.gd")
const STAGE = preload("res://assets/arcade/stage-rooftop.webp")
const ART = preload("res://scripts/arcade/pixel_art.gd")
const ATLAS = preload("res://assets/arcade/fighters/atlas.json")
const SAVE_PATH := "user://shadepi-arcade.cfg"
const VIEW := Vector2(640, 360)
const GROUND := 304.0
const WALLS := Vector2(36.0, 604.0)
const SCALE := 0.5                       # Arcade-eigene Quellen, Originalhelden unverändert
const REACH := 1.2                       # Reichweiten der Tabelle gelten für die kleinere Weltgröße
const CELL := Vector2(512, 320)
const ANCHOR := Vector2(224, 288)
const GRAVITY := 980.0
const JUMP := -350.0
const ROUND_SECONDS := 60.0
const SPECIAL_COST := 50.0
const ROUNDS_TO_WIN := 2
const MAX_FIGHT_STEP := 1.0 / 60.0
const MAX_FRAME_TIME := 0.25

## hp, Tempo, leichter/schwerer Schaden, Reichweite, Spezialangriff, Farbe der Effekte.
const ROSTER: Array[Dictionary] = [
	{"id": "shadepi", "name": "SHADEPI", "sheet": "res://assets/sprites/heroes/shadepi.png", "hp": 100, "speed": 150.0, "light": 7, "heavy": 14, "reach": 58.0, "special": "dash", "move": "SCHATTENSCHNITT", "color": Color("ff4b5c")},
	{"id": "raven", "name": "RAVEN", "sheet": "res://assets/sprites/heroes/raven.png", "hp": 90, "speed": 168.0, "light": 5, "heavy": 11, "reach": 46.0, "special": "shot", "move": "HACK-IMPULS", "color": Color("5fe8f8")},
	{"id": "jackal", "name": "JACKAL", "sheet": "res://assets/sprites/npcs/jackal.png", "hp": 120, "speed": 118.0, "light": 8, "heavy": 17, "reach": 56.0, "special": "slam", "move": "CHROMFAUST", "color": Color("ff6fd0")},
	{"id": "kenzo", "name": "KENZŌ", "sheet": "res://assets/sprites/npcs/kenzo.png", "hp": 105, "speed": 152.0, "light": 7, "heavy": 13, "reach": 52.0, "special": "flurry", "move": "DRACHENHAGEL", "color": Color("ffd46b")},
	{"id": "punk-1", "name": "PUNK ROT", "sheet": "res://assets/sprites/npcs/punk-1.png", "hp": 95, "speed": 148.0, "light": 6, "heavy": 13, "reach": 56.0, "special": "flurry", "move": "SCHLAGSERIE", "color": Color("ff7a4b")},
	{"id": "punk-2", "name": "PUNK GRÜN", "sheet": "res://assets/sprites/npcs/punk-2.png", "hp": 95, "speed": 136.0, "light": 6, "heavy": 12, "reach": 50.0, "special": "shot", "move": "FEUERSTOSS", "color": Color("ffc04b")},
	{"id": "punk-3", "name": "PUNK VIOLETT", "sheet": "res://assets/sprites/npcs/punk-3.png", "hp": 95, "speed": 140.0, "light": 6, "heavy": 12, "reach": 52.0, "special": "shot", "move": "PLASMASCHUSS", "color": Color("c17bff")},
	{"id": "punk-4", "name": "PUNK OCKER", "sheet": "res://assets/sprites/npcs/punk-4.png", "hp": 110, "speed": 126.0, "light": 7, "heavy": 16, "reach": 58.0, "special": "slam", "move": "KEULENHIEB", "color": Color("ffb04b")},
	{"id": "shooter-violet", "name": "WACHE VIOLETT", "sheet": "res://assets/sprites/npcs/shooter-violet.png", "hp": 85, "speed": 160.0, "light": 5, "heavy": 10, "reach": 44.0, "special": "shot", "move": "SALVE", "color": Color("ffb86b")},
	{"id": "shooter-visor", "name": "WACHE CYAN", "sheet": "res://assets/sprites/npcs/shooter-visor.png", "hp": 85, "speed": 160.0, "light": 5, "heavy": 10, "reach": 44.0, "special": "shot", "move": "SALVE", "color": Color("ffd88a")},
]
## Anlauf, Ende der Trefferphase, Gesamtdauer, Rückstoß, Vorwärtsschritt.
const MOVES := {
	"light": {"start": 0.09, "active": 0.2, "total": 0.3, "push": 70.0, "lunge": 30.0},
	"medium": {"start": 0.14, "active": 0.27, "total": 0.42, "push": 115.0, "lunge": 45.0},
	"rise": {"start": 0.08, "active": 0.29, "total": 0.62, "push": 170.0, "lunge": 0.0},
	"rush": {"start": 0.12, "active": 0.32, "total": 0.56, "push": 210.0, "lunge": 170.0},
	"heavy": {"start": 0.2, "active": 0.34, "total": 0.56, "push": 190.0, "lunge": 80.0},
	"dash": {"start": 0.1, "active": 0.34, "total": 0.5, "push": 150.0, "lunge": 0.0},
	"slam": {"start": 0.3, "active": 0.42, "total": 0.75, "push": 260.0, "lunge": 0.0},
	"flurry": {"start": 0.08, "active": 0.52, "total": 0.68, "push": 60.0, "lunge": 150.0},
	"shot": {"start": 0.16, "active": 0.2, "total": 0.46, "push": 110.0, "lunge": 0.0},
}
const KEYS := [
	{"left": [KEY_A], "right": [KEY_D], "up": [KEY_W], "down": [KEY_S], "a": [KEY_J], "b": [KEY_K], "c": [KEY_L], "d": [KEY_H], "ok": [KEY_E, KEY_SPACE]},
	{"left": [KEY_LEFT], "right": [KEY_RIGHT], "up": [KEY_UP], "down": [KEY_DOWN], "a": [KEY_U], "b": [KEY_I], "c": [KEY_O], "d": [KEY_P], "ok": [KEY_ENTER, KEY_KP_ENTER]},
]
const PAD := {"left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT, "up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN, "a": JOY_BUTTON_X, "b": JOY_BUTTON_Y, "c": JOY_BUTTON_B, "d": JOY_BUTTON_A, "ok": JOY_BUTTON_A}

enum Screen {TITLE, SELECT, FIGHT, RESULT}

var world: Node
var screen := Screen.TITLE
var versus := false
var menu_index := 0
var cursors: Array[int] = [0, 1]
var locked: Array[bool] = [false, false]
var fighters: Array[Dictionary] = []
var shots: Array[Dictionary] = []
var hits: Array[Dictionary] = []
var wins: Array[int] = [0, 0]
var round_number := 1
var timer := ROUND_SECONDS
var phase := "intro"                     # intro → fight → ko → (nächste Runde | RESULT)
var phase_time := 0.0
var hitstop := 0.0
var shake := 0.0
var clock := 0.0
var banner := ""
var winner := -1
var cpu_think := 0.0
var cpu_plan := {"dir": 0.0, "block": 0.0, "jump": false}
var inputs := [FighterInput.new(),FighterInput.new()]
var cpu_sequence: Array[int] = []
var cpu_sequence_time := 0.0
var cpu_sequence_step := 0
var cpu_attack := "a"
var held: Array[Dictionary] = [{}, {}]
var pressed: Array[Dictionary] = [{}, {}]
var sheets := {}
var stage_node: Node2D
var hud_node: Node2D
var rng := RandomNumberGenerator.new()
var total_wins := 0
var session_paused := false
var pause_panel: PanelContainer
var pause_note: Label
var resume_button: Button
var exit_button: Button

func _ready() -> void:
	layer = 70
	rng.seed = 5707
	# Maus und Fokus bleiben beim Automaten; das Spiel darunter reagiert nicht.
	var shield := Control.new()
	shield.set_anchors_preset(Control.PRESET_FULL_RECT)
	shield.mouse_filter = Control.MOUSE_FILTER_STOP
	shield.focus_mode = Control.FOCUS_ALL
	add_child(shield)
	shield.grab_focus.call_deferred()
	stage_node = Node2D.new()
	stage_node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	stage_node.draw.connect(_draw_stage)
	add_child(stage_node)
	hud_node = Node2D.new()
	hud_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hud_node.draw.connect(_draw_hud)
	add_child(hud_node)
	for entry in ROSTER:
		sheets[entry.id] = load("res://assets/arcade/fighters/" + str(entry.id) + ".png")
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		total_wins = int(config.get_value("arcade", "wins", 0))
	_build_pause()
	_remember()
	_sound("hack")

static func unlocked() -> bool:
	var config := ConfigFile.new()
	return config.load(SAVE_PATH) == OK and bool(config.get_value("arcade", "found", false))

func _remember() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	config.set_value("arcade", "found", true)
	config.set_value("arcade", "wins", total_wins)
	config.save(SAVE_PATH)

func _sound(key: String, variance: float = 0.06) -> void:
	if is_instance_valid(world) and world.has_method("sound"):
		world.sound(key, variance)

# --- Eingabe -----------------------------------------------------------------------------------

## Tastatur: Spieler 1 WASD + J/K/L/H, Spieler 2 Pfeile + U/I/O/P. Gamepads: erstes Pad Spieler 1,
## zweites Spieler 2; im Duell mit nur einem Pad gehört es Spieler 2 (wie im Koop).
func _pad_for(index: int) -> int:
	var pads := preload("res://scripts/gamepad_bindings.gd").devices()
	if pads.is_empty(): return -1
	if not versus: return pads[0] if index == 0 else -1
	if pads.size() == 1: return pads[0] if index == 1 else -1
	return pads[index]

func _down(index: int, what: String) -> bool:
	for key in KEYS[index][what]:
		if Input.is_physical_key_pressed(key): return true
	# Allein am Automaten gelten auch die Pfeiltasten und Enter für Spieler 1.
	if index == 0 and not versus:
		for key in KEYS[1][what]:
			if Input.is_physical_key_pressed(key): return true
	var pad := _pad_for(index)
	if pad >= 0:
		if Input.is_joy_button_pressed(pad, PAD[what]): return true
		var axis := Vector2(Input.get_joy_axis(pad, JOY_AXIS_LEFT_X), Input.get_joy_axis(pad, JOY_AXIS_LEFT_Y))
		match what:
			"left": return axis.x < -0.5
			"right": return axis.x > 0.5
			"up": return axis.y < -0.6
			"down": return axis.y > 0.6
	return false

func _poll() -> void:
	for index in 2:
		var now := {}
		var fresh := {}
		for what in PAD:
			now[what] = _down(index, what)
			fresh[what] = now[what] and not held[index].get(what, false)
		held[index] = now
		pressed[index] = fresh

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event.is_pressed() and not event.is_echo() and ((event is InputEventKey and event.physical_keycode == KEY_ESCAPE) or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_START)):
			if session_paused: resume_game()
			else: pause_game()
			get_viewport().set_input_as_handled(); return
		if session_paused: return
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	# v0.67.1 · CodexAI: backgrounding must not leave a live CPU fight running.
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		if screen == Screen.FIGHT and not session_paused and is_instance_valid(pause_panel):
			pause_game("NEON KOMBAT · PAUSE · FENSTER INAKTIV")

func _build_pause() -> void:
	pause_panel = PanelContainer.new()
	pause_panel.position = Vector2(174, 92); pause_panel.size = Vector2(292, 0)
	pause_panel.add_theme_stylebox_override("panel", UiSkin.panel("raven"))
	add_child(pause_panel)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation", 8); pause_panel.add_child(box)
	pause_note = Label.new(); pause_note.text = "NEON KOMBAT · PAUSE"; pause_note.custom_minimum_size.x = 268
	pause_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_note.add_theme_font_override("font",UiSkin.font()); pause_note.add_theme_font_size_override("font_size",12); box.add_child(pause_note)
	for entry in [["Kampf fortsetzen", resume_game], ["Zur Titelauswahl", func(): _show_title(); resume_game()], ["WLAN-Verbindung", func(): get_node("/root/NetworkSession").show_lobby()], ["Automat verlassen", close]]:
		var button := Button.new(); button.text = entry[0]; button.custom_minimum_size.y = 28
		UiSkin.apply_button(button,"raven",16); button.pressed.connect(entry[1]); box.add_child(button)
		if resume_button == null: resume_button = button
		if entry[0]=="Automat verlassen": exit_button=button
	pause_panel.hide()

func pause_game(reason: String = "NEON KOMBAT · PAUSE") -> void:
	session_paused = true
	for input in inputs:input.reset()
	for f in fighters:f.buffer="";f.buffer_t=0.0
	cpu_sequence.clear()
	held = [{}, {}]; pressed = [{}, {}]
	pause_note.text = reason; pause_panel.show(); resume_button.grab_focus.call_deferred()

func resume_game() -> void:
	session_paused = false; pause_panel.hide()
	# Suppress attacks held while the modal menu was open until they are released.
	_poll(); pressed = [{}, {}]

func back() -> void:
	match screen:
		Screen.TITLE: close()
		Screen.SELECT: _show_title()
		_: _show_title()
	_sound("prop_metal")

func close() -> void:
	closed.emit()
	queue_free()

# --- Ablauf ------------------------------------------------------------------------------------

func _show_title() -> void:
	for input in inputs:input.reset()
	cpu_sequence.clear()
	screen = Screen.TITLE
	shots.clear(); hits.clear(); fighters.clear()
	wins = [0, 0]

func _show_select(two_players: bool) -> void:
	versus = two_players
	screen = Screen.SELECT
	locked = [false, false]

func start_match(first: int, second: int, two_players: bool) -> void:
	versus = two_players
	cursors = [first, second]
	wins = [0, 0]
	round_number = 1
	screen = Screen.FIGHT
	_start_round()

func _start_round() -> void:
	hitstop=0.0;shake=0.0
	cpu_plan={"dir":0.0,"block":0.0,"jump":false}
	cpu_sequence_step=0;cpu_sequence_time=0.0;cpu_attack="a"
	for input in inputs:input.reset()
	cpu_sequence.clear()
	fighters.clear()
	for index in 2:
		var data: Dictionary = ROSTER[cursors[index]]
		fighters.append({"data": data, "x": 200.0 if index == 0 else 440.0, "y": 0.0, "vx": 0.0, "vy": 0.0, "face": 1.0 if index == 0 else -1.0, "hp": float(data.hp), "meter": 0.0 if round_number == 1 else 25.0, "state": "idle", "t": 0.0, "hit": 0, "anim": 0.0, "flash": 0.0, "combo": 0, "combo_t": 0.0, "blocking": false, "guard_t":0.0, "cool": 0.0, "buffer": "", "buffer_t": 0.0, "land": 0.0, "crouching":false, "guard_x":0, "guard_y":0, "attack_height":"mid", "move_face":1.0 if index==0 else -1.0, "air_t":0.0, "air_y":0.0, "air_vy":0.0, "air_vx":0.0, "strength":1.0, "ex":false, "buffer_strength":1.0, "buffer_ex":false, "command":"", "command_t":0.0})
	shots.clear(); hits.clear()
	timer = ROUND_SECONDS
	phase = "intro"
	phase_time = 0.0
	banner = "RUNDE %d" % round_number
	cpu_think = 0.6

func _process(delta: float) -> void:
	if session_paused: return
	clock += delta
	shake = move_toward(shake, 0.0, delta * 14.0)
	_poll()
	match screen:
		Screen.TITLE: _update_title()
		Screen.SELECT: _update_select()
		Screen.FIGHT: _update_fight(delta)
		Screen.RESULT: _update_result()
	stage_node.queue_redraw()
	hud_node.queue_redraw()

func _update_title() -> void:
	var step := int(pressed[0].down) - int(pressed[0].up)
	if step != 0:
		menu_index = posmod(menu_index + step, 3)
		_sound("calib_tick")
	if pressed[0].ok or pressed[0].a:
		_sound("calib_accept")
		match menu_index:
			0: _show_select(false)
			1: _show_select(true)
			2: close()

func _update_select() -> void:
	for index in 2:
		# Gegen die CPU wählt Spieler 1 zuerst sich, danach den Gegner.
		var source := index if versus else 0
		if not versus and ((index == 0 and locked[0]) or (index == 1 and not locked[0])): continue
		if locked[index]: continue
		var step := int(pressed[source].right) - int(pressed[source].left) + 5 * (int(pressed[source].down) - int(pressed[source].up))
		if step != 0:
			cursors[index] = posmod(cursors[index] + step, ROSTER.size())
			_sound("calib_tick")
		elif pressed[source].ok or pressed[source].a:
			locked[index] = true
			pressed[source].ok = false; pressed[source].a = false
			_sound("calib_accept")
	if locked[0] and locked[1]:
		start_match(cursors[0], cursors[1], versus)

func _update_result() -> void:
	var step := int(pressed[0].down) - int(pressed[0].up)
	if step != 0:
		menu_index = posmod(menu_index + step, 3)
		_sound("calib_tick")
	if pressed[0].ok or pressed[0].a:
		_sound("calib_accept")
		match menu_index:
			0: start_match(cursors[0], cursors[1], versus)
			1: _show_select(versus)
			2: _show_title()
		menu_index = 0

func _update_fight(delta: float) -> void:
	# v0.67.1 · CodexAI: never skip a short contact/emission window on a slow frame.
	# The physical button edge belongs to the first step only; held directions persist.
	var remaining := clampf(delta, 0.0, MAX_FRAME_TIME)
	var frame_buttons: Array[Dictionary] = pressed
	while remaining > 0.000001 and screen == Screen.FIGHT:
		var step := minf(remaining, MAX_FIGHT_STEP)
		_step_fight(step)
		remaining -= step
		pressed = [{}, {}]
	pressed = frame_buttons

func _step_fight(delta: float) -> void:
	phase_time += delta
	for i in range(hits.size() - 1, -1, -1):
		hits[i].t -= delta
		if hits[i].t <= 0.0: hits.remove_at(i)
	if phase=="fight":
		_sync_facing()
		for index in 2:
			var controls: Dictionary=_cpu_controls(delta) if index==1 and not versus else {"held":held[index],"pressed":pressed[index]}
			_control(index,controls,delta)
	if hitstop > 0.0:
		hitstop -= delta
		return
	match phase:
		"intro":
			banner = ("RUNDE %d" % round_number) if phase_time < 1.1 else "KÄMPFT!"
			if phase_time >= 1.7:
				phase = "fight"; banner = ""
			for f in fighters: _animate(f, delta)
			return
		"ko":
			for index in 2: _physics(fighters[index], fighters[1 - index], delta, {})
			if phase_time >= 2.6: _next_round()
			return
	timer = maxf(0.0, timer - delta)
	for index in 2:_physics(fighters[index],fighters[1-index],delta,{})
	_separate()
	_sync_facing()
	for index in 2:_strike(index)
	_advance_shots(delta)
	if fighters[0].hp <= 0.0 or fighters[1].hp <= 0.0 or timer <= 0.0:
		_end_round()

func _sync_facing() -> void:
	if fighters.size()!=2:return
	for index in 2:
		var f: Dictionary=fighters[index]
		var gap: float=fighters[1-index].x-f.x
		if absf(gap)>0.1:f.face=signf(gap)
		inputs[index].set_facing(int(f.face))
		if hitstop<=0:_guard(f)

func _guard(f: Dictionary) -> void:
	if f.state in ["hurt","ko"] or MOVES.has(f.state) or f.y<0:
		f.blocking=false;return
	f.crouching=int(f.guard_y)>0
	f.blocking=int(f.guard_x)*float(f.face)<0
	if f.crouching:f.state="block_low" if f.blocking and f.guard_t>0 else "crouch"
	elif f.blocking and f.guard_t>0:f.state="block"
	elif f.state in ["block","block_low","crouch"]:f.state="idle"

func _control(index: int, controls: Dictionary, delta: float=1.0/60.0) -> void:
	var f: Dictionary=fighters[index]
	var h: Dictionary=controls.held
	var p: Dictionary=controls.pressed
	var x:=int(h.get("right",false))-int(h.get("left",false))
	var y:=int(h.get("down",false))-int(h.get("up",false))
	f.guard_x=x;f.guard_y=y
	if hitstop<=0 and f.y>=0 and not MOVES.has(f.state):f.crouching=y>0
	inputs[index].sample(x,y,int(f.face),delta)
	var requested:="";var strength:=1.0;var ex:=false
	var button:="a" if p.get("a",false) else "b" if p.get("b",false) else "c" if p.get("c",false) else ""
	if button!="":
		strength=1.0 if button=="a" else 1.15 if button=="b" else 1.3
		var motion: String=inputs[index].take_motion() if f.y>=0 else ""
		match motion:
			"dragon","charge_up":requested="rise"
			"charge_forward":requested="rush"
			"quarter":requested=str(f.data.special)
			_:requested={"a":"light","b":"medium","c":"heavy"}[button];strength=1.0
		if motion!="":f.command={"dragon":"623 · AUFSTIEG","charge_up":"[2]8 · AUFSTIEG","charge_forward":"[4]6 · ANSTURM","quarter":"236 · "+str(f.data.move)}[motion];f.command_t=1.2
	if p.get("d",false):
		if f.meter>=SPECIAL_COST:requested=str(f.data.special);ex=true;strength=1.35;f.command="S · EX "+str(f.data.move);f.command_t=1.2
		else:f.command="S BRAUCHT 50 ENERGIE";f.command_t=0.8
	if requested!="" and f.state!="ko":
		f.buffer=requested;f.buffer_t=0.18;f.buffer_strength=strength;f.buffer_ex=ex
	if hitstop>0 or f.guard_t>0 or f.state in ["hurt","ko"]:return
	if MOVES.has(f.state):
		# Only confirmed L→M/H/S and M→H/S may cancel; whiffs/blocks keep recovery.
		var next_rank:=_rank(str(f.buffer))
		if f.get("confirmed",false) and f.t>=float(MOVES[f.state].active) and f.buffer_t>0 and _rank(str(f.state))<next_rank and f.state in ["light","medium"]:
			_begin(f,str(f.buffer),float(f.buffer_strength),bool(f.buffer_ex))
		return
	if f.buffer_t>0 and f.cool<=0:
		_begin(f,str(f.buffer),float(f.buffer_strength),bool(f.buffer_ex));return
	var grounded: bool=f.y>=0
	if not grounded:
		f.vx=f.air_vx;f.state="jump";f.blocking=false;return
	_guard(f)
	if y<0 or (p.get("up",false) and not h.get("down",false)):
		_launch(f,JUMP,x*float(f.data.speed)*1.05)
		f.state="jump";f.blocking=false
		_sound("drive_near_miss",0.1);return
	f.vx=0.0 if f.crouching else x*float(f.data.speed)
	if not f.crouching:f.state="walk" if x!=0 else "idle"

static func _rank(move: String) -> int:
	return {"":0,"light":1,"medium":2,"heavy":3}.get(move,4)
func _launch(f: Dictionary, vertical: float,horizontal: float):
	f.air_t=0.0;f.air_y=f.y;f.air_vy=vertical;f.air_vx=horizontal
	f.vy=vertical;f.vx=horizontal
	if f.y>=0:f.y=-0.001

func _begin(f: Dictionary, move: String, strength: float=1.0, ex: bool=true) -> void:
	if f.y<0 and move not in ["light","medium","heavy"]:
		f.buffer="";f.buffer_t=0.0;return
	f.move_face=f.face;f.strength=strength;f.ex=ex
	f.attack_height="overhead" if f.y<0 or move=="heavy" else "low" if f.get("crouching",false) and move in ["light","medium"] else "low" if move=="slam" else "mid"
	f.state = move
	f.t = 0.0
	f.hit = 0
	f.confirmed = false
	f.buffer = ""; f.buffer_t = 0.0
	f.blocking = false
	if f.y >= 0.0: f.vx = 0.0
	if move not in ["light", "medium", "heavy"]:
		if ex:f.meter=maxf(0,f.meter-SPECIAL_COST)
		f.flash = 0.25
		_sound("electric" if move == "shot" else "slash" if move == "dash" else "enemy_attack_0")
		if move=="rise":_launch(f,-310.0,f.face*100.0)
	else:
		_sound("slash" if f.data.id == "shadepi" else "enemy_attack_1", 0.12)

func _physics(f: Dictionary, other: Dictionary, delta: float, _unused: Dictionary) -> void:
	f.t += delta
	f.cool=maxf(0,f.cool-delta)
	f.command_t=maxf(0,f.command_t-delta)
	if f.guard_t>0:f.vx=move_toward(f.vx,0,900*delta)
	f.guard_t=maxf(0,f.guard_t-delta)
	f.anim += delta
	f.flash = maxf(0.0, f.flash - delta)
	f.buffer_t = maxf(0.0, f.buffer_t - delta)
	f.land = maxf(0.0, f.land - delta)
	f.combo_t = maxf(0.0, f.combo_t - delta)
	if f.combo_t <= 0.0: f.combo = 0
	if MOVES.has(f.state):
		var move: Dictionary = MOVES[f.state]
		if f.state == "dash":
			f.vx = f.move_face * 760.0 if f.t >= move.start and f.t < move.active else 0.0
		elif f.t < move.active and f.y >= 0.0:
			f.vx = f.move_face * float(move.lunge) / float(move.active)
		elif f.y >= 0.0:
			f.vx = 0.0
		if f.t >= move.total:
			f.state = "idle"; f.t = 0.0
			f.cool = 0.06
	elif f.state == "hurt":
		f.vx = move_toward(f.vx, 0.0, 520.0 * delta)
		if f.t >= 0.3 and f.y >= 0.0:
			f.state = "idle"; f.t = 0.0
	elif f.state == "ko":
		f.vx = move_toward(f.vx, 0.0, 300.0 * delta)
	var moving_time:=delta
	if f.y<0 or f.vy<0:
		# Analytic vertical arc, fixed take-off horizontal speed: no air steering.
		var prior: float=f.air_t
		var land_at: float=(-float(f.air_vy)+sqrt(float(f.air_vy)*float(f.air_vy)-2*GRAVITY*float(f.air_y)))/GRAVITY
		f.air_t=minf(land_at,float(f.air_t)+delta)
		f.y=float(f.air_y)+float(f.air_vy)*float(f.air_t)+0.5*GRAVITY*float(f.air_t)*float(f.air_t)
		f.vy=float(f.air_vy)+GRAVITY*float(f.air_t)
		if f.state not in ["hurt","ko"]:f.vx=f.air_vx
		if f.air_t>=land_at:
			moving_time=float(f.air_t)-prior;f.y=0.0;f.vy=0.0;f.land=0.12
	f.x=clampf(f.x+f.vx*moving_time,WALLS.x,WALLS.y)

func _separate() -> void:
	var a: Dictionary = fighters[0]
	var b: Dictionary = fighters[1]
	if a.state == "dash" or b.state == "dash": return
	var gap: float = b.x - a.x
	if absf(gap) < 34.0 and absf(a.y - b.y) < 38.0:
		var push := (34.0 - absf(gap)) * 0.5 * (1.0 if gap >= 0.0 else -1.0)
		a.x = clampf(a.x - push, WALLS.x, WALLS.y)
		b.x = clampf(b.x + push, WALLS.x, WALLS.y)

func _strike(index: int) -> void:
	var f: Dictionary = fighters[index]
	var other: Dictionary = fighters[1 - index]
	if not MOVES.has(f.state): return
	var move: Dictionary = MOVES[f.state]
	if f.t < move.start or f.t > move.active: return
	var reach := float(f.data.reach) * REACH
	var gap: float = (other.x - f.x) * f.face
	var level: bool = absf(f.y - other.y) < 90.0
	match f.state:
		"light", "medium", "heavy", "rise", "rush":
			if f.hit == 0 and gap > -8.0 and gap < reach + (10.0 if f.state == "heavy" else 0.0) and level:
				f.hit = 1
				_land(index, float(f.data.light) if f.state=="light" else (float(f.data.light)+float(f.data.heavy))*0.5 if f.state=="medium" else float(f.data.heavy)+2.0 if f.state in ["rise","rush"] else float(f.data.heavy), f.state in ["heavy","rise","rush"])
		"dash":
			if f.hit == 0 and absf(other.x - f.x) < 42.0 and level:
				f.hit = 1
				_land(index, 18.0, true)
		"slam":
			if f.hit == 0:
				f.hit = 1
				shake = 7.0
				_sound("prop_blast")
				hits.append({"p": Vector2(f.x + f.face * 30.0, GROUND - 6.0), "t": 0.3, "d": 0.3, "s": 2.2, "c": f.data.color})
				if absf(other.x - f.x) < 140.0 and other.y > -24.0:
					_land(index, 20.0, true)
		"flurry":
			var wanted := 1 + int((f.t - move.start) / 0.15)
			if f.hit < mini(3, wanted) and gap > -8.0 and gap < reach and level:
				f.hit += 1
				_land(index, 7.0, f.hit == 3)
			elif f.hit < mini(3, wanted):
				f.hit += 1
		"shot":
			if f.hit == 0:
				f.hit = 1
				var muzzle := emitter(f)
				shots.append({"x": muzzle.x, "y": muzzle.y, "vx": f.face * 400.0, "owner": index, "height":"mid", "dmg": 14.0*float(f.strength), "c": f.data.color, "art": 4 if f.data.id == "raven" else 6 if f.data.id == "punk-3" else 5})
				_sound("electric" if f.data.id in ["raven", "punk-3"] else "pistol", 0.1)

func _land(index: int, damage: float, strong: bool, point: Vector2 = Vector2.INF, height: String="") -> void:
	var f: Dictionary = fighters[index]
	var other: Dictionary = fighters[1 - index]
	if other.state=="ko":return
	if other.state=="dash" and other.get("ex",false) and other.t>=0.1 and other.t<0.22:return
	if height=="":height=str(f.get("attack_height","mid"))
	var at := point if point != Vector2.INF else Vector2((f.x + other.x) * 0.5 + f.face * 8.0, GROUND + other.y - (22.0 if height=="low" else 86.0))
	var side: float = 1.0 if other.x >= f.x else -1.0
	if point != Vector2.INF: side = signf(float(shots_side))
	if f.state == "dash": side = f.move_face          # Schattenschnitt: der Gegner bleibt hinter Shadepi zurück
	var push := float(MOVES[f.state].push) if MOVES.has(f.state) and point == Vector2.INF else 110.0
	if point==Vector2.INF:damage*=float(f.get("strength",1.0))
	var low_guard: bool=other.get("crouching",false)
	var guarded: bool=other.blocking and other.face==-side and (low_guard if height=="low" else not low_guard if height=="overhead" else true)
	if guarded:
		other.guard_t=0.24 if strong else 0.16
		other.state="block_low" if low_guard else "block"
		other.hp -= damage * 0.2
		other.vx = side * push * 0.5
		other.meter = minf(100.0, other.meter + 4.0)
		hits.append({"p": at, "t": 0.2, "d": 0.2, "s": 0.8, "c": Color("7fd8ff")})
		_sound("prop_metal", 0.1)
		hitstop = 0.04
	else:
		f.confirmed = true
		other.hp -= damage
		other.state = "hurt"
		other.t = 0.0 if not strong else -0.14
		other.vx = side * push
		if strong and other.y >= 0.0:
			_launch(other,-170.0,side*push)
		other.flash = 0.2
		other.meter = minf(100.0, other.meter + 6.0)
		f.meter = minf(100.0, f.meter + (10.0 if point == Vector2.INF else 5.0))
		f.combo = f.combo + 1 if f.combo_t > 0.0 else 1
		f.combo_t = 1.1
		hits.append({"p": at, "t": 0.26, "d": 0.26, "s": 1.5 if strong else 1.0, "c": f.data.color})
		_sound("prop_hit" if strong else "hit", 0.12)
		hitstop = 0.09 if strong else 0.055
		shake = maxf(shake, 5.0 if strong else 2.0)
	other.hp = maxf(0.0, other.hp)

var shots_side := 1.0

func _advance_shots(delta: float) -> void:
	for i in range(shots.size() - 1, -1, -1):
		var shot: Dictionary = shots[i]
		shot.x += shot.vx * delta
		var target: Dictionary = fighters[1 - int(shot.owner)]
		if absf(shot.x - target.x) < 16.0 and absf(shot.y - (GROUND + target.y - 74.0)) < 60.0:
			shots_side = signf(shot.vx)
			_land(int(shot.owner), float(shot.dmg), false, Vector2(shot.x, shot.y),str(shot.get("height","mid")))
			shots.remove_at(i)
			continue
		if shot.x < -20.0 or shot.x > 660.0:
			shots.remove_at(i)
	# Zwei Geschosse heben sich auf.
	for i in range(shots.size() - 1, 0, -1):
		for j in range(i - 1, -1, -1):
			if i < shots.size() and shots[i].owner != shots[j].owner and absf(shots[i].x - shots[j].x) < 14.0:
				hits.append({"p": Vector2(shots[i].x, shots[i].y), "t": 0.2, "d": 0.2, "s": 1.0, "c": Color.WHITE})
				shots.remove_at(i); shots.remove_at(j)
				_sound("prop_metal")
				break

func _end_round() -> void:
	var a: float = fighters[0].hp / float(fighters[0].data.hp)
	var b: float = fighters[1].hp / float(fighters[1].data.hp)
	winner = -1 if is_equal_approx(a, b) else (0 if a > b else 1)
	phase = "ko"
	phase_time = 0.0
	banner = "K.O." if minf(a, b) <= 0.0 else "ZEIT!"
	if winner < 0: banner = "UNENTSCHIEDEN"
	for index in 2:
		if fighters[index].hp <= 0.0:
			fighters[index].state = "ko"; fighters[index].t = 0.0
			_launch(fighters[index],-220.0,fighters[index].vx)
	if winner >= 0: wins[winner] += 1
	shots.clear()
	shake = 8.0
	hitstop = 0.25
	_sound("enemy_death_0")

func _next_round() -> void:
	if wins[0] >= ROUNDS_TO_WIN or wins[1] >= ROUNDS_TO_WIN:
		screen = Screen.RESULT
		menu_index = 0
		winner = 0 if wins[0] > wins[1] else 1
		if winner == 0 and not versus:
			total_wins += 1
			_remember()
		_sound("calib_lock")
		return
	round_number += 1
	_start_round()

# --- CPU ---------------------------------------------------------------------------------------

func _cpu_controls(delta: float) -> Dictionary:
	var me: Dictionary=fighters[1];var foe: Dictionary=fighters[0]
	var h:={"left":false,"right":false,"up":false,"down":false}
	var p:={"up":false,"a":false,"b":false,"c":false,"d":false}
	if not cpu_sequence.is_empty():
		cpu_sequence_time+=delta
		if cpu_sequence_time>=0.065:
			cpu_sequence_time=0;cpu_sequence_step+=1
		if cpu_sequence_step>=cpu_sequence.size():
			p[cpu_attack]=true;cpu_sequence.clear()
		else:
			var code: int=cpu_sequence[cpu_sequence_step]
			h.down=code in [1,2,3];h.up=code in [7,8,9]
			var x:=(-1 if code in [1,4,7] else 1 if code in [3,6,9] else 0)*int(me.face)
			h.left=x<0;h.right=x>0
			return {"held":h,"pressed":p}
		# Finish on the final direction, not neutral, including a skipped diagonal.
		h.right=me.face>0;h.left=me.face<0
		return {"held":h,"pressed":p}
	var gap: float=absf(foe.x-me.x)
	cpu_plan.block=maxf(0,float(cpu_plan.block)-delta);cpu_think-=delta
	if cpu_think<=0:
		cpu_think=rng.randf_range(0.14,0.3);cpu_plan.dir=0.0
		var threatened: bool=(MOVES.has(foe.state) and gap<115) or _incoming(1)
		if threatened and rng.randf()<0.55:cpu_plan.block=rng.randf_range(0.2,0.4)
		elif foe.y< -20 and gap<115 and rng.randf()<0.5:
			cpu_sequence.assign([6,2,3]);cpu_sequence_step=0;cpu_sequence_time=0;cpu_attack="b"
		elif gap>float(me.data.reach)*REACH-4:
			if str(me.data.special) in ["shot","dash"] and gap<360 and rng.randf()<0.4:
				cpu_sequence.assign([2,3,6]);cpu_sequence_step=0;cpu_sequence_time=0;cpu_attack="a"
			else:
				cpu_plan.dir=signf(foe.x-me.x)
				if rng.randf()<0.10:p.up=true;h.up=true
		else:
			var roll:=rng.randf()
			if roll<0.14 and me.meter>=SPECIAL_COST:p.d=true
			elif roll<0.44:p.a=true
			elif roll<0.69:p.b=true
			elif roll<0.83:p.c=true
			else:cpu_plan.dir=-float(me.face)
	if not cpu_sequence.is_empty():return _cpu_controls(0)
	if float(cpu_plan.block)>0:
		h.left=me.face>0;h.right=me.face<0
		h.down=foe.get("attack_height","mid")=="low"
	elif float(cpu_plan.dir)<0:h.left=true
	elif float(cpu_plan.dir)>0:h.right=true
	return {"held":h,"pressed":p}

func _incoming(index: int) -> bool:
	for shot in shots:
		if int(shot.owner) != index and absf(float(shot.x) - float(fighters[index].x)) < 150.0: return true
	return false

# --- Zeichnen ----------------------------------------------------------------------------------

func _animate(f: Dictionary, delta: float) -> void:
	f.anim += delta

## Pose selection shares the same wind-up/contact/recovery windows as damage.
func pose_index(f: Dictionary) -> int:
	if f.state == "ko": return 6 if f.y < 0.0 else 7
	if (screen == Screen.RESULT or phase == "ko") and winner >= 0 and f == fighters[winner]: return 14
	match str(f.state):
		"block": return 5
		"crouch","block_low": return 15
		"hurt": return 6
		"jump": return 4
		"walk": return [2, 0, 3, 1][int(f.anim * 10.0) % 4]
	if MOVES.has(f.state):
		if f.get("attack_height","mid")=="low" and f.state in ["light","medium"]:return 15
		var move: Dictionary = MOVES[f.state]
		var first := 8 if f.state == "light" else 10 if f.state in ["medium","heavy","rise"] else 12
		if f.state == "flurry" and f.t >= move.start and f.t <= move.active:
			return 13 if fmod(f.t - move.start, 0.15) < 0.10 else 12
		return first + 1 if f.t >= move.start and f.t <= move.active else first
	if f.get("land", 0.0) > 0.0: return 15
	return int(f.anim * 3.0) % 2

func _frame(f: Dictionary) -> Rect2:
	var pose := pose_index(f)
	return Rect2(Vector2(pose % 4, pose / 4) * CELL, CELL)

func emitter(f: Dictionary) -> Vector2:
	var point: Array = ATLAS.data.fighters[f.data.id].emitter
	return Vector2(f.x + point[0] * SCALE * f.face, GROUND + f.y + point[1] * SCALE)

func _draw_fighter(c: CanvasItem, f: Dictionary, offset: Vector2) -> void:
	var feet := Vector2(f.x, GROUND + f.y) + offset
	var size := CELL * SCALE
	var lift := clampf(1.0 + float(f.y) / 160.0, 0.45, 1.0)
	ART.centered(c, 7, Vector2(f.x, GROUND + 3.0) + offset, Vector2(68, 18) * lift, Color(1, 1, 1, 0.7 * lift))
	var tint := Color.WHITE
	if f.flash > 0.0: tint = Color(2.2, 2.2, 2.2) if int(f.flash * 30.0) % 2 == 0 else Color(1.6, 0.6, 0.6)
	if f.state == "dash" and f.t >= 0.1 and f.t < 0.34:
		for ghost in 3:
			c.draw_set_transform(feet - Vector2(f.face * 26.0 * (ghost + 1), 0.0), 0.0, Vector2(f.face, 1.0))
			c.draw_texture_rect_region(sheets[f.data.id], Rect2(-ANCHOR * SCALE, size), _frame(f), Color(f.data.color, 0.32 - ghost * 0.09))
	# Real hurt/lying/block poses; never rotate a standing body into a K.O.
	c.draw_set_transform(feet, 0.0, Vector2(f.face, 1.0))
	c.draw_texture_rect_region(sheets[f.data.id], Rect2(-ANCHOR * SCALE, size), _frame(f), tint)
	c.draw_set_transform(Vector2.ZERO)

func _draw_stage() -> void:
	var c: Node2D = stage_node
	var offset := Vector2(sin(clock * 61.0), cos(clock * 47.0)) * shake
	c.draw_texture_rect(STAGE, Rect2(offset * 0.5 - Vector2(6, 4), VIEW + Vector2(12, 8)), false, Color(0.42, 0.42, 0.5) if screen != Screen.FIGHT else Color.WHITE)
	if screen != Screen.FIGHT and screen != Screen.RESULT: return
	var order := [0, 1] if not MOVES.has(str(fighters[0].state)) else [1, 0]
	for index in order: _draw_fighter(c, fighters[index], offset)

func _text(c: CanvasItem, text: String, at: Vector2, size: int, color: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0, kind: String = "title") -> void:
	text = GameText.t(text)
	var font := UiSkin.font(kind)
	c.draw_string_outline(font, at, text, align, width, size, 4, Color(0.03, 0.02, 0.07))
	c.draw_string(font, at, text, align, width, size, color)

func _bar(c: CanvasItem, area: Rect2, value: float, color: Color, mirrored: bool) -> void:
	c.draw_rect(area.grow(2.0), Color("0b0c16"))
	c.draw_rect(area.grow(1.0), Color("3b4666"), false, 1.0)
	c.draw_rect(area, Color("26131c"))
	var fill := Rect2(area.position, Vector2(roundf(area.size.x * clampf(value, 0.0, 1.0)), area.size.y))
	if mirrored: fill.position.x = area.end.x - fill.size.x
	c.draw_rect(fill, color)
	c.draw_rect(Rect2(fill.position, Vector2(fill.size.x, 2.0)), color.lightened(0.45))

func _draw_hud() -> void:
	var c: Node2D = hud_node
	var pink := Color("ff3e96")
	var cyan := Color("54e8f8")
	var gold := Color("ffd46b")
	match screen:
		Screen.TITLE:
			_text(c, "NEON KOMBAT", Vector2(0, 104), 48, pink, HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "ECHOS IN NEON · ARCADE", Vector2(0, 128), 16, cyan, HORIZONTAL_ALIGNMENT_CENTER, 640)
			var entries := ["1 SPIELER · GEGEN CPU", "2 SPIELER · DUELL", "AUTOMAT VERLASSEN"]
			for i in entries.size():
				var chosen := i == menu_index
				if chosen: c.draw_rect(Rect2(190, 163 + i * 30, 260, 24), Color(pink, 0.28 + 0.1 * sin(clock * 6.0)))
				c.draw_rect(Rect2(190, 163 + i * 30, 260, 24), pink if chosen else Color("3b4666"), false, 1.0)
				_text(c, entries[i], Vector2(190, 180 + i * 30), 16, Color.WHITE if chosen else Color("9aa6c8"), HORIZONTAL_ALIGNMENT_CENTER, 260)
			_text(c, "S1  WASD · J LIGHT · K MEDIUM · L HEAVY · H SPECIAL", Vector2(0, 288), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "S2  PFEILE · U LIGHT · I MEDIUM · O HEAVY · P SPECIAL", Vector2(0, 302), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "PAD X/Y/B/A = L/M/H/S · ZURÜCK BLOCK · RUNTER-ZURÜCK TIEFBLOCK", Vector2(0, 316), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "236 + L/M/H · 623 + L/M/H · [4]6 + L/M/H · CPU-SIEGE: %d" % total_wins, Vector2(0, 340), 8, gold, HORIZONTAL_ALIGNMENT_CENTER, 640)
		Screen.SELECT:
			_text(c, "KÄMPFER WÄHLEN", Vector2(0, 40), 32, pink, HORIZONTAL_ALIGNMENT_CENTER, 640)
			for i in ROSTER.size():
				var card := Rect2(70 + (i % 5) * 102, 58 + (i / 5) * 118, 92, 108)
				c.draw_rect(card, Color(0.04, 0.05, 0.11, 0.86))
				c.draw_texture_rect_region(sheets[ROSTER[i].id], Rect2(card.position + Vector2(14, 6), Vector2(64, 80)), Rect2(Vector2((int(clock * 3.0) % 2 if i in cursors else 0) * CELL.x + 96, 24), Vector2(256, 280)))
				_text(c, str(ROSTER[i].name), Vector2(card.position.x, card.end.y - 7), 8, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, card.size.x)
				c.draw_rect(card, Color("3b4666"), false, 1.0)
				for index in 2:
					if cursors[index] != i: continue
					var color := pink if index == 0 else cyan
					var blink := locked[index] or int(clock * 6.0) % 2 == 0
					if blink: c.draw_rect(card.grow(1.0 + index * 2.0), color, false, 2.0)
					_text(c, (GameText.t("S%d") % (index + 1)) if versus or index == 0 else "CPU", card.position + Vector2(3 if index == 0 else 64, 11), 8, color)
			for index in 2:
				var data: Dictionary = ROSTER[cursors[index]]
				var x := 20.0 if index == 0 else 330.0
				_text(c, "%s%s" % [data.name, "  · BEREIT" if locked[index] else ""], Vector2(x, 312), 16, pink if index == 0 else cyan, HORIZONTAL_ALIGNMENT_LEFT if index == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 290)
				_text(c, "SPEZIAL · %s    LEBEN %d · TEMPO %d" % [data.move, data.hp, int(data.speed)], Vector2(x, 326), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_LEFT if index == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 290)
			_text(c, "A / E / ENTER WÄHLEN · ESC PAUSE", Vector2(0, 350), 8, gold, HORIZONTAL_ALIGNMENT_CENTER, 640)
		Screen.FIGHT, Screen.RESULT:
			var offset := Vector2(sin(clock * 61.0), cos(clock * 47.0)) * shake
			for shot in shots:
				var dir := signf(shot.vx)
				c.draw_set_transform(Vector2(shot.x, shot.y) + offset, 0.0, Vector2(dir, 1.0))
				ART.draw(c, int(shot.get("art", 5)), Rect2(0, -9, 40, 18))
				c.draw_set_transform(Vector2.ZERO)
			for hit in hits:
				var age: float = 1.0 - hit.t / float(hit.d)
				var side: float = 48.0 * float(hit.s)
				ART.centered(c, 8 + mini(3, int(age * 4.0)), hit.p + offset, Vector2(side, side))

			_text(c,"HOCH / SCHRÄG-HOCH: SPRUNG · RUNTER: DUCKEN · ZURÜCK / TIEF-ZURÜCK: BLOCK",Vector2(0,337),8,Color("c8d2f0"),HORIZONTAL_ALIGNMENT_CENTER,640)
			_text(c,"L/M/H: J/K/L · S: H / PAD A (50) · 236 / 623 / [4]6 + L/M/H",Vector2(0,351),8,Color("7fe3ee"),HORIZONTAL_ALIGNMENT_CENTER,640)
			for index in 2:
				var f: Dictionary = fighters[index]
				var left := index == 0
				var bar := Rect2(24 if left else 346, 22, 270, 12)
				_bar(c, bar, f.hp / float(f.data.hp), Color("ffd46b") if f.hp / float(f.data.hp) > 0.3 else Color("ff4b5c"), left)
				_bar(c, Rect2(24 if left else 486, 40, 130, 5), f.meter / 100.0, cyan if f.meter >= SPECIAL_COST else Color("3f7fa8"), left)
				_text(c, str(f.data.name) + ("" if versus or left else " · CPU"), Vector2(24 if left else 346, 16), 8, pink if left else cyan, HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT, 270)
				if f.meter >= SPECIAL_COST and int(clock * 4.0) % 2 == 0:
					_text(c, "S · EX", Vector2(160 if left else 346, 46), 8, cyan, HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT, 134)
				for pip in ROUNDS_TO_WIN:
					var px := (24.0 + pip * 10.0) if left else (608.0 - pip * 10.0)
					c.draw_rect(Rect2(px, 50, 7, 7), gold if wins[index] > pip else Color("26131c"))
					c.draw_rect(Rect2(px, 50, 7, 7), Color("0b0c16"), false, 1.0)
				if f.command_t>0:_text(c,str(f.command),Vector2(24 if left else 346,68),8,cyan,HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT,270)
				elif inputs[index].charge_fraction()>0.05:_text(c,"CHARGE %d / 45"%mini(45,int(inputs[index].charge_fraction()*45)),Vector2(24 if left else 346,68),8,gold,HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT,270)
				if f.combo >= 2 and f.combo_t > 0.0:
					_text(c, "%d TREFFER!" % f.combo, Vector2(24 if left else 346, 84), 16, gold, HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT, 270)
			c.draw_rect(Rect2(300, 14, 40, 26), Color("0b0c16"))
			c.draw_rect(Rect2(300, 14, 40, 26), pink, false, 1.0)
			_text(c, "%02d" % int(ceilf(timer)), Vector2(300, 34), 16, Color.WHITE if timer > 10.0 else Color("ff4b5c"), HORIZONTAL_ALIGNMENT_CENTER, 40)
			if screen == Screen.FIGHT and banner != "":
				_text(c, banner, Vector2(0, 170), 48, gold if phase == "ko" else Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 640)
			if screen == Screen.RESULT:
				c.draw_rect(Rect2(0, 0, 640, 360), Color(0.02, 0.02, 0.06, 0.6))
				var champion := str(fighters[winner].data.name)
				_text(c, champion + " GEWINNT", Vector2(0, 110), 32, pink if winner == 0 else cyan, HORIZONTAL_ALIGNMENT_CENTER, 640)
				_text(c, "%d : %d" % [wins[0], wins[1]], Vector2(0, 136), 16, gold, HORIZONTAL_ALIGNMENT_CENTER, 640)
				var options := ["REVANCHE", "KÄMPFERWAHL", "TITELBILD"]
				for i in options.size():
					var chosen := i == menu_index
					if chosen: c.draw_rect(Rect2(230, 163 + i * 30, 180, 24), Color(pink, 0.3))
					c.draw_rect(Rect2(230, 163 + i * 30, 180, 24), pink if chosen else Color("3b4666"), false, 1.0)
					_text(c, options[i], Vector2(230, 180 + i * 30), 16, Color.WHITE if chosen else Color("9aa6c8"), HORIZONTAL_ALIGNMENT_CENTER, 180)
	# Röhrenbild: feine Zeilen und Rahmen des Automaten.
	for row in range(0, 360, 3):
		c.draw_rect(Rect2(0, row, 640, 1), Color(0, 0, 0, 0.1))
	c.draw_rect(Rect2(0, 0, 640, 360), Color("0b0c16"), false, 6.0)
	c.draw_rect(Rect2(3, 3, 634, 354), Color(pink, 0.7), false, 1.0)
