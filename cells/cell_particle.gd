extends KinematicBody2D
class_name CellParticle

var velo_abs = 1000;
var velocity = Vector2(-1000, 0)
var rng = RandomNumberGenerator.new()
export var type = Globals.ParticleType.PROTEIN_WHITE setget _set_type, _get_type

onready var collision_shape = get_node("CollisionShape2D").shape as CircleShape2D
onready var collision_radius = collision_shape.radius setget _set_collision_radius, _get_collision_radius

func set_type(type: int):
	match type:
		Globals.ParticleType.PROTEIN_WHITE:
			$Sprite.texture = load("res://textures/white_prot.png")
		Globals.ParticleType.PROTEIN_TRANSPORTER:
			$Sprite.texture = load("res://textures/green_enzyme.png")
		Globals.ParticleType.ENZYME_ALCOHOL:
			$Sprite.texture = load("res://textures/yellow_enzyme.png")
		Globals.ParticleType.ENZYME_LYE:
			$Sprite.texture = load("res://textures/blue_enzyme.png")
		Globals.ParticleType.QUEEN:
			$Sprite.texture = load("res://textures/purple_ribosome.png")
		Globals.ParticleType.PRO_QUEEN:
			$Sprite.texture = load("res://textures/pink_ribosome.png")
		Globals.ParticleType.AMINO_PHE:
			$Sprite.texture = load("res://textures/green_amino.png")
		Globals.ParticleType.AMINO_ALA:
			$Sprite.texture = load("res://textures/yellow_amino.png")
		Globals.ParticleType.AMINO_LYS:
			$Sprite.texture = load("res://textures/blue_amino.png")
		Globals.ParticleType.AMINO_TYR:
			$Sprite.texture = load("res://textures/purple_amino.png")
		Globals.ParticleType.AMINO_PRO:
			$Sprite.texture = load("res://textures/pink_amino.png")
		Globals.ParticleType.SUGAR:
			$Sprite.texture = load("res://textures/sugar.png")
		Globals.ParticleType.RIBOSOME_TRANSPORTER:
			$Sprite.texture = load("res://textures/green_ribosome.png")
		Globals.ParticleType.RIBOSOME_ALCOHOL:
			$Sprite.texture = load("res://textures/yellow_ribosome.png")
		Globals.ParticleType.RIBOSOME_LYE:
			$Sprite.texture = load("res://textures/blue_ribosome.png")

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

func _set_type(type_: int):
	type = type_
	match type:
		Globals.ParticleType.RIBOSOME_TRANSPORTER:
			get_node("Sprite").texture = load("res://textures/green_ribosome.png")
		_:
			get_node("Sprite").texture = load("res://textures/white_prot.png")

func _get_type() -> int:
	return type
