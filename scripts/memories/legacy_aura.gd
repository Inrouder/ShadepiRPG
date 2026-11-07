extends Node
## Two atlas layers attached around the actual actor sprite; no body deformation.
const ART=preload("res://assets/memories/legacy/shadepi-aura.png")
var world: Node2D
var back: Sprite2D
var front: Sprite2D
var sound_player: AudioStreamPlayer
var frames: Array[AtlasTexture]=[]
var target: Node2D
var anchor_offset:=Vector2.ZERO
var power:=0.0
var elapsed:=0.0
var frame_index:=0
var quality:=2
func _ready() -> void:
	process_priority=110
	for index in 16:
		var left:=roundi((index%4)*ART.get_width()/4.0)
		var top:=roundi((index/4)*ART.get_height()/4.0)
		var right:=roundi((index%4+1)*ART.get_width()/4.0)
		var bottom:=roundi((index/4+1)*ART.get_height()/4.0)
		var texture:=AtlasTexture.new()
		texture.atlas=ART
		texture.region=Rect2(left,top,right-left,bottom-top)
		frames.append(texture)
	back=Sprite2D.new()
	front=Sprite2D.new()
	for sprite in [back,front]:
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale=Vector2.ONE*0.34
		add_child(sprite)
		sprite.hide()
	sound_player=AudioStreamPlayer.new()
	sound_player.volume_db=-22
	var stream=load("res://assets/audio/legacy_aura.wav").duplicate()
	if stream is AudioStreamWAV:
		stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin=0
		stream.loop_end=stream.data.size()/2
	sound_player.stream=stream
	add_child(sound_player)
	_apply_frame()
func attach_to(actor: Node2D, offset: Vector2=Vector2.ZERO) -> void:
	target=actor
	anchor_offset=offset
	back.reparent(actor,false)
	front.reparent(actor,false)
	var visual: Sprite2D=actor.visual if actor is PixelActor else actor.sprite
	actor.move_child(back,visual.get_index())
	actor.move_child(front,actor.get_child_count()-1)
	_apply_frame()
func set_power(value: float) -> void:
	power=clampf(value,0,1)
	_update_color(false)
	if power==0: sound_player.stop()
func _apply_frame() -> void:
	for layer in 2:
		var sprite: Sprite2D=back if layer==0 else front
		var texture: AtlasTexture=frames[frame_index+layer*8]
		sprite.texture=texture
		sprite.position=anchor_offset+Vector2(0,texture.region.size.y*(0.5-0.96))*sprite.scale
func _update_color(boost: bool) -> void:
	var pulse:=0.93+sin(elapsed*TAU*1.3)*0.05
	back.visible=power>0.001
	front.visible=power>0.001 and quality>0
	back.modulate=Color(1,1,1,power*pulse*(0.85 if quality>0 else 0.65))
	front.modulate=Color(1,1,1,power*(0.55 if boost else 0.35))
func _process(delta: float) -> void:
	if world==null or world.closed:
		set_power(0)
		return
	if world.menu_open:
		sound_player.stream_paused=true
		return
	var defeated: bool=world.phase=="final_battle" and world.battle!=null and world.battle.dead
	if defeated:
		sound_player.stream_paused=true
		return
	sound_player.stream_paused=false
	if power<=0: return
	elapsed+=delta
	frame_index=int(elapsed*(5 if quality==0 else 10))%8
	_apply_frame()
	var boost: bool=world.phase=="final_battle" and world.battle!=null and world.battle.attack_pose>0
	_update_color(boost)
	var enabled: bool=world.host!=null and world.host.audio_on
	if not enabled: sound_player.stop()
	elif not sound_player.playing and DisplayServer.get_name()!="headless" and AudioServer.get_driver_name()!="Dummy": sound_player.play()
