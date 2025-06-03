extends Camera2D

# Settings
@export var zoom_speed := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 3.0

var dragging := false
var last_mouse_pos := Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				last_mouse_pos = event.position

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(-zoom_speed)

	elif event is InputEventMouseMotion and dragging:
		var mouse_delta = event.position - last_mouse_pos
		global_position -= mouse_delta * zoom  # scale by zoom so movement feels consistent
		last_mouse_pos = event.position

func _zoom_camera(delta: float) -> void:
	var new_zoom = zoom + Vector2(delta, delta)
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	zoom = new_zoom
