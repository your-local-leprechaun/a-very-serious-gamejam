extends Node2D

@export var enemy_scene: PackedScene

enum State { COUNTDOWN, PLAYING, ENDED }
var state = State.COUNTDOWN
var countdown = 4
var countdown_timer = 0.0
var countdown_label_remove = 3
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_duel()

func start_duel():
	state = State.COUNTDOWN
	countdown = 4
	countdown_timer = 0.0
	$Countdown.visible = true
	$Countdown.text = ""
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
				$Countdown.text = str(countdown)
				print(countdown)
			else:
				$Countdown.text = "DUEL!"
				print("DUEL!")
			if countdown <= 0:
				state = State.PLAYING
				$Player.launch_ready = true
				$Enemy.start_countdown()
				await get_tree().create_timer(2.0).timeout
				fade_out_label(1.0)
	if state == State.ENDED:
		if Input.is_key_pressed(KEY_SPACE):
			get_tree().reload_current_scene()

func fade_out_label(duration: float = 3.0):
	var tween = create_tween()
	tween.tween_property($Countdown, "modulate:a", 0.0, duration)

func _on_beyblade_stopped(winner: String):
	if state == State.ENDED:
		return
	state = State.ENDED
	print(winner)
	$Player.freeze()
	$Enemy.freeze()
