extends Node

var rng: RandomNumberGenerator
var debug_visual: bool = false

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
		Recipe.new({}, { Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, {  Globals.ParticleType.QUEEN: 1, }),

		# Auto recipes
		# Creating White Protein
		Recipe.new({ Globals.ParticleType.SUGAR: 1, }, { Globals.ParticleType.PROTEIN_TRANSPORTER: 1, Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.QUEEN: 1, }, true),
		# Creating Queens
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 10, }, { Globals.ParticleType.QUEEN: 1, }, { Globals.ParticleType.PRO_QUEEN: 1, }, true),
		# Creating Enzymes
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.RIBOSOME_TRANSPORTER: 1, }, true),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.ENZYME_ALCOHOL: 1, }, { Globals.ParticleType.RIBOSOME_ALCOHOL: 1, }, true),
		Recipe.new({ Globals.ParticleType.PROTEIN_WHITE: 1, }, { Globals.ParticleType.ENZYME_LYE: 1, }, { Globals.ParticleType.RIBOSOME_LYE: 1, }, true),
		# Creating Resources
		Recipe.new({ Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.SUGAR: 1, }, { Globals.ParticleType.ANTI_MITOCHONDRION: 1, }, true, 0.05),
		Recipe.new({ Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.AMINO_ALA: 1, }, { Globals.ParticleType.RESOURCE_AMINO_ALA: 1, }, true, 30.0),
		Recipe.new({ Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.AMINO_LYS: 1, }, { Globals.ParticleType.RESOURCE_AMINO_LYS: 1, }, true, 40.0),
		Recipe.new({ Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.AMINO_PHE: 1, }, { Globals.ParticleType.RESOURCE_AMINO_PHE: 1, }, true, 60.0),
		Recipe.new({ Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.AMINO_PRO: 1, }, { Globals.ParticleType.RESOURCE_AMINO_PRO: 1, }, true, 90.0),
		Recipe.new({ Globals.ParticleType.PROTEIN_TRANSPORTER: 1, }, { Globals.ParticleType.AMINO_TYR: 1, }, { Globals.ParticleType.RESOURCE_AMINO_TYR: 1, }, true, 200.0),
		
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
			cell.init_captured()
			cell.add_particles(Globals.ParticleType.PROTEIN_WHITE, 40)
			cell.add_particles(Globals.ParticleType.AMINO_PHE, 1)
		Globals.TechType.SUGAR_CELL:
			cell.init_resource(Globals.ParticleType.ANTI_MITOCHONDRION)
		Globals.TechType.POISON_ALCOHOL:
			cell.init_toxin(Globals.ToxinType.ALCOHOL)
		Globals.TechType.POISON_LYE:
			cell.init_toxin(Globals.ToxinType.LYE)
		Globals.TechType.DEBUG_PARTICLES:
			cell.init_captured()
			cell.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)
		_:
			cell.init_empty()

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
]

static func particle_type_get_toxin_potency(particle: int, toxin: int, toxins: Dictionary) -> float:
	match particle:
		Globals.ParticleType.ENZYME_ALCOHOL:
			if toxin == Globals.ToxinType.ALCOHOL:
				return 1.0 / 50.0
		Globals.ParticleType.ENZYME_LYE:
			if toxin == Globals.ToxinType.LYE:
				return 1.0/100.0
		Globals.ParticleType.PROTEIN_WHITE:
			if toxin == Globals.ToxinType.ANTI_BIOMASS and toxins.size() == 1:  # this only works if there are no other toxins
				return 1.0/25.0
	return 0.0

static func particle_type_toxin_susceptible(particle: int, toxin: int) -> bool:
	match particle:
		Globals.ParticleType.POISON_ALCOHOL, Globals.ParticleType.POISON_LYE, Globals.ParticleType.POISON_LYE, Globals.ParticleType.ANTI_MITOCHONDRION, Globals.ParticleType.RESOURCE_AMINO_PHE, Globals.ParticleType.RESOURCE_AMINO_ALA, Globals.ParticleType.RESOURCE_AMINO_LYS, Globals.ParticleType.RESOURCE_AMINO_TYR, Globals.ParticleType.RESOURCE_AMINO_PRO:
			return false
	return true

