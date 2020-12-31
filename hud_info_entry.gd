extends HBoxContainer
class_name HudInfoEntry

export(int) var particle_type = Globals.ParticleType.PROTEIN_WHITE setget _set_particle_type
export(int) var count = 0 setget _set_count

func _set_particle_type(value: int):
	particle_type = value
	$TextureRect.texture = Globals.particle_type_get_res(value)

func _set_count(value: int):
	count = value
	$Label.text = str(value)
	visible = value > 0
