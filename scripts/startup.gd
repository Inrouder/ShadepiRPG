extends Control
## v0.68.0 · CodexAI. Quiet branding, readable health/content notice, then the existing menu.
const UiSkin=preload("res://scripts/ui_skin.gd")
const MENU_PATH:="res://scenes/chapter_one.tscn"
const LOGO_SECONDS:=2.8
const NOTICE_SECONDS:=0.75
const HEALTH_TEXT:="Dieses Spiel enthält blinkende Lichter und schnelle Bildwechsel. Sie können bei empfindlichen Personen epileptische Anfälle auslösen – auch ohne bekannte Vorerkrankung.\n\nBei entsprechender Vorgeschichte vorab ärztlichen Rat einholen. Bei Schwindel, Sehstörungen, Muskelzucken oder Unwohlsein sofort aufhören."
const BREAK_TEXT:="Spiele in einem gut beleuchteten Raum, halte ausreichend Abstand zum Bildschirm und lege regelmäßig Pausen ein."
const LEGAL_TEXT:="Enthält fiktive Gewalt. Marken und Logos gehören ihren Inhabern. Lizenz- und Quellenhinweise findest du in der Spieldokumentation."
enum Phase { LOGO, NOTICE, LOADING }
@export var logo_texture: Texture2D
var menu_path:=MENU_PATH
var phase:=Phase.LOGO
var elapsed:=0.0
var notice_elapsed:=0.0
var handoff_elapsed:=0.0
var active:=true
var changing_scene:=false
# The shared touch context sees a menu; story controls must stay hidden here.
var menu_open:=true
var logo: TextureRect
var notices: Control
var continue_button: Button
var hint: Label
var health: Label
var breaks: Label
var legal: Label

func _ready():
	get_node("/root/DisplaySettings").set_menu_context(true)
	var black:=ColorRect.new();black.color=Color.BLACK;black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);black.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(black)
	logo=TextureRect.new();logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture=logo_texture;logo.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;logo.mouse_filter=Control.MOUSE_FILTER_IGNORE
	logo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);logo.modulate.a=0;add_child(logo)
	notices=Control.new();notices.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(notices)
	var panel:=Panel.new();panel.position=Vector2(30,24);panel.size=Vector2(580,294);panel.add_theme_stylebox_override("panel",UiSkin.panel("raven"));notices.add_child(panel)
	_label("HINWEISE VOR DEM SPIEL",Rect2(52,42,536,24),16,Color("a6e6ed"),true)
	health=_label(HEALTH_TEXT,Rect2(52,79,536,116),16,Color("e7eff2"))
	breaks=_label(BREAK_TEXT,Rect2(52,199,536,38),16,Color("e7eff2"))
	legal=_label(LEGAL_TEXT,Rect2(52,244,536,34),12,Color("a5bbc5"))
	continue_button=Button.new();continue_button.text="Weiter zum Hauptmenü";continue_button.position=Vector2(162,283);continue_button.size=Vector2(316,30)
	UiSkin.apply_button(continue_button,"raven",18);continue_button.disabled=true;continue_button.pressed.connect(request_menu);notices.add_child(continue_button)
	hint=_label("ENTER / LEERTASTE / E · CONTROLLER A · TIPPEN",Rect2(20,333,600,14),8,Color("a5bbc5"),true)
	hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	notices.hide()

func _label(text: String,rect: Rect2,font_size: int,color: Color,title: bool=false) -> Label:
	var item:=Label.new();item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_override("font",UiSkin.font("title" if title else "ui"));item.add_theme_font_size_override("font_size",font_size);item.add_theme_color_override("font_color",color)
	item.mouse_filter=Control.MOUSE_FILTER_IGNORE;notices.add_child(item)
	# Configure wrap/font and a nonzero width before text, avoiding one-character lines.
	item.position=rect.position;item.size=rect.size;item.text=text
	return item

func _process(delta: float):
	if not active or changing_scene:return
	var step:=clampf(delta,0,0.1)
	if phase==Phase.LOGO:
		elapsed+=step
		logo.modulate.a=minf(clampf(elapsed/0.35,0,1),clampf((LOGO_SECONDS-elapsed)/0.45,0,1))
		if elapsed>=LOGO_SECONDS:show_notice()
	elif phase==Phase.NOTICE:
		notice_elapsed+=step
		if continue_button.disabled and notice_elapsed>=NOTICE_SECONDS:
			continue_button.disabled=false;continue_button.grab_focus.call_deferred()
	elif phase==Phase.LOADING:
		handoff_elapsed+=step
		if handoff_elapsed>=0.12:_finish_menu()

func show_notice():
	if phase!=Phase.LOGO:return
	phase=Phase.NOTICE;notice_elapsed=0;logo.hide();notices.show()

func request_menu():
	if phase!=Phase.NOTICE or notice_elapsed<NOTICE_SECONDS:return
	if not ResourceLoader.exists(menu_path):
		hint.text="Hauptmenü konnte nicht geladen werden. Bitte erneut versuchen.";return
	phase=Phase.LOADING;handoff_elapsed=0;continue_button.disabled=true;continue_button.text="Hauptmenü wird geladen …"

func _finish_menu():
	# Draw the loading state before the existing scene is loaded on the main thread.
	# This also avoids keeping an unfinished background scene load alive on early quit.
	var scene:=load(menu_path) as PackedScene
	if scene!=null:
		changing_scene=true
		if get_tree().change_scene_to_packed(scene)==OK:return
		changing_scene=false
	phase=Phase.NOTICE;continue_button.disabled=false;continue_button.text="Erneut versuchen"
	hint.text="Hauptmenü konnte nicht geladen werden. Bitte erneut versuchen."

func _input(event: InputEvent):
	if not active:return
	if event is InputEventKey and event.echo:
		get_viewport().set_input_as_handled();return
	var accept:=false;var skip:=false
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int=event.physical_keycode if event.physical_keycode!=0 else event.keycode
		accept=key in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE,KEY_E];skip=accept or key==KEY_ESCAPE
	elif event is InputEventJoypadButton and event.pressed:
		accept=event.button_index==JOY_BUTTON_A;skip=accept or event.button_index==JOY_BUTTON_START
	elif event is InputEventMouseButton:
		skip=event.pressed and event.button_index==MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch and event.pressed:
		skip=true
		accept=phase==Phase.NOTICE and continue_button.get_global_rect().has_point(event.position)
	if phase==Phase.LOGO and elapsed>=0.2 and skip:
		show_notice();get_viewport().set_input_as_handled()
	elif phase==Phase.NOTICE and accept:
		request_menu();get_viewport().set_input_as_handled()

func _notification(what: int):
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]:active=false
	elif what in [NOTIFICATION_APPLICATION_FOCUS_IN,NOTIFICATION_APPLICATION_RESUMED]:active=true
