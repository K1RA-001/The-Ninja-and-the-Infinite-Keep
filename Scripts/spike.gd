extends Area2D

@export var spike_width := 64.0:
	set(value):
		spike_width = value
		if is_node_ready():
			_refresh()
@export_range(0, 5) var spike_style := 0
@export_range(0.65, 1.45, 0.05) var height_scale := 1.0:
	set(value):
		height_scale = value
		if is_node_ready():
			_refresh()

const PEAKS := [-27.0, -31.0, -34.0, -30.0, -34.0, -32.0]

func _ready() -> void:
	_refresh()
	body_entered.connect(_on_body_entered)

func _refresh() -> void:
	# Keep the hitbox aligned with the tallest tooth while leaving its base
	# just below the drawn baseline. All variations stay fair and predictable.
	var base_peak: float = PEAKS[clampi(spike_style, 0, PEAKS.size() - 1)]
	var top: float = 2.0 - (2.0 - base_peak) * height_scale
	var hazard_height: float = 2.0 - top
	$CollisionShape2D.shape.size = Vector2(spike_width, hazard_height)
	$CollisionShape2D.position.y = (top + 2.0) * 0.5
	queue_redraw()

func _draw() -> void:
	var tooth_count := maxi(1, int(ceil(spike_width / 22.0)))
	var tooth_width := spike_width / tooth_count
	var fill := Color("79746b")
	var edge := Color("c2b491")
	var glint := Color("e0d3b4")
	match spike_style:
		1: # Old bone fangs
			fill = Color("a79a77")
			edge = Color("e0d2ad")
			glint = Color("f1e7c9")
		2: # Bamboo thorns
			fill = Color("596447")
			edge = Color("b6a36a")
			glint = Color("ddc986")
		3: # Broken kunai
			fill = Color("555a62")
			edge = Color("d1c6ab")
			glint = Color("eee4ce")
		4: # Cursed crystal
			fill = Color("624358")
			edge = Color("c08b9c")
			glint = Color("f0c3cf")
		5: # Castle portcullis teeth
			fill = Color("6d5541")
			edge = Color("c19a65")
			glint = Color("ead19a")

	for i in range(tooth_count):
		var x := -spike_width * 0.5 + i * tooth_width
		var peak: float = 2.0 - (2.0 - PEAKS[spike_style]) * height_scale
		if i % 2 == 1:
			peak += 4.0 # Deliberately uneven silhouettes, like hand-built traps.
		var mid := x + tooth_width * 0.5
		var left := Vector2(x, 1.0)
		var tip := Vector2(mid, peak)
		var right := Vector2(x + tooth_width, 1.0)
		match spike_style:
			0: # Forged iron pikes, nicked along the edge
				var points := PackedVector2Array([left, tip, right])
				draw_colored_polygon(points, fill)
				draw_polyline(PackedVector2Array([left, tip, right]), edge, 2.0)
				draw_line(Vector2(mid - 2.0, peak + 7.0), Vector2(mid + 3.0, peak + 12.0), glint, 1.0)
			1: # Bone has shoulders and a narrow ivory point
				var points := PackedVector2Array([left, Vector2(mid - tooth_width * 0.28, peak + 8.0), tip, Vector2(mid + tooth_width * 0.28, peak + 8.0), right])
				draw_colored_polygon(points, fill)
				draw_polyline(PackedVector2Array([left, Vector2(mid - tooth_width * 0.28, peak + 8.0), tip, Vector2(mid + tooth_width * 0.28, peak + 8.0), right]), edge, 2.0)
				draw_circle(Vector2(mid, peak + 10.0), 1.5, glint)
			2: # Bamboo stalk, node bands, and leaf-like barbs
				var points := PackedVector2Array([Vector2(mid - tooth_width * 0.28, 1.0), Vector2(mid - tooth_width * 0.16, peak + 5.0), tip, Vector2(mid + tooth_width * 0.20, peak + 7.0), Vector2(mid + tooth_width * 0.30, 1.0)])
				draw_colored_polygon(points, fill)
				draw_polyline(PackedVector2Array([Vector2(mid - tooth_width * 0.28, 1.0), Vector2(mid - tooth_width * 0.16, peak + 5.0), tip, Vector2(mid + tooth_width * 0.20, peak + 7.0), Vector2(mid + tooth_width * 0.30, 1.0)]), edge, 2.0)
				draw_line(Vector2(mid - tooth_width * 0.4, peak + 13.0), Vector2(mid + tooth_width * 0.4, peak + 10.0), glint, 1.5)
				draw_line(Vector2(mid - tooth_width * 0.38, peak + 18.0), Vector2(mid + tooth_width * 0.36, peak + 16.0), edge, 1.5)
			3: # Kunai blade, faceted point, and red binding
				var points := PackedVector2Array([left, Vector2(mid - 2.0, peak + 8.0), tip, Vector2(mid + 2.0, peak + 8.0), right])
				draw_colored_polygon(points, fill)
				draw_polyline(PackedVector2Array([left, Vector2(mid - 2.0, peak + 8.0), tip, Vector2(mid + 2.0, peak + 8.0), right]), edge, 2.0)
				draw_line(tip, Vector2(mid + tooth_width * 0.15, 1.0), glint, 1.0)
				draw_rect(Rect2(Vector2(mid - 3.0, peak + 13.0), Vector2(6.0, 3.0)), Color("9a3831"), true)
			4: # Jagged crystal shards with a bright inner facet
				var points := PackedVector2Array([left, Vector2(mid - tooth_width * 0.3, peak + 12.0), tip, Vector2(mid + tooth_width * 0.18, peak + 8.0), right])
				draw_colored_polygon(points, fill)
				draw_polyline(PackedVector2Array([left, Vector2(mid - tooth_width * 0.3, peak + 12.0), tip, Vector2(mid + tooth_width * 0.18, peak + 8.0), right]), edge, 2.0)
				var shard := PackedVector2Array([Vector2(mid, peak - 4.0), Vector2(mid + 3.0, peak + 3.0), Vector2(mid, peak + 8.0), Vector2(mid - 2.0, peak + 2.0)])
				draw_colored_polygon(shard, glint)
			5: # Chunky machicolation teeth with chipped stone corners
				var points := PackedVector2Array([left, Vector2(x + tooth_width * 0.22, peak + 9.0), Vector2(mid - 2.0, peak + 6.0), tip, Vector2(mid + tooth_width * 0.3, peak + 9.0), right])
				draw_colored_polygon(points, fill)
				draw_polyline(PackedVector2Array([left, Vector2(x + tooth_width * 0.22, peak + 9.0), Vector2(mid - 2.0, peak + 6.0), tip, Vector2(mid + tooth_width * 0.3, peak + 9.0), right]), edge, 2.0)
				draw_rect(Rect2(Vector2(mid - 2.0, peak + 13.0), Vector2(4.0, 3.0)), glint, true)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
