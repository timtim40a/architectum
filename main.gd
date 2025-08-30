extends Node2D

var availableRooms = {}
var roomMap = {
	Vector2i(-1,-1):"-empty-",
	Vector2i(0,0):"Kitchen", 
	Vector2i(1,1):"Bedroom", 
	Vector2i(2,0):"DiningHall",#
	Vector2i(4,2):"FeastHall"
}
var resourceMap = {"Comfort":0,"Abode":0,"Prestige":0}
var current_room = null
var comfort = 0

signal room_placed

func _on_room_placed(current_room, cell):
	var tilemap = $TileMapLayer
	$UI/RoomLabel.text = ""
	
	if availableRooms[current_room]["effect"]:
		var roomEffect = availableRooms[current_room]["effect"]
		resourceMap[roomEffect] += availableRooms[current_room]["value"]
			
			
	if availableRooms[current_room]["adjacency"]:
		var roomAdjProps = availableRooms[current_room]["adjacency"]
		var offsets = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		
		for offset in offsets:
			var neighbour_cell = cell + offset
			var neighbour_name = roomMap.get(tilemap.get_cell_atlas_coords(neighbour_cell), "-empty-")
			if roomAdjProps.has(neighbour_name):
				resourceMap[roomAdjProps[neighbour_name]["effect"]] += 1
			print(neighbour_name)
		
	for i in resourceMap:
		$UI/RoomLabel.text += i + " +" + str(resourceMap[i]) + "\n" 
		
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
	$TileMapLayer.set_cell(center_cell, 4, upgrade_room, rotation)
	if !availableRooms[roomMap[upgrade_room]]["unlocked"]:
		availableRooms[roomMap[upgrade_room]]["unlocked"] = true
		make_room_buttons()
	emit_signal("room_placed", roomMap[upgrade_room], center_cell)

	# Clear the rest (optional)
	for c in cells:
		if c != center_cell:
			roomMap[c] = "-empty-"
			$TileMapLayer.set_cell(c, 4, Vector2i(-1,-1))

	print(roomMap[upgrade_room] + " created at " + str(center_cell))

func make_room_buttons():
	var palette = $UI/RoomPalette
	
	for child in palette.get_children():
		child.queue_free()

	for room_name in availableRooms.keys():
		if availableRooms[room_name]["unlocked"]:
			var btn_scene = preload("res://RoomButton.tscn")
			var btn = btn_scene.instantiate()
			btn.text = room_name
			btn.connect("pressed", Callable(self, "_on_room_button_pressed").bind(room_name))
			palette.add_child(btn)

func _on_room_button_pressed(room_name):
	current_room = room_name
	$UI/InfoLabel.text = "Selected: " + current_room


func place_room(cell: Vector2i, room_name: String):
	var tilemap = $TileMapLayer

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

func _ready():
	var file = FileAccess.open("res://rooms.json", FileAccess.READ)
	var text = file.get_as_text()
	availableRooms = JSON.parse_string(text)
	file.close()

	print(availableRooms["Kitchen"]["adjacency"])
	
	make_room_buttons()
	
	self.connect("room_placed", Callable(self, "_on_room_placed"))
	
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
		if current_room != null:
			var tilemap = $TileMapLayer
			var mouse_pos = tilemap.get_local_mouse_position()
			var cell = tilemap.local_to_map(mouse_pos)
			if is_mouse_over_ui(mouse_pos):
				return # Skip tile placement if mouse is over UI
			place_room(cell, current_room)
			
