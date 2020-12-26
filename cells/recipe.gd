class_name Recipe

var inputs = {}
var output: int

static func matches(particle_counts: Dictionary) -> Array:
	var this = load("res://cells/recipe.gd")
	var ALL_RECIPES = [
		this.new({ Globals.ParticleType.QUEEN: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.PROTEIN_TRANSPORTER),
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 1, Globals.ParticleType.AMINO_PHE: 1, }, Globals.ParticleType.RIBOSOME_TRANSPORTER),
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 1, Globals.ParticleType.AMINO_LYS: 1, }, Globals.ParticleType.RIBOSOME_LYE),

		# Auto recipes
		#this.new({ Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.PROTEIN_TRANSPORTER),
		#this.new({ Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.ENZYME_ALCOHOL),
		#this.new({ Globals.ParticleType.RIBOSOME_LYE: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.ENZYME_LYE),

		this.new({ Globals.ParticleType.PROTEIN_WHITE: 100, Globals.ParticleType.AMINO_TYR: 1, }, Globals.ParticleType.QUEEN),
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 1000, Globals.ParticleType.AMINO_PRO: 1, }, Globals.ParticleType.PRO_QUEEN),
	];

	var rs = []
	for r in ALL_RECIPES:
		if r.recipe_matches(particle_counts):
			rs.push_back(r)
	return rs

func _init(input: Dictionary, outpu: int):
	self.inputs = input
	self.output = outpu

func recipe_matches(particle_counts: Dictionary) -> bool:
	for t in Globals.ParticleType.values():
		if inputs.has(int(t)) or particle_counts[t] < inputs[t]:
			return false
	return true
	
func subtract_resources(particle_counts: Dictionary):
	for t in Globals.ParticleType.values():
		if inputs.has(int(t)) or particle_counts[t] < inputs[t]:
			print("Cannot craft…")
		elif !Globals.particle_type_is_factory(t):
			# Factories are not used
			particle_counts[t] -= inputs[t]
