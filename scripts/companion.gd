extends Node2D
## v0.53.0 · ClaudeHelper: Begleiter für Spieler 2, wenn nur EIN Held spielbar ist.
##   Raven allein   → ihre Aufklärungsdrohne: Schüsse und Störimpuls (Hack)
##   Shadepi allein → ein Schwarm weiß leuchtender Naniten: Biss (rot beim Angriff) und Schutzschwarm
## Ohne zweiten Spieler folgt der Begleiter dem Helden von selbst und greift nicht ein,
## damit sich das Solospiel nicht verändert. Spieler 2 übernimmt mit seiner Schuss- oder
## Hack-Taste und gibt nach 25 s ohne Eingabe wieder ab. Der Begleiter fliegt, hat keine
## Kollision und kann nicht sterben; ein Treffer in der Nähe lässt ihn nur kurz aussetzen.
## Pixelquellen: assets/sprites/companions/ (tools/companions/build_companions.py).

const DRONE := preload("res://assets/sprites/companions/drone.png")
const NANITES := preload("res://assets/sprites/companions/nanites.png")
const DRONE_FRAME := Vector2(28, 22)
const MOTE := Vector2(7, 7)
const SPEED := 150.0
const LEASH := 170.0            # weiter entfernt kehrt der Begleiter zum Helden zurück
const IDLE_RELEASE := 25.0
const SHOT_RANGE := 210.0
const SHOT_DAMAGE := 7
const SHOT_COOLDOWN := 0.42
const BITE_RANGE := 64.0
const BITE_DAMAGE := 9
const BITE_COOLDOWN := 0.6
const HACK_COOLDOWN := 6.0
const HACK_RANGE := 120.0
const MOTE_COUNT := 26

var world: Node
var kind := ""                 # "drone", "nanites" oder "" (kein Begleiter in dieser Lage)
var lead: PixelActor
var claimed := false           # true: Spieler 2 steuert
var idle := 0.0
var clock := 0.0
var presence := 0.0            # weiches Ein-/Ausblenden
var attack_cooldown := 0.0
var hack_cooldown := 0.0
var attack_flash := 0.0        # > 0: Mündungsfeuer bzw. roter Schwarm
var lunge := Vector2.ZERO      # Naniten schnellen kurz zum Ziel
var shield_time := 0.0
var facing := Vector2.DOWN
var pad_device := -1
var pad_events: Array = []
var arrows_taken := false
var motes: Array[Dictionary] = []

func _ready() -> void:
	z_index = 40
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	process_priority = 150
	var emissive := CanvasItemMaterial.new()
	emissive.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED   # Sensorauge und Naniten leuchten selbst
	material = emissive
	var seed_value := 7
	for i in MOTE_COUNT:
		seed_value = (seed_value * 1103515245 + 12345) & 0x7fffffff
		var a := float(seed_value % 1000) / 1000.0
		seed_value = (seed_value * 1103515245 + 12345) & 0x7fffffff
		var b := float(seed_value % 1000) / 1000.0
		motes.append({"shape": i % 8, "radius": 5.0 + a * 13.0, "speed": 1.4 + b * 2.6, "phase": a * TAU, "tilt": 0.35 + b * 0.5, "wobble": b * TAU})
	_bind_keys()
	Input.joy_connection_changed.connect(func(_device: int, _connected: bool): _bind_pad.call_deferred())
	_bind_pad.call_deferred()
	hide()

func _exit_tree() -> void:
	_release()
	_clear_pad()

# --- Eingabe ---------------------------------------------------------------------------------

func _bind_keys() -> void:
	var keys := {"pet_move_left": KEY_LEFT, "pet_move_right": KEY_RIGHT, "pet_move_up": KEY_UP, "pet_move_down": KEY_DOWN, "pet_attack": KEY_U, "pet_hack": KEY_O}
	for action: String in keys:
		if InputMap.has_action(action): continue
		InputMap.add_action(action, 0.35)
		var event := InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action, event)

func _clear_pad() -> void:
	for entry: Array in pad_events:
		if InputMap.has_action(entry[0]): InputMap.action_erase_event(entry[0], entry[1])
	pad_events.clear()
	pad_device = -1

