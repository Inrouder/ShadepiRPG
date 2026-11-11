extends CanvasLayer
## v0.57.0 · ClaudeHelper (Nutzerauftrag vom 11. November 2026): Arcade-Automat „NEON KOMBAT“.
## Seitliches Kampfspiel mit den Figuren des Spiels – 1 Spieler gegen CPU oder 2 Spieler im Duell.
## Nutzt ausschließlich die vorhandenen Seitenansichten der Figurenblätter (Stand, Lauf, Angriff).
signal closed

const UiSkin = preload("res://scripts/ui_skin.gd")
const STAGE = preload("res://assets/arcade/stage-rooftop.webp")
const SPARKS = preload("res://assets/arcade/sparks.png")
const SAVE_PATH := "user://shadepi-arcade.cfg"
const VIEW := Vector2(640, 360)
const GROUND := 304.0
const WALLS := Vector2(36.0, 604.0)
const SCALE := 1.0                       # 128×160-Zelle in voller Größe
const REACH := 1.2                       # Reichweiten der Tabelle gelten für die kleinere Weltgröße
const CELL := Vector2(128, 160)
const FOOT := 152.0                      # Fußlinie in der Zelle
const GRAVITY := 980.0
const JUMP := -350.0
const ROUND_SECONDS := 60.0
const SPECIAL_COST := 50.0
const ROUNDS_TO_WIN := 2

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
	"heavy": {"start": 0.2, "active": 0.34, "total": 0.56, "push": 190.0, "lunge": 80.0},
	"dash": {"start": 0.1, "active": 0.34, "total": 0.5, "push": 150.0, "lunge": 0.0},
	"slam": {"start": 0.3, "active": 0.42, "total": 0.75, "push": 260.0, "lunge": 0.0},
	"flurry": {"start": 0.08, "active": 0.52, "total": 0.68, "push": 60.0, "lunge": 150.0},
	"shot": {"start": 0.16, "active": 0.2, "total": 0.46, "push": 110.0, "lunge": 0.0},
}
const KEYS := [
	{"left": [KEY_A], "right": [KEY_D], "up": [KEY_W], "down": [KEY_S], "a": [KEY_J], "b": [KEY_K], "c": [KEY_L], "ok": [KEY_E, KEY_SPACE]},
	{"left": [KEY_LEFT], "right": [KEY_RIGHT], "up": [KEY_UP], "down": [KEY_DOWN], "a": [KEY_U], "b": [KEY_I], "c": [KEY_O], "ok": [KEY_ENTER, KEY_KP_ENTER]},
]
const PAD := {"left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT, "up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN, "a": JOY_BUTTON_X, "b": JOY_BUTTON_Y, "c": JOY_BUTTON_B, "ok": JOY_BUTTON_A}

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
var held: Array[Dictionary] = [{}, {}]
var pressed: Array[Dictionary] = [{}, {}]
var sheets := {}
var stage_node: Node2D
var hud_node: Node2D
var rng := RandomNumberGenerator.new()
var total_wins := 0

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
		sheets[entry.id] = load(entry.sheet)
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		total_wins = int(config.get_value("arcade", "wins", 0))
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

## Tastatur: Spieler 1 WASD + J/K/L, Spieler 2 Pfeile + U/I/O. Gamepads: erstes Pad Spieler 1,
## zweites Spieler 2; im Duell mit nur einem Pad gehört es Spieler 2 (wie im Koop).
func _pad_for(index: int) -> int:
	var pads := Input.get_connected_joypads()
	pads.sort()
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
			back()
		get_viewport().set_input_as_handled()

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
	fighters.clear()
	for index in 2:
		var data: Dictionary = ROSTER[cursors[index]]
		fighters.append({"data": data, "x": 200.0 if index == 0 else 440.0, "y": 0.0, "vx": 0.0, "vy": 0.0, "face": 1.0 if index == 0 else -1.0, "hp": float(data.hp), "meter": 0.0 if round_number == 1 else 25.0, "state": "idle", "t": 0.0, "hit": 0, "anim": 0.0, "flash": 0.0, "combo": 0, "combo_t": 0.0, "blocking": false, "cool": 0.0})
	shots.clear(); hits.clear()
	timer = ROUND_SECONDS
	phase = "intro"
	phase_time = 0.0
	banner = "RUNDE %d" % round_number
	cpu_think = 0.6

