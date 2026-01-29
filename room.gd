class_name Room
extends RefCounted

var name: String
var tile_id: int
var atlas: Vector2i
var alt_atlas: Vector2i
var description: String
var culture: String
var religion: String
var tags: Array
var placeable_on: Array
var effects: Dictionary = {}
var adjacency: Dictionary = {}      # neighbour_name -> { effect, value }

func _init(from_json: Dictionary) -> void:
	name = from_json.get("name", "")
	var atlas_array = from_json.get("atlas_coords")
	atlas = Vector2i(atlas_array[0], atlas_array[1]) if atlas_array else Vector2i(7,7)
	var alt_atlas_array = from_json.get("alt_atlas_coords")
	alt_atlas = Vector2i(alt_atlas_array[0], alt_atlas_array[1]) if alt_atlas_array else Vector2i(7,7)
	description = from_json.get("description", "")
	culture = from_json.get("culture", "")
	religion = from_json.get("religion", "")
	tags = from_json.get("tags", [""])
	placeable_on = from_json.get("placeable_on", [""])
	effects = from_json.get("effects", {})
	adjacency = from_json.get("adjacency", {})
