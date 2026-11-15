extends StaticBody2D

@export var platform_width := 240.0:
	set(value):
		platform_width = value
		if is_node_ready():
			_refresh()
@export_range(0, 5) var platform_style := 0

const STONE_PALETTES := [
	[Color("343440"), Color("827867"), Color("514d48")], # Limestone balcony
	[Color("303a34"), Color("879071"), Color("485344")], # Mossy parapet
	[Color("49382e"), Color("a07a50"), Color("352b28")], # Lantern gallery
	[Color("3c3332"), Color("9b674d"), Color("2f292b")], # Timber lookout
	[Color("393643"), Color("8a8190"), Color("51424a")], # Broken ridge
	[Color("353d4a"), Color("a18c66"), Color("454b55")]  # Roofline ledge
]

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	$CollisionShape2D.shape.size = Vector2(platform_width, 30.0)
	queue_redraw()

func _draw() -> void:
	var half := platform_width * 0.5
	var palette: Array = STONE_PALETTES[clampi(platform_style, 0, STONE_PALETTES.size() - 1)]
	var base: Color = palette[0]
	var cap: Color = palette[1]
	var mortar: Color = palette[2]
	var trim := cap.lightened(0.14)
	var dark := base.darkened(0.35)

	# Heavy stone corbels make each ledge read as part of the castle wall.
	var left_support := PackedVector2Array([
		Vector2(-half + 10.0, 12.0), Vector2(-half + 46.0, 12.0),
		Vector2(-half + 35.0, 27.0), Vector2(-half + 17.0, 27.0)
	])
	var right_support := PackedVector2Array([
		Vector2(half - 46.0, 12.0), Vector2(half - 10.0, 12.0),
		Vector2(half - 17.0, 27.0), Vector2(half - 35.0, 27.0)
	])
	draw_colored_polygon(left_support, dark)
	draw_colored_polygon(right_support, dark)
	draw_line(left_support[0], left_support[3], mortar, 2.0)
	draw_line(right_support[1], right_support[2], mortar, 2.0)

	# The playable top stays flat and level for reliable landings.
	draw_rect(Rect2(Vector2(-half, -15.0), Vector2(platform_width, 30.0)), base, true)
	draw_rect(Rect2(Vector2(-half, -15.0), Vector2(platform_width, 6.0)), cap, true)
	draw_rect(Rect2(Vector2(-half, -9.0), Vector2(platform_width, 3.0)), mortar, true)
	draw_rect(Rect2(Vector2(-half, 12.0), Vector2(platform_width, 3.0)), dark, true)

	for x in range(int(-half + 8.0), int(half - 16.0), 32):
		draw_rect(Rect2(Vector2(x, -3.0), Vector2(24.0, 15.0)), base.lightened(0.025), true)
		draw_line(Vector2(x + 24.0, -2.0), Vector2(x + 24.0, 8.0), mortar, 2.0)
		draw_rect(Rect2(Vector2(x + 3.0, 2.0), Vector2(3.0, 3.0)), cap.darkened(0.12), true)

	match platform_style:
		0:
			_draw_balcony(half, cap, trim, dark)
		1:
			_draw_parapet(half, cap, trim, mortar)
		2:
			_draw_lantern_gallery(half, cap, trim, dark)
		3:
			_draw_timber_lookout(half, cap, trim, dark)
		4:
			_draw_broken_ridge(half, cap, trim, mortar)
		5:
			_draw_roofline(half, cap, trim, dark)

func _draw_balcony(half: float, cap: Color, trim: Color, dark: Color) -> void:
	# Little merlons and a low parapet, like a walk around the keep.
	draw_rect(Rect2(Vector2(-half + 10.0, -21.0), Vector2(platform_width - 20.0, 6.0)), dark, true)
	draw_rect(Rect2(Vector2(-half + 10.0, -22.0), Vector2(platform_width - 20.0, 2.0)), cap, true)
	for x in [-half + 12.0, -half + 38.0, half - 50.0, half - 24.0]:
		draw_rect(Rect2(Vector2(x, -27.0), Vector2(12.0, 7.0)), cap, true)
		draw_rect(Rect2(Vector2(x + 2.0, -27.0), Vector2(3.0, 7.0)), trim, true)
	# Warm inlaid stones along the front face.
	for x in range(int(-half + 20.0), int(half - 12.0), 48):
		draw_rect(Rect2(Vector2(x, 7.0), Vector2(12.0, 2.0)), cap.darkened(0.2), true)

