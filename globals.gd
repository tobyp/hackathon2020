class_name Globals

### TYPES
enum ParticleType {
	PROTEIN_WHITE,
	PROTEIN_TRANSPORTER, # Green
	ENZYME_ALCOHOL, # Yellow
	ENZYME_LYE, # Cyan
	QUEEN, # Violet
	PRO_QUEEN, # Pink
	AMINO_PHE, # Green
	AMINO_ALA, # Yellow
	AMINO_LYS, # Cyan
	AMINO_TYR, # Violet
	AMINO_PRO, # Pink
	SUGAR, # White
	RIBOSOME_TRANSPORTER,
	RIBOSOME_ALCOHOL,
	RIBOSOME_LYE,

	# Uses the energy of your pc to create sugar, lives in sugar cells, but is very shy so you never see it
	ANTI_MITOCHONDRION,
}

enum PoisonType {
	ANTI_BIOMASS,
	ALCOHOL,
	LYE,
}

enum TechType {
	A
	B
	C
	D
	E
	F
}

### CONSTANTS
const SIMULATION_TICK_PERIOD = 0.1

### FUNCTIONS
static func particle_type_get_name(particle: int) -> String:
	match particle:
		ParticleType.PROTEIN_WHITE:
			return "Generic Protein"
		ParticleType.PROTEIN_TRANSPORTER:
			return "Transporter"
		ParticleType.ENZYME_ALCOHOL:
			return "Alcohol Enzyme"
		ParticleType.ENZYME_LYE:
			return "Lye Enzyme"
		ParticleType.QUEEN:
			return "Queen"
		ParticleType.PRO_QUEEN:
			return "Pro Queen"
		ParticleType.AMINO_PHE:
			return "Phenylalanin"
		ParticleType.AMINO_ALA:
			return "Alanin"
		ParticleType.AMINO_LYS:
			return "Lysin"
		ParticleType.AMINO_TYR:
			return "Tyrosin"
		ParticleType.AMINO_PRO:
			return "Prolin"
		ParticleType.SUGAR:
			return "Sugar"
		ParticleType.RIBOSOME_TRANSPORTER:
			return "Transporter Ribosome"
		ParticleType.RIBOSOME_ALCOHOL:
			return "Alcohol Ribosome"
		ParticleType.RIBOSOME_LYE:
			return "Lye Ribosome"
		ParticleType.ANTI_MITOCHONDRION:
			return "Anti-Mitochondrion"
	return "Unknown Particle"

static func particle_type_is_factory(particle: int) -> bool:
	match particle:
		ParticleType.QUEEN:
			return true
		ParticleType.PRO_QUEEN:
			return true
		ParticleType.RIBOSOME_TRANSPORTER:
			return true
		ParticleType.RIBOSOME_ALCOHOL:
			return true
		ParticleType.RIBOSOME_LYE:
			return true
		ParticleType.ANTI_MITOCHONDRION:
			return true
	return false

static func particle_type_is_in_transporter(particle: int) -> bool:
	match particle:
		ParticleType.AMINO_PHE:
			return true
		ParticleType.AMINO_ALA:
			return true
		ParticleType.AMINO_LYS:
			return true
		ParticleType.AMINO_TYR:
			return true
		ParticleType.AMINO_PRO:
			return true
		ParticleType.SUGAR:
			return true
	return false

static func particle_type_get_potency(particle: int, poison: int, poisons: Dictionary) -> float:
	match particle:
		ParticleType.ENZYME_ALCOHOL:
			if poison == PoisonType.ALCOHOL:
				return 1.0 / 50.0
		ParticleType.ENZYME_LYE:
			if poison == PoisonType.LYE:
				return 1.0/100.0
		ParticleType.PROTEIN_WHITE:
			if poison == PoisonType.ANTI_BIOMASS and poisons.size() == 1:  # this only works if there are no other poisons
				return 1.0/25.0
	return 0.0

static func poison_type_get_name(poison: int) -> String:
	match poison:
		PoisonType.ALCOHOL:
			return "Alcohol"
		PoisonType.LYE:
			return "Lye"
		PoisonType.ANTI_BIOMASS:
			return "Anti-Biomass"
	return "Unknown Poison"
	

# Calculate how many particles to send, in `delta` seconds, given a `budget` of cells that could be sent, and a `demand` weight from 0 to 1
# There's a lot of tuning to be had on the constants here.
static func diffuse_func(budget: int, demand: float, delta: float) -> float:
	# for debugging, here's a very slow and even diffuse function that makes it easily visible
	return budget * demand * 0.1 * delta
	# this exponential will make diffusion go faster if the differential pressure is higher
	# return budget * 0.55 * exp(-4 * demand) * delta
