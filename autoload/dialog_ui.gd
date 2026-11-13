extends CanvasLayer
## Autoload "DialogUI": Menampilkan dialog box RPG untuk perkenalan anggota tim & brief Kepala UPT.

signal closed

var is_open: bool = false

var _tween: Tween
var _panel: PanelContainer
var _portrait: TextureRect
var _name: Label
var _nim: Label
var _role: Label
var _speech: RichTextLabel

func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_panel.hide()

func _line(parent: Control, color: Color) -> Label:
	var l := UIKit.label("", 10, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	parent.add_child(l)
	return l

func _build() -> void:
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", UIKit.panel_style())
	_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 8
	_panel.offset_right = -8
	_panel.offset_top = -118
	_panel.offset_bottom = -8
	add_child(_panel)

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	_panel.add_child(hb)

	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(80, 80)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hb.add_child(_portrait)

	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hb.add_child(vb)

	_name = _line(vb, Color("ffd166"))
	_nim = _line(vb, Color.WHITE)
	_role = _line(vb, Color("8ecae6"))

	_speech = RichTextLabel.new()
	_speech.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_speech.scroll_active = true
	_speech.add_theme_font_size_override("normal_font_size", 10)
	var f := UIKit.get_font()
	if f:
		_speech.add_theme_font_override("normal_font", f)
	vb.add_child(_speech)

func open(m: MemberData) -> void:
	is_open = true
	get_tree().paused = true
	_portrait.texture = m.get_portrait()
	_portrait.show()
	_name.text = m.nama
	_nim.text = "NIM : " + m.nim
	_role.text = "Peran: " + m.peran
	_start_typing(m.dialog)

func open_brief(speaker: String, subtitle: String, body_text: String) -> void:
	is_open = true
	get_tree().paused = true
	_portrait.texture = GameState.get_player_member().get_portrait()
	_portrait.show()
	_name.text = speaker
	_nim.text = subtitle
	_role.text = "Tekan [E] / [Enter] / [Spasi] untuk melanjutkan"
	_start_typing(body_text)

func _start_typing(txt: String) -> void:
	_speech.text = txt
	_speech.visible_ratio = 0.0
	_panel.show()
	AudioManager.play_sfx("dialog")
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_speech, "visible_ratio", 1.0, maxf(0.3, txt.length() / 55.0))

func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		if _tween and _tween.is_running():
			_tween.kill()
			_speech.visible_ratio = 1.0
		else:
			close()

func close() -> void:
	_panel.hide()
	is_open = false
	get_tree().paused = false
	closed.emit()
