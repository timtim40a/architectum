extends Node

# Signals (same as before)
signal room_list_updated(rooms: Dictionary)
signal stats_updated(effects: Dictionary, is_deleting: bool)
signal room_placed(current_room: Room, cell: Vector2i)

@onready var tilemap := $"../Map/RoomLayer"

# --- Data stores ---
var available_rooms: Array[Room]       # room_name -> properties (from JSON)

# The canonical logical map: cell (Vector2i) -> room_name (String)
var room_defs: Dictionary = {}              # room_name -> Room
var room_map: Dictionary = {}

# Useful adjacency offsets (4-neighbour)
const ADJ_OFFSETS: Array = [ Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1) ]

# -------------------------
# Lifecycle
# -------------------------
func _ready() -> void:
	_load_rooms_json("res://rooms.json")
	emit_signal("room_list_updated", available_rooms)


# -------------------------
# Loading & normalization
# -------------------------
func _load_rooms_json(path: String) -> void:
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("Could not open rooms.json at %s" % path)
		return

	var text = f.get_as_text()
	f.close()

	var rooms_json = JSON.parse_string(text)
	if !rooms_json:
		push_error("Failed to parse rooms.json")
		return

	room_defs.clear()
	for room_name in rooms_json["rooms"].keys():
		var room_data: Dictionary = rooms_json["rooms"][room_name]
		room_data["name"] = room_name  # Inject the name
		room_data["effects"] = rooms_json["effects"][room_name]
		if (rooms_json["adjacency"].keys().has(room_name)):
			room_data["adjacency"] = rooms_json["adjacency"][room_name]

		var room_init = Room.new(room_data)  # ✅ Pass Dictionary
		room_defs[room_init.name] = room_init

		if room_data.get("unlocked", false):
			available_rooms.append(room_init)
			
# -------------------------
# Public API
# -------------------------
func get_room_at(cell: Vector2i) -> Room:
	return room_map.get(cell, null)

func set_room_at(room: Room, cell: Vector2i) -> void:
	room_map[cell] = room
			
			
func place_room(room: Room, cell: Vector2i) -> void:
	
	#if is_deleting:
		#clear_room_at(cell)
		#return
	
	if not available_rooms.has(room):
		push_error("place_room: unknown room: %s" % room.name)
		return
		
	if get_room_at(cell) != null:
		push_error("room " + get_room_at(cell).name + " already exists at: %s" % cell)
		return

	# Set the logical map
	set_room_at(room, cell)

	# Inform listeners
	emit_signal("room_placed", room, cell)
	print("%s placed at %s" % [room.name, str(cell)])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var selected_room = $"../UIManager".get_selected_room()
			if selected_room != null:
				var mouse_pos = tilemap.get_local_mouse_position()
				var cell = tilemap.local_to_map(mouse_pos)
				place_room(selected_room, cell)
