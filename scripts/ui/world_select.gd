extends Control
## Layar Peta Pemilihan World (World 1, World 3, World 4, dan World 5 Boss VLSM).

const MAP_SCENE := "res://scenes/world/campus_map.tscn"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UIKit.make_theme(11)
	UIKit.background(self, Color("141e30"))

	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	cc.add_child(root)

	root.add_child(UIKit.label("PETA KURIKULUM WORLD SUBNETQUEST", 18, Color("ffd166")))
	root.add_child(UIKit.label("Selesaikan tiap World untuk membuka tahap magang berikutnya (atau buka langsung untuk pengujian):", 9, Color("8ecae6")))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	root.add_child(grid)

	for i in GameState.worlds.size():
		var w: Dictionary = GameState.worlds[i]
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(280, 100)
		var unlocked := (i < GameState.unlocked_worlds)
		var border_col := Color("2ecc71") if unlocked else Color("666666")
		card.add_theme_stylebox_override("panel", UIKit.panel_style(Color("1b263b"), border_col))

		var vb := VBoxContainer.new()
		vb.add_theme_constant_override("separation", 3)
		card.add_child(vb)

		vb.add_child(UIKit.label(str(w.get("title", "World")), 10, Color("ffd166")))
		vb.add_child(UIKit.label(str(w.get("subtitle", "")), 9, Color.WHITE))

		var stars := int(GameState.world_stars.get(i, 0))
		var star_txt := "Rekor: " + ("★".repeat(stars) + "☆".repeat(3 - stars))
		vb.add_child(UIKit.label(star_txt, 9, Color("f1c40f")))

		var btn_txt := "Mainkan " + str(w.get("code", "")) if unlocked else "Buka & Uji " + str(w.get("code", ""))
		vb.add_child(UIKit.button(btn_txt, _on_select_world.bind(i), 140, 22))
		grid.add_child(card)

	root.add_child(UIKit.button("Kembali ke Menu Utama", func(): get_tree().change_scene_to_file(MENU_SCENE), 180, 26))

func _on_select_world(idx: int) -> void:
	GameState.current_world_idx = idx
	get_tree().change_scene_to_file(MAP_SCENE)
