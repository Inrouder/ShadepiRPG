extends RefCounted
## Pixel-art look for menus and Raven's hacking decks, themed by scene / target.
## Art: assets/ui/<theme>/*.png and assets/ui/emblems.png, built 1:1 for the
## 640x360 viewport by tools/ui_pixel/build_ui_pixel.py (drawn in Pixelwright).
## Everything uses nearest filtering and whole-pixel nine-slices.

const THEMES := {
	"raven": {"primary": Color("62e3ee"), "accent": Color("ff7fc0"), "deep": Color("070a12"), "text": Color("d9f3f7"), "muted": Color("7f9fb0"), "warn": Color("ff697c"),
		"system": "NIGHTWING · RAVENS EIGENES NETZ"},
	"jackal": {"primary": Color("ff5fa2"), "accent": Color("ffcf7a"), "deep": Color("0d070c"), "text": Color("ffe3ef"), "muted": Color("b98aa2"), "warn": Color("ff4d4d"),
		"system": "GANG-TECH · CHROME JACKALS"},
	"order": {"primary": Color("e9e2cf"), "accent": Color("f5dc96"), "deep": Color("080b0a"), "text": Color("f4f0e4"), "muted": Color("9aaa9f"), "warn": Color("ff7a6b"),
		"system": "ORDEN DES WEISSEN DRACHEN"},
	"artos": {"primary": Color("ffb43a"), "accent": Color("d6ecaa"), "deep": Color("0c0905"), "text": Color("ffe7bd"), "muted": Color("b89a6c"), "warn": Color("ff5a3c"),
		"system": "ARToS-7 · MILITÄR-AERODYNE"},
	"tower": {"primary": Color("ff3150"), "accent": Color("f5e0a0"), "deep": Color("0b0507"), "text": Color("ffe9ec"), "muted": Color("b98d95"), "warn": Color("ffcf5a"),
		"system": "MORIYAMA · PRIVATNETZ"},
	"lake": {"primary": Color("bcd8ff"), "accent": Color("7ff0ff"), "deep": Color("060b16"), "text": Color("eaf3ff"), "muted": Color("8ea4c0"), "warn": Color("ff8aa0"),
		"system": "HEILIGTUM · SEE"},
}

const TERMINALS := {
	"jackal": "jackal", "garage": "order", "power": "order", "transponder": "artos",
	"repair": "artos", "roof_signal": "tower", "penthouse": "tower", "charge": "tower",
}

## Look of the pause menu per chapter (0 = prologue … 7 = epilogue at the lake).
const CHAPTERS := ["raven", "jackal", "raven", "raven", "order", "order", "tower", "lake"]
const EMBLEMS := ["raven", "jackal", "order", "artos", "tower", "lake"]
const BUTTON_STATES := {"normal": 0, "hover": 1, "focus": 1, "pressed": 2, "hover_pressed": 2, "disabled": 3}
const CELL_STATES := {"idle": 0, "open": 1, "cursor": 2, "used": 3}
## Native sizes: one font pixel equals one screen pixel.
const UI_SIZE := 20
const TITLE_SIZE := 16
const SMALL_TITLE_SIZE := 8

static var _fonts := {}

static func terminal_theme(context: String) -> String:
	return TERMINALS.get(context, "raven")

static func chapter_theme(chapter: int) -> String:
	return CHAPTERS[clampi(chapter, 0, CHAPTERS.size() - 1)]

static func colors(theme: String) -> Dictionary:
	return THEMES.get(theme, THEMES.raven)

static func texture(theme: String, part: String) -> Texture2D:
	return load("res://assets/ui/%s/%s.png" % [theme if THEMES.has(theme) else "raven", part])

static func atlas(source: Texture2D, region: Rect2) -> AtlasTexture:
	var piece := AtlasTexture.new()
	piece.atlas = source
	piece.region = region
	return piece

static func emblem(theme: String) -> AtlasTexture:
	return atlas(load("res://assets/ui/emblems.png"), Rect2(maxi(0, EMBLEMS.find(theme)) * 24, 0, 24, 24))

## "ui": Shadepi Pixel (Jersey 10 on a 1 px grid at size 20, with pixel arrows).
## "title" / "mono": Silkscreen capitals at 8 or 16.
static func font(kind: String = "ui") -> Font:
	if _fonts.has(kind):
		return _fonts[kind]
	var file: String = "ShadepiPixel.ttf" if kind == "ui" else "Silkscreen-Regular.ttf"
	var result := (load("res://assets/fonts/" + file) as FontFile).duplicate() as FontFile
	result.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	result.hinting = TextServer.HINTING_NONE
	result.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	result.generate_mipmaps = false
	_fonts[kind] = result
	return result

static func _box(source: Texture2D, region: Rect2, margins: Array, content: Array = []) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = source
	box.region_rect = region
	box.texture_margin_left = margins[0]
	box.texture_margin_top = margins[1]
	box.texture_margin_right = margins[2]
	box.texture_margin_bottom = margins[3]
	if content.is_empty():
		content = margins
	box.content_margin_left = content[0]
	box.content_margin_top = content[1]
	box.content_margin_right = content[2]
	box.content_margin_bottom = content[3]
	return box

## Steel panel with chamfered corners. slim keeps the corners intact on low
## panels (status bars) by using thin top and bottom slices.
static func panel(theme: String, slim: bool = false) -> StyleBoxTexture:
	var margins := [22, 8, 22, 8] if slim else [22, 22, 22, 22]
	var box := _box(texture(theme, "frame"), Rect2(0, 0, 64, 64), margins, [10, 6, 10, 6] if slim else [10, 9, 10, 9])
	# Plate seams, rivets and brushed flecks repeat every 20 px instead of smearing.
	box.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	if not slim:
		box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	return box

