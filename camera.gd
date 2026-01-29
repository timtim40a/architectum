extends Camera2D

var zoom_level = 0  # -2, -1, 0, 1, 2
var is_panning = false
var pan_start_position = Vector2.ZERO

const PAN_SPEED = 400.0  # pixels per second
const MIN_ZOOM = -2
const MAX_ZOOM = 2

func _process(delta: float) -> void:
	# Keyboard panning (delta-independent)
	var pan_direction = Vector2.ZERO
	
	if Input.is_action_pressed("pan_up"):
		pan_direction.y -= 1
	if Input.is_action_pressed("pan_down"):
		pan_direction.y += 1
	if Input.is_action_pressed("pan_left"):
		pan_direction.x -= 1
	if Input.is_action_pressed("pan_right"):
		pan_direction.x += 1
	
	if pan_direction != Vector2.ZERO:
		offset += pan_direction.normalized() * PAN_SPEED * delta / zoom.x

func _unhandled_input(event: InputEvent) -> void:
	# Mouse panning
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_position = event.position
			else:
				is_panning = false
	
	elif event is InputEventMouseMotion and is_panning:
		var pan_delta = event.position - pan_start_position
		offset -= pan_delta / zoom.x  # Adjust for zoom level
		pan_start_position = event.position
	
	# Zoom
	if event.is_action_pressed("zoom_in"):
		zoom_level = clamp(zoom_level + 1, MIN_ZOOM, MAX_ZOOM)
		zoom = Vector2.ONE * pow(2.0, zoom_level)
		
	elif event.is_action_pressed("zoom_out"):
		zoom_level = clamp(zoom_level - 1, MIN_ZOOM, MAX_ZOOM)
		zoom = Vector2.ONE * pow(2.0, zoom_level)
