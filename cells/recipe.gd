class_name Recipe

var inputs = {}
var output: int
var automatic: bool

static func matches(particle_counts: Dictionary) -> Array:
	var rs = []
	for r in Rules.ALL_RECIPES:
		if r.recipe_matches(particle_counts):
			rs.push_back(r)
	return rs

func _init(input: Dictionary, outpu: int, auto: bool = false):
	self.inputs = input
	self.output = outpu
	self.automatic = auto

func recipe_matches(particle_counts: Dictionary) -> bool:
	for t in Globals.ParticleType.values():
		if inputs.has(t) and particle_counts[t] < inputs[t]:
			return false
	return true
	
func subtract_resources(particle_counts: Dictionary):
	for t in Globals.ParticleType.values():
		if inputs.has(t):
			if particle_counts[t] < inputs[t]:
				print("Cannot craft…")
			elif !Globals.particle_type_is_factory(t):
				# Factories are not used
				particle_counts[t] -= inputs[t]
