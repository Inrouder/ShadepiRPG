extends SceneTree
# Original pixel textures: stepped cores, branched sparks, palette glow; no vectors.
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/fx")
	for kind in ["lightning", "bullet", "muzzle"]:
		var sheet := Image.create(768, 48, false, Image.FORMAT_RGBA8)
		for frame in 8:
			var image := Image.create(96, 48, false, Image.FORMAT_RGBA8)
			var rng := RandomNumberGenerator.new()
			rng.seed = 423 + frame * 41
			var path: Array[Vector2i] = []
			if kind == "lightning":
				path.append(Vector2i(8, 24))
				for x in range(14, 85, 6): path.append(Vector2i(x, 24 + rng.randi_range(-7, 7)))
				path.append(Vector2i(90, 24))
				for i in range(1, path.size()):
					for pass_index in 3: line(image, path[i-1], path[i], pass_index, false)
					if i % 3 == 0:
						var tip := path[i] + Vector2i(-14, rng.randi_range(-14, 14))
						line(image, path[i], tip, 1, false)
				for i in 18:
					var point := Vector2i(rng.randi_range(10, 86), rng.randi_range(6, 42))
					image.set_pixelv(point, Color("2581b8") if i%2 else Color("66dbf4"))
			elif kind == "bullet":
				for p in 3: line(image, Vector2i(22,24), Vector2i(76,24), p, true)
			else:
				for i in 9:
					var angle := i * TAU / 9 + frame * 0.2
					var tip := Vector2i(Vector2(48,24) + Vector2(cos(angle)*rng.randf_range(8,21), sin(angle)*rng.randf_range(3,11)))
					for p in 3: line(image, Vector2i(48,24), tip, p, true)
			sheet.blit_rect(image, Rect2i(0,0,96,48), Vector2i(frame*96,0))
		sheet.save_png("res://assets/fx/"+kind+".png")
	quit()
func line(image: Image, a: Vector2i, b: Vector2i, layer: int, warm: bool) -> void:
	var colors := [Color("1e588880"),Color("28aee3"),Color("e3fcff")] if not warm else [Color("b04e2560"),Color("ffb651"),Color("fff2c5")]
	var width: int = [3,1,0][layer]
	var steps := maxi(absi(b.x-a.x), absi(b.y-a.y))
	for i in steps+1:
		var p := Vector2i(Vector2(a).lerp(Vector2(b), float(i)/maxi(1,steps)).round())
		for y in range(-width,width+1):
			for x in range(-width,width+1):
				var q := p+Vector2i(x,y)
				if q.x>=0 and q.y>=0 and q.x<96 and q.y<48: image.set_pixelv(q,colors[layer])
