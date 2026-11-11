extends SceneTree
## v0.44.0 · CodexAI. Real controller popup events, focus and desktop termination.
var checks := 0
var failures := 0
func _initialize():run.call_deferred()
func check(ok: bool,msg: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+msg)
func pad(button: JoyButton):
	for pressed in [true,false]:
		var e := InputEventJoypadButton.new()
		e.device = 77
		e.button_index = button
		e.pressed = pressed
		Input.parse_input_event(e)
		await process_frame
		await process_frame
func run():
	set_meta("shadepi_admin_testing",true)
	Engine.max_fps = 120
	var w = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	current_scene = w
	var devices: Array[int] = [77]
	w.set_process(false)
	w.gamepads.assign(devices,false)
	root.size = Vector2i(1920,1080)
	for i in 5:await process_frame
	check(w.ui.quit_button.is_visible_in_tree() and w.ui.quit_button.text=="Zurück zum Desktop","desktop action visible at Full HD")
	check(w.ui.menu.position.y+w.ui.quit_button.position.y+w.ui.quit_button.size.y<355,"desktop button remains inside the viewport")
	check(not w.ui.restart_button.visible and not w.ui.main_menu_button.visible and w.ui.mode_button.visible,"main menu shows the mode switch, no restart and no way back to itself")
	check(w.ui.resume_button.get_global_rect().end.y<=w.ui.load_button.get_global_rect().position.y+1,"start and load rows share at most their one-pixel frame border")
	w.ui._toggle_admin_panel()
	w.admin_flags["unlock_all"]=true
	w.ui._refresh_admin_controls()
	w.ui.admin_chapter_picker.grab_focus()
	await pad(JOY_BUTTON_A)
	check(w.ui.admin_chapter_picker.get_popup().visible,"controller A opens chapter choices")
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_A)
	check(w.ui.admin_chapter_picker.get_selected_id()==2 and w.ui.admin_checkpoint_picker.item_count==8,"controller selects chapter 2 and refreshes checkpoints")
	w.ui.admin_checkpoint_picker.grab_focus()
	await pad(JOY_BUTTON_A)
	check(w.ui.admin_checkpoint_picker.get_popup().visible,"controller A opens checkpoint choices")
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_A)
	check(w.ui.admin_checkpoint_picker.selected==1,"controller chooses the next authored checkpoint")
	await pad(JOY_BUTTON_B)
	check(not w.ui.admin_panel.visible and w.menu_open and root.gui_get_focus_owner()==w.ui.resume_button,"controller B closes testlab and restores menu focus")
	w.ui._toggle_admin_panel()
	w.ui.admin_checkpoint_picker.grab_focus()
	await pad(JOY_BUTTON_A)
	await pad(JOY_BUTTON_B)
	check(not w.ui.admin_checkpoint_picker.get_popup().visible and w.ui.admin_panel.visible,"B first closes a dropdown and preserves its testlab")
	await pad(JOY_BUTTON_B)
	check(not w.ui.admin_panel.visible,"second B closes testlab")
	w.ui._toggle_admin_panel()
	await pad(JOY_BUTTON_START)
	check(not w.ui.admin_panel.visible and w.menu_open,"Start closes the testlab while retaining pause")
	w.ui._toggle_admin_panel()
	w.ui.admin_checkpoint_button.grab_focus()
	await pad(JOY_BUTTON_A)
	for i in 30:
		await process_frame
		if current_scene!=w:break
	w=current_scene
	check(w.scene_file_path.ends_with("chapter_two.tscn") and w.section==w.Section.HIDEOUT,"controller A starts the selected test checkpoint")
	w.cutscene.abort()
	w.set_process(false)
	w.gamepads.assign(devices,false)
	w.menu_open = true
	w.ui.show_menu()
	check(w.ui.quit_button.is_visible_in_tree(),"desktop remains available after cross-chapter selection")
	print("MENU NAVIGATION: %d checks, %d failures; testing real desktop exit"%[checks,failures])
	if failures:
		w.free()
		quit(1)
		return
	w.ui.quit_button.grab_focus()
	await pad(JOY_BUTTON_A)
	push_error("Desktop button did not terminate the application")
	quit(1)
