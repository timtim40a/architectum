extends Node

var selected_room
@onready var selected_room_label = $"../UI/LeftPanel/SelectedRoom"
@onready var stats_label = $"../UI/LeftPanel/StatResourcePanel/StatsLabels"
@onready var resources_label = $"../UI/LeftPanel/StatResourcePanel/ResourcesLabels"

func _on_room_list_updated(rooms: Array):
	make_room_buttons(rooms)
	
func make_room_buttons(rooms: Array):
	var palette = $"../UI/RightPanel/ScrollContainer/RoomPalette"
	var button_scene = preload("res://room_button.tscn")

	for child in palette.get_children():
		child.queue_free()

	for room in rooms:
		var button = button_scene.instantiate()
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = load("res://tilemap_rooms.png")
		atlas_texture.region = Rect2(room.atlas[0]*16, room.atlas[1]*16, 16, 16)
		var icon : TextureRect = button.get_node("RoomIcon")
		
		# Get the source texture from the AtlasTexture
		icon.texture = atlas_texture
		var label : Label = button.get_node("RoomDisplayName")
		label.text = room.name
		var clickable = button.get_node("ClickableArea")
		button.connect("pressed", Callable(self, "_on_room_button_pressed").bind(room))
		
		palette.add_child(button)
# Called when the node enters the scene tree for the first time.

func get_selected_room():
	return selected_room

func _ready() -> void:
	pass # Replace with function body.

func _on_room_button_pressed(room):
	selected_room = room
	selected_room_label.text = "Selected: " + room.name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
