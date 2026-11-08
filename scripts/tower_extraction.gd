extends Node2D
## v0.33.0 · CodexAI: Raven stays at the deck; three real hits restart protection.
const Tableau = preload("res://scripts/tower_tableau.gd")
const MAX_HITS := 3
const TRANSFER_SECONDS := 24.0
var world: Node2D
var tableau: Node2D
var active := false
var hits := 0
var elapsed := 0.0
var failed := false
var waves_done := false

func _ready() -> void:
	tableau = Tableau.new()
	world.actors.add_child(tableau)
	tableau.position = world.boss_spot
	world.kenzo_body.visual.hide()
	world.kenzo_body.cast_shadow.hide()
	world.kenzo_body.hide()
	world.kenzo_body.set_physics_process(false)
	tableau.show_pose("dead" if world.tower_stage>=2 else "kneel")

func begin() -> void:
	active = true
	hits = 0
	elapsed = 0
	failed = false
	waves_done = false
	world.reset_raven(world.boss_spot+Tableau.RAVEN_OFFSET)
	world.raven.health_floor = 1
	world.raven.visual.hide()
	world.raven.cast_shadow.hide()
	tableau.show_pose("extract")
	world.set_music_section("fight")
	world._spawn_wave()
	world.toast("SCHÜTZE RAVEN · 3 Treffer unterbrechen die Extraktion · Wachen abfangen")

func resume() -> void:
	if world.tower_stage==0:
		world.player.position = world.boss_spot+Vector2(-125,65)
		begin()
	elif world.tower_stage==1:
		world._scene_tower_resolution()
	elif world.tower_stage==3:
		world._scene_tower_departure()

func struck() -> void:
	if not active or failed: return
	hits += 1
	world.sound("hit")
	world.toast("RAVEN GETROFFEN · %d / %d · Wachen von ihr fernhalten"%[hits,MAX_HITS])
	if hits>=MAX_HITS:
		failed = true
		active = false
		world._retry.call_deferred("Extraktion unterbrochen · Raven dreimal getroffen · Abschnitt neu starten")

func completed_waves() -> void:
	if failed: return
	waves_done = true
	_finish_if_ready()

func _finish_if_ready() -> void:
	if not active or not waves_done or elapsed<TRANSFER_SECONDS: return
	active = false
	world.raven.health_floor = 0
	world.tower_stage = 1
	world.autosave()
	world._scene_tower_resolution.call_deferred()

func status_text() -> String:
	var value := 100 if world.tower_stage>=1 else mini(94,int(elapsed/TRANSFER_SECONDS*94))
	return "Raven schützen · %d %% · %d/%d Treffer"%[value,hits,MAX_HITS]

func _process(delta: float) -> void:
	if not active or world.is_busy(): return
	elapsed = minf(TRANSFER_SECONDS,elapsed+delta)
	world.raven.invulnerable = maxf(0,world.raven.invulnerable-delta)
	world.raven.knockback = Vector2.ZERO
	world.raven.velocity = Vector2.ZERO
	world.raven.position = world.boss_spot+Tableau.RAVEN_OFFSET
	world.raven.animate("idle",delta)
	tableau.raven.modulate = Color(2,0.65,0.65) if world.raven.flash_time>0 else Color.WHITE
	if int(elapsed*5)!=int((elapsed-delta)*5):
		world.effects.hack_arc(world.raven.position+Vector2(26,-44),world.boss_spot+Vector2(-4,-32))
	_finish_if_ready()

func _exit_tree() -> void:
	if is_instance_valid(world) and is_instance_valid(world.raven): world.raven.health_floor = 0
	if is_instance_valid(tableau): tableau.queue_free()
