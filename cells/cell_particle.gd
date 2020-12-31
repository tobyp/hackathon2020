extends KinematicBody2D
class_name CellParticle

var velocity = Vector2(0, 0)
var _time = 0.0

export var type = Globals.ParticleType.PROTEIN_WHITE setget _set_type, _get_type

onready var collision_shape = get_node("CollisionShape2D").shape as CircleShape2D
onready var collision_radius = collision_shape.radius setget _set_collision_radius, _get_collision_radius

func set_texture_material(mat: Material):
	$Sprite.material = mat

func _physics_process(delta):
	if Rules.particle_type_render_hover_center(type):
		# Move a little random
		_time += delta
		position = Vector2(sin(_time * 0.3) * sin(_time), cos(_time * 0.3) * sin(_time * 0.4)) * 30
	elif Rules.particle_type_render_orbit_center(type):
		_time += delta
		position = Vector2(200 + 5 * sin(_time * 2.1) * cos(_time), 0).rotated(_time * 0.5)
	else:
		var motion = velocity * delta
		var collision = move_and_collide(motion)
		if collision != null:
			var reflect = collision.remainder.bounce(collision.normal)
			# This is a Box-Muller transform, to get a normal distributed sample
			var phi = deg2rad(sqrt(-1 * log(Rules.rng.randf())) * cos(2 * PI * Rules.rng.randf()))
			velocity = velocity.bounce(collision.normal).rotated(phi)
			collision = move_and_collide(reflect)

func _set_collision_radius(v):
	collision_shape.radius = v
	
func _get_collision_radius():
	return 20 # collision_shape.radius

func _set_type(type_: int):
	type = type_
	var tex = Globals.particle_type_get_res(type)
	scale = Vector2(1, 1)
	$InnerSprite.scale = Vector2(1, 1)

	match type:
		Globals.ParticleType.SUGAR:
			$InnerSprite.scale = Vector2(0.2, 0.2)
		Globals.ParticleType.ANTI_MITOCHONDRION:
			scale = Vector2(5, 5)
		Globals.ParticleType.POISON_ALCOHOL, Globals.ParticleType.POISON_LYE, Globals.ParticleType.POISON_PLUTONIUM:
			scale = Vector2(2.5, 2.5)
		Globals.ParticleType.RESOURCE_AMINO_ALA, Globals.ParticleType.RESOURCE_AMINO_LYS, Globals.ParticleType.RESOURCE_AMINO_PHE, Globals.ParticleType.RESOURCE_AMINO_PRO, Globals.ParticleType.RESOURCE_AMINO_TYR:
			scale = Vector2(10, 10)

	if Rules.particle_type_is_in_transporter(type):
		$InnerSprite.texture = tex
		$Sprite.texture = preload("res://textures/green_enzyme.png")
	else:
		$InnerSprite.texture = null
		$Sprite.texture = tex

func _get_type() -> int:
	return type