func _process(delta: float) -> void:
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
	phase_time += delta
	for i in range(hits.size() - 1, -1, -1):
		hits[i].t -= delta
		if hits[i].t <= 0.0: hits.remove_at(i)
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
	for index in 2:
		var controls: Dictionary = _cpu_controls(delta) if index == 1 and not versus else {"held": held[index], "pressed": pressed[index]}
		_control(index, controls)
	for index in 2:
		_physics(fighters[index], fighters[1 - index], delta, {})
		_strike(index)
	_separate()
	_advance_shots(delta)
	if fighters[0].hp <= 0.0 or fighters[1].hp <= 0.0 or timer <= 0.0:
		_end_round()

func _control(index: int, controls: Dictionary) -> void:
	var f: Dictionary = fighters[index]
	var other: Dictionary = fighters[1 - index]
	var h: Dictionary = controls.held
	var p: Dictionary = controls.pressed
	f.cool = maxf(0.0, f.cool - get_process_delta_time())
	f.blocking = false
	if f.state in ["hurt", "ko"] or MOVES.has(f.state):
		return
	var grounded: bool = f.y >= 0.0
	if grounded:
		f.face = 1.0 if other.x >= f.x else -1.0
	var dir := float(int(h.get("right", false)) - int(h.get("left", false)))
	if grounded and h.get("down", false):
		f.blocking = true
		f.vx = 0.0
		f.state = "block"
		return
	f.vx = dir * float(f.data.speed) * (1.0 if grounded else 0.85)
	if grounded and p.get("up", false):
		f.vy = JUMP
		f.y = -1.0
		_sound("drive_near_miss", 0.1)
	f.state = "jump" if f.y < 0.0 else ("walk" if dir != 0.0 else "idle")
	var move := ""
	if p.get("c", false) and f.meter >= SPECIAL_COST and grounded: move = str(f.data.special)
	elif p.get("b", false): move = "heavy"
	elif p.get("a", false): move = "light"
	if move != "" and f.cool <= 0.0:
		_begin(f, move)

func _begin(f: Dictionary, move: String) -> void:
	f.state = move
	f.t = 0.0
	f.hit = 0
	if f.y >= 0.0: f.vx = 0.0
	if move not in ["light", "heavy"]:
		f.meter -= SPECIAL_COST
		f.flash = 0.25
		_sound("electric" if move == "shot" else "slash" if move == "dash" else "enemy_attack_0")
	else:
		_sound("slash" if f.data.id == "shadepi" else "enemy_attack_1", 0.12)

func _physics(f: Dictionary, other: Dictionary, delta: float, _unused: Dictionary) -> void:
	f.t += delta
	f.anim += delta
	f.flash = maxf(0.0, f.flash - delta)
	f.combo_t = maxf(0.0, f.combo_t - delta)
	if f.combo_t <= 0.0: f.combo = 0
	if MOVES.has(f.state):
		var move: Dictionary = MOVES[f.state]
		if f.state == "dash":
			f.vx = f.face * 760.0 if f.t >= move.start and f.t < move.active else 0.0
		elif f.t < move.active and f.y >= 0.0:
			f.vx = f.face * float(move.lunge) / float(move.active)
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
	if f.y < 0.0 or f.vy < 0.0:
		f.vy += GRAVITY * delta
		f.y += f.vy * delta
		if f.y >= 0.0:
			f.y = 0.0; f.vy = 0.0
	f.x = clampf(f.x + f.vx * delta, WALLS.x, WALLS.y)

func _separate() -> void:
	var a: Dictionary = fighters[0]
	var b: Dictionary = fighters[1]
	if a.state == "dash" or b.state == "dash": return
	var gap: float = b.x - a.x
	if absf(gap) < 34.0 and absf(a.y - b.y) < 80.0:
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
		"light", "heavy":
			if f.hit == 0 and gap > -8.0 and gap < reach + (10.0 if f.state == "heavy" else 0.0) and level:
				f.hit = 1
				_land(index, float(f.data[f.state]), f.state == "heavy")
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
				shots.append({"x": f.x + f.face * 44.0, "y": GROUND + f.y - 84.0, "vx": f.face * 400.0, "owner": index, "dmg": 14.0, "c": f.data.color})
				_sound("pistol", 0.1)

