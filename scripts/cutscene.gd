extends CanvasLayer
## In-engine cutscene director: letterbox, camera moves, scripted walks,
## subtitles, flashes and title cards. Scenes are written as coroutines:
##     var cs := world.begin_cutscene()
##     await cs.walk(world.raven, Vector2(640, 420))
##     await cs.say("RAVEN", "…")
##     cs.end(func(): start_fight())
## Every step becomes a no-op once the scene was aborted (checkpoint, retry,
## chapter jump), so stale coroutines can never change the next scene.
## Leertaste / B skips the remaining scene; E / Enter / A advances subtitles.

signal ended
signal tick

const BAR_TOP := 30.0
const BAR_BOTTOM := 68.0
const SPEAKER_COLORS := {
	"RAVEN": Color("7fe3ee"), "SHADEPI": Color("ff6f86"), "KENZŌ MORIYAMA": Color("e7b36a"),
	"CHROME JACKAL": Color("c7d2e4"), "HEILIGTUM": Color("b9f3ff"),
}

var world: Node2D
var running := false
var skipping := false
var generation := 0
var waiting_input := false
var top_bar: ColorRect
var bottom_bar: ColorRect
var overlay: ColorRect
var speaker_label: Label
var line_label: Label
var hint_label: Label
var title_label: Label
var subtitle_label: Label
var walkers := {}
var poses := {}
var camera_from := Vector2.ZERO
var camera_to := Vector2.ZERO
var zoom_from := 1.0
var zoom_to := 1.0
var camera_time := 0.0
var camera_duration := 0.0
var camera_moving := false
var bars := 0.0
var bars_target := 0.0
var hud_hidden := false
var home_zoom := 1.0

func _init() -> void:
	layer = 9
	process_priority = 100

func _ready() -> void:
	overlay = _rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, 0))
	top_bar = _rect(Rect2(0, -BAR_TOP, 640, BAR_TOP), Color("03060b"))
	bottom_bar = _rect(Rect2(0, 360, 640, BAR_BOTTOM), Color("03060b"))
	speaker_label = _label(Vector2(28, 5), Vector2(584, 14), 10, Color("7fe3ee"), bottom_bar)
	line_label = _label(Vector2(28, 18), Vector2(584, 36), 12, Color("e5edf3"), bottom_bar)
	line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label = _label(Vector2(330, 54), Vector2(290, 12), 8, Color("7f93a8"), bottom_bar)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_label.text = "E / A · Weiter     Leertaste / B · Überspringen"
	title_label = _label(Vector2(0, 140), Vector2(640, 34), 24, Color("f2f6fa"), self)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label = _label(Vector2(0, 176), Vector2(640, 18), 11, Color("ff7d92"), self)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for node in [title_label, subtitle_label]:
		node.add_theme_color_override("font_shadow_color", Color.BLACK)
		node.add_theme_constant_override("shadow_offset_x", 2)
		node.add_theme_constant_override("shadow_offset_y", 2)
		node.modulate.a = 0.0
	visible = false

func _rect(rect: Rect2, color: Color) -> ColorRect:
	var node := ColorRect.new()
	node.position = rect.position
	node.size = rect.size
	node.color = color
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func _label(point: Vector2, size: Vector2, font_size: int, color: Color, parent: Node) -> Label:
	var node := Label.new()
	node.position = point
	node.size = size
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

# --- lifecycle ---------------------------------------------------------------

func begin() -> int:
	abort()
	running = true
	skipping = false
	visible = true
	home_zoom = world.camera.zoom.x
	_refresh_actors()
	bars_target = 1.0
	return generation

func alive(gen: int) -> bool:
	return running and gen == generation

func end(callback: Callable = Callable()) -> void:
	if not running:
		return
	var gen := generation
	if not is_equal_approx(world.camera.zoom.x, home_zoom) or world.camera.position.distance_to(world.camera_home()) > 4.0:
		await camera(world.camera_home(), 0.55, home_zoom)
	await letterbox(false)
	if gen != generation:
		return
	_release()
	if callback.is_valid():
		callback.call()

func abort() -> void:
	generation += 1
	if running:
		_release()
	_reset_overlay()
	bars = 0.0
	bars_target = 0.0
	_layout_bars()

func _refresh_actors() -> void:
	# Health bars and markers hide during scenes; force a redraw of every actor.
	if world != null and world.actors != null:
		for node in world.actors.get_children():
			if node is CanvasItem:
				node.queue_redraw()

