extends CanvasLayer
## Pop-up Tutorial Pembelajaran Dinamis: Muncul saat konfigurasi salah untuk menjelaskan langkah hitung.

signal retry_requested

var is_open: bool = false
var _panel: PanelContainer
var _title_lbl: Label
var _diag_lbl: Label
var _steps_box: RichTextLabel

func _ready() -> void:
	layer = 22
	_build()
	_panel.hide()

func _build() -> void:
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", UIKit.panel_style(Color("2b1b2d"), Color("ff6b6b")))
	_panel.position = Vector2(36, 20)
	_panel.size = Vector2(568, 320)
	add_child(_panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	_panel.add_child(vb)

	_title_lbl = UIKit.label("POP-UP TUTORIAL PEMBELAJARAN SUBNETTING", 12, Color("ffd166"))
	vb.add_child(_title_lbl)

	_diag_lbl = UIKit.label("", 9, Color("ff6b6b"))
	_diag_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(_diag_lbl)

	_steps_box = RichTextLabel.new()
	_steps_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_steps_box.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_steps_box.scroll_active = true
	_steps_box.add_theme_font_size_override("normal_font_size", 10)
	var f := UIKit.get_font()
	if f:
		_steps_box.add_theme_font_override("normal_font", f)
	vb.add_child(_steps_box)

	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_child(hb)
	hb.add_child(UIKit.button("Mengerti & Coba Lagi", _on_retry, 190, 28))

func show_tutorial(bldg: Dictionary, validation_res: Dictionary) -> void:
	is_open = true
	_title_lbl.text = "PEMBAHASAN LANGKAH: " + str(bldg.get("name", "Gedung"))
	_diag_lbl.text = str(validation_res.get("error_summary", "Periksa kembali hitungan subnetting."))
	var steps: Array = validation_res.get("steps", [])
	var lines: PackedStringArray = []
	for s in steps:
		lines.append(str(s))
	_steps_box.text = "\n\n".join(lines)
	_panel.show()

func _on_retry() -> void:
	_panel.hide()
	is_open = false
	retry_requested.emit()
