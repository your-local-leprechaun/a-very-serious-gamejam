extends 'bayblade.gd'

var charging = false
var charge_time = 0.0
var charge_duration = 3.0

func _ready():
	super()
	rotation = randf() * TAU
	spin_speed = 0.0
	velocity = Vector2.ZERO
	charge_duration = randf_range(3.0, 10.0)
	#start_countdown()

func start_countdown():
	charging = true
	charge_time = 0.0

func _process(delta):
	if charging:
		charge_time += delta
		spin_speed = 20.0 * (charge_time / charge_duration)
		if charge_time >= charge_duration:
			charging = false
			launch()
	super(delta)
