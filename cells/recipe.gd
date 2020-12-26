class_name Recipe

var inputs = {}
var output: int

static func matches(particle_counts: Dictionary) -> Array:
	var this = load("res://cells/recipe.gd")
	var ALL_RECIPES = [
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 100 }, Globals.ParticleType.AMINO_PHE)
	];

	var rs = []
	for r in ALL_RECIPES:
		if r.recipe_matches(particle_counts):
			rs.push_back(r)
	return rs

func _init(inputs: Dictionary, output: int):
	self.inputs = inputs
	self.output = output

func recipe_matches(particle_counts: Dictionary) -> bool:
	for t in Globals.ParticleType:
		if inputs.has(int(t)) or particle_counts[t] < inputs[t]:
			return false
	return true
	
func subtract_resources(particle_counts: Dictionary):
	for t in Globals.ParticleType:
		if inputs.has(int(t)) or particle_counts[t] < inputs[t]:
			print("Cannot craft…")
		else:
			particle_counts[t] -= inputs[t]
