extends Node2D

func _ready() -> void:
	$UI/Center/MenuCard/Stack/Start.grab_focus()

func _on_start_pressed() -> void:
	AudioManager.play_sfx("menu_select", -4.0)
	await get_tree().create_timer(0.14).timeout
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _on_controls_pressed() -> void:
	AudioManager.play_sfx("menu_select", -7.0)
	$UI/ControlsCard.visible = true

func _on_close_controls_pressed() -> void:
	AudioManager.play_sfx("menu_select", -7.0)
	$UI/ControlsCard.visible = false
	$UI/Center/MenuCard/Stack/Controls.grab_focus()

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select", -6.0)
	await get_tree().create_timer(0.12).timeout
	get_tree().quit()
