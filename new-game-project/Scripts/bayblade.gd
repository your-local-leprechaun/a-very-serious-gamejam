extends Node2D

signal beyblade_stopped

var spin_speed = 0.0
var last_angle = null
var velocity = Vector2.ZERO

var frozen = false

var shootable = false

var launched = false

# stats - override these in subclasses
var spin_reduction_on_hit = 0.05
var speed_reduction_on_hit = 0.02
var spin_efficiency = 0.2  # how well mouse input converts to spin

func _ready():
	connect("area_entered", _on_hit)

func _process(delta):
	if frozen:
		return
	#spin_speed *= 0.999  # spin decays very slowly
	rotation += spin_speed * delta
	position += velocity * delta
	if launched:
		velocity *= 0.98

		# pull toward center gets stronger the further out they are
		var center = get_viewport_rect().size / 2
		var to_center = center - global_position
		var dist = to_center.length()
		velocity += to_center.normalized() * (dist * 0.1)  # scales with distance

		# tiny random drift for organic movement
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
	
	# Check for Spin Win
	if abs(spin_speed) < 7.0 and launched:
		spin_speed = 0.0
		emit_signal("beyblade_stopped")

func take_hit(spin_reduction: float, speed_reduction: float):
	spin_speed *= 1.0 - spin_reduction
	velocity *= 1.0 - speed_reduction

func _on_hit(other):
	if spin_speed < other.spin_speed:
		return
	
	print(name, " hit ", other.name)
	
	var dir = (other.global_position - global_position).normalized()
	var tangent = Vector2(-dir.y, dir.x)
	
	var power = spin_speed * randf_range(0.8, 1.2)  # randomness factor
	
	var bounce = -dir * power * 100.0
	var spin_deflect = tangent * power * 15.0
	
	velocity += bounce + spin_deflect
	other.velocity += -bounce - spin_deflect
	
	take_hit(0.09, 0.02)
	other.take_hit(0.1, 0.05)

func launch():
	launched = true
	velocity = Vector2.from_angle(rotation) * spin_speed * 50.0

func freeze():
	spin_speed = 0.0
	velocity = Vector2.ZERO
	frozen = true