func _land(index: int, damage: float, strong: bool, point: Vector2 = Vector2.INF) -> void:
	var f: Dictionary = fighters[index]
	var other: Dictionary = fighters[1 - index]
	if other.state == "ko" or other.state == "dash": return
	var at := point if point != Vector2.INF else Vector2((f.x + other.x) * 0.5 + f.face * 8.0, GROUND + other.y - 86.0)
	var side: float = 1.0 if other.x >= f.x else -1.0
	if point != Vector2.INF: side = signf(float(shots_side))
	if f.state == "dash": side = -f.face          # Schattenschnitt: der Gegner bleibt hinter Shadepi zurück
	var push := float(MOVES[f.state].push) if MOVES.has(f.state) and point == Vector2.INF else 110.0
	if other.blocking and other.face == -side:
		other.hp -= damage * 0.2
		other.vx = side * push * 0.5
		other.meter = minf(100.0, other.meter + 4.0)
		hits.append({"p": at, "t": 0.2, "d": 0.2, "s": 0.8, "c": Color("7fd8ff")})
		_sound("prop_metal", 0.1)
		hitstop = 0.04
	else:
		other.hp -= damage
		other.state = "hurt"
		other.t = 0.0 if not strong else -0.14
		other.vx = side * push
		if strong and other.y >= 0.0:
			other.vy = -170.0; other.y = -1.0
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
			_land(int(shot.owner), float(shot.dmg), false, Vector2(shot.x, shot.y))
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
			fighters[index].vy = -220.0; fighters[index].y = -1.0
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
	var me: Dictionary = fighters[1]
	var foe: Dictionary = fighters[0]
	var h := {"left": false, "right": false, "down": false}
	var p := {"up": false, "a": false, "b": false, "c": false}
	var gap: float = absf(foe.x - me.x)
	var reach := float(me.data.reach) * REACH
	cpu_plan.block = maxf(0.0, float(cpu_plan.block) - delta)
	cpu_think -= delta
	if cpu_think <= 0.0:
		cpu_think = rng.randf_range(0.14, 0.3)
		cpu_plan.dir = 0.0
		var threatened: bool = (MOVES.has(foe.state) and gap < 110.0) or _incoming(1)
		if threatened and rng.randf() < 0.5:
			cpu_plan.block = rng.randf_range(0.25, 0.45)
		elif _incoming(1) and rng.randf() < 0.5:
			p.up = true
		elif gap > reach - 4.0:
			if str(me.data.special) == "shot" and me.meter >= SPECIAL_COST and gap > 150.0 and rng.randf() < 0.6: p.c = true
			elif str(me.data.special) == "dash" and me.meter >= SPECIAL_COST and gap < 190.0 and rng.randf() < 0.5: p.c = true
			else:
				cpu_plan.dir = signf(foe.x - me.x)
				if rng.randf() < 0.07: p.up = true
		else:
			var roll := rng.randf()
			if roll < 0.14 and me.meter >= SPECIAL_COST: p.c = true
			elif roll < 0.5: p.a = true
			elif roll < 0.74: p.b = true
			elif roll < 0.86: cpu_plan.dir = -signf(foe.x - me.x)
	if float(cpu_plan.block) > 0.0: h.down = true
	elif float(cpu_plan.dir) < 0.0: h.left = true
	elif float(cpu_plan.dir) > 0.0: h.right = true
	return {"held": h, "pressed": p}

func _incoming(index: int) -> bool:
	for shot in shots:
		if int(shot.owner) != index and absf(float(shot.x) - float(fighters[index].x)) < 150.0: return true
	return false

# --- Zeichnen ----------------------------------------------------------------------------------

func _animate(f: Dictionary, delta: float) -> void:
	f.anim += delta

## Zelle im Figurenblatt: Zustand × 8 Richtungen; Reihe 2 ist die Ansicht nach rechts.
func _frame(f: Dictionary) -> Rect2:
	var state := 0
	var column := int(f.anim * 8.0) % 8
	match str(f.state):
		"walk":
			state = 1; column = int(f.anim * 10.0) % 8
		"jump":
			state = 1; column = 2
		"light":
			state = 2; column = clampi(int(f.t / 0.3 * 6.0), 0, 5)
		"heavy":
			state = 2; column = clampi(int(f.t / 0.56 * 6.0), 0, 5)
		"dash", "slam", "flurry", "shot":
			state = 2; column = 2 + int(f.t * 14.0) % 4
		"hurt", "ko":
			state = 3; column = 0
	return Rect2(Vector2(column, state * 8 + 2) * CELL, CELL)

