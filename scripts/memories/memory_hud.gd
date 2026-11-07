extends CanvasLayer
const UISkin = preload("res://scripts/ui_skin.gd")
var world: Node2D
var controls: Label
var game_hud_nodes: Array[CanvasItem] = []
var start_backdrop: Control
var pause_panel: Panel
var buttons: Array[Button] = []
func _ready() -> void:
	layer = 12
	start_backdrop = Control.new()
	start_backdrop.hide()
	add_child(start_backdrop)
	controls = Label.new()
	controls.position = Vector2(18,338)
	controls.text = "E / A Weiter · Leertaste / B Überspringen · Esc / Start Pause"
	controls.add_theme_font_override("font",UISkin.font())
	controls.add_theme_font_size_override("font_size",16)
	add_child(controls)
	pause_panel = Panel.new()
	pause_panel.position = Vector2(176,93)
	pause_panel.size = Vector2(288,170)
	pause_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pause_panel.add_theme_stylebox_override("panel",UISkin.panel("order"))
	add_child(pause_panel)
	var title := Label.new()
	title.text = "ERINNERUNG · PAUSE"
	title.position = Vector2(18,12)
	title.add_theme_font_override("font",UISkin.font())
	title.add_theme_font_size_override("font_size",20)
	pause_panel.add_child(title)
	for i in 3:
		var button := Button.new()
		button.text = ["Fortsetzen","Erinnerung überspringen","Erinnerung verlassen"][i]
		button.position = Vector2(18,45+i*36)
		button.size = Vector2(252,30)
		button.add_theme_font_override("font",UISkin.font())
		button.add_theme_font_size_override("font_size",20)
		for state in ["normal","hover","pressed","focus"]: button.add_theme_stylebox_override(state,UISkin.button("order",state))
		button.pressed.connect(func():
			if i==0: world.toggle_pause()
			elif i==1:
				world.toggle_pause()
				world.cutscene.skip()
			else: world.cancel())
		pause_panel.add_child(button)
		buttons.append(button)
	pause_panel.hide()
