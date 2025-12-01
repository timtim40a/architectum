extends Node

var house_catalogue = {}

func save_house(name, house):
	house_catalogue[name] = house


func _on_save_house_button_pressed() -> void:
	pass
