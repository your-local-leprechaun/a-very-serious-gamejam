extends AudioStreamPlayer

@export var tracks: Array[String]

func _ready() -> void:
	# Connect the signal so it fires when a track ends
	finished.connect(_on_finished)
	_play_random()

func _play_random() -> void:
	if tracks.is_empty():
		return
	stream = load(tracks.pick_random())
	play()

func _on_finished() -> void:
	_play_random()
