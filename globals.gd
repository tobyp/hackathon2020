class_name Globals

### TYPES
enum ParticleType {
	PROTEIN_WHITE,  # ... White
	PROTEIN_TRANSPORTER,  # Green
	ENZYME_ALCOHOL,  # Yellow
	ENZYME_LYE,  # Cyan
	QUEEN,  # Violet
	PRO_QUEEN,  # Pink
	AMINO_PHE,  # Green (Transporter)
	AMINO_ALA,  # Yellow (Alcohol)
	AMINO_LYS,  # Cyan (Lye)
	AMINO_TYR,  # Violet (Queen)
	AMINO_PRO,  # Pink (Pro Queen)
	SUGAR,  # White
	RIBOSOME_TRANSPORTER,  # Green 
	RIBOSOME_ALCOHOL,  # Yellow
	RIBOSOME_LYE,  # Cyan

	# Uses the energy of your pc to create sugar, lives in sugar cells, but is very shy so you never see it
	ANTI_MITOCHONDRION,
}

enum CellType {
	NORMAL,
	RESOURCE,
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

static func poison_type_get_name(poison: int) -> String:
	match poison:
		PoisonType.ALCOHOL:
			return "Alcohol"
		PoisonType.LYE:
			return "Lye"
		PoisonType.ANTI_BIOMASS:
			return "Anti-Biomass"
	return "Unknown Poison"

static func cell_type_get_name(type: int) -> String:
	match type:
		CellType.NORMAL:
			return "Normal"
		CellType.RESOURCE:
			return "Resource"
	return "Unknown Cell Type"
