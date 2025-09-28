extends Node


var resourceMap = {"Comfort":0,"Abode":0,"Prestige":0}

func _on_resources_updated(effects: Dictionary) -> void:
	for i in effects.keys():
		resourceMap.set(i, effects[i] + resourceMap.get(i))
	display_resources()
		
		
func display_resources():
	$"../UI/RoomLabel".text = ""
	for i in resourceMap.keys():
		$"../UI/RoomLabel".text += i + " +" + str(resourceMap[i]) + "\n" 
