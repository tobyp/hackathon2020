extends Node

var rng: RandomNumberGenerator
var debug_visual: bool = false
var _selected_cells = []

func _ready():
	_init_recipes()
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
		# Bootstrap by creating a transporter from a queen
		Recipe.new({ Globals.ParticleType.QUEEN: 1, }, { Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }),

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
		Recipe.new({ Globals.ParticleType.ANTI_MITOCHONDRION: 1, Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.SUGAR: 1, }, true, 0.05),
	];

static func new_tech_tree() -> Array:
	var ring_list = [
		# Ring 0 (Our starting cell)
		[Tech.new(Globals.TechType.INIT, 1, 1, 1, true)],
		# Ring 1
		[Tech.new(Globals.TechType.SUGAR_CELL, 1, 1, 1, true)],
		# Ring 2
		[Tech.new(Globals.TechType.SUGAR_CELL, 1, 1, 0.2, true), Tech.new(Globals.TechType.DEBUG_PARTICLES, 1, 2, 0.4) ],
		# Ring 3
		[Tech.new(Globals.TechType.SUGAR_CELL, 1, 2, 0.1, true)],
	];
	for ring in ring_list:
		ring.append(Tech.new(Globals.TechType.NONE, -1, -1, 1))
	return ring_list

# Gets called to initialize an undiscovered/uncaptured Cell
static func apply_tech(tech_type: int, cell: Cell):
	match tech_type:
		Globals.TechType.INIT:
			cell.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
			cell.add_particles(Globals.ParticleType.PROTEIN_WHITE, 40)
			cell.add_particles(Globals.ParticleType.AMINO_PHE, 1)
		Globals.TechType.SUGAR_CELL:
			cell.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
			cell.set_input_allowed([Globals.ParticleType.PROTEIN_TRANSPORTER])
			cell.add_particles(Globals.ParticleType.ANTI_MITOCHONDRION, 1)
			cell.type = Globals.CellType.RESOURCE
		Globals.TechType.POISON_ALCOHOL:
			cell.set_poison(Globals.PoisonType.ALCOHOL, 1.0)
		Globals.TechType.POISON_LYE:
			cell.set_poison(Globals.PoisonType.LYE, 1.0)
		Globals.TechType.DEBUG_PARTICLES:
			cell.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
			cell.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)

static func sugar_requirement(type: int) -> float:
	return 0.05

# Which particles have tunnels
const TUNNEL_TYPES: Array = [
	Globals.ParticleType.PROTEIN_WHITE,
	Globals.ParticleType.PROTEIN_TRANSPORTER,
	Globals.ParticleType.ENZYME_ALCOHOL,
	Globals.ParticleType.ENZYME_LYE,
	Globals.ParticleType.AMINO_PHE,
	Globals.ParticleType.AMINO_ALA,
	Globals.ParticleType.AMINO_LYS,
	Globals.ParticleType.AMINO_TYR,
	Globals.ParticleType.AMINO_PRO,
	Globals.ParticleType.SUGAR,
]

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
	#Globals.ParticleType.RIBOSOME_TRANSPORTER,
	#Globals.ParticleType.RIBOSOME_ALCOHOL,
	#Globals.ParticleType.RIBOSOME_LYE,
	#Globals.ParticleType.PRO_QUEEN,
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

static func particle_type_poison_susceptible(particle: int, poison: int) -> bool:
	match particle:
		Globals.ParticleType.POISON_ALCOHOL, Globals.ParticleType.POISON_LYE, Globals.ParticleType.POISON_LYE, Globals.ParticleType.ANTI_MITOCHONDRION:
			return false
	return true

# calculate pressure between own cell (having `own` particles) and another cell (having `other` particles).
# There's a lot of tuning to be had here.
# If the result is <= 0, no particles will be transferred
# Pressures will be normalized together with the pressures against other cells to calculate diffusion weights (weight in diffuse_func).
static func pressure_func(own: float, other: float) -> float:
	# Output rules will always take, but become very slow quickly when the other cell has more than us.
	# Tip: calculate for 0, 10 and 100 and see how that goes.
	var differential = own - other
	return differential * differential / 10

# how many particles to send from a cell with `supply` particles inside, given the `total_pressure` of all neighbors is 
static func budget_func(supply: int, total_pressure: float) -> float:
	# if the pressure is weak (about 1), we send about a third.
	# use a sigmoid here: at pressure 1.5, we send a half; higher we approach all, lower we approach none.
	return supply * 1 / (1 + exp(-total_pressure - 1.5))  # x-shifted logistics function

# Calculate diffuse rate (number of particles to send per second), given a `budget` of cells that could be sent, and a `normalized_pressure` weight from 0 to 1
# normalized_pressure sums to 1 for all (positive) pressures going out of the cell.
# There's a lot of tuning to be had on the constants here.
static func diffuse_func(budget: int, normalized_pressure: float, total_pressure: float) -> float:
	# for debugging, here's a very slow and even diffuse function that makes it easily visible
	# normalized_pressure is simply used to split the budget between neightbors proportionally to pressure.
	# the 0.1 is the total diffusion rate
	return budget * normalized_pressure * total_pressure
	# this exponential will make diffusion go faster if the differential pressure is higher
	# return budget * 0.55 * exp(-4 * demand) * delta

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_F1:
				debug_visual = not debug_visual

func select_cell(cell):
	for oldcell in _selected_cells:
		oldcell.selected = false
	_selected_cells = [cell]
	cell.selected = true
