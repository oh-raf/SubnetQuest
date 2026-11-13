extends CanvasLayer
## HUD Permainan: Menampilkan status World, Gedung Online, Rekan Ditemukan, Bintang, dan Tombol Pintas.

signal shortcut_building_selected(bldg: Dictionary)
signal open_brief_requested

var _world_lbl: Label
var _bldg_lbl: Label
var _npc_lbl: Label
var _star_lbl: Label
var _shortcut_bar: HBoxContainer

func _ready() -> void:
	layer = 5
	var w := GameState.get_current_world()

	_world_lbl = UIKit.label(str(w.get("title", "SubnetQuest")), 10, Color("ffd166"))
	_world_lbl.position = Vector2(8, 4)
	_world_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_world_lbl)

	_bldg_lbl = UIKit.label("", 9, Color("2ecc71"))
	_bldg_lbl.position = Vector2(8, 18)
	_bldg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_bldg_lbl)

	_npc_lbl = UIKit.label("", 9, Color("8ecae6"))
	_npc_lbl.position = Vector2(180, 18)
	_npc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(_npc_lbl)

	_star_lbl = UIKit.label("", 10, Color("ffd166"))
	_star_lbl.position = Vector2(470, 4)
	_star_lbl.size = Vector2(162, 16)
	_star_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_star_lbl)

	# Baris tombol pintas gedung di bagian bawah agar pemain bisa langsung klik gedung
	_shortcut_bar = HBoxContainer.new()
	_shortcut_bar.position = Vector2(8, 330)
	_shortcut_bar.add_theme_constant_override("separation", 4)
	add_child(_shortcut_bar)

	var b_list: Array = w.get("buildings", [])
	for b in b_list:
		var btn := UIKit.button(str(b.get("short_name", "Gedung")), func(): shortcut_building_selected.emit(b), 108, 22)
		btn.add_theme_font_size_override("font_size", 8)
		_shortcut_bar.add_child(btn)

	var brief_btn := UIKit.button("Brief Misi", func(): open_brief_requested.emit(), 74, 22)
	brief_btn.add_theme_font_size_override("font_size", 8)
	_shortcut_bar.add_child(brief_btn)

	var menu_btn := UIKit.button("Pilih World", func(): get_tree().change_scene_to_file("res://scenes/ui/world_select.tscn"), 78, 22)
	menu_btn.add_theme_font_size_override("font_size", 8)
	_shortcut_bar.add_child(menu_btn)

	refresh_hud()
	GameState.member_found.connect(func(_m, _c, _t): refresh_hud())
	GameState.building_updated.connect(func(_id, _on): refresh_hud())

func refresh_hud() -> void:
	_bldg_lbl.text = "Gedung Online: %d / %d" % [GameState.get_online_count(), GameState.get_total_buildings()]
	_npc_lbl.text = "Tim Ditemukan: %d / %d" % [GameState.found_ids.size(), GameState.total_to_find()]
	var stars := GameState.calculate_earned_stars()
	_star_lbl.text = "Bintang: %s (Salah: %d)" % ["★".repeat(stars) + "☆".repeat(3 - stars), GameState.current_mistakes]
