extends Control

var paused = false

func _input(event):
	# Pause Menu, but only when in game
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		paused = !paused
		self.visible = paused
		get_tree().paused = paused

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
