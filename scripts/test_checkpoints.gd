extends RefCounted
## v0.44.0 · CodexAI. Authored, story-consistent test entries; no production saves.
const Admin = preload("res://scripts/admin_tools.gd")
const REQUEST := "shadepi_test_checkpoint"
# id, chapter, label, state, interaction point, arcade section / relay
const ENTRIES := [
	["raven-home",1,"Wohnung · Auftragsannahme",0,0,0],
	["hunt-west",1,"Jagd · Westlicher Abschnitt",1,0,0],
	["hunt-mid",1,"Jagd · Mittlerer Abschnitt",1,0,1],
	["hunt-east",1,"Jagd · Östlicher Abschnitt",1,0,2],
	["rescue",1,"Shadepi · Rettungsweg",4,0,0],
	["jackal",1,"Chrome Jackal · Teamkampf",6,0,0],
	["chapter1-end",1,"Ausgang zu Kapitel 2",7,0,0],
	["yard",2,"Industriehof",0,0,0],
	["hideout",2,"Versteck · Gespräch",1,0,0],
	["ice-bath",2,"Eisbad · Anschluss",5,0,0],
	["relay1",2,"Deep Dive · Relais 1",2,0,0],
	["relay2",2,"Deep Dive · Relais 2",2,0,1],
	["relay3",2,"Deep Dive · ICE-Bossarena",2,0,2],
	["recovery",2,"Rückkehr aus dem Netz",3,0,0],
	["chapter2-end",2,"Versteck · Nach dem Eisbad",4,0,0],
	["pact",3,"Der Pakt · Gespräch",0,0,0],
	["ambush-west",3,"Hinterhalt · Erster Abschnitt",1,0,0],
	["ambush-east",3,"Hinterhalt · Zweiter Abschnitt",1,0,1],
	["chase",3,"Motorrad · Verfolgung",2,0,0],
	["garage",4,"Garage · Werkbanksymbol",3,0,0],
	["garage-lock",4,"Garage · Verriegelung",3,1,0],
	["hangar",4,"Hangar · Aerodyne vorbereiten",4,0,0],
	["hangar-power",4,"Hangar · Energiebus",4,1,0],
	["hangar-id",4,"Hangar · Kennung",4,2,0],
	["sanctuary",5,"Heiligtum · Ravens Ankunft",5,0,0],
	["sanctuary-wake",5,"Heiligtum · Nach zwei Stunden",5,0,0],
	["memory1",5,"Erinnerung 1 · Der Angriff",5,0,0],
	["memory2",5,"Erinnerung 2 · Lys Opfer",5,1,0],
	["memory3",5,"Erinnerung 3 · Das Vermächtnis",5,2,0],
	["flight",6,"Aerodyne · Flug zum Tower",6,0,0],
	["roof",6,"Tower · Dach-Landeplatz",7,0,0],
	["roof-door",6,"Tower · Türzugang",7,1,0],
	["kenzo",6,"Penthouse · Kenzō-Kampf",8,0,0],
	["extraction",6,"Penthouse · Raven schützen",9,0,0],
	["escape-charge",6,"Flucht · Bombe scharfstellen",9,1,0],
	["escape-gate",6,"Flucht · Ausgang hacken",9,2,0],
	["escape-pad",6,"Flucht · Zum Aerodyne",9,3,0],
	["lake-arrival",7,"See · Landeanflug und Finale",10,0,0],
	["lake-shore",7,"See · Ufer erkunden",10,0,0],
	["ending",7,"Der neue Orden · Abschluss",11,0,0],
]

static func entries(chapter: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in ENTRIES:
		if row[1]==chapter: result.append({"id":row[0],"chapter":row[1],"label":row[2],"state":row[3],"point":row[4],"section":row[5]})
	return result

static func find(id: String) -> Dictionary:
	for chapter in range(1,8):
		for entry in entries(chapter):
			if entry.id==id: return entry
	return {}

static func request(tree: SceneTree,id: String) -> Error:
	var entry := find(id)
	if entry.is_empty(): return ERR_INVALID_PARAMETER
	var previous := Admin.is_test_session(tree)
	tree.set_meta(Admin.SESSION_KEY,true)
	tree.set_meta(REQUEST,id)
	var error := tree.change_scene_to_file(Admin.scene_for_chapter(entry.chapter))
	if error!=OK:
		tree.remove_meta(REQUEST)
		if not previous: tree.remove_meta(Admin.SESSION_KEY)
	return error

static func consume(world: Node2D) -> bool:
	var tree := world.get_tree()
	var id: Variant = tree.get_meta(REQUEST,"")
	if not id is String: return false
	var entry := find(id)
	if entry.is_empty() or Admin.scene_for_chapter(entry.chapter)!=world.scene_file_path: return false
	tree.remove_meta(REQUEST)
	tree.set_meta(Admin.SESSION_KEY,true)
	world.restore_dressing_state({})
	if entry.chapter==1:
		world.chapter_coop = false
		world._enter_checkpoint(entry.state,entry.section)
	elif entry.chapter==2:
		world._enter(entry.state,entry.section)
	else:
		world.fresh_entry = false
		var memory: bool = id.begins_with("memory")
		var tower: int = 0 if id=="extraction" else 2 if id.begins_with("escape-") else -1
		world._enter(entry.state,entry.section,entry.point,memory,id in ["memory2","memory3"],id=="memory3",false,1 if id=="sanctuary-wake" else 0,false,tower,id=="lake-arrival")
	world.toast("Test-Kontrollpunkt: "+entry.label)
	return true
