extends Node2D

const PLATFORM_SCENE := preload("res://Scenes/Platform.tscn")
const SPIKE_SCENE := preload("res://Scenes/Spike.tscn")
const START_Y := 320.0
const AHEAD_DISTANCE := 1000.0
const KEEP_BELOW_DISTANCE := 1000.0

@onready var platforms: Node2D = $Platforms
@onready var spikes: Node2D = $Spikes
@onready var player: CharacterBody2D = get_parent().get_node("Player")

var _rng := RandomNumberGenerator.new()
var _top_y := START_Y
var _last_x := 0.0
var _last_y := START_Y
var _last_width := 300.0
var _platform_index := 0
var _route_direction := 1.0

func _ready() -> void:
	_rng.randomize()
	_route_direction = -1.0 if _rng.randf() < 0.5 else 1.0
	_build_start()
	_ensure_ahead()

func _process(_delta: float) -> void:
	_ensure_ahead()
	if not player.is_dead:
		_recycle_below_camera()

func reset_run() -> void:
	for item in platforms.get_children():
		item.queue_free()
	for item in spikes.get_children():
		item.queue_free()
	_top_y = START_Y
	_last_x = 0.0
	_last_y = START_Y
	_last_width = 300.0
	_platform_index = 0
	_route_direction = -1.0 if _rng.randf() < 0.5 else 1.0
	_build_start()
	_ensure_ahead()

func _build_start() -> void:
	_add_platform(0.0, START_Y, 300.0)

func _ensure_ahead() -> void:
	if player == null:
		return
	var reference_y := START_Y if player.is_dead else player.global_position.y
	while _top_y > reference_y - AHEAD_DISTANCE:
		var help_steps := maxi(0, player.death_count - 2)
		var spacing_ease := minf(18.0, help_steps * 1.5)
		var width_bonus := minf(20.0, help_steps * 1.5)
		var next_y := _top_y - _rng.randf_range(195.0 - spacing_ease, 220.0 - spacing_ease)
		var next_width := _rng.randf_range(180.0 + width_bonus, 225.0 + width_bonus)
		var next_x := _next_platform_x()
		var trap_chance := maxf(0.10, 0.30 - help_steps * 0.02)
		if _platform_index >= 3 and _rng.randf() < trap_chance:
			# Keep the trap on the edge opposite the next jump.
			var safe_direction := signf(next_x - _last_x)
			var trap_side := -safe_direction if safe_direction != 0.0 else -1.0
			_add_spike(_last_x, _last_y, _last_width, trap_side)
		_top_y = next_y
		_last_x = next_x
		_last_y = _top_y
		_last_width = next_width
		_add_platform(_last_x, _top_y, next_width)

func _next_platform_x() -> float:
	# Sweep across the keep in gentle zigzags instead of clustering around the
	# middle. Each hop remains within a comfortable horizontal jump distance.
	var stride := _rng.randf_range(108.0, 165.0)
	var jitter := _rng.randf_range(-20.0, 20.0)
	var candidate := _last_x + _route_direction * stride + jitter
	if candidate > 360.0:
		_route_direction = -1.0
		if 360.0 - _last_x >= 88.0:
			candidate = 360.0
		else:
			candidate = _last_x + _route_direction * _rng.randf_range(108.0, 165.0) + _rng.randf_range(-20.0, 20.0)
	elif candidate < -360.0:
		_route_direction = 1.0
		if _last_x + 360.0 >= 88.0:
			candidate = -360.0
		else:
			candidate = _last_x + _route_direction * _rng.randf_range(108.0, 165.0) + _rng.randf_range(-20.0, 20.0)
	return clampf(candidate, -360.0, 360.0)

func _add_platform(x: float, y: float, width: float) -> void:
	var platform := PLATFORM_SCENE.instantiate()
	platform.platform_width = width
	platform.platform_style = _rng.randi_range(0, 5)
	platform.position = Vector2(x, y)
	platforms.add_child(platform)
	_platform_index += 1

func _add_spike(x: float, y: float, width: float, side: float) -> void:
	# Most trap patches are one or two pieces. Their size and position vary so
	# the same edge does not keep repeating one identical cluster.
	var roll := _rng.randf()
	var spike_count := 1
	if roll > 0.48:
		spike_count = 2
	if roll > 0.88:
		spike_count = 3
	var half_width := width * 0.5
	var anchor_ratio := _rng.randf_range(0.10, 0.94) if spike_count == 1 else _rng.randf_range(0.42, 0.92)
	var anchor_offset := half_width * anchor_ratio
	var minimum_offset := 18.0
	var group_span := 0.0
	if spike_count > 1:
		var available_span: float = maxf(8.0, anchor_offset - minimum_offset)
		group_span = _rng.randf_range(minf(16.0, available_span), minf(68.0, available_span))
	for i in range(spike_count):
		var spike := SPIKE_SCENE.instantiate()
		spike.spike_width = _rng.randf_range(14.0, 42.0)
		spike.spike_style = _rng.randi_range(0, 5)
		spike.height_scale = _rng.randf_range(0.70, 1.45)
		var progress := float(i) / float(maxi(1, spike_count - 1))
		var placement_jitter := _rng.randf_range(-5.0, 5.0) if spike_count > 1 else 0.0
		var offset_from_center: float = maxf(spike.spike_width * 0.5 + 5.0, anchor_offset - group_span * progress + placement_jitter)
		spike.position = Vector2(x + side * offset_from_center, y - 20.0)
		spikes.add_child(spike)

func _recycle_below_camera() -> void:
	var camera := player.get_node("Camera2D") as Camera2D
	var cleanup_y := camera.get_screen_center_position().y + KEEP_BELOW_DISTANCE
	for item in platforms.get_children():
		# Keep the spawn and first-step ledges ready for the next run.
		var is_opening_route: bool = item.position.y <= START_Y and item.position.y >= START_Y - 230.0
		if item.position.y > cleanup_y and not is_opening_route:
			item.queue_free()
	for item in spikes.get_children():
		if item.position.y > cleanup_y:
			item.queue_free()