static func particle_type_z_index(particle: int) -> float:
	match particle:
		Globals.ParticleType.PROTEIN_WHITE:
			return 0.0
		Globals.ParticleType.PROTEIN_TRANSPORTER, Globals.ParticleType.ENZYME_ALCOHOL, Globals.ParticleType.ENZYME_LYE:
			return 1.0
		Globals.ParticleType.SUGAR:
			return 2.0
		Globals.ParticleType.AMINO_PHE, Globals.ParticleType.AMINO_ALA, Globals.ParticleType.AMINO_LYS, Globals.ParticleType.AMINO_TYR, Globals.ParticleType.AMINO_PRO:
			return 3.0
		Globals.ParticleType.QUEEN, Globals.ParticleType.PRO_QUEEN, Globals.ParticleType.RIBOSOME_TRANSPORTER, Globals.ParticleType.RIBOSOME_ALCOHOL, Globals.ParticleType.RIBOSOME_LYE:
			return 4.0
		Globals.ParticleType.ANTI_MITOCHONDRION, Globals.ParticleType.POISON_ALCOHOL, Globals.ParticleType.POISON_LYE, Globals.ParticleType.POISON_PLUTONIUM:
			return 5.0
	return 0.0

static func particle_type_is_factory(particle: int) -> bool:
	return [
		Globals.ParticleType.QUEEN,
		Globals.ParticleType.PRO_QUEEN,
		Globals.ParticleType.RIBOSOME_TRANSPORTER,
		Globals.ParticleType.RIBOSOME_ALCOHOL,
		Globals.ParticleType.RIBOSOME_LYE,
	].has(particle)

static func particle_type_is_in_transporter(particle: int) -> bool:
	return [
		Globals.ParticleType.AMINO_PHE,
		Globals.ParticleType.AMINO_ALA,
		Globals.ParticleType.AMINO_LYS,
		Globals.ParticleType.AMINO_TYR,
		Globals.ParticleType.AMINO_PRO,
		Globals.ParticleType.SUGAR,
	].has(particle)

static func particle_type_is_resource(particle: int) -> bool:
	return [
		Globals.ParticleType.ANTI_MITOCHONDRION,
		Globals.ParticleType.RESOURCE_AMINO_PHE,
		Globals.ParticleType.RESOURCE_AMINO_ALA,
		Globals.ParticleType.RESOURCE_AMINO_LYS,
		Globals.ParticleType.RESOURCE_AMINO_TYR,
		Globals.ParticleType.RESOURCE_AMINO_PRO,
	].has(particle)

static func particle_type_is_toxin(particle: int) -> bool:
	return [
		Globals.ParticleType.POISON_ALCOHOL,
		Globals.ParticleType.POISON_LYE,
		Globals.ParticleType.POISON_PLUTONIUM,
	].has(particle)

static func particle_type_craft_allowed_in_cell(particle: int, cell: Cell) -> bool:
	if particle_type_is_factory(particle):
		var present_factory_types = []
		for type in Globals.ParticleType.values():
			if particle_type_is_factory(type) and cell.particle_counts.get(type, 0) > 0:
				present_factory_types.append(type)
		if not present_factory_types.has(particle):
			present_factory_types.append(particle)
		present_factory_types.sort()
		if present_factory_types.size() > 1 and not present_factory_types != [Globals.ParticleType.QUEEN, Globals.ParticleType.PRO_QUEEN]:
			return false
		return true
	elif particle_type_is_resource(particle) or particle_type_is_toxin(particle):
		return false
	return true

static func particle_type_render_hover_center(particle: int) -> bool:
	return [
		Globals.ParticleType.ANTI_MITOCHONDRION,
		Globals.ParticleType.POISON_ALCOHOL,
		Globals.ParticleType.POISON_LYE,
		Globals.ParticleType.POISON_PLUTONIUM,
		Globals.ParticleType.PRO_QUEEN,
		Globals.ParticleType.QUEEN,
		Globals.ParticleType.RESOURCE_AMINO_ALA,
		Globals.ParticleType.RESOURCE_AMINO_LYS,
		Globals.ParticleType.RESOURCE_AMINO_PHE,
		Globals.ParticleType.RESOURCE_AMINO_PRO,
		Globals.ParticleType.RESOURCE_AMINO_TYR,
		Globals.ParticleType.RIBOSOME_ALCOHOL,
		Globals.ParticleType.RIBOSOME_LYE,
		Globals.ParticleType.RIBOSOME_TRANSPORTER,
	].has(particle)

static func particle_type_render_orbit_center(particle: int) -> bool:
	return [
		Globals.ParticleType.AMINO_ALA,
		Globals.ParticleType.AMINO_LYS,
		Globals.ParticleType.AMINO_PHE,
		Globals.ParticleType.AMINO_PRO,
		Globals.ParticleType.AMINO_TYR,
	].has(particle)

