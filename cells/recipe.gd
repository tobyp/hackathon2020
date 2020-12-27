class_name Recipe

var inputs = {}
var outputs = {}
var automatic: bool
var _output_has_factory: bool = false

static func matches(particle_counts: Dictionary) -> Array:
	var rs = []
	for r in Rules.ALL_RECIPES:
		if r.recipe_matches(particle_counts):
			rs.push_back(r)
	return rs

func _init(input: Dictionary, output: Dictionary, auto: bool = false):
	self.inputs = input
	self.outputs = output
	self.automatic = auto
	for t in outputs:
		if Globals.particle_type_is_factory(t):
			_output_has_factory = true
			break

func recipe_matches(particle_counts: Dictionary) -> bool:
	for t in Globals.ParticleType.values():
		if inputs.has(t) and particle_counts[t] < inputs[t]:
			return false
		# Only one factory type per cell is allowed
		if _output_has_factory and Globals.particle_type_is_factory(t) and !outputs.has(t):
			return false
	return true
