extends Node


var selected_room = null

func _on_room_list_updated(rooms: Array):
	make_room_buttons(rooms)
	
func make_room_buttons(rooms: Array):
	var palette = $"../UI/RoomPalette"
	var room_defs = $"../RoomManager".room_defs

	for child in palette.get_children():
		child.queue_free()

	for room_name in rooms:
		var btn_scene = preload("res://RoomButton.tscn")
		var btn = btn_scene.instantiate()
		var room_atlas = room_defs.get(room_name).atlas
		var btn_icon = load("res://splitanimage-grid-8x8/splitanimage-r" + str(int(room_atlas[1]+1)) + "-c" + str(int(room_atlas[0]+1)) + ".png")
		btn.text = room_name
		btn.icon = btn_icon
		btn.connect("pressed", Callable(self, "_on_room_button_pressed").bind(room_name))
		palette.add_child(btn)

func _on_room_button_pressed(room_name):
	selected_room = room_name
	$"../UI/InfoLabel".text = "Selected: " + room_name
	
func _on_delete_button_toggled(toggled_on = false):
	$"../UI/DeleteButton".text = "Place Rooms" if toggled_on else "Delete Rooms" 
	
func get_selected_room():
	return selected_room

func _on_save_house_button_pressed() -> void:
	pass # Replace with function body.
