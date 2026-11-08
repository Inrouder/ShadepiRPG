extends "res://scripts/enemy.gd"
## v0.33.0 · CodexAI: combat defeat disables Kenzō; execution is a later event.
var subdued := false

func _init() -> void:
	min_health = 1

func take_damage(amount: int, source: Vector2 = Vector2.INF) -> void:
	if subdued: return
	super.take_damage(amount, source)
	if health != 1: return
	subdued = true
	active = false
	windup = 0
	lunge = 0
	attack_visual_time = 0
	knock_velocity = Vector2.ZERO
	flash_time = 0
	body_material.set_shader_parameter("flash", 0.0)
	# Zero combat HP means defeated, not dead: no death voice, fall or corpse tween.
	health = 0
	world.enemy_defeated(self)
