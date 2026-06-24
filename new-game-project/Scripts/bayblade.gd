extends Node2D

signal beyblade_stopped

var spin_speed = 0.0
var last_angle = null
var velocity = Vector2.ZERO
var frozen = false
var shootable = false
var launched = false

# parry
var parrying = false
var parry_duration = 0.2
var parry_timer = 0.0
var parry_cost = 3.0

# stats
var spin_reduction_on_hit = 0.05
var speed_reduction_on_hit = 0.02
var spin_efficiency = 0.2

func _ready():
	connect("area_entered", _on_hit)
	add_to_group("beyblade")

func _process(delta):
	if frozen:
		return
	rotation += spin_speed * delta
	position += velocity * delta
	
	if parrying:
		parry_timer -= delta
		if parry_timer <= 0:
			reset_parry()
			spin_speed -= parry_cost
			print(name, " parry whiffed")
	   
	if launched:
		velocity *= 0.98
		var center = get_viewport_rect().size / 2
		var to_center = center - global_position
		var dist = to_center.length()
		velocity += to_center.normalized() * (dist * 0.1)
		velocity += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * spin_speed * 0.5
	
	var size = get_viewport_rect().size
	var buffer = 10.0
	if position.x < buffer:
		position.x = buffer + (buffer - position.x)
		velocity.x = abs(velocity.x)
	if position.x > size.x - buffer:
		position.x = (size.x - buffer) - (position.x - (size.x - buffer))
		velocity.x = -abs(velocity.x)
	if position.y < buffer:
		position.y = buffer + (buffer - position.y)
		velocity.y = abs(velocity.y)
	if position.y > size.y - buffer:
		position.y = (size.y - buffer) - (position.y - (size.y - buffer))
		velocity.y = -abs(velocity.y)

	if abs(spin_speed) < 7.0 and launched:
		spin_speed = 0.0
		emit_signal("beyblade_stopped")

func take_hit(spin_reduction: float, speed_reduction: float):
	spin_speed *= 1.0 - spin_reduction
	velocity *= 1.0 - speed_reduction

func _on_hit(other):
	if spin_speed < other.spin_speed:
		if is_parrying():
			reset_parry()
			var bonus = other.spin_speed * 0.3
			spin_speed += bonus
			other.take_hit(0.15, 0.05)
			@warning_ignore("confusable_local_declaration")
			var dir = (other.global_position - global_position).normalized()
			other.velocity += -dir * other.spin_speed * 500.0
			print(name, " parried ", other.name)
		return
	
	print(name, " hit ", other.name)
	var dir = (other.global_position - global_position).normalized()
	var tangent = Vector2(-dir.y, dir.x)
	var power = spin_speed * randf_range(0.8, 1.2)
	var bounce = -dir * power * 100.0
	var spin_deflect = tangent * power * 15.0
	velocity += bounce + spin_deflect
	other.velocity += -bounce - spin_deflect
	take_hit(0.09, 0.02)
	other.take_hit(0.1, 0.05)

func is_parrying() -> bool:
	return parrying

func start_parry():
	parrying = true
	parry_timer = parry_duration
	modulate = Color(0.0, 1.0, 1.0)
	print(name, " parrying!")

func reset_parry():
	parrying = false
	parry_timer = 0.0
	modulate = Color(1, 1, 1)

func launch():
	launched = true
	velocity = Vector2.from_angle(rotation) * spin_speed * 50.0

func freeze():
	spin_speed = 0.0
	velocity = Vector2.ZERO
	frozen = true
