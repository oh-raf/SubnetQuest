extends Node
## Singleton Global "GameState": Mengelola data anggota tim, level subnetting, skor bintang & progres.

signal member_found(member: MemberData, found_count: int, total: int)
signal building_updated(bldg_id: String, is_online: bool)
signal all_buildings_online

const MEMBERS_JSON := "res://data/members.json"
const LEVELS_JSON := "res://data/levels.json"
const SAVE_PATH := "user://subnetquest_progress.json"

var members: Array[MemberData] = []
var worlds: Array[Dictionary] = []
var selected_index: int = 0
var current_world_idx: int = 0

var found_ids: Array[String] = []
var building_states: Dictionary = {} # bldg_id -> Dictionary {online, net, prefix, bc, net_int, bc_int}
var active_allocations: Array[Dictionary] = []

var current_mistakes: int = 0
var current_hints: int = 0
var unlocked_worlds: int = 1
var world_stars: Dictionary = {} # world_idx -> int (1..3)

func _ready() -> void:
	_register_inputs()
	_load_members()
	_load_levels()
	_load_progress()

func _register_inputs() -> void:
	var map := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"interact": [KEY_E, KEY_ENTER, KEY_SPACE],
	}
	for action in map:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in map[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)

func _load_members() -> void:
	members.clear()
	var fallback_team := [
		{
			"id": "m1",
			"nama": "MUHAMMAD RAFIF IMTITHAL",
			"nim": "240533608447",
			"peran": "Project + Level",
			"dialog": "Halo! Aku MUHAMMAD RAFIF IMTITHAL (NIM 240533608447), Project & Level Designer tim ini. Aku yang merancang kurikulum soal subnetting, skenario gedung kampus UM, dan papan Kanban proyek.",
			"portrait": "res://assets/portraits/portrait_1.png",
			"sheet": "res://assets/characters/char_1.png",
			"layout": "knight",
			"faces_right": true
		},
		{
			"id": "m2",
			"nama": "IHSAN YUSUF ADRIAN",
			"nim": "240533615464",
			"peran": "Artist",
			"dialog": "Hai! Aku IHSAN YUSUF ADRIAN (NIM 240533615464), Artist tim ini. Seluruh sprite karakter, ikon gedung kampus, palet warna antarmuka, dan efek visual kabel jaringan aku yang siapkan.",
			"portrait": "res://assets/portraits/portrait_2.png",
			"sheet": "res://assets/characters/char_2.png",
			"layout": "knight",
			"faces_right": true
		},
		{
			"id": "m3",
			"nama": "MUHAMMAD ASHAR FARHANDIKA PUTRA FARIAL",
			"nim": "240533615493",
			"peran": "Programmer",
			"dialog": "Halo! Aku MUHAMMAD ASHAR FARHANDIKA PUTRA FARIAL (NIM 240533615493), Programmer tim ini. Aku yang membangun kalkulator subnetting IPv4, sistem validasi per-field, dan pop-up tutorial di Godot 4.3.",
			"portrait": "res://assets/portraits/portrait_3.png",
			"sheet": "res://assets/characters/char_3.png",
			"layout": "knight",
			"faces_right": true
		}
	]
	var raw_data: Variant = fallback_team
	if FileAccess.file_exists(MEMBERS_JSON):
		var f := FileAccess.open(MEMBERS_JSON, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if typeof(parsed) == TYPE_ARRAY and parsed.size() >= 3:
				raw_data = parsed
	for i in (raw_data as Array).size():
		members.append(MemberData.from_dict(raw_data[i], i + 1))

func _load_levels() -> void:
	worlds.clear()
	if FileAccess.file_exists(LEVELS_JSON):
		var f := FileAccess.open(LEVELS_JSON, FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			if typeof(parsed) == TYPE_ARRAY and parsed.size() > 0:
				for item in parsed:
					worlds.append(item)
				return
	# Fallback bila levels.json belum ditemukan
	worlds.append({
		"world_id": 1,
		"code": "W1",
		"title": "World 1: Bit Basics",
		"subtitle": "Nyalakan Panel Server UPT",
		"mode": "bit_basics",
		"base_block": "192.168.1.0/24",
		"brief_speaker": "Pak Hendra (Kepala UPT TIK UM)",
		"brief_text": "Konfigurasikan rak server utama UPT TIK dengan menentukan Network Address, Prefix, dan Broadcast Address!",
		"buildings": [
			{
				"id": "w1_b1",
				"name": "Rak Server Core-A",
				"short_name": "Server Core-A",
				"tile_pos": [7, 7],
				"needed_hosts": 250,
				"given_ip": "192.168.1.10/24",
				"expected_network": "192.168.1.0",
				"expected_prefix": 24,
				"expected_broadcast": "192.168.1.255",
				"hint_1": "Prefix /24 berarti 255.255.255.0 (254 host valid).",
				"hint_2": "Network = 192.168.1.0, Mask = /24, Broadcast = 192.168.1.255."
			}
		]
	})

func select_character(index: int) -> void:
	selected_index = clampi(index, 0, maxi(0, members.size() - 1))

func get_player_member() -> MemberData:
	return members[clampi(selected_index, 0, members.size() - 1)]

func get_npc_members() -> Array[MemberData]:
	var result: Array[MemberData] = []
	for i in members.size():
		if i != selected_index:
			result.append(members[i])
	return result

func total_to_find() -> int:
	return maxi(0, members.size() - 1)

func get_current_world() -> Dictionary:
	return worlds[clampi(current_world_idx, 0, worlds.size() - 1)]

func start_world(world_idx: int) -> void:
	current_world_idx = clampi(world_idx, 0, worlds.size() - 1)
	building_states.clear()
	active_allocations.clear()
	current_mistakes = 0
	current_hints = 0
	var w := get_current_world()
	for b in w.get("buildings", []):
		building_states[str(b["id"])] = {
			"online": false,
			"net": "",
			"mask": "",
			"bc": ""
		}

func register_found(member: MemberData) -> void:
	if member.id in found_ids:
		return
	found_ids.append(member.id)
	AudioManager.play_sfx("found")
	member_found.emit(member, found_ids.size(), total_to_find())

func record_mistake() -> void:
	current_mistakes += 1

func record_hint() -> void:
	current_hints += 1

func mark_building_online(bldg: Dictionary, net_str: String, prefix: int, bc_str: String) -> void:
	var b_id := str(bldg.get("id", ""))
	var info := SubnetCalc.calculate_subnet(net_str, prefix)
	building_states[b_id] = {
		"online": true,
		"net": net_str,
		"mask": "/" + str(prefix),
		"bc": bc_str
	}
	# Perbarui daftar alokasi aktif untuk pengecekan overlap VLSM/FLSM
	for i in range(active_allocations.size() - 1, -1, -1):
		if str(active_allocations[i].get("id", "")) == b_id:
			active_allocations.remove_at(i)
	active_allocations.append({
		"id": b_id,
		"name": str(bldg.get("short_name", "Gedung")),
		"net_int": int(info["network_int"]),
		"bc_int": int(info["broadcast_int"])
	})
	AudioManager.play_sfx("connect")
	building_updated.emit(b_id, true)
	if get_online_count() >= get_total_buildings():
		_complete_current_world()
		all_buildings_online.emit()

func get_online_count() -> int:
	var c := 0
	for k in building_states:
		if bool(building_states[k].get("online", false)):
			c += 1
	return c

func get_total_buildings() -> int:
	var w := get_current_world()
	return (w.get("buildings", []) as Array).size()

func calculate_earned_stars() -> int:
	if current_hints == 0 and current_mistakes <= 1:
		return 3
	if current_mistakes <= 3 and current_hints <= 1:
		return 2
	return 1

func _complete_current_world() -> void:
	var stars := calculate_earned_stars()
	var prev := int(world_stars.get(current_world_idx, 0))
	if stars > prev:
		world_stars[current_world_idx] = stars
	if current_world_idx + 1 >= unlocked_worlds:
		unlocked_worlds = mini(worlds.size(), current_world_idx + 2)
	_save_progress()

func _save_progress() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		var payload := {
			"unlocked_worlds": unlocked_worlds,
			"world_stars": world_stars
		}
		f.store_string(JSON.stringify(payload))

func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var d = JSON.parse_string(f.get_as_text())
		if typeof(d) == TYPE_DICTIONARY:
			unlocked_worlds = maxi(1, int(d.get("unlocked_worlds", 1)))
			var ws: Dictionary = d.get("world_stars", {})
			for k in ws:
				world_stars[int(str(k))] = int(ws[k])
