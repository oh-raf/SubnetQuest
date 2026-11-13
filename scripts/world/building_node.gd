extends StaticBody2D
## Node Terminal Gedung Kampus untuk Konfigurasi Subnetting (Mendukung Aset Bangunan bldg_*.png & Fallback Prosedural).

signal request_configure(building_data: Dictionary)

const BLDG_PATHS := {
	"server": "res://assets/buildings/bldg_server.png",
	"fakultas": "res://assets/buildings/bldg_fakultas.png",
	"lab": "res://assets/buildings/bldg_lab.png",
	"kantor": "res://assets/buildings/bldg_kantor.png",
}

var building_data: Dictionary = {} # WAJIB di-set sebelum add_child()
var is_online: bool = false

var _bldg_sprite: Sprite2D
var _led: ColorRect
var _title_lbl: Label
var _status_lbl: Label
var _prompt_lbl: Label
var _area: Area2D
var _player_near: bool = false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

	# Muat visual bangunan (bldg_server.png, bldg_fakultas.png, bldg_lab.png, bldg_kantor.png) bila tersedia
	_setup_building_sprite()

	# Visual Terminal Router Gedung (32x24 px) di pintu masuk gedung
	var base_box := ColorRect.new()
	base_box.color = Color("1e3a5f")
	base_box.position = Vector2(-18, -14)
	base_box.size = Vector2(36, 24)
	add_child(base_box)

	_led = ColorRect.new()
	_led.color = Color("e74c3c")
	_led.position = Vector2(-14, -10)
	_led.size = Vector2(28, 6)
	add_child(_led)

	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(32, 16)
	cs.shape = rs
	add_child(cs)

	var short_name := str(building_data.get("short_name", "Gedung"))
	var hosts := int(building_data.get("needed_hosts", 0))
	_title_lbl = UIKit.label("%s (%dh)" % [short_name, hosts], 8, Color("ffd166"))
	_title_lbl.position = Vector2(-55, -28)
	_title_lbl.size = Vector2(110, 12)
	add_child(_title_lbl)

	_status_lbl = UIKit.label("OFFLINE", 8, Color("ff6b6b"))
	_status_lbl.position = Vector2(-40, 10)
	_status_lbl.size = Vector2(80, 12)
	add_child(_status_lbl)

	_prompt_lbl = UIKit.label("[E] Konfigurasi IP", 8, Color("8ecae6"))
	_prompt_lbl.position = Vector2(-50, 20)
	_prompt_lbl.size = Vector2(100, 12)
	_prompt_lbl.hide()
	add_child(_prompt_lbl)

	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = 1
	var acs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 30.0
	acs.shape = circle
	_area.add_child(acs)
	add_child(_area)
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)

func _resolve_building_key() -> String:
	var b_id := str(building_data.get("id", "")).to_lower()
	var b_name := str(building_data.get("name", "")).to_lower()
	if b_id.begins_with("w1_") or "server" in b_name or "gateway" in b_name or "router" in b_name:
		return "server"
	if "lab" in b_name:
		return "lab"
	if "kantor" in b_name or "perpustakaan" in b_name or "fip" in b_name:
		return "kantor"
	return "fakultas"

func _prepare_building_texture(raw_tex: Texture2D, key: String) -> Texture2D:
	if raw_tex == null:
		return null
	var w := raw_tex.get_width()
	var h := raw_tex.get_height()
	# Bila file yang dimuat adalah sheet tileset utuh (432x288 atau 256x2240), potong region gedung secara otomatis
	if w == 432 and h == 288:
		var at := AtlasTexture.new()
		at.atlas = raw_tex
		at.region = Rect2(272, 64, 96, 64) if key == "kantor" else Rect2(272, 0, 96, 64)
		return at
	if w == 256 and h >= 1000:
		var at2 := AtlasTexture.new()
		at2.atlas = raw_tex
		at2.region = Rect2(32, 1280, 64, 160) if key == "server" else Rect2(64, 1024, 192, 192)
		return at2
	return raw_tex

func _setup_building_sprite() -> void:
	var key := _resolve_building_key()
	var path: String = BLDG_PATHS.get(key, BLDG_PATHS["fakultas"])
	if not ResourceLoader.exists(path):
		return
	var loaded: Texture2D = load(path)
	var tex := _prepare_building_texture(loaded, key)
	if tex == null:
		return
	_bldg_sprite = Sprite2D.new()
	_bldg_sprite.texture = tex
	_bldg_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tw := maxf(1.0, float(tex.get_width()))
	var th := maxf(1.0, float(tex.get_height()))
	# Skala proporsional agar pas di area gedung (lebar ~120px, tinggi ~68px) tepat di atas pintu terminal
	var target_w := 120.0
	var target_h := 68.0
	var s := minf(target_w / tw, target_h / th)
	_bldg_sprite.scale = Vector2(s, s)
	_bldg_sprite.position = Vector2(0, -48)
	_bldg_sprite.z_index = -1
	add_child(_bldg_sprite)

func set_online_state(online: bool, summary_ip: String = "") -> void:
	is_online = online
	if online:
		_led.color = Color("2ecc71")
		_status_lbl.text = "ONLINE " + summary_ip
		_status_lbl.add_theme_color_override("font_color", Color("2ecc71"))
	else:
		_led.color = Color("e74c3c")
		_status_lbl.text = "OFFLINE"
		_status_lbl.add_theme_color_override("font_color", Color("ff6b6b"))

func flash_error() -> void:
	var tw := create_tween()
	for i in 3:
		tw.tween_property(_led, "color", Color("ff0000"), 0.1)
		tw.tween_property(_led, "color", Color("550000"), 0.1)
	tw.tween_callback(func(): _led.color = Color("2ecc71") if is_online else Color("e74c3c"))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = true
		_prompt_lbl.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = false
		_prompt_lbl.hide()

func _unhandled_input(event: InputEvent) -> void:
	if _player_near and event.is_action_pressed("interact") and not DialogUI.is_open:
		get_viewport().set_input_as_handled()
		request_configure.emit(building_data)