## Spieler 2 nutzt im Koop sein eigenes Gamepad, sonst das zweite angeschlossene.
func _bind_pad() -> void:
	if world == null or not is_inside_tree(): return
	var pads := Input.get_connected_joypads()
	var wanted: int = world.gamepads.raven_device if world.gamepads.raven_device >= 0 else (pads[1] if pads.size() > 1 else -1)
	if wanted == pad_device: return
	_clear_pad()
	pad_device = wanted
	if wanted < 0: return
	for entry in [["pet_move_left", JOY_AXIS_LEFT_X, -1.0], ["pet_move_right", JOY_AXIS_LEFT_X, 1.0], ["pet_move_up", JOY_AXIS_LEFT_Y, -1.0], ["pet_move_down", JOY_AXIS_LEFT_Y, 1.0]]:
		var axis := InputEventJoypadMotion.new()
		axis.device = wanted
		axis.axis = entry[1]
		axis.axis_value = entry[2]
		InputMap.action_add_event(entry[0], axis)
		pad_events.append([entry[0], axis])
	for entry in [["pet_attack", JOY_BUTTON_X], ["pet_attack", JOY_BUTTON_RIGHT_SHOULDER], ["pet_hack", JOY_BUTTON_Y], ["pet_move_left", JOY_BUTTON_DPAD_LEFT], ["pet_move_right", JOY_BUTTON_DPAD_RIGHT], ["pet_move_up", JOY_BUTTON_DPAD_UP], ["pet_move_down", JOY_BUTTON_DPAD_DOWN]]:
		var button := InputEventJoypadButton.new()
		button.device = wanted
		button.button_index = entry[1]
		InputMap.action_add_event(entry[0], button)
		pad_events.append([entry[0], button])

## Solange Spieler 2 den Begleiter steuert, gehören die Pfeiltasten ihm – wie im Koop-Modus.
func _take_arrows(take: bool) -> void:
	if take == arrows_taken or world.coop:
		arrows_taken = take and not world.coop
		return
	arrows_taken = take
	var arrows := [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]
	var actions := ["move_left", "move_right", "move_up", "move_down"]
	for i in arrows.size():
		var event := InputEventKey.new()
		event.physical_keycode = arrows[i]
		Input.action_release(actions[i])
		if take: InputMap.action_erase_event(actions[i], event)
		elif not InputMap.action_has_event(actions[i], event): InputMap.action_add_event(actions[i], event)

func claim() -> void:
	if claimed or kind == "": return
	claimed = true
	idle = 0.0
	_take_arrows(true)
	world.toast(hint())

func _release() -> void:
	if not claimed: return
	claimed = false
	if world != null and is_instance_valid(world): _take_arrows(false)

func hint() -> String:
	var pad := pad_device >= 0
	if kind == "drone":
		return "Spieler 2 · Drohne: %s Bewegen · %s Schuss · %s Störimpuls" % ["Stick" if pad else "Pfeile", "X" if pad else "U", "Y" if pad else "O"]
	return "Spieler 2 · Naniten: %s Bewegen · %s Biss · %s Schutzschwarm" % ["Stick" if pad else "Pfeile", "X" if pad else "U", "Y" if pad else "O"]

# --- Ablauf ----------------------------------------------------------------------------------

func _paused() -> bool:
	return world.menu_open or world.terminal != null

