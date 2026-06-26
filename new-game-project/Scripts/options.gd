extends Control

@export_enum("MENU", "PAUSE") var back_path

func _on_back_pressed() -> void:
	if back_path == 0:
		# MENU
		$"../Main Menu".visible = true
		self.visible = false
	else:
		# Pause
		$"../Pause".visible = true
		self.visible = false


func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
