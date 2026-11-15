extends Node
## v0.64.0 · CodexAI. A bounded shared picture, without the host's local touch/lobby overlays.
## Root retains input, cameras and simulation. Embedded popup textures are copied explicitly.
const BASE := Vector2i(640,360)
const LOCAL_BIT := 1 << 20
var target: SubViewport
var window: Window
var session: Node
var attached: Dictionary = {}
var popup_layer: CanvasLayer
var popups: Dictionary = {}
var armed := false

func _ready():
	window=get_window(); session=get_parent()
	target=SubViewport.new(); target.name="WLANPicture"; target.size=session.VIDEO_SIZE
	target.size_2d_override=BASE; target.size_2d_override_stretch=true; target.gui_disable_input=true
	target.canvas_item_default_texture_filter=window.canvas_item_default_texture_filter
	target.snap_2d_transforms_to_pixel=window.snap_2d_transforms_to_pixel
	target.snap_2d_vertices_to_pixel=window.snap_2d_vertices_to_pixel
	target.render_target_update_mode=SubViewport.UPDATE_DISABLED
	add_child(target); target.world_2d=window.world_2d
	popup_layer=CanvasLayer.new(); popup_layer.layer=1024; target.add_child(popup_layer)
	RenderingServer.frame_pre_draw.connect(sync_frame)
	get_tree().node_removed.connect(_removed)

func _removed(node: Node):
	if node is CanvasLayer and attached.has(node.get_canvas()):
		RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),node.get_canvas()); attached.erase(node.get_canvas())

func _local_only(node: Node) -> bool:
	var parent:=node
	while parent!=null and parent!=window:
		if parent.get_meta("root_only",false): return true
		parent=parent.get_parent()
	return false

func sync_frame():
	if not session.is_host() or not session.connected() or session.in_flight>=0: return
	if session.clock-session.frame_clock<1.0/(15.0 if session.profile==0 else 12.0): return
	var desired: Vector2i=session.VIDEO_SIZE if session.profile==0 else BASE
	if target.size!=desired: target.size=desired
	var hq=get_node("/root/DisplaySettings").renderer
	target.canvas_cull_mask=(hq.saved_cull_mask if hq.enabled else window.canvas_cull_mask) & ~LOCAL_BIT
	target.canvas_transform=window.canvas_transform; target.global_canvas_transform=window.global_canvas_transform
	var active: Dictionary={}
	for layer in window.find_children("*","CanvasLayer",true,false):
		if layer.get_viewport()!=window or not layer.visible or _local_only(layer) or layer==hq.presentation: continue
		var canvas: RID=layer.get_canvas(); active[canvas]=true
		if not attached.has(canvas): RenderingServer.viewport_attach_canvas(target.get_viewport_rid(),canvas)
		RenderingServer.viewport_set_canvas_stacking(target.get_viewport_rid(),canvas,layer.layer,layer.get_index())
		RenderingServer.viewport_set_canvas_transform(target.get_viewport_rid(),canvas,layer.get_final_transform())
	for canvas: RID in attached:
		if not active.has(canvas): RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),canvas)
	attached=active
	var shown: Dictionary={}
	for popup in window.get_embedded_subwindows():
		if not popup.visible or _local_only(popup): continue
		shown[popup]=true
		if not popups.has(popup):
			var image:=TextureRect.new(); image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; image.mouse_filter=Control.MOUSE_FILTER_IGNORE
			image.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST; popup_layer.add_child(image); popups[popup]=image
		var image: TextureRect=popups[popup]
		image.texture=popup.get_texture(); image.position=Vector2(popup.position); image.size=Vector2(popup.size)
	for popup in popups.keys():
		if not shown.has(popup): popups[popup].queue_free(); popups.erase(popup)
	target.render_target_update_mode=SubViewport.UPDATE_ONCE; armed=true

func _exit_tree():
	if RenderingServer.frame_pre_draw.is_connected(sync_frame): RenderingServer.frame_pre_draw.disconnect(sync_frame)
	if is_instance_valid(target):
		for canvas: RID in attached: RenderingServer.viewport_remove_canvas(target.get_viewport_rid(),canvas)
	attached.clear(); popups.clear()
