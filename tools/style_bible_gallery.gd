extends SceneTree
## v0.32.2 · CodexAI: reference cards rendered from active source pixels only.
## These documentation layouts do not redraw or modify any gameplay artwork.
const OUT := "res://docs/stilbibel/bilder/"
const NORMAL := "res://assets/sprites/"
var viewport: SubViewport
var stage: Node2D
var catalog: Dictionary
var attack: Dictionary
var sacrifice: Dictionary
var legacy: Dictionary
var contact: Dictionary
var frames_written := 0

func _initialize() -> void: run.call_deferred()

func read_json(path: String):
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func label_at(value: String, point: Vector2, size: int = 16, tint := Color("bfceda")) -> void:
	var label := Label.new()
	label.text = value
	label.position = point
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", tint)
	stage.add_child(label)

func start_card(size: Vector2i, title: String, subtitle: String) -> void:
	if stage != null: stage.free()
	viewport.size = size
	stage = Node2D.new()
	viewport.add_child(stage)
	var bg := ColorRect.new()
	bg.size = size
	bg.color = Color("101923")
	stage.add_child(bg)
	label_at(title, Vector2(22, 12), 24, Color("79dfed"))
	label_at(subtitle, Vector2(22, 46), 14)

func pose(path: String, rect: Array, anchor: Array, factor: float, title: String, linear := false) -> Dictionary:
	return {"path": path, "rect": rect, "anchor": anchor, "scale": factor, "title": title, "linear": linear}

func meta_pose(path: String, data: Dictionary, title: String) -> Dictionary:
	return pose(path, data.region, data.anchor, float(data.scale), title)

func normal_pose(id: String, frame: int, title: String, hero: bool) -> Dictionary:
	return pose(NORMAL + ("heroes/" if hero else "npcs/") + id + ".png", [frame % 8 * 128, int(frame / 8) * 160, 128, 160], [64,152], 0.5, title, true)

func figure_poses(entry: Dictionary) -> Array:
	var id: String = entry.id
	var result: Array = []
	if entry.kind in ["hero", "npc"]:
		result = [normal_pose(id,0,"Vorne",entry.kind=="hero"), normal_pose(id,8,"Seite",entry.kind=="hero"), normal_pose(id,24,"Hinten",entry.kind=="hero")]
		if entry.kind == "npc":
			var action := meta_pose(NORMAL+"npcs/contact-poses.png",contact[id][0],"Kontaktpose")
			action.linear = true
			result.append(action)
		else: result.append(normal_pose(id,68,"Gehphase",true))
	elif entry.kind in ["memory","civilian","bot"]:
		var data: Dictionary = attack[id]
		var key := "civilian" if entry.kind == "civilian" else "idle"
		var art := "res://assets/memories/attack/" + ("residents.png" if key=="civilian" else "bots.png" if entry.kind=="bot" else "warriors-ready.png")
		for i in [0,1,3]: result.append(meta_pose(art,data[key][i],["Vorne","Seite","","Hinten"][i]))
		if entry.kind == "civilian": result.append(meta_pose("res://assets/memories/attack/residents-walk.png",data.walk_cycle[1],"Gehphase"))
		else: result.append(meta_pose("res://assets/memories/attack/combat.png",data.combat[2],"Aktionspose"))
	elif entry.kind == "master":
		for i in [0,2]: result.append(meta_pose("res://assets/memories/legacy/characters.png",legacy.figures[i],"Stehend" if i==0 else "Gespräch mit Shadepi"))
		result.append(meta_pose("res://assets/memories/legacy/master-death.png",legacy.master_death[2],"Nach Übergabe · tot"))
	elif entry.kind == "minotaur":
		for i in [0,1,3,7]: result.append(meta_pose("res://assets/memories/sacrifice/minotaur.png",sacrifice.minotaur[i],["Bereit","Schritt","","Feuer","","","","Wrack"][i]))
	elif entry.kind == "digital":
		var art: Texture2D = load(NORMAL+"npcs/"+id+".png")
		result.append(pose(art.resource_path,[0,0,art.get_width(),art.get_height()],[art.get_width()/2.0,art.get_height()/2.0],entry.diameter/float(art.get_width()),"Schwebende Form",true))
	return result

func place(data: Dictionary, point: Vector2, zoom: float = 1.0) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = load(data.path)
	var r: Array = data.rect
	texture.region = Rect2(r[0],r[1],r[2],r[3])
	texture.filter_clip = true
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if data.linear else CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * float(data.scale) * zoom
	sprite.position = point + (Vector2(r[2],r[3])*0.5 - Vector2(data.anchor[0],data.anchor[1]))*sprite.scale
	stage.add_child(sprite)

