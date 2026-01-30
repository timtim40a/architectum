extends Node2D

@export var tilemap_path: NodePath = ^"../../Map/RoomLayer"
@export var line_color: Color = Color(1, 1, 1, 0.3)
@export var line_width: float = 1.0

var tilemap: TileMapLayer
var camera: Camera2D
var cell_size: Vector2

func _ready() -> void:
	tilemap = get_node(tilemap_path) as TileMapLayer
	camera = get_viewport().get_camera_2d()
	
	if tilemap:
		var actual_size = tilemap.tile_set.tile_size
		print("=== GRID DEBUG ===")
		print("TileSet tile_size: ", actual_size)
		
		# Test: get distance between two adjacent tiles
		var tile_0_0 = tilemap.map_to_local(Vector2i(0, 0))
		var tile_1_0 = tilemap.map_to_local(Vector2i(1, 0))
		var tile_0_1 = tilemap.map_to_local(Vector2i(0, 1))
		print("Distance between tiles (X): ", tile_1_0 - tile_0_0)
		print("Distance between tiles (Y): ", tile_0_1 - tile_0_0)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if tilemap == null or camera == null:
		return
	
	var viewport_size = get_viewport_rect().size
	var cell_size = tilemap.tile_set.tile_size
	var cam_zoom = camera.zoom
	
	# Convert grid coordinate to screen position
	var grid_to_screen = func(grid_x: int, grid_y: int) -> Vector2:
		var tile_local = tilemap.map_to_local(Vector2i(grid_x, grid_y))
		var corner_local = tile_local - cell_size / 2.0  # Top-left corner
		var world_pos = tilemap.to_global(corner_local)
		var cam_center = camera.get_screen_center_position()
		return (world_pos - cam_center) * cam_zoom + viewport_size / 2.0
	
	# Calculate visible range
	var cam_center = camera.get_screen_center_position()
	var half_view = viewport_size / (2.0 * cam_zoom)
	
	var top_left_world = cam_center - half_view
	var bottom_right_world = cam_center + half_view
	
	var start_grid = tilemap.local_to_map(tilemap.to_local(top_left_world)) - Vector2i(2, 2)
	var end_grid = tilemap.local_to_map(tilemap.to_local(bottom_right_world)) + Vector2i(2, 2)
	
	# Draw vertical grid lines
	for x in range(start_grid.x, end_grid.x + 2):
		var top_screen = grid_to_screen.call(x, start_grid.y)
		var bottom_screen = grid_to_screen.call(x, end_grid.y + 1)
		draw_line(
			Vector2(top_screen.x, 0),
			Vector2(bottom_screen.x, viewport_size.y),
			line_color, line_width
		)
	
	# Draw horizontal grid lines
	for y in range(start_grid.y, end_grid.y + 2):
		var left_screen = grid_to_screen.call(start_grid.x, y)
		var right_screen = grid_to_screen.call(end_grid.x + 1, y)
		draw_line(
			Vector2(0, left_screen.y),
			Vector2(viewport_size.x, right_screen.y),
			line_color, line_width
		)
