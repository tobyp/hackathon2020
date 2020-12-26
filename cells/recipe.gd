class_name Recipe

### MEMBERS
var inputs = {}
var output: int

static func matches(particle_counts: Dictionary) -> Array:
	var this = load("res://cells/recipe.gd")
	var ALL_RECIPES = [
		this.new({ CellParticle.ParticleType.PARTICLE_PROTEIN_WHITE: 100 }, CellParticle.ParticleType.PARTICLE_ENZYME_GREEN)
	];

	var rs = []
	for r in ALL_RECIPES:
		if r.recipe_matches(particle_counts):
			rs.push_back(r)
	return rs

static func get_particle_type_name(particle: int) -> String:
	match particle:
		CellParticle.ParticleType.PARTICLE_PROTEIN_WHITE:
			return "Generic Protein"
		CellParticle.ParticleType.PARTICLE_ENZYME_PINK:
			return "Prolin"
		CellParticle.ParticleType.PARTICLE_ENZYME_PURPLE:
			return "Tyrosin"
		CellParticle.ParticleType.PARTICLE_ENZYME_GREEN:
			return "Phenylalanin"
		CellParticle.ParticleType.PARTICLE_ENZYME_YELLOW:
			return "Alanin"
	return "Unknown"

func _init(inputs: Dictionary, output: int):
	self.inputs = inputs
	self.output = output

func recipe_matches(particle_counts: Dictionary) -> bool:
	for t in CellParticle.ParticleType:
		if inputs.has(int(t)) or particle_counts[t] < inputs[t]:
			return false
	return true
	
func subtract_resources(particle_counts: Dictionary):
	for t in CellParticle.ParticleType:
		if inputs.has(int(t)) or particle_counts[t] < inputs[t]:
			print("Cannot craft…")
		else:
			particle_counts[t] -= inputs[t]
