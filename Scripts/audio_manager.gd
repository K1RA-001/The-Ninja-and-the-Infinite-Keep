extends Node

const SAMPLE_RATE := 22050
const POOL_SIZE := 8

var _players: Array[AudioStreamPlayer] = []
var _sounds: Dictionary = {}
var _next_player := 0

func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)
	_sounds["jump"] = _make_sound("jump", 0.20)
	_sounds["bonk"] = _make_sound("bonk", 0.32)
	_sounds["vine_boom"] = _make_sound("boom", 0.74)
	_sounds["death_wah"] = _make_sound("death", 0.64)
	_sounds["respawn"] = _make_sound("respawn", 0.58)
	_sounds["menu_select"] = _make_sound("select", 0.10)
	_sounds["victory"] = _make_sound("victory", 1.10)

func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	if not _sounds.has(sound_name):
		return
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _sounds[sound_name]
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.94, 1.06) if sound_name == "bonk" or sound_name == "jump" else 1.0
	player.play()

func _make_sound(kind: String, duration: float) -> AudioStreamWAV:
	var sample_count := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	var phase2 := 0.0
	for i in sample_count:
		var t := float(i) / SAMPLE_RATE
		var envelope := 0.0
		var value := 0.0
		var frequency := 440.0
		match kind:
			"jump":
				envelope = pow(maxf(0.0, 1.0 - t / duration), 1.3)
				frequency = 280.0 + 620.0 * t / duration
				value = sin(phase) * 0.7 + sin(phase * 0.5) * 0.2
			"bonk":
				envelope = pow(maxf(0.0, 1.0 - t / duration), 1.2)
				frequency = 520.0 * exp(-t * 15.0) + 95.0
				value = sin(phase) * 0.85
				if t < 0.025:
					value += sin(2.0 * PI * 1900.0 * t) * (1.0 - t / 0.025) * 0.25
			"boom":
				envelope = pow(maxf(0.0, 1.0 - t / duration), 1.0)
				frequency = 78.0 - 32.0 * t / duration
				value = sin(phase) + sin(phase2) * 0.35
				if t < 0.11:
					value += randf_range(-1.0, 1.0) * (1.0 - t / 0.11) * 0.7
			"death":
				envelope = pow(maxf(0.0, 1.0 - t / duration), 0.8)
				frequency = 210.0 - 140.0 * t / duration
				value = sin(phase) * 0.55 + sin(phase2 + sin(2.0 * PI * 3.2 * t)) * 0.3
			"respawn":
				envelope = pow(maxf(0.0, 1.0 - t / duration), 0.8)
				frequency = 420.0 + 750.0 * t / duration
				value = sin(phase) * (0.65 + 0.35 * sin(2.0 * PI * 9.0 * t))
			"select":
				envelope = pow(maxf(0.0, 1.0 - t / duration), 2.2)
				frequency = 880.0
				value = sin(phase)
			"victory":
				envelope = 1.0
				var note_length := duration / 5.0
				var note := mini(4, int(t / note_length))
				var local_t := fmod(t, note_length)
				var notes := [440.0, 587.0, 740.0, 587.0, 880.0]
				frequency = notes[note] * (1.0 + 0.012 * sin(t * 39.0))
				value = (sin(2.0 * PI * frequency * local_t) * 0.65 + sin(4.0 * PI * frequency * local_t) * 0.12) * pow(maxf(0.0, 1.0 - local_t / note_length), 0.7)
		phase += 2.0 * PI * frequency / SAMPLE_RATE
		phase2 += 2.0 * PI * frequency * 1.49 / SAMPLE_RATE
		var pcm := int(clampf(value * envelope, -1.0, 1.0) * 30000.0)
		data[i * 2] = pcm & 0xff
		data[i * 2 + 1] = (pcm >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream
