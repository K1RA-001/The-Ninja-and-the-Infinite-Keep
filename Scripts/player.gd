extends CharacterBody2D

signal died(death_count: int)
signal reached_finish

@export var run_speed := 330.0
@export var acceleration := 1900.0
@export var jump_velocity := -980.0
@export var gravity := 1700.0
@export var fall_below_camera_margin := 24.0

var death_count := 0
var spawn_position := Vector2.ZERO
var is_dead := false
var finished := false

func _ready() -> void:
	spawn_position = global_position

func _physics_process(delta: float) -> void:
	if is_dead or finished:
		return
	var was_on_floor := is_on_floor()
	if _has_fallen_below_camera():
		die()
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	var axis := Input.get_axis("ui_left", "ui_right")
	var left_arrow := Input.is_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_LEFT)
	var right_arrow := Input.is_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_RIGHT)
	if left_arrow or right_arrow:
		axis = 0.0 if left_arrow and right_arrow else (-1.0 if left_arrow else 1.0)
	velocity.x = move_toward(velocity.x, axis * run_speed, acceleration * delta)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		$Body.scale = Vector2(0.88, 1.13)
		$Camera2D.shake(1.8)
		AudioManager.play_sfx("jump", -8.0)
	move_and_slide()
	if not was_on_floor and is_on_floor() and velocity.y == 0.0:
		$Camera2D.shake(2.5)
		AudioManager.play_sfx("bonk", -13.0)
	$Body.scale = $Body.scale.lerp(Vector2.ONE, minf(1.0, delta * 12.0))
	if velocity.x != 0.0:
		$Body.scale.x = signf(velocity.x) * absf($Body.scale.x)

func _has_fallen_below_camera() -> bool:
	var camera := $Camera2D as Camera2D
	var screen_center := camera.get_screen_center_position()
	var half_screen_height := get_viewport_rect().size.y / (2.0 * camera.zoom.y)
	return global_position.y > screen_center.y + half_screen_height + fall_below_camera_margin

func die() -> void:
	if is_dead or finished:
		return
	is_dead = true
	death_count += 1
	_apply_secret_help()
	velocity = Vector2.ZERO
	$Camera2D.shake(14.0)
	var death_sounds := ["bonk", "vine_boom", "death_wah"]
	AudioManager.play_sfx(death_sounds.pick_random(), -2.0)
	died.emit(death_count)
	await get_tree().create_timer(0.85).timeout
	if not is_inside_tree():
		return
	global_position = spawn_position
	velocity = Vector2.ZERO
	$Camera2D.snap_to_player()
	AudioManager.play_sfx("respawn", -5.0)
	is_dead = false

func _apply_secret_help() -> void:
	if death_count < 3:
		return
	# The keep quietly gives a struggling ninja a little more air and time.
	var help_steps := death_count - 2
	jump_velocity = -minf(1060.0, 980.0 + help_steps * 15.0)
	$Camera2D.auto_scroll_speed = maxf(7.0, 13.0 - help_steps * 1.2)

func win() -> void:
	if finished or is_dead:
		return
	finished = true
	velocity = Vector2.ZERO
	reached_finish.emit()
