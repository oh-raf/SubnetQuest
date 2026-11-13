extends Control
## Layar Menu Utama SubnetQuest: Misi Kampus Jaringan.

const CHAR_SELECT_SCENE := "res://scenes/ui/character_select.tscn"
const WORLD_SELECT_SCENE := "res://scenes/ui/world_select.tscn"
const CREDITS := "Tim Pengembang UM: Rafif (240533608447), Ihsan (240533615464), Ashar (240533615493)"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UIKit.make_theme(11)
	UIKit.background(self, Color("141e30"))
	AudioManager.play_bgm("menu")

	var cc := CenterContainer.new()
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cc)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	cc.add_child(box)

	box.add_child(UIKit.label("SUBNETQUEST", 26, Color("ffd166")))
	box.add_child(UIKit.label("Misi Kampus Jaringan — Bagi Alamatnya, Hubungkan Kampusnya!", 11, Color("8ecae6")))

	var btn_box := VBoxContainer.new()
	btn_box.add_theme_constant_override("separation", 6)
	btn_box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(btn_box)

	btn_box.add_child(UIKit.button("Mulai Magang (Pilih Karakter)", func(): get_tree().change_scene_to_file(CHAR_SELECT_SCENE), 220, 28))
	btn_box.add_child(UIKit.button("Pilih World / Level", func(): get_tree().change_scene_to_file(WORLD_SELECT_SCENE), 220, 28))
	btn_box.add_child(UIKit.button("Cara Bermain & Rumus", _show_how_to_play, 220, 28))
	btn_box.add_child(UIKit.button("Keluar", func(): get_tree().quit(), 220, 28))

	var credit := UIKit.label(CREDITS, 8, Color("aaaaaa"))
	credit.position = Vector2(0, 340)
	credit.size = Vector2(640, 14)
	add_child(credit)

func _show_how_to_play() -> void:
	var guide := (
		"CARA BERMAIN SUBNETQUEST:\n" +
		"1. Pilih karakter Admin Magang dan pilih World (World 1 s/d World 5 Boss VLSM).\n" +
		"2. Gerakkan karakter dengan WASD/Panah mendekati gedung lalu tekan [E], atau klik tombol pintas gedung di bawah layar.\n" +
		"3. Isi Network Address, Subnet Mask/Prefix (/n), dan Broadcast Address sesuai kebutuhan host gedung.\n" +
		"4. Jika BENAR, kabel menyala HIJAU. Jika SALAH, baca Pop-up Tutorial langkah demi langkah lalu coba lagi!"
	)
	DialogUI.open_brief("Panduan Magang UPT TIK UM", "Aturan Permainan & Kontrol", guide)
