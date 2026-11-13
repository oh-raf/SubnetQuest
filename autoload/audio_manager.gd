extends Node
## Autoload "AudioManager": Pemutar BGM dan SFX dengan fallback senyap bila aset audio kosong.

const EXTS := ["ogg", "mp3", "wav"]

var _bgm: AudioStreamPlayer
var _sfx: AudioStreamPlayer
var _current_bgm: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bgm = AudioStreamPlayer.new()
	_bgm.volume_db = -8.0
	add_child(_bgm)
	_sfx = AudioStreamPlayer.new()
	add_child(_sfx)

func _find(kind: String, key: String) -> AudioStream:
	for e in EXTS:
		var p := "res://assets/audio/%s/%s_%s.%s" % [kind, kind, key, e]
		if ResourceLoader.exists(p):
			return load(p)
	return null

func play_bgm(key: String) -> void:
	if key == _current_bgm and _bgm.playing:
		return
	var s := _find("bgm", key)
	if s == null:
		return
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	elif s is AudioStreamMP3:
		(s as AudioStreamMP3).loop = true
	_current_bgm = key
	_bgm.stream = s
	_bgm.play()

func play_sfx(key: String) -> void:
	var s := _find("sfx", key)
	if s == null:
		return
	_sfx.stream = s
	_sfx.play()
