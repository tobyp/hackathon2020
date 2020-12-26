extends KinematicBody2D
class_name CellParticle

var velo_abs = 1000;
var velocity = Vector2(-1000, 0)
var rng = RandomNumberGenerator.new()

onready var collision_shape = get_node("CollisionShape2D").shape as CircleShape2D
onready var collision_radius = collision_shape.radius setget _set_collision_radius, _get_collision_radius

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func _physics_process(delta):
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	if collision != null:
		var reflect = collision.remainder.bounce(collision.normal)
		velocity = (velocity.bounce(collision.normal) + Vector2(rng.randf(), rng.randf()) * velocity.length() / 2).normalized() * velo_abs
		collision = move_and_collide(reflect)

func _set_collision_radius(v):
	collision_shape.radius = v
	
func _get_collision_radius():
	return 20 # collision_shape.radius
