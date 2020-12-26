extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velo_abs = 1000;
var velocity = Vector2(-1000, 0)
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	if collision != null:
		var reflect = collision.remainder.bounce(collision.normal)
		
		velocity = (velocity.bounce(collision.normal) + Vector2(rng.randf(), rng.randf()) * velocity.length() / 2).normalized() * velo_abs
		move_and_collide(reflect)
