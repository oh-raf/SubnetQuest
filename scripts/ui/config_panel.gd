extends CanvasLayer
## Panel Input Konfigurasi Jaringan per Gedung: LineEdit IP, Bit Board 8-Bit, Hint & Validasi Per-Field.

signal configuration_succeeded(bldg: Dictionary, net_str: String, prefix: int, bc_str: String)
signal configuration_failed(bldg: Dictionary, validation_result: Dictionary)

var is_open: bool = false
var _current_bldg: Dictionary = {}
var _hint_stage: int = 0
var _bit_values: Array[int] = [1, 1, 0, 0, 0, 0, 0, 0]
var _bit_buttons: Array[Button] = []

var _panel: PanelContainer
var _title_lbl: Label
var _brief_lbl: Label
var _bit_result_lbl: Label
var _net_edit: LineEdit
var _mask_edit: LineEdit
var _bc_edit: LineEdit
var _net_status: Label
var _mask_status: Label
var _bc_status: Label
var _hint_lbl: Label

func _ready() -> void:
	layer = 15
	_build()
	_panel.hide()

func _build() -> void:
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", UIKit.panel_style(Color("141e30"), Color("ffd166")))
	_panel.position = Vector2(40, 16)
	_panel.size = Vector2(560, 328)
	add_child(_panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 5)
	_panel.add_child(vb)

	_title_lbl = UIKit.label("KONFIGURASI JARINGAN GEDUNG", 12, Color("ffd166"))
	vb.add_child(_title_lbl)

	_brief_lbl = UIKit.label("", 9, Color("8ecae6"))
	_brief_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_brief_lbl)

	# Bit Board Kalkulator 8-Bit Interaktif (128, 64, 32, 16, 8, 4, 2, 1)
	var bit_box := PanelContainer.new()
	bit_box.add_theme_stylebox_override("panel", UIKit.panel_style(Color("0f172a"), Color("3b82f6")))
	vb.add_child(bit_box)
	var bit_vb := VBoxContainer.new()
	bit_vb.add_theme_constant_override("separation", 3)
	bit_box.add_child(bit_vb)

	_bit_result_lbl = UIKit.label("Bit Board (Klik Saklar Bit): 11000000 = 192", 9, Color("ffd166"))
	bit_vb.add_child(_bit_result_lbl)

	var bit_hb := HBoxContainer.new()
	bit_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	bit_hb.add_theme_constant_override("separation", 4)
	bit_vb.add_child(bit_hb)

	var weights := [128, 64, 32, 16, 8, 4, 2, 1]
	for i in 8:
		var btn := UIKit.button("%d:%d" % [weights[i], _bit_values[i]], _toggle_bit.bind(i), 56, 22)
		btn.add_theme_font_size_override("font_size", 8)
		_bit_buttons.append(btn)
		bit_hb.add_child(btn)

	# Form 3 Komponen Input Utama
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 5)
	vb.add_child(grid)

	# Baris 1: Network Address
	var l1 := UIKit.label("1. Network Address:", 10, Color.WHITE)
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	grid.add_child(l1)
	_net_edit = UIKit.line_edit("Contoh: 192.168.10.0", 210)
	grid.add_child(_net_edit)
	_net_status = UIKit.label("Wajib diisi", 9, Color("cccccc"))
	grid.add_child(_net_status)

	# Baris 2: Subnet Mask / Prefix
	var l2 := UIKit.label("2. Subnet Mask / Prefix:", 10, Color.WHITE)
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	grid.add_child(l2)
	_mask_edit = UIKit.line_edit("Contoh: /26 atau 255.255.255.192", 210)
	grid.add_child(_mask_edit)
	_mask_status = UIKit.label("Wajib diisi", 9, Color("cccccc"))
	grid.add_child(_mask_status)

	# Baris 3: Broadcast Address
	var l3 := UIKit.label("3. Broadcast Address:", 10, Color.WHITE)
	l3.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	grid.add_child(l3)
	_bc_edit = UIKit.line_edit("Contoh: 192.168.10.63", 210)
	grid.add_child(_bc_edit)
	_bc_status = UIKit.label("Wajib diisi", 9, Color("cccccc"))
	grid.add_child(_bc_status)

	# Label Hint Bertahap
	_hint_lbl = UIKit.label("Butuh bantuan? Klik tombol Hint (maks 2 tahap).", 9, Color("f39c12"))
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_hint_lbl)

	# Baris Tombol Aksi
	var act_hb := HBoxContainer.new()
	act_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	act_hb.add_theme_constant_override("separation", 8)
	vb.add_child(act_hb)

	act_hb.add_child(UIKit.button("Nyalakan Koneksi", _on_submit, 145, 26))
	act_hb.add_child(UIKit.button("Hint Bertahap", _on_hint, 115, 26))
	act_hb.add_child(UIKit.button("Tabel Referensi", _on_reference, 120, 26))
	act_hb.add_child(UIKit.button("Tutup", close_panel, 80, 26))

