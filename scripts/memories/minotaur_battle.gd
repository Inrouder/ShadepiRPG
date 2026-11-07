extends RefCounted
## Historical survival encounter. Only its local vitals change; the present is frozen.
const DURATION := 45.0
const UISkin = preload("res://scripts/ui_skin.gd")
var world: Node2D
var running := false
var elapsed := 0.0
var health := 100
var dead := false
var stage := 0
var hit_count := 0
var stagger := 0.0
var stun := 0.0
var attack_cooldown := 0.0
var attack_pose := 0.0
var dodge_cooldown := 0.0
var dodge_time := 0.0
var invulnerable := 0.0
var dodge_direction := Vector2.RIGHT
var stick := Vector2.ZERO
var held := {}
var next_attack := 1.4
var warning := 0.0
var fire_pose := 0.0
var volley := 0
var targets: Array[Vector2] = []
var markers: Array[Sprite2D] = []
var hud: CanvasLayer
var title: Label
var status: Label
var help: Label
var life: ProgressBar
var clock: ProgressBar

func _init(scene: Node2D) -> void: world = scene

func start() -> void:
	running = true
	for actor in world.squad+[world.tank]: world.cutscene.release(actor)
	hud = CanvasLayer.new()
	hud.layer = 11
	world.add_child(hud)
	var panel := Panel.new()
	panel.position = Vector2(12,10)
	panel.size = Vector2(616,69)
	panel.add_theme_stylebox_override("panel",UISkin.panel("order"))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(panel)
	title = label(Vector2(24,16),18)
	status = label(Vector2(24,39),14)
	life = bar(Vector2(24,62),Vector2(178,6),Color("ff667f"),100)
	clock = bar(Vector2(214,62),Vector2(402,6),Color("e8c77d"),DURATION)
	help = label(Vector2(18,315),12)
	help.text = "WASD / Pfeile / Stick · J / X / Maus: Schlag\nLeertaste / B: Ausweichen · Esc / Start: Pause"
	reset()

func label(point: Vector2,size: int) -> Label:
	var node := Label.new()
	node.position = point
	node.add_theme_font_override("font",UISkin.font())
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_shadow_color",Color.BLACK)
	node.add_theme_constant_override("shadow_offset_x",1)
	node.add_theme_constant_override("shadow_offset_y",1)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(node)
	return node

func bar(point: Vector2,size: Vector2,color: Color,maximum: float) -> ProgressBar:
	var node := ProgressBar.new()
	node.position = point
	node.size = size
	node.max_value = maximum
	node.show_percentage = false
	node.add_theme_font_size_override("font_size",1)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	node.add_theme_stylebox_override("fill",fill)
	var back := StyleBoxFlat.new()
	back.bg_color = Color("1c2938")
	node.add_theme_stylebox_override("background",back)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(node)
	# Adding the control refreshes theme minima; shrink after that refresh.
	node.size = size
	return node

func clear_inputs() -> void:
	held.clear()
	stick = Vector2.ZERO

func reset() -> void:
	elapsed = 0
	health = 100
	dead = false
	stage = 0
	hit_count = 0
	stagger = 0
	stun = 0
	attack_cooldown = 0
	attack_pose = 0
	dodge_cooldown = 0
	dodge_time = 0
	invulnerable = 0
	next_attack = 1.4
	volley = 0
	fire_pose = 0
	clear_inputs()
	clear_warning()
	world.squad[0].position = Vector2(550,360)
	world.squad[0].facing = Vector2.RIGHT
	world.squad[0].visual.modulate = Color.WHITE
	world.squad[0].animate("idle",0)
	update_hud()

func direction() -> Vector2:
	var keys := Vector2(float(held.has(KEY_D) or held.has(KEY_RIGHT))-float(held.has(KEY_A) or held.has(KEY_LEFT)),float(held.has(KEY_S) or held.has(KEY_DOWN))-float(held.has(KEY_W) or held.has(KEY_UP)))
	return (keys+stick).limit_length()

