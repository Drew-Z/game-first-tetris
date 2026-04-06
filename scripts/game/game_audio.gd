extends Node

@export var lock_stream: AudioStream
@export var line_clear_stream: AudioStream
@export var hard_drop_stream: AudioStream
@export var game_over_stream: AudioStream
@export var restart_stream: AudioStream
@export var fallback_mix_rate: int = 22050

var _players: Dictionary = {}


func _ready() -> void:
	_ensure_fallback_streams()
	_register_player(&"lock", lock_stream)
	_register_player(&"line_clear", line_clear_stream)
	_register_player(&"hard_drop", hard_drop_stream)
	_register_player(&"game_over", game_over_stream)
	_register_player(&"restart", restart_stream)


func play_lock() -> void:
	_play_event(&"lock")


func play_line_clear(_cleared_row_count: int = 0) -> void:
	var line_clear_player: AudioStreamPlayer = _players.get(&"line_clear")
	if line_clear_player != null:
		line_clear_player.pitch_scale = 1.0 + (0.12 * float(maxi(_cleared_row_count - 1, 0)))
	_play_event(&"line_clear")


func play_hard_drop() -> void:
	_play_event(&"hard_drop")


func play_game_over() -> void:
	_play_event(&"game_over")


func play_restart() -> void:
	_play_event(&"restart")


func _register_player(event_name: StringName, stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.name = "%sPlayer" % [String(event_name).capitalize()]
	player.stream = stream
	add_child(player)
	_players[event_name] = player


func _play_event(event_name: StringName) -> void:
	var player: AudioStreamPlayer = _players.get(event_name)
	if player == null or player.stream == null:
		return

	player.play()


func _ensure_fallback_streams() -> void:
	if lock_stream == null:
		lock_stream = _build_tone_stream(330.0, 0.06, 0.28)
	if line_clear_stream == null:
		line_clear_stream = _build_tone_stream(660.0, 0.12, 0.42)
	if hard_drop_stream == null:
		hard_drop_stream = _build_tone_stream(220.0, 0.08, 0.34)
	if game_over_stream == null:
		game_over_stream = _build_tone_stream(140.0, 0.28, 0.36)
	if restart_stream == null:
		restart_stream = _build_tone_stream(520.0, 0.1, 0.32)


func _build_tone_stream(frequency_hz: float, duration_seconds: float, amplitude: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = fallback_mix_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	stream.data = _build_pcm16_sine_data(frequency_hz, duration_seconds, amplitude)
	return stream


func _build_pcm16_sine_data(frequency_hz: float, duration_seconds: float, amplitude: float) -> PackedByteArray:
	var sample_count := maxi(int(ceil(duration_seconds * float(fallback_mix_rate))), 1)
	var data := PackedByteArray()
	data.resize(sample_count * 2)

	for sample_index in range(sample_count):
		var t := float(sample_index) / float(fallback_mix_rate)
		var envelope := 1.0 - (float(sample_index) / float(sample_count))
		var sample_value: float = sin(TAU * frequency_hz * t) * amplitude * envelope
		var pcm_value := int(clampi(int(round(sample_value * 32767.0)), -32768, 32767))
		var packed_value := pcm_value & 0xffff
		data[sample_index * 2] = packed_value & 0xff
		data[sample_index * 2 + 1] = (packed_value >> 8) & 0xff

	return data
