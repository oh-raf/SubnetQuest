extends Node2D
## Peta Kampus Jaringan UM: Membangun TileMapLayer, Kabel Jaringan Line2D, Gedung, Player & NPC.

const TILE := 16
const TILESET_PATH := "res://assets/tilesets/campus_tileset.png"
const SERVER_BLDG_PATH := "res://assets/buildings/bldg_server.png"
const TILE_SEPARATION := 0

const PLAYER_SCENE := preload("res://scenes/characters/player.tscn")
const NPC_SCENE := preload("res://scenes/characters/npc.tscn")
const BLDG_SCENE := preload("res://scenes/world/building_node.tscn")
const WIN_SCENE := "res://scenes/ui/win_screen.tscn"

const SOLID := ["T", "B", "F", "H", "S"]

# >>> DIISI ARGON sesuai analisis campus_tileset.png (128x80 px, grid 8x5 tile 16x16 px) <<<
const ATLAS_REAL := {
	"G": [Vector2i(7, 3), Vector2i(7, 4)],
	"P": [Vector2i(0, 2), Vector2i(1, 2)],
	"T": [Vector2i(2, 2)],
	"B": [Vector2i(0, 0), Vector2i(0, 1)],
	"D": [Vector2i(2, 1)],
	"F": [Vector2i(6, 1), Vector2i(7, 1)],
	"H": [Vector2i(6, 2)],
	"S": [Vector2i(0, 4), Vector2i(3, 4), Vector2i(4, 4)],
}

const ATLAS_PLACEHOLDER := {
	"G": [Vector2i(0, 0)], "P": [Vector2i(1, 0)], "T": [Vector2i(2, 0)],
	"B": [Vector2i(3, 0)], "D": [Vector2i(4, 0)], "F": [Vector2i(5, 0)],
	"H": [Vector2i(6, 0)], "S": [Vector2i(7, 0)],
}

const PLACEHOLDER_COLORS := {
	"G": Color("5aa469"), "P": Color("d9c9a3"), "T": Color("2f6b3a"),
	"B": Color("3b5998"), "D": Color("ffd166"), "F": Color("8a6d3b"),
	"H": Color("7a5c3e"), "S": Color("1b263b"),
}

const LAYOUT: Array[String] = [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TGGGGGGGGGGGGGGGGGGPPGGGGGGGGGGGGGGGGGGT",
	"TGGBBBBBBBBBBGGGGGGPPGGGGGGBBBBBBBBBBGGT",
	"TGGBBBBBBBBBBGGTGGGPPGGTGGGBBBBBBBBBBGGT",
	"TGGBBBBBBBBBBGGGGGGPPGGGGGGBBBBBBBBBBGGT",
	"TGGBBBBBBBBBBGGGGGGPPGGGGGGBBBBBBBBBBGGT",
	"TGGBBBBDBBBBBGGGTGGPPGGGTGGBBBBDBBBBBGGT",
	"TGGGGGGPGGGGGGGGGGGPPGGGGGGGGGGPGGGGGGGT",
	"TGTGGGGPGGGGGGGGGGGPPGGGGGGGGGGPGGGGGTGT",
	"TGGGGGGPGGGGGGGGHGGSSGGHGGGGGGGPGGGGGGGT",
	"TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPT",
	"TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPT",
	"TGGGGGGGGGGGGGGGHGGPPGGHGGGGGGGGGGGGGGGT",
	"TGGBBBBBBBBBBGGGGGGPPGGGGGGBBBBBBBBBBGGT",
	"TGGBBBBBBBBBBGGTGGGPPGGTGGGBBBBBBBBBBGGT",
	"TGGBBBBBBBBBBGGGGGGPPGGGGGGBBBBBBBBBBGGT",
	"TGGBBBBBBBBBBGGGTGGPPGGGTGGBBBBBBBBBBGGT",
	"TGGBBBBDBBBBBGGGGGGPPGGGGGGBBBBDBBBBBGGT",
	"TGGGGGGPGGGGGGGGGGGPPGGGGGGGGGGPGGGGGGGT",
	"TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPT",
	"TPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPT",
	"TGGGGGGGGGGGGGTGGGGPPGGGGTGGGGGGGGGGGGGT",
	"TGTGGGGGGGTGGGGFFFGPPGFFFGGGGGTGGGGGGTGT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]

const SERVER_HUB_TILE := Vector2i(19, 9)
const PLAYER_SPAWN := Vector2i(19, 14)
const NPC_SPOTS := [Vector2i(14, 10), Vector2i(25, 10), Vector2i(14, 19), Vector2i(25, 19)]

var world: Node2D
var cable_layer: Node2D
var hud: CanvasLayer
var config_panel: CanvasLayer
var tutorial_popup: CanvasLayer

var _coords: Dictionary = {}
var _cables: Dictionary = {} # bldg_id -> Line2D
var _bldg_nodes: Dictionary = {} # bldg_id -> Node2D
var _player_node: CharacterBody2D

func _ready() -> void:
	AudioManager.play_bgm("campus")
	GameState.start_world(GameState.current_world_idx)
	_build_map()
	_spawn_entities()
	_setup_ui_overlays()
	GameState.all_buildings_online.connect(_on_all_buildings_online)
	await get_tree().process_frame
	_show_world_brief()

func _tile_center(v: Vector2i) -> Vector2:
	return Vector2(v * TILE) + Vector2(TILE / 2.0, TILE / 2.0)

func _make_tileset() -> TileSet:
	var tex: Texture2D
	if ResourceLoader.exists(TILESET_PATH):
		tex = load(TILESET_PATH)
		_coords = ATLAS_REAL
	else:
		var letters := ["G", "P", "T", "B", "D", "F", "H", "S"]
		var img := Image.create(TILE * letters.size(), TILE, false, Image.FORMAT_RGBA8)
		for i in letters.size():
			img.fill_rect(Rect2i(i * TILE, 0, TILE, TILE), PLACEHOLDER_COLORS[letters[i]])
		tex = ImageTexture.create_from_image(img)
		_coords = ATLAS_PLACEHOLDER

	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 2)
	ts.set_physics_layer_collision_mask(0, 0)

	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE, TILE)
	src.separation = Vector2i(TILE_SEPARATION, TILE_SEPARATION)
	ts.add_source(src, 0)

	var half := TILE / 2.0
	var square := PackedVector2Array([
		Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)
	])
	for letter in _coords:
		for c in _coords[letter]:
			if not src.has_tile(c):
				src.create_tile(c)
			if letter in SOLID:
				var td := src.get_tile_data(c, 0)
				if td.get_collision_polygons_count(0) == 0:
					td.add_collision_polygon(0)
					td.set_collision_polygon_points(0, 0, square)
	return ts

func _pick(letter: String, x: int, y: int) -> Vector2i:
	var arr: Array = _coords[letter]
	return arr[(x * 7 + y * 13) % arr.size()]

func _build_map() -> void:
	var ts := _make_tileset()
	var ground := TileMapLayer.new()
	ground.tile_set = ts
	add_child(ground)

	var objects := TileMapLayer.new()
	objects.tile_set = ts
	add_child(objects)

	for y in LAYOUT.size():
		var row := LAYOUT[y]
		for x in row.length():
			var ch := row[x]
			var cell := Vector2i(x, y)
			ground.set_cell(cell, 0, _pick("P" if ch == "P" else "G", x, y))
			if ch in ["T", "B", "D", "F", "H", "S"]:
				objects.set_cell(cell, 0, _pick(ch, x, y))

	cable_layer = Node2D.new()
	add_child(cable_layer)

	world = Node2D.new()
	world.y_sort_enabled = true
	add_child(world)