func _draw_parapet(half: float, cap: Color, trim: Color, mortar: Color) -> void:
	# A stair-stepped battlement ridge with crenels visible against the sky.
	draw_rect(Rect2(Vector2(-half, -19.0), Vector2(platform_width, 4.0)), cap.darkened(0.18), true)
	for x in range(int(-half + 8.0), int(half - 10.0), 34):
		draw_rect(Rect2(Vector2(x, -27.0), Vector2(18.0, 8.0)), cap, true)
		draw_rect(Rect2(Vector2(x + 3.0, -27.0), Vector2(3.0, 8.0)), trim, true)
		draw_line(Vector2(x + 18.0, -19.0), Vector2(x + 18.0, -15.0), mortar, 2.0)

func _draw_lantern_gallery(half: float, cap: Color, trim: Color, dark: Color) -> void:
	# A tiny arched window and lantern sit in the wall under this shelf.
	var window_x := -11.0
	draw_rect(Rect2(Vector2(window_x - 12.0, -4.0), Vector2(24.0, 18.0)), dark, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(window_x - 12.0, -4.0), Vector2(window_x, -12.0), Vector2(window_x + 12.0, -4.0)
	]), dark)
	draw_rect(Rect2(Vector2(window_x - 15.0, -5.0), Vector2(30.0, 3.0)), cap, true)
	draw_rect(Rect2(Vector2(window_x - 3.0, 0.0), Vector2(6.0, 14.0)), Color("e1a853"), true)
	draw_rect(Rect2(Vector2(window_x - 1.0, 1.0), Vector2(2.0, 11.0)), Color("f6d18b"), true)
	draw_rect(Rect2(Vector2(-half + 12.0, 7.0), Vector2(14.0, 3.0)), trim.darkened(0.18), true)
	draw_rect(Rect2(Vector2(half - 26.0, 7.0), Vector2(14.0, 3.0)), trim.darkened(0.18), true)

func _draw_timber_lookout(half: float, cap: Color, trim: Color, dark: Color) -> void:
	# A wooden watch balcony bolted onto the stone tower face.
	draw_rect(Rect2(Vector2(-half, -6.0), Vector2(platform_width, 18.0)), Color("4a3028"), true)
	for y in [-3.0, 4.0, 11.0]:
		draw_line(Vector2(-half + 4.0, y), Vector2(half - 4.0, y), Color("8d5940"), 2.0)
	for x in [-half + 14.0, half - 18.0]:
		draw_rect(Rect2(Vector2(x, -24.0), Vector2(5.0, 10.0)), dark, true)
		draw_rect(Rect2(Vector2(x - 2.0, -26.0), Vector2(9.0, 3.0)), cap, true)
		draw_line(Vector2(x + 2.0, -14.0), Vector2(x + 2.0, -6.0), trim, 2.0)
	draw_rect(Rect2(Vector2(-half + 6.0, -15.0), Vector2(platform_width - 12.0, 3.0)), trim, true)

func _draw_broken_ridge(half: float, cap: Color, trim: Color, mortar: Color) -> void:
	# Weathered, mismatched capstones and a few readable cracks.
	for x in range(int(-half), int(half - 22.0), 28):
		var chip_height := 5.0 if posmod(x, 3) == 0 else 3.0
		draw_rect(Rect2(Vector2(x + 3.0, -15.0 - chip_height), Vector2(20.0, chip_height + 1.0)), cap.darkened(0.08), true)
		draw_rect(Rect2(Vector2(x + 5.0, -15.0 - chip_height), Vector2(4.0, 2.0)), trim, true)
	draw_line(Vector2(-18.0, -7.0), Vector2(-11.0, -1.0), trim, 2.0)
	draw_line(Vector2(-11.0, -1.0), Vector2(-15.0, 5.0), mortar, 2.0)
	draw_line(Vector2(half - 30.0, 1.0), Vector2(half - 23.0, 7.0), mortar, 2.0)

func _draw_roofline(half: float, cap: Color, trim: Color, dark: Color) -> void:
	# A steep roof-eave silhouette with tile marks and chunky timber brackets.
	draw_rect(Rect2(Vector2(-half, -19.0), Vector2(platform_width, 5.0)), dark, true)
	draw_rect(Rect2(Vector2(-half, -20.0), Vector2(platform_width, 3.0)), cap, true)
	for x in range(int(-half + 8.0), int(half - 8.0), 24):
		draw_line(Vector2(x, -19.0), Vector2(x + 7.0, -15.0), trim, 2.0)
	for x in [-half + 18.0, half - 42.0]:
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, 14.0), Vector2(x + 26.0, 14.0), Vector2(x + 15.0, 27.0), Vector2(x + 9.0, 27.0)
		]), dark)
		draw_line(Vector2(x + 3.0, 16.0), Vector2(x + 12.0, 25.0), trim.darkened(0.1), 2.0)
