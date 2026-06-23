extends Node2D

@export var enemy_scene: PackedScene

enum State { COUNTDOWN, PLAYING, ENDED }
var state = State.COUNTDOWN
var countdown = 4
var countdown_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_duel()

func start_duel():
	state = State.COUNTDOWN
	countdown = 4
	countdown_timer = 0.0
	$Player.beyblade_stopped.connect(_on_beyblade_stopped.bind("Enemy wins!"))
	$Enemy.beyblade_stopped.connect(_on_beyblade_stopped.bind("Player wins!"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.COUNTDOWN:
		countdown_timer += delta
		if countdown_timer >= 1.0:
			countdown_timer = 0.0
			countdown -= 1
			if countdown > 0:
				print(countdown)
			else:
				print("DUEL!")
			if countdown <= 0:
				state = State.PLAYING
				$Player.launch_ready = true
				$Enemy.start_countdown()

func _on_beyblade_stopped(winner: String):
	if state == State.ENDED:
		return
	state = State.ENDED
	print(winner)
	$Player.freeze()
	$Enemy.freeze()
