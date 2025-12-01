extends Node2D

var name_to_atlas: Dictionary
var preview_grid: TileMapLayer
var previous_hovered_cell: Vector2i
var room_map: Dictionary

func do_hover_effect(current_room: String, hovered_cell: Vector2i, is_deleting: bool):
	
	if previous_hovered_cell != null and previous_hovered_cell != hovered_cell:
		preview_grid.set_cell(previous_hovered_cell, -1, Vector2i(-1,-1))
	previous_hovered_cell = hovered_cell
	
	if room_map.get(hovered_cell):
		if is_deleting:
			preview_grid.set_cell(hovered_cell, 1, Vector2i(7,7))
		return

	if !is_deleting:
		var current_atlas = name_to_atlas.get(current_room)
		preview_grid.set_cell(hovered_cell, 1, current_atlas)
