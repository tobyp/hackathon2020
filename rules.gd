extends Node

var rng: RandomNumberGenerator
var debug_visual: bool = false

func _ready():
	_init_recipes()
	_init_tech()
	rng = RandomNumberGenerator.new()
	rng.randomize()

var ALL_RECIPES
func _init_recipes():
	self.ALL_RECIPES = [
		# Building ribosomes
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 10, Globals.ParticleType.AMINO_PHE: 1, }, { Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, }),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 25, Globals.ParticleType.AMINO_ALA: 1, }, { Globals.ParticleType.RIBOSOME_ALCOHOL: 1, }),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 40, Globals.ParticleType.AMINO_LYS: 1, }, { Globals.ParticleType.RIBOSOME_LYE: 1, }),
		# Building Queens
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 100, Globals.ParticleType.AMINO_TYR: 1, }, { Globals.ParticleType.QUEEN: 1, }),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1000, Globals.ParticleType.AMINO_PRO: 1, }, { Globals.ParticleType.PRO_QUEEN: 1, }),

		# Auto recipes
		# Creating White Protein
		Recipe.new({ Globals.ParticleType.QUEEN: 1, Globals.ParticleType.SUGAR: 1, }, { Globals.ParticleType.PROTEIN_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, true),
		# Creating Queens
		Recipe.new({ Globals.ParticleType.PRO_QUEEN: 1, Globals.ParticleType.PROTEIN_WHITE: 10, }, { Globals.ParticleType.QUEEN: 1, }, true),
		# Creating Enzymes
		Recipe.new({ Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, true),
		Recipe.new({ Globals.ParticleType.RIBOSOME_ALCOHOL: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.ENZYME_ALCOHOL: 1, }, true),
		Recipe.new({ Globals.ParticleType.RIBOSOME_LYE: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.ENZYME_LYE: 1, }, true),
		# Creating Resources
		Recipe.new({ Globals.ParticleType.ANTI_MITOCHONDRION: 1, Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.SUGAR: 1, }, true),
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


static func sugar_requirement(type: int) -> float:
	return 0.01

# The order in which particles get destroyed if there is not enough sugar.
const SUGAR_DEATH_ORDER: Array = [
	Globals.ParticleType.SUGAR,
	Globals.ParticleType.PROTEIN_WHITE,
	Globals.ParticleType.AMINO_PHE,
	Globals.ParticleType.AMINO_ALA,
	Globals.ParticleType.AMINO_LYS,
	Globals.ParticleType.AMINO_TYR,
	Globals.ParticleType.AMINO_PRO,
	Globals.ParticleType.ENZYME_ALCOHOL,
	Globals.ParticleType.ENZYME_LYE,
	Globals.ParticleType.PROTEIN_TRANSPORTER,
	Globals.ParticleType.RIBOSOME_TRANSPORTER,
	Globals.ParticleType.RIBOSOME_ALCOHOL,
	Globals.ParticleType.RIBOSOME_LYE,
	Globals.ParticleType.PRO_QUEEN,
];

static func particle_type_get_poison_potency(particle: int, poison: int, poisons: Dictionary) -> float:
	match particle:
		Globals.ParticleType.ENZYME_ALCOHOL:
			if poison == Globals.PoisonType.ALCOHOL:
				return 1.0 / 50.0
		Globals.ParticleType.ENZYME_LYE:
			if poison == Globals.PoisonType.LYE:
				return 1.0/100.0
		Globals.ParticleType.PROTEIN_WHITE:
			if poison == Globals.PoisonType.ANTI_BIOMASS and poisons.size() == 1:  # this only works if there are no other poisons
				return 1.0/25.0
	return 0.0

# Calculate how many particles to send, in `delta` seconds, given a `budget` of cells that could be sent, and a `demand` weight from 0 to 1
# There's a lot of tuning to be had on the constants here.
static func diffuse_func(budget: int, demand: float, delta: float) -> float:
	# for debugging, here's a very slow and even diffuse function that makes it easily visible
	return budget * demand * 0.1 * delta
	# this exponential will make diffusion go faster if the differential pressure is higher
	# return budget * 0.55 * exp(-4 * demand) * delta

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_F1:
				debug_visual = not debug_visual