static func header(theme: String) -> StyleBoxTexture:
	return _box(texture(theme, "header"), Rect2(0, 0, 64, 20), [6, 4, 26, 4], [10, 0, 28, 0])

static func button(theme: String, state: String) -> StyleBoxTexture:
	var row: int = BUTTON_STATES.get(state, 0)
	var box := _box(texture(theme, "button"), Rect2(0, row * 18, 64, 18), [8, 5, 12, 5], [11, 0, 13, 1])
	# The scanlines repeat every 2 px; tiling keeps them even at any height.
	box.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	if state == "pressed" or state == "hover_pressed":
		box.content_margin_top = 1
		box.content_margin_bottom = 0
	return box

static func cell(theme: String, state: String) -> StyleBoxTexture:
	return _box(texture(theme, "cells"), Rect2(CELL_STATES.get(state, 0) * 16, 0, 16, 16), [4, 4, 4, 4], [2, 0, 2, 0])

static func apply_button(target: Control, theme: String, font_size: int = UI_SIZE) -> void:
	var c := colors(theme)
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		target.add_theme_stylebox_override(state, button(theme, state) if state != "focus" else StyleBoxEmpty.new())
	_text(target, font_size)
	for key in ["font_color", "font_hover_color", "font_focus_color", "font_hover_pressed_color"]:
		target.add_theme_color_override(key, c.text)
	target.add_theme_color_override("font_pressed_color", Color.WHITE)
	target.add_theme_color_override("font_disabled_color", Color(c.muted, 0.55))
	target.add_theme_color_override("font_outline_color", Color(c.deep, 0.9))
	target.add_theme_constant_override("outline_size", 0)
	target.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Keyboard / pad focus uses the bright hover art too.
	target.set_meta("ui_theme", theme)
	if target is BaseButton and not target.has_meta("ui_focus_hooked"):
		target.set_meta("ui_focus_hooked", true)
		target.focus_entered.connect(_refresh_focus.bind(target))
		target.focus_exited.connect(_refresh_focus.bind(target))
	_refresh_focus(target)

static func _refresh_focus(target: Control) -> void:
	var theme: String = target.get_meta("ui_theme", "raven")
	var focused: bool = target.has_focus() and not (target is BaseButton and target.disabled)
	target.add_theme_stylebox_override("normal", button(theme, "focus" if focused else "normal"))

## Hex / code cell: idle, open (legal), cursor and used looks.
static func apply_cell(target: Button, theme: String) -> void:
	var c := colors(theme)
	target.add_theme_stylebox_override("normal", cell(theme, "open"))
	target.add_theme_stylebox_override("hover", cell(theme, "cursor"))
	target.add_theme_stylebox_override("pressed", cell(theme, "cursor"))
	target.add_theme_stylebox_override("hover_pressed", cell(theme, "cursor"))
	target.add_theme_stylebox_override("disabled", cell(theme, "idle"))
	target.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	target.add_theme_font_override("font", font("mono"))
	target.add_theme_font_size_override("font_size", TITLE_SIZE)
	target.add_theme_color_override("font_color", c.text)
	target.add_theme_color_override("font_hover_color", Color.WHITE)
	target.add_theme_color_override("font_focus_color", Color.WHITE)
	target.add_theme_color_override("font_disabled_color", Color(c.muted, 0.7))
	target.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var refresh := func():
		target.add_theme_stylebox_override("normal", cell(theme, "cursor" if target.has_focus() else "open"))
	target.focus_entered.connect(refresh)
	target.focus_exited.connect(refresh)

static func mark_used(target: Button, theme: String, used: bool) -> void:
	target.add_theme_stylebox_override("disabled", cell(theme, "used" if used else "idle"))

static func apply_slider(slider: Slider, theme: String) -> void:
	var parts := texture(theme, "parts")
	slider.add_theme_stylebox_override("slider", _box(parts, Rect2(0, 0, 16, 6), [3, 2, 3, 2], [0, 2, 0, 2]))
	slider.add_theme_stylebox_override("grabber_area", _box(parts, Rect2(0, 8, 16, 6), [3, 2, 3, 2], [0, 2, 0, 2]))
	slider.add_theme_stylebox_override("grabber_area_highlight", _box(parts, Rect2(0, 8, 16, 6), [3, 2, 3, 2], [0, 2, 0, 2]))
	slider.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	slider.add_theme_icon_override("grabber", atlas(parts, Rect2(18, 1, 10, 14)))
	slider.add_theme_icon_override("grabber_highlight", atlas(parts, Rect2(30, 1, 10, 14)))
	slider.add_theme_icon_override("grabber_disabled", atlas(parts, Rect2(18, 1, 10, 14)))
	slider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

static func chevron(theme: String) -> AtlasTexture:
	return atlas(texture(theme, "parts"), Rect2(42, 4, 5, 7))

static func _text(target: Control, font_size: int) -> void:
	target.add_theme_font_override("font", font("ui"))
	target.add_theme_font_size_override("font_size", font_size)

## Label helper in the pixel font. title uses Silkscreen capitals.
static func style_label(label: Label, color: Color, kind: String = "ui", font_size: int = -1) -> Label:
	if font_size < 0:
		font_size = UI_SIZE if kind == "ui" else TITLE_SIZE
	label.add_theme_font_override("font", font(kind))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	if kind == "ui":
		label.add_theme_constant_override("line_spacing", -5)
	return label

## Blurred live scene with the theme tint and scanlines.
static func backdrop(theme: String, strength: float = 0.78) -> ColorRect:
	var c := colors(theme)
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/ui_backdrop.gdshader")
	material.set_shader_parameter("tint", Color(c.deep, strength))
	material.set_shader_parameter("glow", c.primary)
	rect.material = material
	return rect
