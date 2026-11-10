extends Node
## v0.51.1 · CodexAI. One capped game image; original nodes retain viewport/input ownership.
## The root only presents this texture at larger outputs. No second simulation or scene routing.
const BASE := Vector2i(640,360)
const CAP := Vector2i(1920,1080)
const PRESENTATION_BIT := 1 << 20
# Godot reserves layer 1024 for embedded windows. Keep the output beneath it.
const PRESENTATION_LAYER := 512
var enabled := false
var target: SubViewport
var presentation: CanvasLayer
var image: TextureRect
var window: Window
var saved_cull_mask := 0xffffffff
var layers: Array[CanvasLayer] = []
var attached: Dictionary = {}

static func target_size(output: Vector2i, integer: bool = false) -> Vector2i:
	var scale := minf(float(output.x)/BASE.x,float(output.y)/BASE.y)
	if integer: scale = maxf(1,floorf(scale))
	scale = clampf(scale,1.0,3.0)
	# Exact 16:9, bounded to Full HD, including odd / ultrawide window sizes.
	var unit := clampi(int(floor(40.0*scale)),40,120)
	return Vector2i(unit*16,unit*9)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	window = get_window()
	target = SubViewport.new()
	target.name = "FullHDGameImage"
	target.size = Vector2i(2,2)
	target.size_2d_override = BASE
	target.size_2d_override_stretch = true
	target.gui_disable_input = true
	# A new SubViewport defaults to linear filtering and disabled pixel snapping.
	# Preserve the project's sampling contract rather than silently smoothing it.
	target.canvas_item_default_texture_filter = window.canvas_item_default_texture_filter
	target.canvas_item_default_texture_repeat = window.canvas_item_default_texture_repeat
	target.snap_2d_transforms_to_pixel = window.snap_2d_transforms_to_pixel
	target.snap_2d_vertices_to_pixel = window.snap_2d_vertices_to_pixel
	target.use_hdr_2d = window.use_hdr_2d
	target.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(target)
	presentation = CanvasLayer.new()
	presentation.name = "FullHDPresentation"
	presentation.layer = PRESENTATION_LAYER
	add_child(presentation)
	image = TextureRect.new()
	image.texture = target.get_texture()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.size = BASE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.visibility_layer = PRESENTATION_BIT
	var unlit := CanvasItemMaterial.new()
	unlit.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	image.material = unlit
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	presentation.add_child(image)
	presentation.hide()
	get_tree().node_added.connect(_added)
	get_tree().node_removed.connect(_removed)
	for layer in window.find_children("*","CanvasLayer",true,false): _added(layer)
	RenderingServer.frame_pre_draw.connect(sync_frame)

func _added(node: Node) -> void:
	if node is CanvasLayer and node != presentation and node.get_viewport() == window and node not in layers:
		layers.append(node)

func _removed(node: Node) -> void:
	if not node is CanvasLayer: return
	if node in layers:
		if attached.has(node):
			RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),attached[node])
			attached.erase(node)
		layers.erase(node)

func set_enabled(value: bool) -> void:
	if enabled == value: return
	enabled = value
	if enabled:
		saved_cull_mask = window.canvas_cull_mask
		# Share only the render canvases. Physics, cameras, GUI focus and input stay on root.
		target.world_2d = window.world_2d
		target.canvas_cull_mask = saved_cull_mask & ~PRESENTATION_BIT
		window.canvas_cull_mask = PRESENTATION_BIT
		target.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		presentation.show()
		sync_frame()
	else:
		presentation.hide()
		window.canvas_cull_mask = saved_cull_mask
		for canvas: RID in attached.values(): RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),canvas)
		attached.clear()
		target.render_target_update_mode = SubViewport.UPDATE_DISABLED
		target.world_2d = World2D.new()
		target.size = Vector2i(2,2)

func sync_frame() -> void:
	if not enabled or not is_inside_tree(): return
	var settings = get_parent()
	var desired := target_size(window.size,settings.integer_scaling)
	if target.size != desired: target.size = desired
	target.canvas_transform = window.canvas_transform
	target.global_canvas_transform = window.global_canvas_transform
	for layer in layers:
		if not is_instance_valid(layer): continue
		var show_layer := layer.visible and layer.get_viewport() == window
		if show_layer:
			var canvas := layer.get_canvas()
			if not attached.has(layer):
				RenderingServer.viewport_attach_canvas(target.get_viewport_rid(),canvas)
				attached[layer] = canvas
			RenderingServer.viewport_set_canvas_stacking(target.get_viewport_rid(),canvas,layer.layer,layer.get_index())
			RenderingServer.viewport_set_canvas_transform(target.get_viewport_rid(),canvas,layer.get_final_transform())
		elif attached.has(layer):
			RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),attached[layer])
			attached.erase(layer)

func _exit_tree() -> void:
	if RenderingServer.frame_pre_draw.is_connected(sync_frame): RenderingServer.frame_pre_draw.disconnect(sync_frame)
	if is_instance_valid(target):
		for canvas: RID in attached.values(): RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),canvas)
	attached.clear()
	if enabled and is_instance_valid(window): window.canvas_cull_mask = saved_cull_mask
