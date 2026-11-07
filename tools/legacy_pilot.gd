extends RefCounted
## Input-only autopilot for tests/renderer captures. No health or damage shortcuts.
static func step(scene: Node2D) -> void:
	var battle=scene.battle
	if battle==null or not battle.running or battle.dead or battle.won or scene.menu_open: return
	var index: int=0 if battle.boss_health[0]>0 else 1
	var player: PixelActor=scene.squad[0]
	var goal: Vector2=scene.tanks[index].position-Vector2(88,0)
	var offset:=goal-player.position
	battle.stick=offset.normalized() if offset.length()>8 else Vector2.ZERO
	if battle.warning>0 and battle.warning<0.2 and battle.dodge_cooldown<=0 and battle.targets.any(func(t): return player.position.distance_to(t)<38):
		battle.stick=Vector2.LEFT
		var event:=InputEventJoypadButton.new()
		event.button_index=JOY_BUTTON_B
		event.pressed=true
		scene.handle_event(event)
	elif offset.length()<=9:
		player.facing=Vector2.RIGHT
		var event:=InputEventJoypadButton.new()
		event.button_index=JOY_BUTTON_X
		event.pressed=true
		scene.handle_event(event)
