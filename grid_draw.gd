extends Node2D

@export var cell_size: float = 64.0
@export var line_color: Color = Color(1, 1, 1, 0.7)
@export var line_width: float = 2.0
@onready var camera: Camera2D = get_parent().get_parent().get_node("Camera2D")  # Adjust path

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if camera == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var cam_offset: Vector2 = camera.offset - Vector2(0, 4)
	var cam_zoom: Vector2 = camera.zoom

	# Screen-space cell size
	var screen_cell_size: Vector2 = Vector2(cell_size, cell_size) * cam_zoom

	# Offset in screen space (wraps perfectly)
	var offset_x: float = fmod(cam_offset.x, cell_size) * cam_zoom.x
	var offset_y: float = fmod(cam_offset.y, cell_size) * cam_zoom.y
	if offset_x < 0: offset_x += screen_cell_size.x
	if offset_y < 0: offset_y += screen_cell_size.y

	var cols: int = int(viewport_size.x / screen_cell_size.x) + 2
	var rows: int = int(viewport_size.y / screen_cell_size.y) + 2

	# Draw full-screen spanning lines
	var INF = 10000.0
	for x in range(-1, cols):
		var px: float = x * screen_cell_size.x - offset_x
		draw_line(Vector2(px, -INF), Vector2(px, INF), line_color, line_width)

	for y in range(-1, rows):
		var py: float = y * screen_cell_size.y - offset_y
		draw_line(Vector2(-INF, py), Vector2(INF, py), line_color, line_width)
	
	
