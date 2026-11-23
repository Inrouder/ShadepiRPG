extends SceneTree
## v0.69.2 · CodexAI. Documentation-only native size/mask inspection; no art generation.
const OUT := "/tmp/shadepi-icon-v0692"
var base: String
var stage: Control
var focus: Panel
func _initialize():run.call_deferred()
func label(value: String,at: Vector2,size: int=16):
 var l:=Label.new();l.text=value;l.position=at;l.add_theme_font_size_override("font_size",size);l.add_theme_color_override("font_color",Color("bed7e5"));stage.add_child(l)
func picture(path: String,at: Vector2,side: float) -> TextureRect:
 var r:=TextureRect.new();r.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;r.texture=ImageTexture.create_from_image(Image.load_from_file(base+path))
 r.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;r.position=at;r.size=Vector2.ONE*side;stage.add_child(r);return r
func run():
 if DisplayServer.get_name()=="headless":quit(1);return
 base=get_script().resource_path.get_base_dir().get_base_dir()+"/"
 DirAccess.make_dir_recursive_absolute(OUT+"/film")
 root.show();Engine.max_fps=30
 root.size=Vector2i(1024,768);root.title="Shadepi · Drachensymbol · v0.69.2 CodexAI"
 DisplayServer.set_icon(Image.load_from_file(base+"assets/icon.png"))
 stage=Control.new();root.add_child(stage)
 var back:=ColorRect.new();back.color=Color("080e19");back.size=Vector2(1024,768);stage.add_child(back)
 label("SHADEPI · WEISSER DRACHE",Vector2(28,18),26)
 label("Native Größenprüfung · v0.69.2 · CodexAI",Vector2(28,52),16)
 picture("assets/icon.png",Vector2(28,95),400)
 var places: Array[Vector2]=[]
 var left:=480.0
 for side in [16,32,48,64,128]:
  places.append(Vector2(left,155))
  picture("assets/icon.png",Vector2(left,155),side)
  label(str(side)+" px",Vector2(left,300),14)
  left+=side+40
 label("Android · runde Maske",Vector2(480,383),16)
 label("Android · monochrom",Vector2(745,383),16)
 var shader:=Shader.new();shader.code="shader_type canvas_item; uniform bool mono = false; void fragment(){ if(distance(UV,vec2(0.5))>0.5)discard; vec4 fg=texture(TEXTURE,(UV-0.5)*0.6666667+0.5); vec3 rgb=mono?vec3(0.50,0.86,0.93):fg.rgb; COLOR=vec4(mix(vec3(0.012,0.027,0.059),rgb,fg.a),1.0); }"
 for i in 2:
  var r:=picture("assets/branding/icon/android-foreground.png" if i==0 else "assets/branding/icon/android-monochrome.png",Vector2(490+i*265,420),170)
  var material:=ShaderMaterial.new();material.shader=shader;material.set_shader_parameter("mono",i==1);r.material=material
 label("Original-SVG → HQ-Pixeltextur → PNG / ICO / Launcher-Ebenen",Vector2(28,660),18)
 label("Form, Kopf und eingerollter Schwanz bleiben erkennbar. Launcher-Vorschau mit 72dp-Ausschnitt.",Vector2(28,700),15)
 focus=Panel.new();var box:=StyleBoxFlat.new();box.bg_color=Color.TRANSPARENT;box.border_color=Color("66d9ef");box.set_border_width_all(2);focus.add_theme_stylebox_override("panel",box);stage.add_child(focus);focus.hide()
 for i in 3:await process_frame
 RenderingServer.force_draw();root.get_texture().get_image().save_png(OUT+"/sizes.png")
 for frame in 20:
  var index:=mini(4,int(frame/4));focus.show();focus.position=places[index]-Vector2(5,5);focus.size=Vector2.ONE*([16,32,48,64,128][index]+10)
  await process_frame;RenderingServer.force_draw()
  root.get_texture().get_image().save_png(OUT+"/film/%03d.png"%frame)
 print("ICON PREVIEW v0.69.2 CodexAI: five native sizes, two launcher masks, 20 documentation frames")
 quit()
