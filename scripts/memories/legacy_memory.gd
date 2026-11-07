extends "res://scripts/memories/attack_memory.gd"
const RUINS = preload("res://assets/memories/legacy/courtyard.png")
const Figure = preload("res://scripts/memories/legacy_figure.gd")
const Minotaur = preload("res://scripts/memories/minotaur.gd")
const FinalBattle = preload("res://scripts/memories/legacy_battle.gd")
const TRANSFER = preload("res://assets/memories/legacy/transfer.png")
var tanks: Array[PixelActor]=[]
var tank: PixelActor
var tableau: Node2D
var master: Node2D
var transfer: Sprite2D
var transfer_frame := -1
var transferred := false
var exhausted := false
var events: Array[String]=[]
func make_map() -> Node2D:
	var result=Map.new()
	result.background_texture=RUINS
	return result
func squad_ids() -> Array: return ["shadepi"]
func resident_count() -> int: return 0
func initial_bot_count() -> int: return 0
func _ready() -> void:
	super._ready()
	squad[0].position=Vector2(263,352)
	squad[0].hide()
	tableau=Figure.new()
	actors.add_child(tableau)
	tableau.position=Vector2(275,340)
	master=Figure.new()
	actors.add_child(master)
	master.position=Vector2(289,340)
	master.set_frame(4)
	master.hide()
	transfer=Sprite2D.new()
	transfer.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	transfer.scale=Vector2.ONE*0.08
	transfer.position=tableau.position+Vector2(-1,-29)
	transfer.z_index=4
	actors.add_child(transfer)
	transfer.hide()
	for i in 2:
		var mech=Minotaur.new()
		actors.add_child(mech)
		mech.prepare(self)
		mech.position=Vector2(940,350 if i==0 else 430)
		mech.hide()
		tanks.append(mech)
	tank=tanks[0]
func active() -> bool: return not closed and cutscene.running
func mark(value: String) -> void:
	if active(): events.append(value)
func sound(kind: String) -> void:
	if active() and not cutscene.skipping and host!=null: host.sound(kind,0.05)
func transfer_step(k: float) -> void:
	if not active(): return
	var index:=mini(7,int(k*8))
	if transfer_frame!=index:
		transfer_frame=index
		var frame:=AtlasTexture.new()
		frame.atlas=TRANSFER
		frame.region=Rect2((index%4)*384,(index/4)*512,384,512)
		transfer.texture=frame
		if not cutscene.skipping:
			effects.burst(tableau.position+Vector2(-8,-27),Color("edffff"),6)
			if index in [0,3,6]: sound("legacy_transfer")
	tableau.sprite.modulate=Color(1+k*0.25,1+k*0.25,1+k*0.25)

func play() -> void:
	if closed or cutscene.running: return
	cutscene.begin()
	phase="arrival"
	mark("master_held")
	await cutscene.letterbox(true)
	await cutscene.camera(Vector2(430,345),0.9,0.85)
	await cutscene.title("ERINNERUNG III","DAS VERMÄCHTNIS",1.8)
	if not active(): return
	await cutscene.camera(Vector2(295,320),1.0,1.85)
	phase="promise"
	await cutscene.say("MEISTER","Shadepi, du musst das Heiligtum beschützen. Das hat oberste Priorität.")
	if not active(): return
	await cutscene.say("SHADEPI","Ich werde es mit meinem Leben beschützen. Der Orden muss leben. Danke für alles, Meister.")
	if not active(): return
	mark("vow")
	phase="transfer"
	mark("transfer_started")
	tableau.set_frame(3)
	transfer.show()
	transfer_step(0)
	await cutscene.animate(transfer_step,3.6)
	if not active(): return
	transfer.hide()
	transferred=true
	mark("transfer_received")
	await cutscene.wait(0.6)
	if not active(): return
	await cutscene.fade(Color.BLACK,0.25)
	if not active(): return
	tableau.hide()
	master.show()
	squad[0].show()
	squad[0].facing=Vector2.RIGHT
	squad[0].animate("idle",0)
	await cutscene.fade(Color(0,0,0,0),0.3)
	await cutscene.camera(Vector2(630,340),1.0,0.72)
	await cutscene.walk(squad[0],Vector2(550,420),88)
	if not active(): return
	phase="two_minotaurs"
	for mech in tanks: mech.show()
	sound("drive_knock")
	cutscene.walk(tanks[0],Vector2(800,350),65)
	await cutscene.walk(tanks[1],Vector2(800,430),65)
	if not active(): return
	await cutscene.walk(tanks[1],Vector2(800,490),65)
	if not active(): return
	await cutscene.say("SHADEPI","Ihr bekommt das Heiligtum nicht.")
	if not active(): return
	await cutscene.letterbox(false)
	phase="final_battle"
	mark("last_stand")
	battle=FinalBattle.new(self)
	battle.start()
	if host!=null: host.set_music_section("boss")
	while active() and not cutscene.skipping and not battle.won:
		await cutscene.tick
	if cutscene.skipping: battle.resolve_skip()
	battle.finish()
	if not active(): return
	for i in 2:
		if not events.has("minotaur_%d_destroyed"%i): mark("minotaur_%d_destroyed"%i)
	mark("both_destroyed")
	if host!=null: host.set_music_section("chapter_5_echo")
	await cutscene.fade(Color.BLACK,0.25)
	if not active(): return
	squad[0].position=Vector2(690,410)
	squad[0].hide()
	tableau.position=squad[0].position
	tableau.sprite.modulate=Color.WHITE
	tableau.set_frame(6)
	tableau.show()
	await cutscene.letterbox(true)
	await cutscene.camera(Vector2(730,410),0.3,0.95)
	await cutscene.fade(Color(0,0,0,0),0.25)
	if not active(): return
	phase="collapse"
	await cutscene.wait(0.7)
	if not active(): return
	tableau.set_frame(7)
	exhausted=true
	mark("shadepi_collapsed")
	phase="stillness"
	await cutscene.wait(2.0)
	await cutscene.fade(Color.BLACK,0.8)
	if not active(): return
	cutscene.end(_complete)

func handle_event(event: InputEvent) -> bool:
	if closed: return false
	if phase=="final_battle" and battle!=null and battle.running and not menu_open:
		var key: int=event.keycode if event is InputEventKey else -1
		var button: int=event.button_index if event is InputEventJoypadButton else -1
		if not (event.is_pressed() and (key==KEY_ESCAPE or button==JOY_BUTTON_START)):
			return battle.handle_event(event)
	return super.handle_event(event)
func toggle_pause() -> void:
	if battle!=null: battle.clear_inputs()
	super.toggle_pause()
	if battle!=null and is_instance_valid(battle.hud): battle.hud.visible=not menu_open
func _physics_process(delta: float) -> void:
	if phase=="final_battle" and battle!=null: battle.tick(delta)
	else: super._physics_process(delta)
func cancel() -> void:
	if battle!=null: battle.finish()
	super.cancel()
func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and phase=="final_battle" and not menu_open and not closed: toggle_pause()