func _draw_fighter(c: CanvasItem, f: Dictionary, offset: Vector2) -> void:
	var feet := Vector2(f.x, GROUND + f.y) + offset
	var size := CELL * SCALE
	# Bodenschatten.
	var lift := clampf(1.0 + float(f.y) / 160.0, 0.45, 1.0)
	c.draw_set_transform(Vector2(f.x + offset.x, GROUND + 3.0 + offset.y), 0.0, Vector2(1.0, 0.28))
	c.draw_circle(Vector2.ZERO, 28.0 * lift, Color(0, 0, 0, 0.45 * lift))
	var angle := 0.0
	var tint := Color.WHITE
	if f.state == "hurt": angle = -0.22 * f.face
	if f.state == "ko":
		angle = -clampf(f.t * 5.0, 0.0, 1.0) * (PI * 0.5) * f.face
		feet.y -= sin(clampf(f.t * 5.0, 0.0, 1.0) * PI * 0.5) * 12.0
	if f.blocking: tint = Color(0.7, 0.85, 1.0)
	if f.flash > 0.0: tint = Color(2.2, 2.2, 2.2) if int(f.flash * 30.0) % 2 == 0 else Color(1.6, 0.6, 0.6)
	if f.state == "dash" and f.t >= 0.1 and f.t < 0.34:
		for ghost in 3:
			c.draw_set_transform(feet - Vector2(f.face * 26.0 * (ghost + 1), 0.0), 0.0, Vector2(f.face, 1.0))
			c.draw_texture_rect_region(sheets[f.data.id], Rect2(Vector2(-size.x * 0.5, -FOOT * SCALE), size), _frame(f), Color(f.data.color, 0.32 - ghost * 0.09))
	c.draw_set_transform(feet + Vector2(0, -6.0 if f.state == "ko" else 0.0), angle, Vector2(f.face, 1.0))
	c.draw_texture_rect_region(sheets[f.data.id], Rect2(Vector2(-size.x * 0.5, -FOOT * SCALE), size), _frame(f), tint)
	c.draw_set_transform(Vector2.ZERO)

func _draw_stage() -> void:
	var c: Node2D = stage_node
	var offset := Vector2(sin(clock * 61.0), cos(clock * 47.0)) * shake
	c.draw_texture_rect(STAGE, Rect2(offset * 0.5 - Vector2(6, 4), VIEW + Vector2(12, 8)), false, Color(0.42, 0.42, 0.5) if screen != Screen.FIGHT else Color.WHITE)
	if screen != Screen.FIGHT and screen != Screen.RESULT: return
	var order := [0, 1] if not MOVES.has(str(fighters[0].state)) else [1, 0]
	for index in order: _draw_fighter(c, fighters[index], offset)

