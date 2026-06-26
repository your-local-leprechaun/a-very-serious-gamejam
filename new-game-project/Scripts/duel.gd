extends Node2D

@export_file var enemies : Array[String]
@export_file var enemy_info
var player_info

var player_spawn = Vector2(635, 540)
var enemy_spawn = Vector2(1285, 540)

enum State { DIALOGUE, COUNTDOWN, PLAYING, ENDED }
var state = State.DIALOGUE
var countdown = 4
var countdown_timer = 0.0
var countdown_label_remove = 3
var timer = 0

# Dialogue Options and whatnot
@onready var textbox_text = $"Control/Text Box/Dialogue"
@onready var enemy_name_text = $"Control/Text Box/Enemy Name"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Prep the two combatants
	player_info = load("res://Char Info/bayblade.tres")
	if enemy_info == null:
		# Randomly grab one of them from enemies
		enemy_info = load(enemies.pick_random())
	
	# Print both to show it's working!
	print(player_info.cname + " VS " + enemy_info.cname)
	
	# Spawn both spinners at correct points
	var spinner = load(player_info.spinner)
	var instance = spinner.instantiate()
	add_child(instance)
	move_child(instance, 1)
	instance.position = player_spawn
	
	spinner = load(enemy_info.spinner)
	instance = spinner.instantiate()
	add_child(instance)
	move_child(instance, 1)
	instance.position = enemy_spawn
	
	# Update text box to have correct name
	$"Control/Text Box/Enemy Name".text = enemy_info.cname
	#start_duel()

func start_duel():
	state = State.COUNTDOWN
	countdown = 4
	countdown_timer = 0.0
	$Countdown.visible = true
	$Countdown.text = ""
	$Player.beyblade_stopped.connect(_on_beyblade_stopped.bind("player"))
	$Enemy.beyblade_stopped.connect(_on_beyblade_stopped.bind("enemy"))


var order = 0
var said = false
enum win_state {PLAYER, ENEMY}
var winner
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.DIALOGUE:
		# Player Entrance Dialogue
		if order == 0 and said == false:
			print("Check")
			# Don't reset anything, set textbox to be correct.
			textbox_text.text = player_info.entrance_lines.pick_random().replace("\\n", "\n")
			said = true
			$Control.visible = true
		
		# Enemy Dialogue
		if order == 1 and said == false:
			# Turn off bayblade name
			$"Control/Text Box/Bayblade Name".visible = false
			# Turn off bayblade sprite
			$"Control/Bayblade Sprite".visible = false
			# Turn on enemy name
			$"Control/Text Box/Enemy Name".visible = true
			# Turn on correct sprite 
			var enemy_sprite = get_node("Control/"+ enemy_info.cname_exact + " Sprite")
			enemy_sprite.visible = true
			# update text for new entrance line
			textbox_text.text = enemy_info.entrance_lines.pick_random().replace("\\n", "\n")
			said = true
		if order == 2:
			# Make all of control invisible
			$Control.visible = false
			# SPM visible
			$SMP.visible = true
			start_duel()
		
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
		if order == 0 and said == false:
			# Get rid of SMP screen
			$SMP.visible = false
			if winner == win_state.PLAYER:
				# Player Won
				# Show player + name
				$"Control/Bayblade Sprite".visible = true
				$"Control/Text Box/Bayblade Name".visible = true
				
				# Stop showing all other sprites
				$"Control/Diva Sprite".visible = false
				$"Control/Rival Sprite".visible = false
				$"Control/Tombraider Sprite".visible = false
				# Stop showing enemy name
				$"Control/Text Box/Enemy Name".visible = false
				
				# Update Text to win line from player
				textbox_text.text = player_info.win_lines.pick_random().replace("\\n", "\n")
				
				# Update win banner
				$Endscreen/Wins.text = player_info.cname + "\nWINS"
				
				# Show whole text box
				$Control.visible = true
			else:
				# Enemey won, but we don't know which one
				
				#Show Enemy + Name
				# Don't worry about this one, since they had the last line, they're already there
				
				# Update text to win line from enemy
				textbox_text.text = enemy_info.win_lines.pick_random().replace("\\n", "\n")
				
				# Update Winner banner
				$Endscreen/Wins.text = enemy_info.cname + "\nWINS"
				
				# Update Continue sign
				$"Control/Text Box/Label".text = "PRESS 'SPACE' TO RETURN"
				
				# Show whole text box
				$Control.visible = true
			
			# Show winner banner
			$Endscreen.visible = true
			said = true
		

func _input(event) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			if state == State.DIALOGUE:
				order += 1
				said = false
				print(order)
			elif state == State.ENDED:
				if winner == win_state.PLAYER:
					# Move to the next round
					get_tree().reload_current_scene()
				else:
					# Go to menu
					get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func fade_out_label(duration: float = 3.0):
	var tween = create_tween()
	tween.tween_property($Countdown, "modulate:a", 0.0, duration)

func _on_beyblade_stopped(stopped: String):
	if state == State.ENDED:
		return
	state = State.ENDED
	if stopped == "player":
		# ENEMY WON
		winner = win_state.ENEMY
	else:
		# PLAYER WON
		winner = win_state.PLAYER
	print(stopped + " Stopped first!")
	order = 0
	said = false
	print(str(winner))
	$Player.freeze()
	$Enemy.freeze()
