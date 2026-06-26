extends 'bayblade.gd'

var charging = false
var charge_time = 0.0
var charge_duration = 3.0

var parry_cooldown = 0.0
var parry_cooldown_duration = 9.0

func _ready():
	super()
	rotation = randf() * TAU
	spin_speed = 0.0
	velocity = Vector2.ZERO
	charge_duration = randf_range(3.0, 10.0)
	spin_speed_text = $"../SMP/Enemy"
	#start_countdown()

func start_countdown():
	charging = true
	charge_time = 0.0

func _process(delta):
	if charging:
		charge_time += delta
		spin_speed = 32.0 * (charge_time / charge_duration)
		if charge_time >= charge_duration:
			charging = false
			launch()
	super(delta)
	
	if parry_cooldown > 0:
		parry_cooldown -= delta
	
	if not launched or parrying or parry_cooldown > 0:
		return
	
	var others = get_tree().get_nodes_in_group("beyblade")
	for b in others:
		if b == self:
			continue
		var dist = global_position.distance_to(b.global_position)
		var heading_toward_me = (global_position - b.global_position).normalized().dot(b.velocity.normalized())
		if dist < 100.0 and heading_toward_me > 0.5 and spin_speed < b.spin_speed:
			print("enemy considering parry")
			if randf() < 0.8:
				start_parry()
				parry_cooldown = parry_cooldown_duration
