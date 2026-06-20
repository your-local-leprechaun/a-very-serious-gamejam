extends 'bayblade.gd'

func _ready():
	super()
	shootable = false
	rotation = randf() * TAU
	spin_speed = randf_range(10.0, 15.0)
	velocity = Vector2.from_angle(randf() * TAU) * randf_range(300, 600)
