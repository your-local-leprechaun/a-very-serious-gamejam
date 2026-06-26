extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/duel.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	$Options.visible = true
	$"Main Menu".visible = false