func save_card(id: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var error := viewport.get_texture().get_image().save_png(OUT+id+".png")
	if error != OK:
		push_error("Cannot save " + id)
		quit(1)
	frames_written += 1

func figures() -> void:
	for entry in catalog.figures:
		var poses := figure_poses(entry)
		var zoom := 1.7 if entry.kind == "minotaur" else 3.0 if entry.kind == "master" else 4.0
		start_card(Vector2i(1200,450),entry.title,"AKTIVE SPIELPIXEL · Ansicht ×%.1f · rechts Weltmaßstab ×1 · v%s · CodexAI" % [zoom,catalog.version])
		for i in poses.size():
			label_at(poses[i].title,Vector2(20+i*238,80),15)
			place(poses[i],Vector2(115+i*238,377 if entry.kind!="digital" else 240),zoom)
		label_at("Spielgröße ×1",Vector2(974,80),15)
		place(poses[0],Vector2(1080,377 if entry.kind!="digital" else 240))
		label_at("ID: "+entry.id+" · "+poses[0].path.trim_prefix("res://"),Vector2(22,423),12)
		await save_card("figur-"+entry.id)
	start_card(Vector2i(1400,1180),"FIGUREN · gesamter aktiver Bestand","23 Figuren / Typen · für die Übersicht angepasst · verbindliche Weltgröße rechts auf jeder Einzelkarte · v0.32.2 · CodexAI")
	for i in catalog.figures.size():
		var entry: Dictionary = catalog.figures[i]
		var data: Dictionary = figure_poses(entry)[0]
		var origin := Vector2(18+(i%5)*280,86+int(i/5)*212)
		label_at(entry.title,origin,13)
		place(data,origin+Vector2(120,184 if entry.kind!="digital" else 100),0.9 if entry.kind=="minotaur" else 2.0)
	await save_card("figuren-uebersicht")

func worlds() -> void:
	var art: Dictionary = preload("res://scripts/painted_world.gd").ART.duplicate()
	art["compensator"] = load("res://assets/world/painted/compensator-clear.png")
	art["angriff"] = load("res://assets/memories/attack/courtyard.png")
	art["lys-opfer"] = load("res://assets/memories/sacrifice/courtyard.png")
	art["tempel"] = load("res://assets/memories/legacy/temple-interior.png")
	start_card(Vector2i(1280,1340),"WELTEN · aktive Hintergrundquellen","Quellbilder ohne Figuren und Zusatz-FX · keine gemeinsame Weltmaßstabsbehauptung · v0.32.2 · CodexAI")
	var index := 0
	for key in art:
		var col: int = index % 4
		var row: int = index / 4
		var tex: Texture2D = art[key]
		label_at(key,Vector2(16+col*318,80+row*246),16)
		var image := Sprite2D.new()
		image.texture = tex
		image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		image.scale = Vector2.ONE * minf(302.0/tex.get_width(),196.0/tex.get_height())
		image.position = Vector2(167+col*318,205+row*246)
		stage.add_child(image)
		if key=="hangar":
			var painted = preload("res://scripts/painted_world.gd")
			var brand := Sprite2D.new()
			brand.texture = painted.HANGAR_BRAND
			var unit := image.scale*tex.get_size()/Vector2(1024,640)
			brand.scale = painted.HANGAR_BRAND_RECT.size*unit/brand.texture.get_size()
			brand.position = image.position+(painted.HANGAR_BRAND_RECT.get_center()-Vector2(512,320))*unit
			stage.add_child(brand)
		index += 1
	await save_card("welten")

func props() -> void:
	const Art = preload("res://scripts/prop_art.gd")
	var titles := ["Kiste","Fass","Lampe","Auto","Container","Elektrokasten","Automat","Serverschrank","Datenspeicher"]
	for sheet in 3:
		start_card(Vector2i(1200,730),"REQUISITEN · Teil %d / 3"%(sheet+1),"Figur und Objekte im gleichen Weltmaßstab ×1,5 · v0.32.2 · CodexAI")
		for column in 3: label_at(["Intakt","Beschädigt","Zerstört"][column],Vector2(350+column*300,80),17)
		for row in 3:
			var i: int = sheet*3+row
			var origin := Vector2(0,280+row*202)
			label_at(titles[i],origin+Vector2(16,-130),18)
			place(normal_pose("raven",0,"Raven",true),origin+Vector2(180,0),1.5)
			for state in 3:
				var node := Node2D.new()
				node.position = origin+Vector2(450+state*300,0)
				node.scale = Vector2.ONE*1.5
				stage.add_child(node)
				var sprite := Sprite2D.new()
				node.add_child(sprite)
				Art.apply(sprite,i,state)
		await save_card("requisiten-%d"%(sheet+1))

func vehicles() -> void:
	start_card(Vector2i(1200,610),"FAHRZEUGE · aktive Einzelquellen","Atlasansichten vergrößert, keine gemeinsame Weltgröße · Hangar-Abweichung separat dokumentiert · v0.32.2 · CodexAI")
	var names := ["Aerodyne · Atlas 0","Verfolgerauto · Atlas 1","Motorrad mit beiden · Atlas 2","Drohne · Atlas 3"]
	for i in 4:
		label_at(names[i],Vector2(20+i*295,80),15)
		place(pose("res://assets/world/hq/vehicles.png",[i%2*627,int(i/2)*627,627,627],[313.5,313.5],0.44,names[i],true),Vector2(150+i*295,260))
	label_at("Geparktes Motorrad · ohne Fahrer",Vector2(24,427),16)
	place(pose("res://assets/world/hq/bike-parked.png",[0,0,217,403],[108.5,201.5],0.4,"Motorrad",true),Vector2(550,510))
	await save_card("fahrzeuge")

func ui_themes() -> void:
	start_card(Vector2i(1200,700),"OBERFLÄCHEN · sechs aktive Materialfamilien","Originalrahmen ×3, Schaltflächen/Zellen ×2 · v0.32.2 · CodexAI")
	var names := ["raven","jackal","order","artos","tower","lake"]
	for i in 6:
		var origin := Vector2(24+(i%3)*397,92+int(i/3)*300)
		label_at(names[i].to_upper(),origin,18)
		var path: String = "res://assets/ui/"+names[i]+"/"
		for j in 3:
			var name: String = ["frame","button","cells"][j]
			var tex: Texture2D = load(path+name+".png")
			var sprite := Sprite2D.new()
			sprite.texture = tex
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.scale = Vector2.ONE*(3 if j==0 else 2)
			sprite.position = origin+Vector2(102 if j==0 else 285,140 if j<2 else 245)
			stage.add_child(sprite)
	await save_card("oberflaechen")

func effects() -> void:
	start_card(Vector2i(1200,930),"FX · Projektile, Feuer, Rauch und Energie","Unveränderte Atlasbilder, vergrößert · Auslösepunkte und Pausenregeln gehören zur jeweiligen Szene · v0.32.2 · CodexAI")
	for row in 3:
		var id: String = ["lightning","bullet","muzzle"][row]
		label_at(["Blitz aus Ravens Hand","Pistolengeschoss","Mündungsfeuer"][row],Vector2(20,90+row*125),17)
		for j in 4:
			place(pose("res://assets/fx/"+id+".png",[j*2*96,0,96,48],[48,24],2.0,id),Vector2(330+j*240,135+row*125))
	for row in 3:
		var path: String = ["res://assets/memories/attack/props-fx.png","res://assets/memories/legacy/transfer.png","res://assets/memories/legacy/shadepi-aura.png"][row]
		label_at(["Feuer / Rauch · Atlas-Zeile 2","Weißer Nanitenstrom","Aura · Rück-/Vordergrund"][row],Vector2(20,492+row*140),16)
		var tex: Texture2D = load(path)
		for j in 4:
			var columns := 4
			var rows := 2 if row==1 else 4
			var index: int = j+(4 if row==0 else 8 if row==2 and j>=2 else 0)
			var left := roundi((index%columns)*tex.get_width()/float(columns))
			var top := roundi(int(index/columns)*tex.get_height()/float(rows))
			var right := roundi((index%columns+1)*tex.get_width()/float(columns))
			var bottom := roundi((int(index/columns)+1)*tex.get_height()/float(rows))
			place(pose(path,[left,top,right-left,bottom-top],[(right-left)/2.0,(bottom-top)/2.0],minf(180.0/(right-left),112.0/(bottom-top)),"FX"),Vector2(330+j*240,550+row*140))
	await save_card("effekte")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Style bible reference rendering requires a real display, e.g. Xvfb/Mesa.")
		quit(1)
		return
	var part := "all"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--part="): part = argument.trim_prefix("--part=")
	if part not in ["all","figures","worlds","props","vehicles","ui","effects"]:
		push_error("Unknown style bible part: "+part)
		quit(1)
		return
	catalog = read_json("res://docs/stilbibel/figuren.json")
	attack = read_json("res://assets/memories/attack/actors.json")
	sacrifice = read_json("res://assets/memories/sacrifice/actors.json")
	legacy = read_json("res://assets/memories/legacy/actors.json")
	contact = read_json("res://assets/sprites/npcs/contact-poses.json")
	viewport = SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	if part in ["all","figures"]: await figures()
	if part in ["all","worlds"]: await worlds()
	if part in ["all","props"]: await props()
	if part in ["all","vehicles"]: await vehicles()
	if part in ["all","ui"]: await ui_themes()
	if part in ["all","effects"]: await effects()
	print("STYLE BIBLE: ",frames_written," reference boards rendered; ",catalog.figures.size()," figures")
	quit()
