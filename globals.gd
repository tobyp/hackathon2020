class_name Globals

### TYPES
enum ParticleType {
	## These can travel:
	PROTEIN_WHITE,  # Gray
	PROTEIN_TRANSPORTER,  # Green
	### note from here, these are technically "Transporter carrying X" particles, because none of these particles are allowed to float around alone
	SUGAR,  # White
	ENZYME_ALCOHOL,  # Yellow
	ENZYME_LYE,  # Cyan
	AMINO_PHE,  # Green (Transporter)
	AMINO_ALA,  # Yellow (Alcohol)
	AMINO_LYS,  # Cyan (Lye)
	AMINO_TYR,  # Violet (Queen)
	AMINO_PRO,  # Pink (Pro Queen)
	
	## These are factories, can't travel, and are limited to one per cell:
	QUEEN,  # Violet
	PRO_QUEEN,  # Pink
	RIBOSOME_TRANSPORTER,  # Green 
	RIBOSOME_ALCOHOL,  # Yellow
	RIBOSOME_LYE,  # Cyan

	# Uses the energy of your pc to create sugar, lives in sugar cells, but is very shy so you never see it
	ANTI_MITOCHONDRION,
	# These have the thankless job of carrying the hazard icons (you can't actually see the particles themselves, the signs are so big)
	POISON_ALCOHOL,
	POISON_LYE,
	POISON_PLUTONIUM,
}

enum CellType {
	UNDISCOVERED,
	NORMAL,
	RESOURCE,
}

enum PoisonType {
	ANTI_BIOMASS,
	ALCOHOL,
	LYE,
	PLUTONIUM,
}

enum TechType {
	NONE
	INIT
	SUGAR_CELL
	DEBUG_PARTICLES
}

### CONSTANTS
const SIMULATION_TICK_PERIOD = 0.1
# By tran5ient under CC-0, https://freesound.org/people/tran5ient/sounds/190112/
const PARTICLE_DIE_SOUND = "res://sounds/Flail.ogg"
# By szegvari under CC-0, https://freesound.org/people/szegvari/sounds/530699/
const PARTICLE_CRAFT_SOUND = "res://sounds/Water-wave.ogg"

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
		ParticleType.POISON_ALCOHOL:
			return true
		ParticleType.POISON_LYE:
			return true
		ParticleType.POISON_PLUTONIUM:
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

static func poison_type_get_name(poison: int) -> String:
	match poison:
		PoisonType.ALCOHOL:
			return "Alcohol"
		PoisonType.LYE:
			return "Lye"
		PoisonType.PLUTONIUM:
			return "Plutonium"
		PoisonType.ANTI_BIOMASS:
			return "Anti-Biomass"
	return "Unknown Poison"

static func poison_type_get_particle_type(poison: int) -> int:
	match poison:
		PoisonType.ALCOHOL:
			return ParticleType.POISON_ALCOHOL
		PoisonType.LYE:
			return ParticleType.POISON_LYE
		PoisonType.PLUTONIUM:
			return ParticleType.POISON_PLUTONIUM
	return -1

static func cell_type_get_name(type: int) -> String:
	match type:
		CellType.NORMAL:
			return "Normal"
		CellType.RESOURCE:
			return "Resource"
	return "Unknown Cell Type"

static func get_enum_name(enu, value) -> String:
	for key in enu.keys():
		if enu[key] == value:
			return key
	return "<Unknown>"