func _release() -> void:
	running = false
	_refresh_actors()
	waiting_input = false
	camera_moving = false
	for actor: PixelActor in walkers.keys():
		if is_instance_valid(actor):
			actor.velocity = Vector2.ZERO
	walkers.clear()
	poses.clear()
	bottom_bar.modulate.a = 1.0
	_reset_overlay()
	speaker_label.text = ""
	line_label.text = ""
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	_restore_hud()
	ended.emit()

func _reset_overlay() -> void:
	overlay.color = Color(0, 0, 0, 0)

func skip() -> void:
	# Fast-forward: every remaining step resolves instantly and synchronously,
	# so tests and impatient players reach the scene's end in this very call.
	if running:
		skipping = true
		waiting_input = false
		_reset_overlay()
		if camera_moving:
			_finish_camera()
		for actor: PixelActor in walkers.keys():
			if is_instance_valid(actor):
				actor.position = walkers[actor][0]
		walkers.clear()
		tick.emit()

func advance() -> void:
	waiting_input = false

func _paused() -> bool:
	return world == null or world.menu_open or world.terminal != null

func _frame(gen: int) -> bool:
	await tick
	return gen == generation

# --- steps -------------------------------------------------------------------

func wait(seconds: float) -> void:
	var gen := generation
	var elapsed := 0.0
	while elapsed < seconds and not skipping:
		if not await _frame(gen):
			return
		if not _paused():
			elapsed += get_process_delta_time()

func letterbox(show: bool) -> void:
	bars_target = 1.0 if show else 0.0
	if skipping:
		bars = bars_target
		_layout_bars()
		return
	var gen := generation
	while not is_equal_approx(bars, bars_target) and not skipping:
		if not await _frame(gen):
			return

func do(callback: Callable) -> void:
	if running:
		callback.call()

func camera(target: Vector2, seconds: float = 1.0, zoom: float = 1.0) -> void:
	if not running:
		return
	camera_from = world.camera.position
	camera_to = target
	zoom_from = world.camera.zoom.x
	zoom_to = zoom
	camera_time = 0.0
	camera_duration = maxf(0.01, seconds)
	camera_moving = true
	if skipping or seconds <= 0.0:
		_finish_camera()
		return
	var gen := generation
	while camera_moving and not skipping:
		if not await _frame(gen):
			return

func _finish_camera() -> void:
	camera_moving = false
	world.camera.position = camera_to
	world.camera.zoom = Vector2.ONE * zoom_to

func walk(actor: PixelActor, target: Vector2, speed: float = 82.0) -> void:
	if not running or not is_instance_valid(actor):
		return
	poses.erase(actor)
	if skipping:
		actor.position = target
		return
	walkers[actor] = [target, speed]
	var gen := generation
	while walkers.has(actor):
		if not await _frame(gen):
			return
		if skipping:
			actor.position = target
			walkers.erase(actor)

func face(actor: PixelActor, toward: Vector2) -> void:
	if running and is_instance_valid(actor) and toward != actor.position:
		actor.facing = (toward - actor.position).normalized()

func pose(actor: PixelActor, state: String) -> void:
	if running and is_instance_valid(actor):
		poses[actor] = state

func release(actor: PixelActor) -> void:
	poses.erase(actor)
	walkers.erase(actor)

## Drops an actor's sprite from above onto its standing pose (a roof jump).
func drop(actor: PixelActor, height: float, seconds: float = 0.4) -> void:
	if not running or not is_instance_valid(actor):
		return
	var base := actor.standing_visual_position.y
	if skipping:
		actor.visual.position.y = base
		return
	var gen := generation
	var t := 0.0
	actor.visual.position.y = base - height
	while t < seconds and not skipping:
		if not await _frame(gen):
			return
		if not _paused():
			t += get_process_delta_time()
		var k := clampf(t / seconds, 0.0, 1.0)
		actor.visual.position.y = base - height * (1.0 - k * k)
	actor.visual.position.y = base

## Speaks several [speaker, text] lines in order.
func lines(entries: Array) -> void:
	for entry: Array in entries:
		if not running:
			return
		await say(str(entry[0]), str(entry[1]))

## Jumps an actor along an arc to a new floor position (roof leaps, vaults).
func leap(actor: PixelActor, target: Vector2, height: float = 70.0, seconds: float = 0.6) -> void:
	if not running or not is_instance_valid(actor):
		return
	var start := actor.position
	var base := actor.standing_visual_position.y
	if not skipping:
		var gen := generation
		var t := 0.0
		while t < seconds and not skipping:
			if not await _frame(gen):
				return
			if not _paused():
				t += get_process_delta_time()
			var k := clampf(t / seconds, 0.0, 1.0)
			actor.position = start.lerp(target, k)
			actor.visual.position.y = base - sin(k * PI) * height
	actor.position = target
	actor.visual.position.y = base

