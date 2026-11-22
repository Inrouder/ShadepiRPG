extends CanvasLayer
## v0.69.0 · CodexAI. Logical/HQ canvas shared by local and WLAN presentation.
const ART = preload("res://assets/story/lake/epilogue/alien-swarm.png")
const UiSkin = preload("res://scripts/ui_skin.gd")
const PAGES := [
 ["EIN SPIEL VON", "Shadepi", "SHADEPI · ECHOS IN NEON"],
 ["IDEE · STORY · CHARAKTERDESIGN", "Shadepi", "SONGTEXTE · ILLUSTRATION · ENTWICKLUNG"],
 ["BILDGENERIERUNG", "ChatGPT · Gemini · Claude · Shadepi", ""],
 ["SPIELEENTWICKLUNG · UMSETZUNG", "Codex AI · Claude · Shadepi", ""],
 ["MUSIK", "Shadepi · Suno", ""],
 ["ENGINE · WEITERE QUELLEN", "Godot Engine", "Lizenz- und Audio-Nachweise: Spieldokumentation"],
 ["DANKE FÜRS SPIELEN", "Der Orden lebt.", "Die gemeinsame Suche beginnt."]
]
var screen: Control
var background: TextureRect
var space_material: ShaderMaterial
var card: Control
var heading: Label
var names: Label
var details: Label
var page := -1

func _ready() -> void:
 layer=8
 screen=Control.new();screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);screen.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(screen)
 background=TextureRect.new();background.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;background.texture=ART
 background.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 background.mouse_filter=Control.MOUSE_FILTER_IGNORE;screen.add_child(background)
 space_material=ShaderMaterial.new();space_material.shader=preload("res://shaders/epilogue_space.gdshader");background.material=space_material
 var shade:=ColorRect.new();shade.color=Color(0.005,0.008,0.025,0.68);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 card=Control.new();card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);card.mouse_filter=Control.MOUSE_FILTER_IGNORE;screen.add_child(card);card.add_child(shade)
 heading=_label(13,Color("8ce6f1"),Rect2(28,105,584,42))
 names=_label(19,Color("f1e4f0"),Rect2(28,158,584,52))
 details=_label(11,Color("b7c5db"),Rect2(28,227,584,44))
 hide();card.hide()

func _label(size: int,color: Color,rect: Rect2) -> Label:
 var label:=Label.new();label.add_theme_font_override("font",UiSkin.font("ui"));label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",color)
 label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label.mouse_filter=Control.MOUSE_FILTER_IGNORE;card.add_child(label);label.position=rect.position;label.size=rect.size
 return label

func frame(travel: float,clock: float,alpha: float=1.0) -> void:
 show();screen.modulate.a=clampf(alpha,0,1)
 space_material.set_shader_parameter("travel",travel);space_material.set_shader_parameter("clock",clock)

func credit(index: int,p: float) -> void:
 page=index;card.show()
 heading.text=PAGES[index][0];names.text=PAGES[index][1];details.text=PAGES[index][2]
 card.modulate.a=minf(clampf(p/0.16,0,1),clampf((1-p)/0.16,0,1))

func reset() -> void:
 hide();card.hide();page=-1
