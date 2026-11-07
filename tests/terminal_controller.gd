extends SceneTree
## Raw pad events travel through the viewport, not direct puzzle-method calls.
const Terminal = preload("res://scripts/terminal_ui.gd")
var panel: CanvasLayer
var checks := 0
var failures := 0
var accepted := false

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func pad(button: JoyButton) -> void:
	for pressed in [true, false]:
		var event := InputEventJoypadButton.new()
		event.device = 77
		event.button_index = button
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
		panel._process(0.0)

func seek(control: Control) -> void:
	for i in 45:
		if root.gui_get_focus_owner() == control: return
		await pad(JOY_BUTTON_RIGHT_SHOULDER)
	check(false, "RB can reach " + str(control))

func adjust(control: Control, value: int) -> void:
	await seek(control)
	for i in 110:
		var current: int = int(control.value) if control is Slider else control.selected
		if current == value: return
		await pad(JOY_BUTTON_DPAD_RIGHT if current < value else JOY_BUTTON_DPAD_LEFT)
	check(false, "pad can adjust value")

func run() -> void:
	for context in ["jackal", "transponder", "garage", "penthouse", "power", "roof_signal", "charge", "repair"]:
		accepted = false
		panel = Terminal.new()
		panel.context = context
		root.add_child(panel)
		panel.set_process(false)
		panel.finished.connect(func(success): accepted = success)
		await process_frame
		# Every available control, including footer actions, is reachable both ways.
		for control in panel._enabled_controls():
			await seek(control)
			check(root.gui_get_focus_owner() == control, context + " control reachable")
		await seek(panel.footer[0])
		await pad(JOY_BUTTON_RIGHT_SHOULDER)
		await pad(JOY_BUTTON_LEFT_SHOULDER)
		check(root.gui_get_focus_owner() == panel.footer[0], "LB reverses focus traversal")
		await pad(JOY_BUTTON_Y)
		var clock: float = panel.puzzle.clock
		panel._process(2.0)
		check(panel.help_open and panel.puzzle.clock == clock, "help freezes puzzle timers")
		await pad(JOY_BUTTON_B)
		check(not panel.help_open and not panel.closed, "B closes help without aborting hack")
		await pad(JOY_BUTTON_START)
		panel._process(2.0)
		check(panel.paused and panel.puzzle.clock == clock, "Start pauses timers")
		await pad(JOY_BUTTON_START)
		check(not panel.paused, "Start resumes")
		match panel.puzzle.kind:
			"matrix":
				for index in ([1, 11, 13, 23, 20] if panel.puzzle.hard else [1, 11, 13]):
					await seek(panel.cells[index])
					await pad(JOY_BUTTON_A)
			"decoder":
				await adjust(panel.controls[8], panel.puzzle.filter_target)
				await seek(panel.cells[panel.puzzle.WORDS.find(panel.puzzle.secret)])
				await pad(JOY_BUTTON_A)
			"routing":
				for entry in [[4, 10], [5, 12], [9, 3], [10, 10], [11, 9], [7, 6]]:
					await seek(panel.cells[entry[0]])
					for turn in 4:
						if panel.puzzle.masks[entry[0]] == entry[1]: break
						await pad(JOY_BUTTON_A)
				await adjust(panel.controls[16], 1)
				await adjust(panel.controls[17], 1)
				await seek(panel.controls[19])
				await pad(JOY_BUTTON_A)
				panel._process(3.1)
			"signal":
				# Also exercise a held analog stick and neutral deadzone.
				await seek(panel.controls[0])
				var axis := InputEventJoypadMotion.new()
				axis.device = 77
				axis.axis = JOY_AXIS_LEFT_X
				axis.axis_value = 0.9
				Input.parse_input_event(axis)
				await process_frame
				check(panel.puzzle.signal_values[0] == 2, "analog stick changes slider once")
				panel._process(0.33)
				check(panel.puzzle.signal_values[0] == 3, "held stick repeats")
				axis.axis_value = 0.1
				Input.parse_input_event(axis)
				await process_frame
				check(panel.held_direction == Vector2.ZERO, "stick deadzone stops repeats")
				for i in 3: await adjust(panel.controls[i], panel.puzzle.signal_target[i])
				panel._process(1.3)
			"jumper":
				for i in 5: await adjust(panel.controls[i], [4, 3, 2, 1, 5][i])
				await adjust(panel.controls[5], 1)
				await adjust(panel.controls[6], 3)
				await seek(panel.controls[7])
				await pad(JOY_BUTTON_A)
		panel._process(0.0)
		check(panel.puzzle.solved, context + " solved using controller")
		check(root.gui_get_focus_owner() == panel.apply_button, "success focuses acceptance")
		await pad(JOY_BUTTON_A)
		check(accepted and panel.closed, context + " accepted with A")
		panel.queue_free()
		await process_frame
	# Footer retry and abort, without a mouse.
	panel = Terminal.new()
	root.add_child(panel)
	panel.set_process(false)
	await process_frame
	await seek(panel.cells[0])
	await pad(JOY_BUTTON_DPAD_RIGHT)
	check(root.gui_get_focus_owner() == panel.cells[1], "D-pad navigates grid spatially")
	await seek(panel.footer[1])
	await pad(JOY_BUTTON_A)
	check(panel.puzzle.buffer.is_empty() and not panel.closed, "retry rebuilds an operable panel")
	await pad(JOY_BUTTON_B)
	check(panel.closed, "B aborts unsolved terminal")
	panel.queue_free()
	await process_frame
	print("Terminal controller: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
