extends CharacterBody2D
## Karakter Utama (Admin Jaringan Magang UPT TIK UM).

@export var speed: float = 85.0

var facing: String = "down"
var can_move: bool = true
var _anim: AnimatedSprite2D
var _cam: Camera2D
var _member: MemberData

func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 2

	_member = GameState.get_player_member()
	_anim = AnimatedSprite2D.new()
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim.sprite_frames = _member.build_frames()
	_anim.scale = _member.get_sprite_scale()
	add_child(_anim)

	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(8, 6)
	cs.shape = shape
	cs.position = Vector2(0, _member.feet_y)
	add_child(cs)

	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = true
	add_child(_cam)

	_anim.play("idle_down")

func set_camera_limits(rect: Rect2i) -> void:
	_cam.limit_left = rect.position.x
	_cam.limit_top = rect.position.y
	_cam.limit_right = rect.end.x
	_cam.limit_bottom = rect.end.y

func _physics_process(_delta: float) -> void:
	if not can_move or DialogUI.is_open:
		velocity = Vector2.ZERO
		_anim.play("idle_" + facing)
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	_update_animation(dir)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		_anim.play("idle_" + facing)
		return
	if absf(dir.x) > absf(dir.y):
		facing = "right" if dir.x > 0.0 else "left"
	else:
		facing = "down" if dir.y > 0.0 else "up"
	if facing == "left" or facing == "right":
		_anim.flip_h = _member.needs_flip(facing)
	_anim.play("walk_" + facing)