func _spawn_entities() -> void:
	# Visual & Label penanda Pusat Server UPT TIK di tengah kampus
	var hub_pos := _tile_center(SERVER_HUB_TILE)
	if ResourceLoader.exists(SERVER_BLDG_PATH):
		var s_tex: Texture2D = load(SERVER_BLDG_PATH)
		if s_tex:
			var hub_spr := Sprite2D.new()
			if s_tex.get_width() == 256 and s_tex.get_height() >= 1000:
				var at := AtlasTexture.new()
				at.atlas = s_tex
				at.region = Rect2(32, 1280, 64, 160)
				hub_spr.texture = at
			else:
				hub_spr.texture = s_tex
			hub_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var h_w := maxf(1.0, float(hub_spr.texture.get_width()))
			var h_h := maxf(1.0, float(hub_spr.texture.get_height()))
			var h_scale := minf(40.0 / h_w, 40.0 / h_h)
			hub_spr.scale = Vector2(h_scale, h_scale)
			hub_spr.position = hub_pos + Vector2(8, -8)
			world.add_child(hub_spr)

	var hub_lbl := UIKit.label("[SERVER UPT TIK]", 8, Color("ffd166"))
	hub_lbl.position = hub_pos + Vector2(-48, -32)
	hub_lbl.size = Vector2(96, 12)
	world.add_child(hub_lbl)

	# Spawn Gedung dan Kabel Jaringan Line2D
	var w_data := GameState.get_current_world()
	var buildings: Array = w_data.get("buildings", [])

	for b in buildings:
		var b_id := str(b.get("id", ""))
		var t_arr: Array = b.get("tile_pos", [7, 7])
		var b_tile := Vector2i(int(t_arr[0]), int(t_arr[1]))
		var b_pos := _tile_center(b_tile)

		# Buat jalur kabel siku (orthogonal routing) dari Server Hub ke Gedung
		var cable := Line2D.new()
		cable.width = 3.0
		cable.default_color = Color("556677")
		var mid_pos := Vector2(hub_pos.x, b_pos.y)
		cable.points = PackedVector2Array([hub_pos, mid_pos, b_pos])
		cable_layer.add_child(cable)
		_cables[b_id] = cable

		var b_node := BLDG_SCENE.instantiate()
		b_node.building_data = b
		b_node.position = b_pos
		b_node.request_configure.connect(_open_config_for_building)
		world.add_child(b_node)
		_bldg_nodes[b_id] = b_node

	# Spawn Player
	_player_node = PLAYER_SCENE.instantiate()
	_player_node.position = _tile_center(PLAYER_SPAWN)
	world.add_child(_player_node)
	_player_node.set_camera_limits(Rect2i(0, 0, LAYOUT[0].length() * TILE, LAYOUT.size() * TILE))

	# Spawn 2 NPC Anggota Tim lainnya
	var spots := NPC_SPOTS.duplicate()
	spots.shuffle()
	var npcs := GameState.get_npc_members()
	for i in npcs.size():
		var n := NPC_SCENE.instantiate()
		n.member = npcs[i]
		n.position = _tile_center(spots[i])
		world.add_child(n)

func _setup_ui_overlays() -> void:
	hud = load("res://scripts/ui/hud.gd").new()
	hud.shortcut_building_selected.connect(_open_config_for_building)
	hud.open_brief_requested.connect(_show_world_brief)
	add_child(hud)

	config_panel = load("res://scripts/ui/config_panel.gd").new()
	config_panel.configuration_succeeded.connect(_on_config_succeeded)
	config_panel.configuration_failed.connect(_on_config_failed)
	add_child(config_panel)

	tutorial_popup = load("res://scripts/ui/tutorial_popup.gd").new()
	tutorial_popup.retry_requested.connect(_on_tutorial_retry)
	add_child(tutorial_popup)

func _show_world_brief() -> void:
	var w := GameState.get_current_world()
	DialogUI.open_brief(
		str(w.get("brief_speaker", "Kepala UPT TIK UM")),
		str(w.get("title", "Misi Kampus Jaringan")) + " | Blok: " + str(w.get("base_block", "")),
		str(w.get("brief_text", "Konfigurasikan seluruh gedung kampus!"))
	)

func _open_config_for_building(bldg: Dictionary) -> void:
	if tutorial_popup.is_open or DialogUI.is_open:
		return
	config_panel.open_for_building(bldg)

func _on_config_succeeded(bldg: Dictionary, net_str: String, prefix: int, bc_str: String) -> void:
	var b_id := str(bldg.get("id", ""))
	if _cables.has(b_id):
		var c: Line2D = _cables[b_id]
		c.default_color = Color("2ecc71")
		c.width = 4.0
	if _bldg_nodes.has(b_id):
		_bldg_nodes[b_id].set_online_state(true, "%s/%d" % [net_str, prefix])
	GameState.mark_building_online(bldg, net_str, prefix, bc_str)

func _on_config_failed(bldg: Dictionary, validation_res: Dictionary) -> void:
	var b_id := str(bldg.get("id", ""))
	if _cables.has(b_id):
		var c: Line2D = _cables[b_id]
		c.default_color = Color("e74c3c")
	if _bldg_nodes.has(b_id):
		_bldg_nodes[b_id].flash_error()
	tutorial_popup.show_tutorial(bldg, validation_res)

func _on_tutorial_retry() -> void:
	# Pengguna dapat langsung melanjutkan pengisian pada panel konfigurasi
	pass

func _on_all_buildings_online() -> void:
	await get_tree().create_timer(0.8).timeout
	AudioManager.play_sfx("win")
	get_tree().change_scene_to_file(WIN_SCENE)
