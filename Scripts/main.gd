extends Node2D

const ROAST_LINES := [
	"The floor won that argument. Again.",
	"That jump had the confidence of a wet sock.",
	"The spikes just added you to their group chat.",
	"Incredible. You missed a platform the size of a platform.",
	"Gravity called. It says this is getting embarrassing.",
	"A stealthy exit. Shame about the landing.",
	"The clan elders are pretending they don't know you."
]
const DOUBT_LINES := [
	"Bro... that gap was kind of rude.",
	"Okay, maybe that jump was unfair.",
	"Wait. The castle might be cheating.",
	"I watched that. That was absolutely suspicious."
]
const SUPPORT_LINES := [
	"You're learning the route. I can tell.",
	"The keep is still tall. You're still trying. Respect.",
	"Every attempt is teaching you something.",
	"I'm on your side now. Don't tell the spikes."
]
const HEART_LINES := [
	"Look how far you've come. Keep going.",
	"I'm serious: you're getting better.",
	"One more try. I'll be right here.",
	"You deserve to see the top. Let's get you there."
]

var elapsed := 0.0
var best_height := 0

func _process(delta: float) -> void:
	elapsed += delta
	var height_now := maxi(0, int((278.0 - $Player.global_position.y) / 10.0))
	var old_best_height := best_height
	best_height = maxi(best_height, height_now)
	if int(best_height / 250) > int(old_best_height / 250):
		AudioManager.play_sfx("victory", -7.0)
	$UI/HUD/TopBar/Stats/Altitude.text = "HEIGHT  %d m" % height_now
	$UI/HUD/TopBar/Stats/Time.text = "TIME  %02d:%02d" % [int(elapsed / 60.0), int(elapsed) % 60]
	$UI/HUD/TopBar/Stats/Score.text = "BEST  %d" % maxi(0, best_height * 10 - $Player.death_count * 25)

func _on_player_died(count: int) -> void:
	$UI/HUD/TopBar/Stats/Deaths.text = "WIPES  %d" % count
	# Spike deaths arrive during the physics collision pass; defer collision-node changes.
	$World.call_deferred("reset_run")
	$UI/HUD/Message.text = _death_message(count)
	$UI/HUD/Message.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(2.6)
	tween.tween_property($UI/HUD/Message, "modulate:a", 0.0, 0.9)

func _death_message(count: int) -> String:
	match count:
		1:
			return "Skill issue."
		4:
			return "Bro..."
		8:
			return "Okay, maybe that jump was unfair."
		20:
			return "Wait... you're actually improving."
		40:
			return "Keep going. You've got this."
		75:
			return "I'm serious. I believe in you."
	if count < 4:
		return ROAST_LINES.pick_random()
	if count < 8:
		return DOUBT_LINES.pick_random()
	if count < 20:
		return SUPPORT_LINES.pick_random()
	return HEART_LINES.pick_random()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		AudioManager.play_sfx("menu_select", -5.0)
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
