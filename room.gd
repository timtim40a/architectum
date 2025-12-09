class_name Room
extends RefCounted

var name: String
var atlas: Vector2i
var alt_atlas: Vector2i
var base_effect_type: String = ""
var base_effect_value: int = 0
var adjacency: Dictionary = {}      # neighbour_name -> { effect, value }
var composite: Dictionary = {}      # e.g. { type="line", length=3, composite_name="Feast Hall" }

func _init(from_json: Dictionary) -> void:
	name = from_json.get("name", "")
	var atlas_array = from_json.get("atlas_coords")
	atlas = Vector2i(atlas_array[0], atlas_array[1]) if atlas_array else Vector2i(7,7)
	var alt_atlas_array = from_json.get("alt_atlas_coords")
	alt_atlas = Vector2i(alt_atlas_array[0], alt_atlas_array[1]) if alt_atlas_array else Vector2i(7,7)
	base_effect_type = from_json.get("effect", "")
	base_effect_value = int(from_json.get("value", 0))
	adjacency = from_json.get("adjacency", {})
	composite = from_json.get("composite", {})
