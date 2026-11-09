extends SceneTree
## v0.44.0 · CodexAI. Fixed-clock foot comparison and actual checkpoint UI/input.
const OUT := "/tmp/shadepi-menu-v044"
var frames := 0
func _initialize():run.call_deferred()
func capture(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+name+".png")
func frame():
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/film/frame-%04d.png"%frames)
	frames += 1
func run():
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT+"/film")
	Engine.max_fps = 60
	var w = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	current_scene = w
	w.save_game()
	w.ui.show_menu()
	root.size = Vector2i(1920,1080)
	for i in 12:await process_frame
	w.ui.start_backdrop.set_process(false)
	await capture("contacts")
	w.ui.start_backdrop.ground_contacts.hide()
	await process_frame
	await capture("no-contacts")
	w.ui.start_backdrop.ground_contacts.show()
	w.ui.start_backdrop.set_quality(0)
	await process_frame
	await capture("contacts-reduced")
	w.ui.start_backdrop.set_quality(2)
	w.ui.start_backdrop.set_process(true)
	root.size = Vector2i(1280,720)
	for i in 30:await frame()
	w.ui._toggle_admin_panel()
	w.admin_flags["unlock_all"] = true
	w.ui.admin_checks["unlock_all"].set_pressed_no_signal(true)
	w.ui._refresh_admin_controls()
	# The controller-focus path auto-scrolls the actual controls into view.
	w.ui.admin_chapter_picker.select(5)
	w.ui.admin_chapter_picker.item_selected.emit(5)
	w.ui.admin_checkpoint_picker.grab_focus()
	for i in 15:await frame()
	await capture("checkpoints")
	w.ui.admin_checkpoint_picker.select(4)
	w.ui.admin_checkpoint_button.grab_focus()
	for i in 15:await frame()
	await capture("extraction-choice")
	w.ui.admin_checkpoint_button.pressed.emit()
	await scene_changed
	w=current_scene
	for i in 40:await frame()
	await capture("extraction")
	w.menu_open = true
	w.ui.show_menu()
	for i in 15:await frame()
	await capture("pause")
	w.free()
	await process_frame
	print("MENU_FILM_FRAMES ",frames)
	quit()
