extends KinematicBody2D
class_name CellParticle

var velo_abs = 1000;
var velocity = Vector2(-1000, 0)
export var type = Globals.ParticleType.PROTEIN_WHITE setget _set_type, _get_type

onready var collision_shape = get_node("CollisionShape2D").shape as CircleShape2D
onready var collision_radius = collision_shape.radius setget _set_collision_radius, _get_collision_radius

func _physics_process(delta):
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	if collision != null:
		var reflect = collision.remainder.bounce(collision.normal)
		velocity = (velocity.bounce(collision.normal) + Vector2(Rules.rng.randf(), Rules.rng.randf()) * velocity.length() / 2).normalized() * velo_abs
		collision = move_and_collide(reflect)

func _set_collision_radius(v):
	collision_shape.radius = v
	
func _get_collision_radius():
	return 20 # collision_shape.radius

func _set_type(type_: int):
	type = type_
	var image_name = "white_prot"
	match type:
		Globals.ParticleType.PROTEIN_TRANSPORTER:
			image_name = "transporter"
		Globals.ParticleType.ENZYME_ALCOHOL:
			image_name = "yellow_enzyme"
		Globals.ParticleType.ENZYME_LYE:
			image_name = "blue_enzyme"
		Globals.ParticleType.QUEEN:
			image_name = "purple_ribosome"
		Globals.ParticleType.PRO_QUEEN:
			image_name = "pink_ribosome"
		Globals.ParticleType.AMINO_PHE:
			image_name = "green_amino"
		Globals.ParticleType.AMINO_ALA:
			image_name = "yellow_amino"
		Globals.ParticleType.AMINO_LYS:
			image_name = "blue_amino"
		Globals.ParticleType.AMINO_TYR:
			image_name = "purple_amino"
		Globals.ParticleType.AMINO_PRO:
			image_name = "pink_amino"
		Globals.ParticleType.SUGAR:
			image_name = "sugar"
		Globals.ParticleType.RIBOSOME_TRANSPORTER:
			image_name = "green_ribosome"
		Globals.ParticleType.RIBOSOME_ALCOHOL:
			image_name = "yellow_ribosome"
		Globals.ParticleType.RIBOSOME_LYE:
			image_name = "blue_ribosome"
	if Globals.particle_type_is_in_transporter(type):
		$InnerSprite.texture = load("res://textures/%s.png" % image_name)
		$Sprite.texture = load("res://textures/transporter.png")
	else:
		$InnerSprite.texture = null
		$Sprite.texture = load("res://textures/%s.png" % image_name)

func _get_type() -> int:
	return type
