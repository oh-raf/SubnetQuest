extends Control
## Layar Hasil Misi & Apresiasi Tim: Menampilkan Bintang (1-3), Ringkasan, dan 3 Kartu Anggota Tim.

const WORLD_SELECT_SCENE := "res://scenes/ui/world_select.tscn"
const MAP_SCENE := "res://scenes/world/campus_map.tscn"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UIKit.make_theme(11)
	UIKit.background(self, Color("163024"))
	AudioManager.play_bgm("menu")

	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 6)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	cc.add_child(root)

	var w := GameState.get_current_world()
	var stars := GameState.calculate_earned_stars()
	var star_str := "★".repeat(stars) + "☆".repeat(3 - stars)

	root.add_child(UIKit.label("SELURUH GEDUNG ONLINE! " + star_str, 18, Color("ffd166")))
	root.add_child(UIKit.label("%s Selesai | Kesalahan: %d | Hint Dipakai: %d" % [
		str(w.get("title", "World")), GameState.current_mistakes, GameState.current_hints
	], 10, Color("8ecae6")))

	root.add_child(UIKit.label("Tim Pengembang SubnetQuest (Universitas Negeri Malang):", 10, Color.WHITE))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(row)

	for m in GameState.members:
		row.add_child(UIKit.member_card(m, true))

	var nav := HBoxContainer.new()
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	nav.add_theme_constant_override("separation", 8)
	root.add_child(nav)

	if GameState.current_world_idx + 1 < GameState.worlds.size():
		nav.add_child(UIKit.button("World Berikutnya", _on_next_world, 150, 26))
	nav.add_child(UIKit.button("Peta World", func(): get_tree().change_scene_to_file(WORLD_SELECT_SCENE), 120, 26))
	nav.add_child(UIKit.button("Menu Utama", func(): get_tree().change_scene_to_file(MENU_SCENE), 120, 26))

func _on_next_world() -> void:
	GameState.current_world_idx += 1
	get_tree().change_scene_to_file(MAP_SCENE)