func _text(c: CanvasItem, text: String, at: Vector2, size: int, color: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0, kind: String = "title") -> void:
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
			_text(c, "S1  WASD · J SCHLAG · K HIEB · L SPEZIAL · S BLOCKEN · W SPRUNG", Vector2(0, 288), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "S2  PFEILE · U SCHLAG · I HIEB · O SPEZIAL · RUNTER BLOCKEN · HOCH SPRUNG", Vector2(0, 302), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "GAMEPAD  X SCHLAG · Y HIEB · B SPEZIAL · A WÄHLEN · START ZURÜCK", Vector2(0, 316), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_CENTER, 640)
			_text(c, "SIEGE GEGEN DIE CPU: %d" % total_wins, Vector2(0, 340), 8, gold, HORIZONTAL_ALIGNMENT_CENTER, 640)
		Screen.SELECT:
			_text(c, "KÄMPFER WÄHLEN", Vector2(0, 40), 32, pink, HORIZONTAL_ALIGNMENT_CENTER, 640)
			for i in ROSTER.size():
				var card := Rect2(70 + (i % 5) * 102, 58 + (i / 5) * 118, 92, 108)
				c.draw_rect(card, Color(0.04, 0.05, 0.11, 0.86))
				c.draw_texture_rect_region(sheets[ROSTER[i].id], Rect2(card.position + Vector2(14, 6), Vector2(64, 80)), Rect2(Vector2(int(clock * 6.0) % 8 if i in cursors else 0, 0) * CELL, CELL))
				_text(c, str(ROSTER[i].name), Vector2(card.position.x, card.end.y - 7), 8, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, card.size.x)
				c.draw_rect(card, Color("3b4666"), false, 1.0)
				for index in 2:
					if cursors[index] != i: continue
					var color := pink if index == 0 else cyan
					var blink := locked[index] or int(clock * 6.0) % 2 == 0
					if blink: c.draw_rect(card.grow(1.0 + index * 2.0), color, false, 2.0)
					_text(c, ("S%d" % (index + 1)) if versus or index == 0 else "CPU", card.position + Vector2(3 if index == 0 else 64, 11), 8, color)
			for index in 2:
				var data: Dictionary = ROSTER[cursors[index]]
				var x := 20.0 if index == 0 else 330.0
				_text(c, "%s%s" % [data.name, "  · BEREIT" if locked[index] else ""], Vector2(x, 312), 16, pink if index == 0 else cyan, HORIZONTAL_ALIGNMENT_LEFT if index == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 290)
				_text(c, "SPEZIAL · %s    LEBEN %d · TEMPO %d" % [data.move, data.hp, int(data.speed)], Vector2(x, 326), 8, Color("c8d2f0"), HORIZONTAL_ALIGNMENT_LEFT if index == 0 else HORIZONTAL_ALIGNMENT_RIGHT, 290)
			_text(c, "A / E / ENTER WÄHLEN · ESC ZURÜCK", Vector2(0, 350), 8, gold, HORIZONTAL_ALIGNMENT_CENTER, 640)
		Screen.FIGHT, Screen.RESULT:
			var offset := Vector2(sin(clock * 61.0), cos(clock * 47.0)) * shake
			for shot in shots:
				var dir := signf(shot.vx)
				c.draw_rect(Rect2(shot.x - 9 + offset.x, shot.y - 2, 18, 4), shot.c)
				c.draw_rect(Rect2(shot.x - 5 + dir * 4 + offset.x, shot.y - 3, 8, 6), Color.WHITE)
				c.draw_rect(Rect2(shot.x - dir * 22 - 6 + offset.x, shot.y - 1, 12, 2), Color(shot.c, 0.5))
			for hit in hits:
				var age: float = 1.0 - hit.t / float(hit.d)
				var side: float = 48.0 * float(hit.s)
				c.draw_texture_rect_region(SPARKS, Rect2(hit.p + offset - Vector2(side, side) * 0.5, Vector2(side, side)), Rect2(mini(5, int(age * 6.0)) * 96, 0, 96, 96), Color(hit.c).lerp(Color.WHITE, 0.55))
			for index in 2:
				var f: Dictionary = fighters[index]
				var left := index == 0
				var bar := Rect2(24 if left else 346, 22, 270, 12)
				_bar(c, bar, f.hp / float(f.data.hp), Color("ffd46b") if f.hp / float(f.data.hp) > 0.3 else Color("ff4b5c"), left)
				_bar(c, Rect2(24 if left else 486, 40, 130, 5), f.meter / 100.0, cyan if f.meter >= SPECIAL_COST else Color("3f7fa8"), left)
				_text(c, str(f.data.name) + ("" if versus or left else " · CPU"), Vector2(24 if left else 346, 16), 8, pink if left else cyan, HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT, 270)
				if f.meter >= SPECIAL_COST and int(clock * 4.0) % 2 == 0:
					_text(c, "SPEZIAL", Vector2(160 if left else 346, 46), 8, cyan, HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT, 134)
				for pip in ROUNDS_TO_WIN:
					var px := (24.0 + pip * 10.0) if left else (608.0 - pip * 10.0)
					c.draw_rect(Rect2(px, 50, 7, 7), gold if wins[index] > pip else Color("26131c"))
					c.draw_rect(Rect2(px, 50, 7, 7), Color("0b0c16"), false, 1.0)
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
