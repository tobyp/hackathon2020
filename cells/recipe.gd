class_name Recipe

var inputs = {}
var output: int
var automatic: bool

static func matches(particle_counts: Dictionary) -> Array:
	var this = load("res://cells/recipe.gd")
	var ALL_RECIPES = [
		this.new({ Globals.ParticleType.QUEEN: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.PROTEIN_TRANSPORTER),
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 1, Globals.ParticleType.AMINO_PHE: 1, }, Globals.ParticleType.RIBOSOME_TRANSPORTER),
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 1, Globals.ParticleType.AMINO_LYS: 1, }, Globals.ParticleType.RIBOSOME_LYE),

		this.new({ Globals.ParticleType.PROTEIN_WHITE: 100, Globals.ParticleType.AMINO_TYR: 1, }, Globals.ParticleType.QUEEN),
		this.new({ Globals.ParticleType.PROTEIN_WHITE: 1000, Globals.ParticleType.AMINO_PRO: 1, }, Globals.ParticleType.PRO_QUEEN),

		# Auto recipes
		this.new({ Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.PROTEIN_TRANSPORTER, true),
		this.new({ Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.ENZYME_ALCOHOL, true),
		this.new({ Globals.ParticleType.RIBOSOME_LYE: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.ENZYME_LYE, true),
		this.new({ Globals.ParticleType.ANTI_MITOCHONTRION: 1, Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, Globals.ParticleType.SUGAR, true),
	];

	var rs = []
	for r in ALL_RECIPES:
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
