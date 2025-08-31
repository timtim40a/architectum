extends Node2D


func _ready():
	
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
		var selected_room = $UIManager.get_selected_room()
		if selected_room != null:
			var tilemap = $TileMapLayer
			var mouse_pos = tilemap.get_local_mouse_position()
			var cell = tilemap.local_to_map(mouse_pos)
			if is_mouse_over_ui(mouse_pos):
				return # Skip tile placement if mouse is over UI
			$RoomManager.place_room(cell, selected_room)
			
