extends Camera2D

@export var look_down_offset := 108.0
@export var dead_zone_x := 58.0
@export var horizontal_look_ahead := 0.16
@export var follow_smoothness := 7.5
@export var auto_scroll_speed := 13.0
@export var shake_decay := 28.0

var _tracked_y := 0.0
var _shake_strength := 0.0
var _initialized := false

func _ready() -> void:
	position_smoothing_enabled = false
	_tracked_y = global_position.y
	_initialized = true

func _process(delta: float) -> void:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return
	if not _initialized:
		_tracked_y = player.global_position.y - look_down_offset
		_initialized = true

	# The player sits below screen center so the next jump is visible.
	# Only lower the camera's world-space Y value (Godot's up direction is negative Y).
	var desired_y := player.global_position.y - look_down_offset
	# Keep climbing even if the player waits; catch up faster when they make progress.
	_tracked_y = maxf(limit_top, minf(_tracked_y - auto_scroll_speed * delta, desired_y))
	var desired_x := global_position.x
	var player_in_camera_space := player.global_position.x - global_position.x
	if player_in_camera_space > dead_zone_x:
		desired_x = player.global_position.x - dead_zone_x
	elif player_in_camera_space < -dead_zone_x:
		desired_x = player.global_position.x + dead_zone_x
	if absf(player_in_camera_space) > dead_zone_x:
		desired_x += clampf(player.velocity.x * horizontal_look_ahead, -54.0, 54.0)
	desired_x = clampf(desired_x, -90.0, 90.0)

	var smoothing := 1.0 - exp(-follow_smoothness * delta)
	global_position.x = lerpf(global_position.x, desired_x, smoothing)
	global_position.y = minf(_tracked_y, lerpf(global_position.y, _tracked_y, smoothing))

	if _shake_strength > 0.05:
		offset = Vector2(randf_range(-_shake_strength, _shake_strength), randf_range(-_shake_strength, _shake_strength))
		_shake_strength = move_toward(_shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

func shake(amount: float = 12.0) -> void:
	_shake_strength = maxf(_shake_strength, amount)

func snap_to_player() -> void:
	var player := get_parent() as CharacterBody2D
	if player == null:
		return
	_tracked_y = player.global_position.y - look_down_offset
	global_position = Vector2(player.global_position.x, _tracked_y)
	offset = Vector2.ZERO
	_shake_strength = 0.0