static func particle_type_resource_output_type(particle: int) -> int:
	match particle:
		Globals.ParticleType.ANTI_MITOCHONDRION:
			return Globals.ParticleType.SUGAR
		Globals.ParticleType.RESOURCE_AMINO_ALA:
			return Globals.ParticleType.AMINO_ALA
		Globals.ParticleType.RESOURCE_AMINO_LYS:
			return Globals.ParticleType.AMINO_LYS
		Globals.ParticleType.RESOURCE_AMINO_PHE:
			return Globals.ParticleType.AMINO_PHE
		Globals.ParticleType.RESOURCE_AMINO_PRO:
			return Globals.ParticleType.AMINO_PRO
		Globals.ParticleType.RESOURCE_AMINO_TYR:
			return Globals.ParticleType.AMINO_TYR
	return -1

# If a particle of `type` is clicked and dragged across cell boundaries, for which particles should corresponding rules be created, and in what direction?
# return [particle_type, direction_out], where particle_type can be null
static func particle_type_drag_rule_type(particle: int) -> Array:
	match particle:
		Globals.ParticleType.ANTI_MITOCHONDRION:
			return [Globals.ParticleType.SUGAR, true]
		Globals.ParticleType.POISON_ALCOHOL:
			return [Globals.ParticleType.ENZYME_ALCOHOL, false]
		Globals.ParticleType.POISON_LYE:
			return [Globals.ParticleType.ENZYME_LYE, false]
		Globals.ParticleType.POISON_PLUTONIUM:
			return [null, false]
		Globals.ParticleType.QUEEN, Globals.ParticleType.PRO_QUEEN, Globals.ParticleType.RIBOSOME_TRANSPORTER, Globals.ParticleType.RIBOSOME_ALCOHOL, Globals.ParticleType.RIBOSOME_LYE:
			return [null, true]
		_:
			return [particle, true]

static func particle_type_rendered_in_hud(particle: int) -> bool:
	return [
		Globals.ParticleType.PROTEIN_WHITE,
		Globals.ParticleType.PROTEIN_TRANSPORTER,
		Globals.ParticleType.ENZYME_ALCOHOL,
		Globals.ParticleType.ENZYME_LYE,
		Globals.ParticleType.AMINO_PHE,
		Globals.ParticleType.AMINO_ALA,
		Globals.ParticleType.AMINO_LYS,
		Globals.ParticleType.AMINO_TYR,
		Globals.ParticleType.AMINO_PRO,
		Globals.ParticleType.QUEEN,
		Globals.ParticleType.PRO_QUEEN,
		Globals.ParticleType.RIBOSOME_TRANSPORTER,
		Globals.ParticleType.RIBOSOME_ALCOHOL,
		Globals.ParticleType.RIBOSOME_LYE,
	].has(particle)

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

static func cell_is_discoverable(cell: Cell) -> bool:
	if cell.type != Globals.CellType.UNDISCOVERED:
		return false
	for n in cell.neighbors:
		if n.type == Globals.CellType.CAPTURED:
			return true
	return false

static func cell_is_selectable(cell: Cell) -> bool:
	for n in cell.neighbors:
		if n.type == Globals.CellType.CAPTURED:
			return true
	return false

static func tunnel_is_rendered(tunnel) -> bool:
	return tunnel.start_cell.type != Globals.CellType.UNDISCOVERED and tunnel.end_cell.type != Globals.CellType.UNDISCOVERED

static func cell_blocks_win(cell: Cell) -> bool:
	return cell.type != Globals.CellType.CAPTURED and cell.type != Globals.CellType.RESOURCE

static func cell_type_renders_particles(cell_type: int, particle_type: int) -> bool:
	if cell_type == Globals.CellType.CAPTURED:
		return true
	elif cell_type == Globals.CellType.RESOURCE and Rules.particle_type_is_resource(particle_type):
		return true
	elif cell_type == Globals.CellType.TOXIC and Rules.particle_type_is_toxin(particle_type):
		return true
	return false

static func cell_type_processes_recipes(type: int) -> bool:
	return type == Globals.CellType.CAPTURED or type == Globals.CellType.RESOURCE

static func cell_type_processes_pressure(type: int) -> bool:
	return type == Globals.CellType.CAPTURED or type == Globals.CellType.RESOURCE

static func cell_type_has_toxin_recovery(type: int) -> bool:
	return type == Globals.CellType.TOXIC or type == Globals.CellType.EMPTY

static func cell_type_renders_recipe_progress(type: int) -> bool:
	return type == Globals.CellType.CAPTURED

static func cell_type_texture_resource(type: int) -> Array:
	if type == Globals.CellType.EMPTY or type == Globals.CellType.CAPTURED:
		return [preload("res://textures/hex.png"), preload("res://textures/hex_pink.png")]
	elif type == Globals.CellType.UNDISCOVERED:
		return [null, null]
	else:
		return [preload("res://textures/hex_gray.png"), preload("res://textures/hex_gray.png")]

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_F1:
				debug_visual = not debug_visual