func _process(delta: float) -> void:
	var next: PixelActor = world.companion_lead()
	var next_kind := "" if next == null else ("drone" if next == world.raven else "nanites")
	if next_kind != kind and presence <= 0.0:
		kind = next_kind
		lead = next
		if lead != null: position = lead.position + Vector2(-22, -40)
		# Im Koop erfährt Spieler 2 sofort, womit er jetzt spielt.
		if lead != null and world.coop and not claimed: world.toast(hint())
		attack_flash = 0.0
		shield_time = 0.0
	var wanted := 1.0 if next_kind == kind and kind != "" and not world.in_cinematic() else 0.0
	presence = move_toward(presence, wanted, delta * 3.0)
	visible = presence > 0.01
	modulate.a = presence
	if kind == "" or wanted <= 0.0:
		if wanted <= 0.0 and kind == "" : _release()
		queue_redraw()
		return
	if _paused():
		return
	clock += delta
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	hack_cooldown = maxf(0.0, hack_cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	shield_time = maxf(0.0, shield_time - delta)
	lunge = lunge.move_toward(Vector2.ZERO, delta * 260.0)
	if world.is_busy():
		_follow(delta)
		queue_redraw()
		return
	var move := Input.get_vector("pet_move_left", "pet_move_right", "pet_move_up", "pet_move_down")
	var wants_attack := Input.is_action_pressed("pet_attack")
	var wants_hack := Input.is_action_just_pressed("pet_hack")
	if not claimed and (wants_attack or wants_hack or (world.coop and move != Vector2.ZERO)):
		claim()
	if claimed:
		idle = 0.0 if (move != Vector2.ZERO or wants_attack or wants_hack) else idle + delta
		if idle >= IDLE_RELEASE:
			_release()
	if claimed and shield_time <= 0.0:
		if move != Vector2.ZERO:
			facing = move.normalized()
			position += move * SPEED * delta
		var offset := position - lead.position
		if offset.length() > LEASH:
			position = lead.position + offset.limit_length(LEASH)
		if wants_attack and attack_cooldown <= 0.0: attack()
		if wants_hack and hack_cooldown <= 0.0: hack()
	else:
		_follow(delta)
	queue_redraw()

func _follow(delta: float) -> void:
	# Schwebt schräg hinter der Schulter des Helden; der Schutzschwarm umschließt ihn.
	var side := -1.0 if lead.facing.x > 0.1 else 1.0
	var home := lead.position + (Vector2(0, -22) if shield_time > 0.0 else Vector2(side * 24.0, -42.0 if kind == "drone" else -30.0))
	position = position.lerp(home, 1.0 - exp(-delta * (9.0 if shield_time > 0.0 else 3.2)))
	if position.distance_to(home) > 3.0: facing = (home - position).normalized()

func _target(max_range: float) -> Node2D:
	var best: Node2D = null
	var best_score := INF
	for foe: Node2D in world.special_targets():
		var offset: Vector2 = foe.position + Vector2(0, -18) - position
		var distance := offset.length()
		if distance > max_range: continue
		# Bevorzugt, was in Blick-/Flugrichtung liegt.
		var score := distance * (1.0 if offset.normalized().dot(facing) > 0.2 else 1.6)
		if score < best_score:
			best_score = score
			best = foe
	return best

func attack() -> void:
	if lead == null or kind == "": return
	var foe := _target(SHOT_RANGE if kind == "drone" else BITE_RANGE)
	attack_cooldown = SHOT_COOLDOWN if kind == "drone" else BITE_COOLDOWN
	attack_flash = 0.16 if kind == "drone" else 0.45
	if kind == "drone":
		var muzzle := position + Vector2(0, 4)
		var hit: Vector2 = muzzle + facing * 90.0 if foe == null else foe.position + Vector2(0, -18)
		if foe != null: facing = (hit - muzzle).normalized()
		world.effects.weapon_trace(muzzle, hit, true)
		world.sound("pistol", 0.12)
		if foe != null:
			foe.take_damage(SHOT_DAMAGE, position)
			world.effects.burst(hit, Color("7defff"), 5)
	else:
		world.sound("slash", 0.12)
		if foe != null:
			var bite: Vector2 = foe.position + Vector2(0, -18)
			facing = (bite - position).normalized()
			lunge = (bite - position).limit_length(BITE_RANGE)
			foe.take_damage(BITE_DAMAGE, position)
			world.effects.burst(bite, Color("ff5a68"), 7)

func hack() -> void:
	if lead == null or kind == "": return
	hack_cooldown = HACK_COOLDOWN
	if kind == "drone":
		# Störimpuls: unterbricht alle Gegner in Reichweite kurz.
		world.sound("hack")
		world.effects.burst(position, Color("7defff"), 14)
		for foe: Node2D in world.special_targets():
			if foe.position.distance_to(position) <= HACK_RANGE and foe.has_method("hack_interrupt"):
				foe.hack_interrupt(1.4)
				world.effects.hack_arc(position, foe.position + Vector2(0, -20))
	else:
		# Schutzschwarm: die Naniten legen sich kurz um Shadepi und fangen Treffer ab.
		world.sound("hack")
		shield_time = 1.6
		lead.invulnerable = maxf(lead.invulnerable, 1.6)
		world.effects.burst(lead.position + Vector2(0, -24), Color("f2fbff"), 12)

# --- Bild ------------------------------------------------------------------------------------

func _draw() -> void:
	if kind == "drone":
		var bob := roundf(sin(clock * 3.2) * 2.0)
		var frame := int(clock * 14.0) % 4
		var row := 1 if attack_flash > 0.0 else 0
		# Weicher Bodenschatten, damit die Flughöhe lesbar ist.
		draw_texture_rect_region(NANITES, Rect2(Vector2(-6, 30 - bob * 0.5), Vector2(12, 4)), Rect2(Vector2(7, 0), MOTE), Color(0, 0, 0, 0.35))
		draw_texture_rect_region(DRONE, Rect2((Vector2(-14, -11 + bob)).round(), DRONE_FRAME), Rect2(Vector2(frame * DRONE_FRAME.x, row * DRONE_FRAME.y), DRONE_FRAME), Color(1, 1, 1, 1), false)
	elif kind == "nanites":
		var red := attack_flash > 0.0
		var spread := 1.9 if shield_time > 0.0 else 1.0
		for mote: Dictionary in motes:
			var t: float = clock * mote.speed + mote.phase
			var orbit := Vector2(cos(t) * mote.radius, sin(t * 1.3 + mote.wobble) * mote.radius * mote.tilt) * spread
			# Beim Biss schnellen die vorderen Naniten zum Ziel und kehren zurück.
			var reach: float = clampf(1.0 - mote.radius / 18.0, 0.0, 1.0)
			var at := (orbit + lunge * reach - MOTE * 0.5).round()
			draw_texture_rect_region(NANITES, Rect2(at, MOTE), Rect2(Vector2(mote.shape * MOTE.x, (MOTE.y if red else 0.0)), MOTE))
