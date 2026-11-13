class_name UIKit
extends RefCounted
## Helper pembuat komponen UI secara prosedural lewat kode (menghindari sub-resource .tscn).

const FONT_PATH := "res://assets/ui/font.ttf"

static func get_font() -> Font:
	if ResourceLoader.exists(FONT_PATH):
		return load(FONT_PATH)
	return null

static func make_theme(font_size: int = 11) -> Theme:
	var t := Theme.new()
	var f := get_font()
	if f:
		t.default_font = f
	t.default_font_size = font_size
	return t

static func label(text: String, size: int = 11, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 3)
	var f := get_font()
	if f:
		l.add_theme_font_override("font", f)
	return l

static func button(text: String, cb: Callable, min_w: float = 130.0, min_h: float = 26.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_w, min_h)
	b.pressed.connect(cb)
	b.pressed.connect(func(): AudioManager.play_sfx("click"))
	return b

static func line_edit(placeholder_txt: String, min_w: float = 150.0) -> LineEdit:
	var le := LineEdit.new()
	le.placeholder_text = placeholder_txt
	le.custom_minimum_size = Vector2(min_w, 24)
	le.add_theme_font_size_override("font_size", 10)
	var f := get_font()
	if f:
		le.add_theme_font_override("font", f)
	return le

static func panel_style(bg: Color = Color("1b263b"), border: Color = Color("f5f5f5")) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(3)
	s.set_content_margin_all(6)
	return s

static func background(parent: Control, color: Color) -> void:
	var r := ColorRect.new()
	r.color = color
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(r)

static func member_card(m: MemberData, with_nim: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	card.add_child(vb)
	var pic := TextureRect.new()
	pic.texture = m.get_portrait()
	pic.custom_minimum_size = Vector2(72, 72)
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vb.add_child(pic)
	vb.add_child(label(m.nama, 9, Color("ffd166")))
	if with_nim:
		vb.add_child(label("NIM: " + m.nim, 9, Color.WHITE))
	vb.add_child(label(m.peran, 9, Color("8ecae6")))
	return card
