extends StaticBody2D
## NPC Rekan Tim di Peta Kampus. Menampilkan biodata (Nama, NIM, Peran, Portrait) saat diajak bicara.

var member: MemberData # WAJIB di-set sebelum add_child()

var _sprite: AnimatedSprite2D
var _prompt: Label
var _area: Area2D
var _player: Node2D = null

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

	_sprite = AnimatedSprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.sprite_frames = member.build_frames()
	_sprite.scale = member.get_sprite_scale()
	add_child(_sprite)
	_sprite.play("idle_down")

	var cs := CollisionShape2D.new()
	var rs := RectangleShape2D.new()
	rs.size = Vector2(10, 8)
	cs.shape = rs
	cs.position = Vector2(0, member.feet_y)
	add_child(cs)

	_prompt = UIKit.label("[E] " + member.peran, 8, Color("ffd166"))
	_prompt.position = Vector2(-36, -30)
	_prompt.size = Vector2(72, 12)
	_prompt.hide()
	add_child(_prompt)

	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = 1
	var acs := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	acs.shape = circle
	_area.add_child(acs)
	add_child(_area)
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body
		_prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_prompt.hide()

func _unhandled_input(event: InputEvent) -> void:
	if _player and event.is_action_pressed("interact") and not DialogUI.is_open:
		get_viewport().set_input_as_handled()
		_face_player()
		DialogUI.open(member)
		GameState.register_found(member)

func _face_player() -> void:
	var d := _player.global_position - global_position
	var f := "down"
	if absf(d.x) > absf(d.y):
		f = "right" if d.x > 0.0 else "left"
	else:
		f = "down" if d.y > 0.0 else "up"
	if f == "left" or f == "right":
		_sprite.flip_h = member.needs_flip(f)
	_sprite.play("idle_" + f)
