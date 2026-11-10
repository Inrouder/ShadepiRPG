extends SceneTree
## v0.49.0 · CodexAI. Actual pose bounds, animation variety, cleanup and menu containment.
const Tableau=preload("res://scripts/lake_tableau.gd")
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+label)
func bounds(image: Image) -> Rect2i:
	var lo:=image.get_size();var hi:=Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a<0.75:continue
			lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x+1,y+1))
	return Rect2i(lo,hi-lo)
func run():
	set_meta("shadepi_admin_testing",true)
	var image: Image=Tableau.ART.get_image()
	for frame in 8:
		var rect:=Rect2i(Tableau.region(frame));var b:=bounds(image.get_region(rect))
		check(absf(b.size.y*Tableau.SCALE-58)<0.3,"contact body height matches the original heroes in frame %d"%frame)
		check(absf((b.end.y-Tableau.ANCHOR.y)*Tableau.SCALE)<0.3,"boots remain at the world anchor in frame %d"%frame)
		check(b.position.x>4 and b.end.x<rect.size.x-4,"hair, mask and complete hat stay inside their frame")
	var dragon: Image=load("res://assets/story/lake/dragon-flight.png").get_image()
	var hashes:=[]
	for frame in 6:
		var cell:=dragon.get_region(Rect2i(frame%3*724,int(frame/3)*362,724,362));var b:=bounds(cell)
		hashes.append(hash(cell.get_data()))
		check(b.position.x>20 and b.end.x<704 and b.position.y>20 and b.end.y<342,"dragon phase retains complete silhouette and gutters")
	var unique={}
	for h in hashes:unique[h]=true
	check(unique.size()==6,"six authored flight phases differ instead of repeating one picture")
	for scene in ["chapter_one","chapter_two","campaign"]:
		var w=load("res://scenes/"+scene+".tscn").instantiate();root.add_child(w)
		w.cutscene.abort();w.ui.clear_dialogue();w.set_process(false)
		for opening in [true,false]:
			w.started=not opening;w.menu_open=true;w.ui.show_menu()
			for size in [Vector2i(640,360),Vector2i(1280,720),Vector2i(1920,1080)]:
				root.size=size
				await process_frame
				w.ui._layout_menu()
				var panel: Rect2=w.ui.menu.get_global_rect();var area:=Rect2(Vector2.ZERO,root.get_visible_rect().size)
				check(area.encloses(panel),"menu remains inside viewport for "+scene)
				check(panel.encloses(w.ui.menu_help.get_global_rect()),"help belongs inside its panel for "+scene)
				var first_y: float=INF
				for button in w.ui.menu_buttons:
					if button.visible:
						check(panel.encloses(button.get_global_rect()),"visible action contained: "+button.text)
						first_y=minf(first_y,button.get_global_rect().position.y)
				check(w.ui.menu_description.get_global_rect().end.y<=first_y,"description cannot overlap the first action")
		if scene=="chapter_one":
			w.ui.next_chapter_button.visible=not w.ui.next_chapter_button.visible
			await process_frame
			check(w.ui.menu.get_global_rect().encloses(w.ui.menu_help.get_global_rect()) and (not w.ui.next_chapter_button.visible or w.ui.menu.get_global_rect().encloses(w.ui.next_chapter_button.get_global_rect())),"live chapter-action visibility reflows menu and help")
		if scene=="campaign":
			w.close_menu();w._enter(w.Beat.END);w.cutscene.abort()
			w.lake_sequence.play_finale()
			check(w.ui.lake_cinema,"lake cinematic uses a clear view without gameplay HUD")
			w.cutscene.abort()
			check(not w.ui.lake_cinema,"direct cinematic cancellation restores the HUD")
			var d=w.lake_sequence;d.tableau.set_pose(2);d.tableau.show();d._hide_actors()
			check(w.player.external_pose and w.raven.external_pose and not w.raven.light_occluder.visible,"contact sequence suppresses duplicate normal shadows")
			d.tableau._process(.65);var before: float=d.tableau.hold_clock
			w.menu_open=true;d.tableau._process(2);d._process(2)
			check(d.tableau.hold_clock==before,"pause freezes the held-kiss animation")
			w.menu_open=false;w._enter(w.Beat.ROOF)
			check(not w.player.external_pose and not w.raven.external_pose and w.player.visual.visible and not w.ui.lake_cinema,"chapter transition restores original actors")
		w.queue_free();await process_frame
	print("MOON LAKE / MENU: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