func say(speaker: String, text: String) -> void:
	if not running or skipping:
		return
	var gen := generation
	speaker_label.text = speaker
	var key := speaker.split(" / ")[0]
	speaker_label.add_theme_color_override("font_color", SPEAKER_COLORS.get(key, Color("9fb4c8")))
	for page in _pages(text):
		if skipping:
			break
		line_label.text = page
		waiting_input = true
		while waiting_input:
			if not await _frame(gen):
				return
	speaker_label.text = ""
	line_label.text = ""

func _pages(text: String) -> Array[String]:
	var pages: Array[String] = []
	var font := line_label.get_theme_font("font")
	var current := ""
	for word in text.split(" "):
		var candidate := word if current.is_empty() else current + " " + word
		if not current.is_empty() and font.get_multiline_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, 584, 12).y > 36:
			pages.append(current)
			current = word
		else:
			current = candidate
	pages.append(current)
	return pages

func flash(color: Color, seconds: float = 0.35) -> void:
	if not running or skipping:
		return
	overlay.color = color
	var gen := generation
	var left := seconds
	while left > 0.0 and not skipping:
		if not await _frame(gen):
			return
		left -= get_process_delta_time()
		overlay.color.a = color.a * maxf(0.0, left / seconds)
	overlay.color.a = 0.0

func fade(color: Color, seconds: float) -> void:
	if not running:
		return
	var start := overlay.color
	var gen := generation
	var t := 0.0
	while t < seconds and not skipping:
		if not await _frame(gen):
			return
		if not _paused():
			t += get_process_delta_time()
		overlay.color = start.lerp(color, clampf(t / seconds, 0.0, 1.0))
	overlay.color = color

func title(text: String, sub: String = "", seconds: float = 2.2) -> void:
	if not running or skipping:
		return
	title_label.text = text
	subtitle_label.text = sub
	var gen := generation
	var t := 0.0
	while t < seconds and not skipping:
		if not await _frame(gen):
			return
		if not _paused():
			t += get_process_delta_time()
		var alpha := clampf(minf(t / 0.45, (seconds - t) / 0.45), 0.0, 1.0)
		title_label.modulate.a = alpha
		subtitle_label.modulate.a = alpha
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0

# --- per frame -----------------------------------------------------------------

func _process(delta: float) -> void:
	if not running and bars <= 0.0:
		visible = false
		return
	bars = move_toward(bars, bars_target, delta * 3.2)
	_layout_bars()
	if not running:
		return
	_hide_hud()
	hint_label.visible = waiting_input
	bottom_bar.modulate.a = 1.0
	if _paused():
		tick.emit()
		return
	if camera_moving:
		camera_time += delta
		var k := smoothstep(0.0, 1.0, clampf(camera_time / camera_duration, 0.0, 1.0))
		world.camera.position = camera_from.lerp(camera_to, k)
		world.camera.zoom = Vector2.ONE * lerpf(zoom_from, zoom_to, k)
		if camera_time >= camera_duration:
			_finish_camera()
	for actor: PixelActor in walkers.keys():
		if not is_instance_valid(actor):
			walkers.erase(actor)
			continue
		var target: Vector2 = walkers[actor][0]
		var step: float = walkers[actor][1] * delta
		var offset := target - actor.position
		if offset.length() <= step:
			actor.position = target
			walkers.erase(actor)
			actor.animate("idle", delta)
		else:
			actor.facing = offset.normalized()
			actor.position += actor.facing * step
			actor.animate("walk", delta)
	for actor: PixelActor in poses.keys():
		if is_instance_valid(actor) and not walkers.has(actor):
			actor.animate(poses[actor], delta)
	tick.emit()

func _layout_bars() -> void:
	var k := smoothstep(0.0, 1.0, bars)
	top_bar.position.y = -BAR_TOP + BAR_TOP * k
	bottom_bar.position.y = 360.0 - BAR_BOTTOM * k
	if bars <= 0.0 and not running:
		visible = false

func _hide_hud() -> void:
	if world.ui == null:
		return
	hud_hidden = true
	for node: CanvasItem in world.ui.game_hud_nodes:
		node.visible = false
	world.ui.controls.visible = false

func _restore_hud() -> void:
	if not hud_hidden or world == null or world.ui == null:
		return
	hud_hidden = false
	if world.ui.start_backdrop.visible:
		return
	for node: CanvasItem in world.ui.game_hud_nodes:
		node.visible = true
