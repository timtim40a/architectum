extends Node

signal room_list_updated(rooms: Dictionary)
signal resources_updated(effects: Dictionary)
signal room_placed(current_room: String, cell: Vector2i)
@onready var tilemap = $"../TileMapLayer"

var availableRooms = {}
var roomMap = {
	Vector2i(-1,-1):"-empty-",
	Vector2i(0,0):"Kitchen", 
	Vector2i(1,1):"Bedroom", 
	Vector2i(2,0):"DiningHall",#
	Vector2i(4,2):"FeastHall"
}

func _on_room_placed(current_room, cell):
	
	if !availableRooms[current_room]["unlocked"]:
		availableRooms[current_room]["unlocked"] = true
		
	
	if availableRooms[current_room]["effect"]:
		var roomEffect = availableRooms[current_room]["effect"]
		emit_signal("resources_updated",{roomEffect: availableRooms[current_room]["value"]})
			
			
	if availableRooms[current_room]["adjacency"]:
		var roomAdjProps = availableRooms[current_room]["adjacency"]
		var offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		
		for offset in offsets:
			var neighbour_cell = cell + offset
			var neighbour_name = roomMap.get(tilemap.get_cell_atlas_coords(neighbour_cell), "-empty-")
			if roomAdjProps.has(neighbour_name):
				var roomEffect = roomAdjProps[neighbour_name]["effect"]
				emit_signal("resources_updated",{roomEffect: roomAdjProps[neighbour_name]["value"]})
			print(neighbour_name)
		
	
		
	if availableRooms[current_room].has("composite"):
		print("placed room has a composite room")
		var compositeProps = availableRooms[current_room]["composite"]
		if compositeProps[0] == "line":
			print("in a form of " + str(compositeProps[0]) + " of minimal size " + str(compositeProps[1]))
			var directions = [Vector2i(1,0), Vector2i(0,1)]  # horizontal (→), vertical (↓)
			for dir in directions:
				# count consecutive rooms in both directions
				var matched_cells: Array[Vector2i] = [cell]

				# forward
				var pos = cell + dir
				while roomMap.get(tilemap.get_cell_atlas_coords(pos), "") == current_room:
					matched_cells.append(pos)
					pos += dir
				print(pos)

				# backward
				pos = cell - dir
				while roomMap.get(tilemap.get_cell_atlas_coords(pos), "") == current_room:
					matched_cells.append(pos)
					pos -= dir
				print(pos)

				print(matched_cells)
				if matched_cells.size() >= compositeProps[1]:
					_upgrade_to_line_compound_room(matched_cells, Vector2i(compositeProps[2][0],compositeProps[2][1]))
					return  # stop after first match


func _upgrade_to_line_compound_room(cells: Array[Vector2i], upgrade_room: Vector2i):
	# Decide which cell is the "main" one
	var center_cell = cells[cells.size() / 2]
	var is_vertical = false
	var rotation = 0
	
	if center_cell.x == cells[0].x:
		is_vertical = true
		rotation = 1
		

	# Place upgraded room at center
	tilemap.set_cell(center_cell, 4, upgrade_room, rotation)
	
	emit_signal("room_placed", roomMap[upgrade_room], center_cell)

	# Clear the rest (optional)
	for c in cells:
		if c != center_cell:
			roomMap[c] = "-empty-"
			tilemap.set_cell(c, 4, Vector2i(-1,-1))

	print(roomMap[upgrade_room] + " created at " + str(center_cell))
	
func place_room(cell: Vector2i, room_name: String):

	# Look up which atlas coord to use for this room
	var atlas = availableRooms[room_name]["atlas_coord"]
	var atlas_coord = Vector2i(atlas[0], atlas[1])
	

	# Place that tile in the grid
	tilemap.set_cell(cell, 4, atlas_coord)
	print(room_name + " has been placed at " + str(cell))
	
	emit_signal("room_placed", room_name, cell)
	# Arguments:
	#   layer = 0
	#   cell position = cell
	#   source_id = 0 (your TileSet resource ID, usually 0 if one TileSet)
	#   atlas_coord = coords of the sprite in the atlas

func _ready() -> void:
	var file = FileAccess.open("res://rooms.json", FileAccess.READ)
	var text = file.get_as_text()
	availableRooms = JSON.parse_string(text)
	file.close()
	emit_signal("room_list_updated", availableRooms)
