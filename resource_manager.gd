extends Node


var resourceMap = {"Comfort":0,"Abode":0,"Prestige":0}

func _on_resources_updated(effects: Dictionary, is_deleting_rooms: bool) -> void:
	for i in effects.keys():
		if is_deleting_rooms:
			resourceMap[i] -= effects[i]
		else:
			resourceMap[i] += effects[i]
	display_resources()
		
		
func display_resources():
	$"../UI/RoomLabel".text = ""
	for i in resourceMap.keys():
		$"../UI/RoomLabel".text += i + " +" + str(resourceMap[i]) + "\n" 
