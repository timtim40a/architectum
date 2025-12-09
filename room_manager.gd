extends Node

# Signals (same as before)
signal room_list_updated(rooms: Dictionary)
signal resources_updated(effects: Dictionary, is_deleting: bool)
signal room_placed(current_room: String, cell: Vector2i)

@onready var tilemap := $"../TileMapLayer"

# --- Data stores ---
var available_rooms: Array = []       # room_name -> properties (from JSON)
var atlas_to_room: Dictionary = {}          # Vector2i(atlas) -> Room (if ever needed)

# The canonical logical map: cell (Vector2i) -> room_name (String)
var room_defs: Dictionary = {}              # room_name -> Room
var room_map: Dictionary = {}               # Vector2i -> Room



var is_deleting = false

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

	var rooms = JSON.parse_string(text)
	if !rooms:
		push_error("Failed to parse rooms.json")
		return

	room_defs.clear()
	for room_name in rooms.keys():
		var room_data: Dictionary = rooms[room_name]
		room_data["name"] = room_name  # Inject the name

		var room_init = Room.new(room_data)  # ✅ Pass Dictionary
		room_defs[room_init.name] = room_init

		# Build atlas_to_name map if needed
		if room_data.has("atlas_coord") and typeof(room_data["atlas_coord"]) == TYPE_ARRAY:
			var a = room_data["atlas_coord"]
			var v = Vector2i(int(a[0]), int(a[1]))
			atlas_to_room[v] = room_init

		if room_data.has("alt_atlas_coord") and typeof(room_data["alt_atlas_coord"]) == TYPE_ARRAY:
			var a = room_data["alt_atlas_coord"]
			var v = Vector2i(int(a[0]), int(a[1]))
			atlas_to_room[v] = room_init

		if room_data.get("unlocked", false):
			available_rooms.append(room_name)

# -------------------------
# Public API
# -------------------------
func get_room_at(cell: Vector2i) -> Room:
	return room_map.get(cell, null)

func set_room_at(cell: Vector2i, room_name: String ) -> void:
	room_map[cell] = room_defs.get(room_name)

func clear_room_at(cell: Vector2i) -> void:
	var room_cleared : Room
	if room_map.has(cell):
		room_cleared = get_room_at(cell)
		room_map.erase(cell)
		
		if room_cleared.base_effect_type != null:
			var eff_type = room_cleared.base_effect_type
			var eff_val = room_cleared.base_effect_value
			_emit_resource_effect(eff_type, eff_val, true)
		
		check_adjacency_effects(room_cleared, cell, true)
	# Clear visual too: set an empty atlas (use -1,-1)
	tilemap.set_cell(cell, 4, Vector2i(-1, -1))

# Place a room by name. Responsible for visuals + logical mapping + emitting room_placed
func place_room(cell: Vector2i, room_name: String) -> void:
	
	if is_deleting:
		clear_room_at(cell)
		return
	
	if not available_rooms.has(room_name):
		push_error("place_room: unknown room: %s" % room_name)
		return
		
	if get_room_at(cell) != null:
		push_error("room already exists at: %s" % cell)
		return

	# Put the atlas tile (visual)
	var atlas_coord: Vector2i = room_defs.get(room_name).atlas 
	tilemap.set_cell(cell, 4, atlas_coord)

	# Set the logical map
	set_room_at(cell, room_name)

	# Inform listeners
	emit_signal("room_placed", room_name, cell)
	print("%s placed at %s" % [room_name, str(cell)])

func _on_delete_button_toggled(toggled_on = false):
	is_deleting = toggled_on
	
# -------------------------
# Event handling: when a room is placed (either from place_room or elsewhere)
# -------------------------
func _on_room_placed(current_room_name: String, cell: Vector2i) -> void:
	# Unlock it if locked
	var current_room: Room = room_defs.get(current_room_name)
	if available_rooms.find(current_room_name) == -1:
		available_rooms.append(current_room_name)
		emit_signal("room_list_updated", available_rooms)

	# Apply the room's base effect (if present)
	if current_room.base_effect_type != null:
		var eff_type = current_room.base_effect_type
		var eff_val = current_room.base_effect_value
		_emit_resource_effect(eff_type, eff_val)

	# Check adjacency effects (neighbours)
	check_adjacency_effects(current_room, cell)

	# Composite check (e.g., lines)
	if current_room.composite != null:
		_check_and_apply_composite(current_room, cell)

func check_adjacency_effects(current_room: Room, cell: Vector2i, is_deleting = false) -> void:
	if current_room.adjacency != null and current_room.adjacency.size() > 0:
		var adj: Dictionary = current_room.adjacency
		for offset in ADJ_OFFSETS:
			var ncell = cell + offset
			var neighbour = get_room_at(ncell)
			if neighbour != null and adj.has(neighbour.name):
				var props = adj[neighbour.name]
				if props.has("effect") and props["effect"] != null:
					_emit_resource_effect(props["effect"], int(props.get("value", 0)), is_deleting)

# -------------------------
# Composite handling (line-type only implemented here)
# -------------------------
func _check_and_apply_composite(room: Room, cell: Vector2i) -> void:
	var composite_props: Dictionary = room.composite
	if composite_props.get("type", "") != "line":
		return

	var min_len: int = int(composite_props.get("length", 0))
	var composite_name: String = composite_props.get("composite_name", null)
	# directions to check: horizontal and vertical (only 2 directions required because we look both ways)
	var directions = [ Vector2i(1,0), Vector2i(0,1) ]

	for dir in directions:
		var matched_cells: Array = []
		# include the just-placed cell
		matched_cells.append(cell)

		# forward direction
		var pos = cell + dir
		while get_room_at(pos) == room:
			matched_cells.append(pos)
			pos += dir

		# backward direction
		pos = cell - dir
		while get_room_at(pos) == room:
			matched_cells.append(pos)
			pos -= dir

		# now we have all contiguous cells for this line
		if matched_cells.size() >= min_len:
			# sort cells to pick a reliable center (by coordinates)
			matched_cells.sort_custom(Callable(self, "_vec2i_sort"))
			var center_index := int(matched_cells.size() / 2)
			var center_cell: Vector2i = matched_cells[center_index]
			var composite_atlas: Vector2i = room_defs.get(composite_name).atlas if dir[0] else room_defs.get(composite_name).alt_atlas
			print(composite_name + " " + str(composite_atlas))
			for v in matched_cells:
				clear_room_at(v)

			# Place upgraded tile visually at center and set logic
			tilemap.set_cell(center_cell, 4, composite_atlas)
			set_room_at(center_cell, composite_name)

			# Clear other cells visually and in logic
			for c in matched_cells:
				if c != center_cell:
					clear_room_at(c)

			# Emit that we created a new room (signals, resource effects if any)
			emit_signal("room_placed", composite_name, center_cell)
			print("%s created at %s by combining %s cells" % [composite_name, str(center_cell), str(matched_cells.size())])
			# Stop after making the first valid composite
			return

# helper comparator for sorting Vector2i arrays (by x then y)
func _vec2i_sort(a: Vector2i, b: Vector2i) -> bool:
	if a.x == b.x:
		return a.y < b.y
	return a.x < b.x

# -------------------------
# Utility
# -------------------------
func _emit_resource_effect(effect_type: String, value: int, is_deleting = false) -> void:
	print(effect_type + " " + str(value))
	if effect_type == null or effect_type == "":
		return
	emit_signal("resources_updated", { effect_type: value }, is_deleting)