func _toggle_bit(index: int) -> void:
	_bit_values[index] = 1 - _bit_values[index]
	var weights := [128, 64, 32, 16, 8, 4, 2, 1]
	var bin_s := ""
	var dec_val := 0
	for i in 8:
		_bit_buttons[i].text = "%d:%d" % [weights[i], _bit_values[i]]
		bin_s += str(_bit_values[i])
		if _bit_values[i] == 1:
			dec_val += weights[i]
	_bit_result_lbl.text = "Bit Board (Klik Saklar Bit): %s = %d (Desimal)" % [bin_s, dec_val]

func open_for_building(bldg: Dictionary) -> void:
	_current_bldg = bldg
	_hint_stage = 0
	is_open = true
	_title_lbl.text = str(bldg.get("name", "Konfigurasi Gedung"))
	var w := GameState.get_current_world()
	_brief_lbl.text = "Blok Misi: %s | Kebutuhan: %d Host | Acuan: %s" % [
		str(w.get("base_block", "192.168.10.0/24")),
		int(bldg.get("needed_hosts", 0)),
		str(bldg.get("given_ip", "-"))
	]
	var b_id := str(bldg.get("id", ""))
	var st: Dictionary = GameState.building_states.get(b_id, {})
	_net_edit.text = str(st.get("net", ""))
	_mask_edit.text = str(st.get("mask", ""))
	_bc_edit.text = str(st.get("bc", ""))
	_net_status.text = "Siap dicek"
	_net_status.add_theme_color_override("font_color", Color("cccccc"))
	_mask_status.text = "Siap dicek"
	_mask_status.add_theme_color_override("font_color", Color("cccccc"))
	_bc_status.text = "Siap dicek"
	_bc_status.add_theme_color_override("font_color", Color("cccccc"))
	_hint_lbl.text = "Klik 'Hint Bertahap' jika membutuhkan petunjuk konsep atau langkah awal."
	_panel.show()
	_net_edit.grab_focus()

func close_panel() -> void:
	_panel.hide()
	is_open = false

func _on_hint() -> void:
	_hint_stage += 1
	GameState.record_hint()
	if _hint_stage == 1:
		_hint_lbl.text = "HINT 1 (Konsep): " + str(_current_bldg.get("hint_1", "Gunakan 2^(32-prefix) untuk ukuran blok."))
	else:
		_hint_lbl.text = "HINT 2 (Langkah): " + str(_current_bldg.get("hint_2", "Pastikan Network dan Broadcast sesuai kelipatan blok."))

func _on_reference() -> void:
	var ref_txt := (
		"TABEL REFERENSI CEPAT SUBNETTING IPv4:\n" +
		"• /24 = 255.255.255.0 | Blok: 256 | Host Valid: 254\n" +
		"• /25 = 255.255.255.128 | Blok: 128 | Host Valid: 126\n" +
		"• /26 = 255.255.255.192 | Blok: 64 | Host Valid: 62\n" +
		"• /27 = 255.255.255.224 | Blok: 32 | Host Valid: 30\n" +
		"• /28 = 255.255.255.240 | Blok: 16 | Host Valid: 14\n" +
		"• /29 = 255.255.255.248 | Blok: 8 | Host Valid: 6\n" +
		"• /30 = 255.255.255.252 | Blok: 4 | Host Valid: 2\n" +
		"Kelas IP: A (1..126), B (128..191), C (192..223), Loopback (127.0.0.1)"
	)
	DialogUI.open_brief("Buku Saku Admin Jaringan UPT TIK", "Tabel Referensi Prefix & Pangkat Dua", ref_txt)

func _on_submit() -> void:
	var res := SubnetCalc.validate_building_submission(
		_current_bldg,
		_net_edit.text,
		_mask_edit.text,
		_bc_edit.text,
		GameState.active_allocations
	)
	_update_field_badge(_net_status, bool(res["net_ok"]), bool(res["format_error"]))
	_update_field_badge(_mask_status, bool(res["mask_ok"]), bool(res["format_error"]))
	_update_field_badge(_bc_status, bool(res["bc_ok"]), bool(res["format_error"]))

	if bool(res["all_ok"]):
		var parsed_p := SubnetCalc.parse_prefix(_mask_edit.text)
		var clean_net := _net_edit.text.strip_edges()
		var clean_bc := _bc_edit.text.strip_edges()
		close_panel()
		configuration_succeeded.emit(_current_bldg, clean_net, parsed_p, clean_bc)
	else:
		GameState.record_mistake()
		AudioManager.play_sfx("error")
		configuration_failed.emit(_current_bldg, res)

func _update_field_badge(lbl: Label, ok: bool, fmt_err: bool) -> void:
	if ok:
		lbl.text = "BENAR [OK]"
		lbl.add_theme_color_override("font_color", Color("2ecc71"))
	elif fmt_err:
		lbl.text = "CEK FORMAT"
		lbl.add_theme_color_override("font_color", Color("f39c12"))
	else:
		lbl.text = "SALAH [X]"
		lbl.add_theme_color_override("font_color", Color("e74c3c"))
