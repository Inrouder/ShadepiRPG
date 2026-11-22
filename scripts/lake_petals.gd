extends Node2D
## v0.69.0 · CodexAI. Authored rose petals, deterministic gust and pause-safe clocks.
const ART = preload("res://assets/story/lake/epilogue/rose-petals.png")
const LIGHT = preload("res://assets/world/light.png")
var sequence: Node2D
var gust_at := -100.0
var strength := 0.0

func _ready() -> void:
 z_index=38
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR

func gust() -> void:
 gust_at=sequence.clock

func _process(_delta: float) -> void:
 if sequence.paused():return
 var age: float=sequence.clock-gust_at
 strength=clampf(age/0.7,0,1)*clampf((14.0-age)/4.0,0,1)
 queue_redraw()

static func region(index: int) -> Rect2:
 var size:=ART.get_size()
 var a: Vector2=Vector2(index%4,int(index/4))*size/Vector2(4,2)
 var b: Vector2=Vector2(index%4+1,int(index/4)+1)*size/Vector2(4,2)
 return Rect2(a.round(),b.round()-a.round())

func _draw() -> void:
 if not is_instance_valid(sequence):return
 var time: float=sequence.clock
 if sequence.clearing_active:
  for i in (18 if sequence.world.visual_quality>0 else 6):
   var point:=Vector2(210+i*89%660,365+i*37%150)+Vector2(sin(time*0.6+i)*8,cos(time*0.7+i)*6)
   draw_texture_rect(LIGHT,Rect2(point-Vector2(4,4),Vector2(8,8)),false,Color(0.5,0.9,0.7,0.16+0.1*sin(time+i)))
 if strength<=0:return
 for i in (44 if sequence.world.visual_quality==2 else 26 if sequence.world.visual_quality==1 else 12):
  var life:=fposmod((time-gust_at)*0.10+i*0.137,1.0)
  var point:=Vector2(940-life*720+i*17%130,208+life*240+sin(time*0.8+i)*24)
  var side:=10.0+i%4*2.0
  draw_set_transform(point,sin(time*0.5+i)*0.5,Vector2(0.65+absf(sin(time+i))*0.35,1))
  draw_texture_rect_region(ART,Rect2(-Vector2.ONE*side*0.5,Vector2.ONE*side),region(posmod(i+int(time*3),8)),Color(1,0.9,1,strength*sin(life*PI)*0.9))
 draw_set_transform(Vector2.ZERO)
