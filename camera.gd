extends Camera2D

var current_mouse_pos: Vector2
var zoom_level = 0  # -2, -1, 0, 1, 2

func _process(delta: float) -> void:
	
	
	if Input.is_action_pressed("pan_down"):
		offset = offset + Vector2(0, 8)
	elif Input.is_action_pressed("pan_up"):
		offset = offset + Vector2(0, -8)
	elif Input.is_action_pressed("pan_left"):
		offset = offset + Vector2(-8, 0)
	elif Input.is_action_pressed("pan_right"):
		offset = offset + Vector2(8, 0)
	elif Input.is_action_pressed("pan"):
		offset = offset + current_mouse_pos - get_viewport().get_mouse_position()
	

	if Input.is_action_just_pressed("zoom_in"):
		if zoom_level < 0:
			zoom_level += 1
			zoom_level = clamp(zoom_level, -2, 2)
			zoom = Vector2.ONE * pow(2.0, zoom_level)
	elif Input.is_action_just_pressed("zoom_out"):
		zoom_level -= 1
		zoom_level = clamp(zoom_level, -2, 2)
		zoom = Vector2.ONE * pow(2.0, zoom_level)

	current_mouse_pos = get_viewport().get_mouse_position()
