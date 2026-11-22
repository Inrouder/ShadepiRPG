extends SceneTree
## v0.69.0 · CodexAI. Real complete chapter playback, isolated saves, native HQ captures.
var OUT := "/tmp/shadepi-v069-gallery"
var w
var seen := {}
var frames_written := 0
var frame_index := 0
var wait_elapsed := 0.0
var last_stage := ""
var stage_elapsed := 0.0

func _initialize() -> void:run.call_deferred()

func shot(tag: String,film: bool=false) -> void:
 await RenderingServer.frame_post_draw
 var image:=root.get_texture().get_image()
 if not tag.is_empty():image.save_png(OUT+"/"+tag+".png");seen[tag]=true
 if film:
  image.resize(640,360,Image.INTERPOLATE_LANCZOS)
  image.save_png(OUT+"/film/%04d.png"%frames_written);frames_written+=1

func sample() -> void:
 var d=w.lake_sequence
 var dt: float=w.get_process_delta_time()
 if d.stage!=last_stage:last_stage=d.stage;stage_elapsed=0
 stage_elapsed+=dt
 if w.cutscene.waiting_input:
  wait_elapsed+=dt
  if wait_elapsed>1.7:w.cutscene.advance();wait_elapsed=0
 else:wait_elapsed=0
 var tag: String=d.stage
 var ready:=stage_elapsed>1.0
 if tag=="touchdown":ready=stage_elapsed>1.0
 if tag=="forest_walk":ready=w.player.position.x>560
 if tag=="lake_reveal":ready=stage_elapsed>1.6
 if tag in ["hands","kiss","embrace"]:ready=stage_elapsed>2.0
 if tag=="dragon":ready=d.dragon_passage>0.45
 if tag in ["moon","galaxy","swarm"]:ready=stage_elapsed>3.0
 if tag=="credits":
  tag="credits-%d"%d.epilogue.page
  ready=d.epilogue.page>=0 and d.epilogue.card.modulate.a>0.98
 if w.cutscene.overlay.color.a>0.01:ready=false
 if ready and not seen.has(tag):await shot(tag)
 if frame_index%5==0:await shot("",true)
 frame_index+=1

func drive_scene() -> void:
 for i in 5000:
  await process_frame
  await sample()
  if not w.cutscene.running:return
 push_error("Chapter gallery exceeded playback budget");quit(1)

func run() -> void:
 if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
  push_error("Use native renderer and isolated /tmp/shadepi- data");quit(1);return
 var cosmos_only:= "--cosmos-only" in OS.get_cmdline_user_args()
 if cosmos_only:OUT="/tmp/shadepi-v069-cosmos"
 DirAccess.make_dir_recursive_absolute(OUT+"/film")
 set_meta("shadepi_admin_testing",true)
 Engine.max_fps=30;Engine.time_scale=4.0
 root.get_node("DisplaySettings").mode=0;root.mode=Window.MODE_WINDOWED
 w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w)
 w.set_visual_quality(2);w.started=true;w.close_menu()
 for i in 5:await process_frame
 root.size=Vector2i(1920,1080)
 if cosmos_only:
  w._enter(w.Beat.END);w.cutscene.abort();w.ui.set_lake_cinema(true)
  await walk_detail()
  play_cosmos()
  await drive_scene()
  print("COSMIC QA: ",frames_written," native frames; ",seen)
  w.free();await process_frame;quit();return
 w.fresh_entry=true;w._enter(w.Beat.LAKE)
 await drive_scene()
 for step in 4:
  w.player.position=w._target();w.interact()
  if w.beat==w.Beat.END:break
  await drive_scene()
 await drive_scene()
 await shot("rest")
 var required:=["touchdown","forest_walk","lake_reveal","kiss","dragon","moon","galaxy","swarm","credits-1","credits-2","credits-4"]
 var ok:=true
 for tag in required:
  if not seen.has(tag):ok=false;push_error("Missing capture "+tag)
 print("LAKE v0.69.0 CodexAI: ",frames_written," native movie frames; captures ",seen)
 w.free();await process_frame;quit(0 if ok else 1)

func play_cosmos() -> void:
 var cs=w.begin_cutscene()
 var d=w.lake_sequence
 cs.ended.connect(d._scene_ended,CONNECT_ONE_SHOT)
 await d.cosmic_departure(cs)
 if cs.running:cs.end(d.rest)

func walk_detail() -> void:
 var d=w.lake_sequence
 d.set_clearing(true);d.tableau.hide();d._restore_actors()
 w.player.position=Vector2(460,456);w.raven.position=Vector2(482,470)
 w.camera.position=Vector2(520,410);w.camera.zoom=Vector2.ONE*1.35
 var cs=w.begin_cutscene();cs.ended.connect(d._scene_ended,CONNECT_ONE_SHOT)
 d._walk_talk(cs,[Vector2(650,390),Vector2(671,407)],"SHADEPI","Hier hat der Orden früher Zuflucht gesucht. Den Weg kennt kaum jemand.")
 for i in 10:await process_frame
 await shot("forest-dialogue")
 cs.abort();d.rest();w.ui.set_lake_cinema(true)
