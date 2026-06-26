extends Control

var paused = false

func _input(event):
	# Pause Menu, but only when in game
	if event is InputEventKey and event.keycode == KEY_P and event.pressed:
		paused = !paused
		self.visible = paused
		if paused == false and $"../Options".visible == true:
			$"../Options".visible = false
		get_tree().paused = paused

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_option_pressed() -> void:
	$"../Options".visible = true
	self.visible = false
