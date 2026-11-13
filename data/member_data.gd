class_name MemberData
extends RefCounted
## Data satu anggota tim SubnetQuest. Dibuat dari data/members.json.

const KNIGHT_FRAME := 32 # ukuran visual target per frame di world space (32x32 px)
const KNIGHT_IDLE_ROW := 0 # 4 frame
const KNIGHT_RUN_ROW := 2 # 8 frame

var id: String = ""
var nama: String = ""
var nim: String = ""
var peran: String = ""
var dialog: String = ""
var portrait_path: String = ""
var sheet_path: String = ""
var layout: String = "knight" # "knight" (1 arah + flip) atau "grid4" (4 arah, 4x4)
var faces_right: bool = true # knight: apakah gambar aslinya menghadap kanan
var feet_y: float = 10.0 # posisi collision kaki relatif pusat sprite
var color: Color = Color.WHITE
var _frames: SpriteFrames

static func from_dict(d: Dictionary, index: int) -> MemberData:
	var m := MemberData.new()
	m.id = str(d.get("id", "m%d" % index))
	m.nama = str(d.get("nama", "Nama %d" % index))
	m.nim = str(d.get("nim", "-"))
	m.peran = str(d.get("peran", "-"))
	m.dialog = str(d.get("dialog", "Halo!"))
	m.portrait_path = str(d.get("portrait", "res://assets/portraits/portrait_%d.png" % index))
	m.sheet_path = str(d.get("sheet", "res://assets/characters/char_%d.png" % index))
	m.layout = str(d.get("layout", "knight"))
	m.faces_right = bool(d.get("faces_right", true))
	m.feet_y = 10.0 if m.layout == "knight" else 5.0
	var palette := [Color("e74c3c"), Color("3498db"), Color("f1c40f")]
	m.color = palette[(index - 1) % palette.size()]
	return m

func get_portrait() -> Texture2D:
	if ResourceLoader.exists(portrait_path):
		return load(portrait_path)
	return _placeholder(32, 32)

func get_sheet() -> Texture2D:
	if ResourceLoader.exists(sheet_path):
		return load(sheet_path)
	var size := 256 if layout == "knight" else 64
	return _placeholder(size, size)

func get_sprite_scale() -> Vector2:
	var tex := get_sheet()
	if layout == "knight":
		var fw := maxf(1.0, float(tex.get_width()) / 8.0)
		var fh := maxf(1.0, float(tex.get_height()) / 8.0)
		return Vector2(float(KNIGHT_FRAME) / fw, float(KNIGHT_FRAME) / fh)
	else:
		var fw4 := maxf(1.0, float(tex.get_width()) / 4.0)
		var fh4 := maxf(1.0, float(tex.get_height()) / 4.0)
		return Vector2(16.0 / fw4, 16.0 / fh4)

func _placeholder(w: int, h: int) -> Texture2D:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

func needs_flip(facing: String) -> bool:
	if layout != "knight":
		return false
	return facing == ("left" if faces_right else "right")

func build_frames() -> SpriteFrames:
	if _frames:
		return _frames
	var tex := get_sheet()
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	if layout == "knight":
		_build_knight(sf, tex)
	else:
		_build_grid4(sf, tex)
	_frames = sf
	return sf

func _add_anim(sf: SpriteFrames, anim: String, tex: Texture2D, fw: int, fh: int, row: int, count: int, fps: float) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, true)
	for c in count:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(c * fw, row * fh, fw, fh)
		sf.add_frame(anim, at)

func _build_knight(sf: SpriteFrames, tex: Texture2D) -> void:
	var fw := maxi(1, int(tex.get_width() / 8))
	var fh := maxi(1, int(tex.get_height() / 8))
	for dir in ["down", "left", "right", "up"]:
		_add_anim(sf, "idle_" + dir, tex, fw, fh, KNIGHT_IDLE_ROW, 4, 5.0)
		_add_anim(sf, "walk_" + dir, tex, fw, fh, KNIGHT_RUN_ROW, 8, 12.0)

func _build_grid4(sf: SpriteFrames, tex: Texture2D) -> void:
	var fw := int(tex.get_width() / 4)
	var fh := int(tex.get_height() / 4)
	var rows := {"down": 0, "left": 1, "right": 2, "up": 3}
	for dir in rows:
		_add_anim(sf, "walk_" + dir, tex, fw, fh, rows[dir], 4, 8.0)
		sf.add_animation("idle_" + dir)
		sf.set_animation_speed("idle_" + dir, 1.0)
		sf.set_animation_loop("idle_" + dir, true)
		sf.add_frame("idle_" + dir, sf.get_frame_texture("walk_" + dir, 0))
