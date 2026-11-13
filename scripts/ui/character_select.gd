extends Control
## Layar Pemilihan Karakter Admin Magang (Menampilkan 3 Kartu Anggota Tim).

const WORLD_SELECT_SCENE := "res://scenes/ui/world_select.tscn"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UIKit.make_theme(11)
	UIKit.background(self, Color("1b263b"))

	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	cc.add_child(root)

	root.add_child(UIKit.label("PILIH KARAKTER ADMIN JARINGAN", 18, Color("ffd166")))
	root.add_child(UIKit.label("2 anggota lainnya akan hadir sebagai rekan tim (NPC) di peta kampus:", 10, Color("8ecae6")))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(row)

	for i in GameState.members.size():
		var m: MemberData = GameState.members[i]
		var card := UIKit.member_card(m, true)
		card.get_child(0).add_child(UIKit.button("Pilih Admin", _on_pick.bind(i), 120, 24))
		row.add_child(card)

	root.add_child(UIKit.button("Kembali ke Menu", func(): get_tree().change_scene_to_file(MENU_SCENE), 160, 26))

func _on_pick(index: int) -> void:
	GameState.select_character(index)
	get_tree().change_scene_to_file(WORLD_SELECT_SCENE)
