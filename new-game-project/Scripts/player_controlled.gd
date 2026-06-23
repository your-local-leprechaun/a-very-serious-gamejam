extends 'bayblade.gd'

var launch_ready = false

func _ready():
	super()

func _input(event):
	if not launch_ready:
		return
	if event is InputEventMouseMotion and Input.is_key_pressed(KEY_SPACE):
		var mouse_pos = get_global_mouse_position()
		var dir = mouse_pos - global_position
		var current_angle = dir.angle()
		
		if last_angle != null:
			var delta_angle = angle_difference(last_angle, current_angle)
			if delta_angle > 0:
				spin_speed += delta_angle * spin_efficiency
		
		last_angle = current_angle

	if event is InputEventKey and event.keycode == KEY_SPACE and not event.pressed:
		launch()
		last_angle = null
