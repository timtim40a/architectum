extends Node2D

var hover1 = preload("res://hover_cell_getter.gd")
var hover2 = preload("res://hover_handler.gd")
var hover_cell_getter = hover1.new()
var hover_handler = hover2.new()
var selected_room

func _ready():
	hover_cell_getter.preview_grid = $PreviewGrid
	hover_handler.preview_grid = $PreviewGrid
	hover_handler.name_to_atlas = $RoomManager.name_to_atlas
	hover_handler.room_map = $RoomManager.room_map
	print("Children in palette: ", $UI/RoomPalette.get_child_count())
	

func is_mouse_over_ui(mouse_pos: Vector2) -> bool:
	# Iterate over all direct children of your UI container
	for control in $UI.get_children():
		if control is Control:
			var rect = control.get_global_rect()
			if rect.has_point(mouse_pos):
				return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.is_action_just_pressed("place_click"):
		selected_room = $UIManager.get_selected_room()
		if selected_room != null:
			var tilemap = $TileMapLayer
			var mouse_pos = tilemap.get_local_mouse_position()
			var cell = tilemap.local_to_map(mouse_pos)
			if !is_mouse_over_ui(mouse_pos):
				$RoomManager.place_room(cell, selected_room)
			
	selected_room = $UIManager.get_selected_room()
	if selected_room != null:
		hover_handler.do_hover_effect(selected_room, hover_cell_getter.get_hovered_cell(get_global_mouse_position()), $RoomManager.is_deleting)
	
