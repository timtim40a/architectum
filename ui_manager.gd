extends Node


var selected_room = null

func _on_room_list_updated(rooms: Dictionary):
	make_room_buttons(rooms)
	
func make_room_buttons(rooms: Dictionary):
	var palette = $"../UI/RoomPalette"
	
	for child in palette.get_children():
		child.queue_free()

	for room_name in rooms.keys():
		if rooms[room_name]["unlocked"]:
			var btn_scene = preload("res://RoomButton.tscn")
			var btn = btn_scene.instantiate()
			btn.text = room_name
			btn.connect("pressed", Callable(self, "_on_room_button_pressed").bind(room_name))
			palette.add_child(btn)

func _on_room_button_pressed(room_name):
	selected_room = room_name
	$"../UI/InfoLabel".text = "Selected: " + room_name
	
func get_selected_room():
	return selected_room

func _on_save_house_button_pressed() -> void:
	pass # Replace with function body.
