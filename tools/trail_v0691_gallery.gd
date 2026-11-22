extends SceneTree
## v0.69.1 · CodexAI: real marked conversations on their actual forest/shore maps.
const OUT := "/tmp/shadepi-v0691-gallery"
const Motion = preload("res://scripts/cinematic_motion.gd")
var w
var seen := {}
var movie := 0
var frame := 0
var waiting := 0.0
func _initialize():run.call_deferred()
func shot(tag: String="",film: bool=false):
 await RenderingServer.frame_post_draw
 var image:=root.get_texture().get_image()
 if not tag.is_empty():image.save_png(OUT+"/"+tag+".png");seen[tag]=true
 if film:
  image.resize(640,360,Image.INTERPOLATE_LANCZOS)
  image.save_png(OUT+"/film/%04d.png"%movie);movie+=1
func sample():
 var d=w.lake_sequence
 if w.cutscene.waiting_input:
  waiting+=w.get_process_delta_time()
  var tag: String=d.stage
  if tag.begins_with("trail_") and not tag.begins_with("trail_done") and waiting>0.4 and not seen.has(tag):await shot(tag)
  if waiting>1.6:w.cutscene.advance();waiting=0
 else:waiting=0
 if frame%5==0:await shot("",true)
 frame+=1
func drive():
 for i in 4000:
  await process_frame;await sample()
  if w.beat==w.Beat.END and w.lake_sequence.stage=="kiss" and w.lake_sequence.tableau.pose==2:
   await shot("kiss");return
  if not w.cutscene.running:return
 push_error("Trail gallery timed out");quit(1)
func travel():
 var cs=w.begin_cutscene()
 var p: Vector2=w._target()
 cs.camera(p-Vector2(0,40),1.0,1.25)
 await Motion.walk_pair(cs,[w.player,w.raven],[p+Vector2(-10,0),p+Vector2(12,15)],65)
 cs.end()
func run():
 if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):quit(1);return
 DirAccess.make_dir_recursive_absolute(OUT+"/film");set_meta("shadepi_admin_testing",true)
 Engine.max_fps=30;root.get_node("DisplaySettings").mode=0;root.mode=Window.MODE_WINDOWED
 w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w)
 w.started=true;w.close_menu();w.set_visual_quality(2)
 for i in 5:await process_frame
 root.size=Vector2i(1920,1080)
 w._enter(w.Beat.LAKE)
 for step in 4:
  travel();await drive()
  await shot("marker-%d"%step)
  w.interact();await drive()
 var ok:=true
 for tag in ["trail_0","trail_1","trail_2","marker-3","kiss"]:
  if not seen.has(tag):ok=false;push_error("Missing "+tag)
 w.cutscene.abort();w.free();await process_frame
 print("TRAIL v0.69.1 CodexAI: ",movie," native frames; ",seen);quit(0 if ok else 1)
