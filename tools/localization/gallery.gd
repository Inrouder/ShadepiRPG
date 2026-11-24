extends SceneTree
## v0.70.0 · CodexAI. Native English UI captures; no art or normal saves modified.
const OUT := "/tmp/shadepi-language-gallery"
var w
func _initialize(): run.call_deferred()
func capture(tag: String):
	for i in 5: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "/" + tag + ".png")
func run():
	if DisplayServer.get_name() == "headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		quit(1); return
	DirAccess.make_dir_recursive_absolute(OUT)
	Engine.max_fps = 30
	root.get_node("LanguageSettings").set_language("en")
	var display = root.get_node("DisplaySettings")
	display.mode = 0; display.menu_context = true; root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280, 720)
	w = load("res://scenes/chapter_one.tscn").instantiate(); root.add_child(w)
	w.set_process(false); w.ui.show_menu()
	await capture("menu-en")
	w.ui._open_display_panel()
	await capture("options-en")
	w.ui.display_panel.language_select.show_popup()
	await capture("language-list-en")
	w.ui.display_panel.dismiss()
	var terminal = load("res://scripts/terminal_ui.gd").new(); terminal.context = "power"; root.add_child(terminal)
	await capture("hack-en")
	terminal._toggle_help()
	await capture("hack-help-en")
	terminal.queue_free(); await process_frame
	w.queue_free(); await process_frame
	var startup = load("res://scenes/startup.tscn").instantiate(); root.add_child(startup)
	startup.show_notice(); startup.set_process(false)
	await capture("notice-en")
	startup.queue_free(); await process_frame
	root.get_node("LanguageSettings").set_language("de")
	print("Localization gallery: 6 native English captures · v0.70.0 CodexAI")
	quit()
