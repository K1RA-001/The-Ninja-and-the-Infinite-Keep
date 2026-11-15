extends Node2D

const STONE_DARK := Color("171b27")
const STONE_MID := Color("222632")
const STONE_LIGHT := Color("30313a")
const LANTERN := Color("d29a52")
var _last_band := 999999

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	var band := int(floor(-camera.get_screen_center_position().y / 430.0))
	if band != _last_band:
		_last_band = band
		queue_redraw()

func _draw() -> void:
	var camera := get_viewport().get_camera_2d()
	var center_y := camera.get_screen_center_position().y if camera else 0.0
	var first := int(floor(-(center_y + 1100.0) / 430.0))
	var last := int(ceil(-(center_y - 1100.0) / 430.0))
	for band in range(first, last + 1):
		var y := -float(band) * 430.0
		_draw_tower(-475.0, y, true)
		_draw_tower(395.0, y, false)
		draw_rect(Rect2(Vector2(-250, y - 165), Vector2(500, 8)), Color(0.12, 0.14, 0.19, 0.5), true)
		draw_rect(Rect2(Vector2(-214, y - 179), Vector2(18, 14)), Color(0.12, 0.14, 0.19, 0.5), true)
		draw_rect(Rect2(Vector2(188, y - 179), Vector2(18, 14)), Color(0.12, 0.14, 0.19, 0.5), true)
		if posmod(band, 4) == 0:
			draw_rect(Rect2(Vector2(270, y - 340), Vector2(36, 36)), Color("d8c89e"), true)
		for star_x in [-310.0, 210.0, -230.0, 275.0]:
			var star_y := y - 270.0 - posmod(band * 37 + int(absf(star_x)), 120)
			draw_rect(Rect2(Vector2(star_x, star_y), Vector2(4, 4)), Color("aaa58d"), true)

func _draw_tower(x: float, y: float, faces_right: bool) -> void:
	draw_rect(Rect2(Vector2(x, y - 210), Vector2(76, 420)), STONE_DARK, true)
	draw_rect(Rect2(Vector2(x + 7, y - 204), Vector2(7, 408)), STONE_LIGHT, true)
	for crenel in range(4):
		draw_rect(Rect2(Vector2(x + crenel * 22, y - 226), Vector2(14, 18)), STONE_MID, true)
		draw_rect(Rect2(Vector2(x + crenel * 22 + 3, y - 226), Vector2(3, 18)), STONE_LIGHT, true)
	for window_index in range(3):
		var wy := y - 160 + window_index * 130
		draw_rect(Rect2(Vector2(x + 28, wy), Vector2(18, 42)), Color("11151f"), true)
		draw_rect(Rect2(Vector2(x + 34, wy + 7), Vector2(6, 27)), LANTERN, true)
		draw_rect(Rect2(Vector2(x + 31, wy + 4), Vector2(12, 3)), Color("f0c878"), true)
	var banner_x := x + (57 if faces_right else 8)
	draw_rect(Rect2(Vector2(banner_x, y - 90), Vector2(4, 46)), Color("92856c"), true)
	draw_rect(Rect2(Vector2(banner_x + 4, y - 88), Vector2(24, 22)), Color("762b27"), true)
	draw_rect(Rect2(Vector2(banner_x + 4, y - 66), Vector2(17, 7)), Color("762b27"), true)
	draw_rect(Rect2(Vector2(banner_x + 11, y - 59), Vector2(10, 7)), Color("762b27"), true)
