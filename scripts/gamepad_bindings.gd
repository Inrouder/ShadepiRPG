extends RefCounted

const MOVEMENT: = {
	"move_left": [JOY_AXIS_LEFT_X, -1.0, JOY_BUTTON_DPAD_LEFT], 
	"move_right": [JOY_AXIS_LEFT_X, 1.0, JOY_BUTTON_DPAD_RIGHT], 
	"move_up": [JOY_AXIS_LEFT_Y, -1.0, JOY_BUTTON_DPAD_UP], 
	"move_down": [JOY_AXIS_LEFT_Y, 1.0, JOY_BUTTON_DPAD_DOWN], 
}

var shadepi_device: = -1
var raven_device: = -1
var bindings: Array[Array] = []

func assign(devices: Array[int], coop: bool) -> void :
	var first: = -1
	var second: = -1
	if not devices.is_empty():
		if coop and devices.size() == 1:
			second = devices[0]
		else:
			first = devices[0]
			if coop:
				second = devices[1]
	if first == shadepi_device and second == raven_device:
		return
	clear()
	shadepi_device = first
	raven_device = second
	if first >= 0:
		_bind_player(first, "", "cloak")
		if not coop:
			_button("hack", first, JOY_BUTTON_RIGHT_SHOULDER)
	if second >= 0:
		_bind_player(second, "raven_", "raven_hack")

func clear() -> void :
	for entry in bindings:
		InputMap.action_erase_event(entry[0], entry[1])
		Input.action_release(entry[0])
	bindings.clear()
	shadepi_device = -1
	raven_device = -1

func _bind_player(device: int, prefix: String, special: String) -> void :
	for direction in MOVEMENT:
		var control: Array = MOVEMENT[direction]
		_axis(prefix + direction, device, control[0], control[1])
		_button(prefix + direction, device, control[2])
	_axis("ui_up", device, JOY_AXIS_LEFT_Y, -1.0)
	_axis("ui_down", device, JOY_AXIS_LEFT_Y, 1.0)
	_button("ui_up", device, JOY_BUTTON_DPAD_UP)
	_button("ui_down", device, JOY_BUTTON_DPAD_DOWN)
	_button("ui_accept", device, JOY_BUTTON_A)
	_button(prefix + "interact", device, JOY_BUTTON_A)
	_button(prefix + "dash", device, JOY_BUTTON_B)
	_button(prefix + "attack", device, JOY_BUTTON_X)
	_axis(prefix + "charge", device, JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_axis(prefix + "kick", device, JOY_AXIS_TRIGGER_LEFT, 1.0)
	_button(special, device, JOY_BUTTON_Y)
	_button("pause_game", device, JOY_BUTTON_START)
	_button("save_game", device, JOY_BUTTON_LEFT_SHOULDER)

func _axis(action: String, device: int, axis: JoyAxis, direction: float) -> void :
	var event: = InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = direction
	_add(action, event)

func _button(action: String, device: int, index: JoyButton) -> void :
	var event: = InputEventJoypadButton.new()
	event.device = device
	event.button_index = index
	_add(action, event)

func _add(action: String, event: InputEvent) -> void :
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
		bindings.append([action, event])
