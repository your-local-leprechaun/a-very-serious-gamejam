extends AudioStreamPlayer

@onready var parry_sfx = load("res://Music/Parry.mp3")
@onready var hit_sfx = load("res://Music/Clash.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func parry_sound():
	pitch_scale = randf_range(0.8, 1.2)
	stream = parry_sfx
	play()

func hit_sound():
	pitch_scale = randf_range(0.8, 1.2)
	stream = hit_sfx
	play()
