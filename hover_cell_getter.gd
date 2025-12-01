extends Node2D

var current_mouse_pos_cell = Vector2i(0,0)
var preview_grid: TileMapLayer

func get_hovered_cell(global_mouse_position: Vector2) -> Vector2i:
	current_mouse_pos_cell = preview_grid.local_to_map(preview_grid.to_local(global_mouse_position))
	return current_mouse_pos_cell
