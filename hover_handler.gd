extends Node2D

var preview_grid: TileMapLayer
var previous_hovered_cell: Vector2i
var room_map: Dictionary

func do_hover_effect(current_room: Room, hovered_cell: Vector2i, is_deleting: bool):
	
	if previous_hovered_cell != null and previous_hovered_cell != hovered_cell:
		preview_grid.set_cell(previous_hovered_cell, -1, Vector2i(-1,-1))
	previous_hovered_cell = hovered_cell
	
	if room_map.get(hovered_cell):
		if is_deleting:
			preview_grid.set_cell(hovered_cell, 1, Vector2i(7,7))
		return

	if !is_deleting:
		preview_grid.set_cell(hovered_cell, 1, current_room.atlas)
