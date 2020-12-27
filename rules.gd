extends Node

var rng

func _ready():
	_init_recipes()
	_init_tech()
	rng = RandomNumberGenerator.new()
	rng.randomize()

var ALL_RECIPES
func _init_recipes():
	self.ALL_RECIPES = [
		Recipe.new({ Globals.ParticleType.QUEEN: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.PROTEIN_TRANSPORTER),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1, Globals.ParticleType.AMINO_PHE: 1, }, Globals.ParticleType.RIBOSOME_TRANSPORTER),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1, Globals.ParticleType.AMINO_LYS: 1, }, Globals.ParticleType.RIBOSOME_LYE),

		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 100, Globals.ParticleType.AMINO_TYR: 1, }, Globals.ParticleType.QUEEN),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1000, Globals.ParticleType.AMINO_PRO: 1, }, Globals.ParticleType.PRO_QUEEN),

		# Auto recipes
		Recipe.new({ Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.PROTEIN_TRANSPORTER, true),
		Recipe.new({ Globals.ParticleType.RIBOSOME_ALCOHOL: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.ENZYME_ALCOHOL, true),
		Recipe.new({ Globals.ParticleType.RIBOSOME_LYE: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, Globals.ParticleType.ENZYME_LYE, true),
		Recipe.new({ Globals.ParticleType.ANTI_MITOCHONDRION: 1, Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, Globals.ParticleType.SUGAR, true),
	];

var TECH_LIST
var TECH_DICT
func _init_tech():
	self.TECH_LIST = [
		Tech.new(Globals.TechType.A, [Globals.TechType.B, Globals.TechType.C]),
		Tech.new(Globals.TechType.B, [Globals.TechType.D]),
		Tech.new(Globals.TechType.C, [Globals.TechType.E, Globals.TechType.F]),
	];
	self.TECH_DICT = {}
	for tech in TECH_LIST:
		TECH_DICT[tech.tech] = tech