func handle_event(event: InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		if event.axis==JOY_AXIS_LEFT_X: stick.x = event.axis_value if absf(event.axis_value)>0.2 else 0.0
		if event.axis==JOY_AXIS_LEFT_Y: stick.y = event.axis_value if absf(event.axis_value)>0.2 else 0.0
		return true
	var key: int = event.keycode if event is InputEventKey else -1
	var button: int = event.button_index if event is InputEventJoypadButton else -1
	var moves := {JOY_BUTTON_DPAD_LEFT:KEY_LEFT,JOY_BUTTON_DPAD_RIGHT:KEY_RIGHT,JOY_BUTTON_DPAD_UP:KEY_UP,JOY_BUTTON_DPAD_DOWN:KEY_DOWN}
	if moves.has(button): key = moves[button]
	if key in [KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT]:
		if event.is_pressed(): held[key] = true
		else: held.erase(key)
		return true
	if not event.is_pressed() or (event is InputEventKey and event.echo): return true
	if dead:
		if key in [KEY_E,KEY_ENTER] or button==JOY_BUTTON_A: reset()
	elif key==KEY_SPACE or button==JOY_BUTTON_B: dodge()
	elif key==KEY_J or button==JOY_BUTTON_X or (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT): attack()
	return true

func dodge() -> void:
	if not running or dead or world.menu_open or dodge_cooldown>0: return
	dodge_direction = direction()
	if dodge_direction.length()<0.1: dodge_direction = world.squad[0].facing
	dodge_time = 0.24
	invulnerable = maxf(invulnerable,0.28)
	dodge_cooldown = 0.85
	world.effects.burst(world.squad[0].position,Color("a4d5e4"),5)

func attack() -> void:
	if not running or dead or world.menu_open or attack_cooldown>0 or dodge_time>0: return
	var player: PixelActor = world.squad[0]
	attack_cooldown = 0.38
	attack_pose = 0.24
	world.effects.slash(player.position+player.facing*26,player.facing)
	world.sound("slash")
	var offset: Vector2 = world.tank.position-player.position
	if offset.length()<124 and player.facing.dot(offset.normalized())>0.15:
		hit_count += 1
		stagger += 26
		world.effects.burst(world.tank.weak_point(),Color("f4ce8c"),8)
		if stagger>=100:
			stagger = 0
			stun = 1.3
			clear_warning()
			next_attack = 0.7
			world.tank.animate("hurt",0)
	update_hud()

func tick(delta: float) -> void:
	if not running or dead or world.closed or world.menu_open: return
	elapsed = minf(DURATION,elapsed+delta)
	stage = mini(2,int(elapsed/15))
	for field in ["attack_cooldown","attack_pose","dodge_cooldown","dodge_time","invulnerable","stun","fire_pose"]:
		set(field,maxf(0.0,float(get(field))-delta))
	var player: PixelActor = world.squad[0]
	var move := direction()
	if dodge_time>0: move = dodge_direction
	if move.length()>0.1: player.facing = move.normalized()
	player.velocity = move*(300 if dodge_time>0 else 128)
	player.move_and_slide()
	player.position = player.position.clamp(Vector2(330,292),Vector2(915,527))
	player.animate("attack" if attack_pose>0 else "walk" if move.length()>0.1 else "idle",delta)
	player.visual.modulate = Color(0.65,0.85,1,0.7) if invulnerable>0 else Color.WHITE
	# Reuse the actual white and robot combat atlases for covering fire.
	for i in [1,2]:
		world.squad[i].animate("strike" if fmod(elapsed+i,2.4)<0.25 else "guard",delta)
	if elapsed>=DURATION:
		update_hud()
		return
	if stun>0:
		world.tank.animate("hurt",delta)
	elif warning>0:
		warning = maxf(0,warning-delta)
		for marker in markers:
			marker.modulate.a = 0.45+sin(elapsed*24)*0.2
		if warning==0: resolve_volley()
	else:
		world.tank.animate("fire" if fire_pose>0 else "guard",delta)
		next_attack -= delta
		if next_attack<=0: begin_volley()
	update_hud()

func begin_volley() -> void:
	volley += 1
	warning = [0.95,0.75,0.58][stage]
	var point: Vector2 = world.squad[0].position
	targets.append(point)
	if stage>=1:
		targets.append(point+Vector2(62,0))
		targets.append(point-Vector2(62,0))
	if stage==2:
		targets.append(point+Vector2(0,60))
		targets.append(point-Vector2(0,60))
	for target in targets:
		# Existing HQ blast pixels signal the locked impact areas; no new art proxies.
		var marker := Sprite2D.new()
		marker.texture = world.map.region(0,3)
		marker.position = target
		marker.scale = Vector2.ONE*0.24
		marker.modulate = Color(1,0.25,0.18,0.6)
		marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		world.map.actors.add_child(marker)
		markers.append(marker)
	world.sound("drive_laser_warn")

func resolve_volley() -> void:
	fire_pose = 0.18
	world.tank.animation_name = ""
	world.tank.animate("fire",0)
	for target in targets:
		world.effects.weapon_trace(world.tank.muzzle(),target+Vector2(0,-14),false)
		world.map.impact(target)
		if world.squad[0].position.distance_to(target)<34: damage([18,23,29][stage])
	world.sound("pistol")
	clear_warning()
	next_attack = [1.15,0.8,0.5][stage]

func damage(amount: int) -> void:
	if dead or invulnerable>0 or not running: return
	health = maxi(0,health-amount)
	invulnerable = 0.65
	world.squad[0].flash_time = 0.2
	world.effects.burst(world.squad[0].position,Color("ff6f86"),8)
	if health==0:
		dead = true
		clear_inputs()
		world.squad[0].velocity = Vector2.ZERO
		world.squad[0].animate("hurt",0)
		clear_warning()
	update_hud()

func update_hud() -> void:
	title.text = "MINOTAURUS · DURCHHALTEN  %02d:%02d"%[int(ceilf(DURATION-elapsed))/60,int(ceilf(DURATION-elapsed))%60]
	status.text = "Leben %d · Panzerung hält · Taumeln %d%% · %s"%[health,int(stagger),["ABWEHR","SPERRFEUER","ÜBERMACHT"][stage]]
	life.value = health
	clock.value = DURATION-elapsed
	if dead:
		title.text = "SHADEPI GEFALLEN · E / A: NOCH EINMAL"
		status.text = "Der Erinnerungsknoten bleibt offen. Esc / Start: Pause"
	elif stun>0: status.text = "MINOTAURUS TAUMELT · Abstand gewinnen!"
	help.modulate = Color.WHITE if dodge_cooldown==0 else Color("9aabb9")

func clear_warning() -> void:
	warning = 0
	targets.clear()
	for marker in markers:
		if is_instance_valid(marker): marker.queue_free()
	markers.clear()

func finish() -> void:
	running = false
	clear_inputs()
	clear_warning()
	world.squad[0].velocity = Vector2.ZERO
	world.squad[0].visual.modulate = Color.WHITE
	if is_instance_valid(hud): hud.queue_free()
