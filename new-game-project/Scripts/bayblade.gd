extends Node2D

var shootable = true

var spin_speed = 0.0
var last_angle = null
var velocity = Vector2.ZERO

# stats - override these in subclasses
var spin_reduction_on_hit = 0.05
var speed_reduction_on_hit = 0.02
var spin_efficiency = 0.2  # how well mouse input converts to spin

func _ready():
	connect("area_entered", _on_hit)
	print("Connected!", name)
	add_to_group("beyblades")

func _process(delta):
	rotation += spin_speed * delta
	position += velocity * delta
	
	if shootable == true:
		return

	# steer toward nearest other beyblade
	var others = get_tree().get_nodes_in_group("beyblades")
	var nearest = null
	var nearest_dist = INF
	for b in others:
		if b == self:
			continue
		var dist = global_position.distance_to(b.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = b
	if nearest:
		var dir = (nearest.global_position - global_position).normalized()
		velocity += dir * 20.0
	var size = get_viewport_rect().size
	if position.x < 10 or position.x > size.x - 10.0:
		velocity.x *= -1
		take_hit(spin_reduction_on_hit, speed_reduction_on_hit)
	if position.y < 10 or position.y > size.y - 10.0:
		velocity.y *= -1
		take_hit(spin_reduction_on_hit, speed_reduction_on_hit)

func take_hit(spin_reduction: float, speed_reduction: float):
	spin_speed *= 1.0 - spin_reduction
	velocity *= 1.0 - speed_reduction

func _on_hit(other):
# only the faster spinner resolves the collision
	if spin_speed < other.spin_speed:
		return
	
	print(name, " hit ", other.name)
		
	var dir = (other.global_position - global_position).normalized()
	var power = spin_speed - other.spin_speed  # difference = impact force
		
	velocity -= dir * power * 75.0
	other.velocity += dir * power * 75.0
	
	take_hit(0.05, 0.02)
	other.take_hit(0.1, 0.05)  # loser takes more damage
