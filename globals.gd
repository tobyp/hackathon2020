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
	NONE,
	INIT,
	SUGAR_CELL,
	DEBUG_PARTICLES,
	POISON_ALCOHOL,
	POISON_LYE,
}

### CONSTANTS
const SIMULATION_TICK_PERIOD = 0.1
# Material to show progress
const PROGRESS_MATERIAL = "res://shader/progress_material.tres"
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
		ParticleType.POISON_ALCOHOL:
			return "Alcohol"
		ParticleType.POISON_LYE:
			return "Lye"
		ParticleType.POISON_PLUTONIUM:
			return "Plutonium"
	return "Unknown Particle"
	
static func particle_type_get_mnemonic(particle: int) -> String:
	match particle:
		ParticleType.PROTEIN_WHITE:
			return "x"
		ParticleType.SUGAR:
			return "s"
		ParticleType.ANTI_MITOCHONDRION:
			return "S"
		ParticleType.AMINO_PHE:
			return "p*"
		ParticleType.PROTEIN_TRANSPORTER:
			return "p"
		ParticleType.RIBOSOME_TRANSPORTER:
			return "P"
		ParticleType.AMINO_ALA:
			return "a*"
		ParticleType.ENZYME_ALCOHOL:
			return "a"
		ParticleType.RIBOSOME_ALCOHOL:
			return "A"
		ParticleType.POISON_ALCOHOL:
			return "(A)"
		ParticleType.AMINO_LYS:
			return "l*"
		ParticleType.ENZYME_LYE:
			return "l"
		ParticleType.RIBOSOME_LYE:
			return "L"
		ParticleType.POISON_LYE:
			return "(L)"
		ParticleType.AMINO_TYR:
			return "q*"
		ParticleType.QUEEN:
			return "Q"
		ParticleType.AMINO_PRO:
			return "o*"
		ParticleType.PRO_QUEEN:
			return "O"
		ParticleType.POISON_PLUTONIUM:
			return "(U)"
	return "?"

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

static func particle_type_get_res(particle: int, outline: bool = false) -> String:
	var image_name = "white_prot"
	match particle:
		ParticleType.PROTEIN_TRANSPORTER:
			image_name = "green_enzyme"
		ParticleType.ENZYME_ALCOHOL:
			image_name = "yellow_enzyme"
		ParticleType.ENZYME_LYE:
			image_name = "blue_enzyme"
		ParticleType.QUEEN:
			image_name = "purple_ribosome"
		ParticleType.PRO_QUEEN:
			image_name = "pink_ribosome"
		ParticleType.AMINO_PHE:
			image_name = "green_amino"
		ParticleType.AMINO_ALA:
			image_name = "yellow_amino"
		ParticleType.AMINO_LYS:
			image_name = "blue_amino"
		ParticleType.AMINO_TYR:
			image_name = "purple_amino"
		ParticleType.AMINO_PRO:
			image_name = "pink_amino"
		ParticleType.SUGAR:
			image_name = "sugar"
		ParticleType.RIBOSOME_TRANSPORTER:
			image_name = "green_ribosome"
		ParticleType.RIBOSOME_ALCOHOL:
			image_name = "yellow_ribosome"
		ParticleType.RIBOSOME_LYE:
			image_name = "blue_ribosome"
		ParticleType.ANTI_MITOCHONDRION:
			image_name = "sugar"
		ParticleType.POISON_ALCOHOL:
			image_name = "poison_flammable"
		ParticleType.POISON_LYE:
			image_name = "poison_corrosive"
		ParticleType.POISON_PLUTONIUM:
			image_name = "poison_radioactive"

	if "ribosome" in image_name and outline:
		image_name += "_outline"

	return "res://textures/%s.png" % image_name

static func particle_type_get_color(particle: int) -> Color:
	match particle:
		ParticleType.PROTEIN_WHITE:
			return Color.gray
		ParticleType.SUGAR, ParticleType.ANTI_MITOCHONDRION:
			return Color.white
		ParticleType.AMINO_PHE, ParticleType.PROTEIN_TRANSPORTER, ParticleType.RIBOSOME_TRANSPORTER:
			return Color("#72f281")  # Green
		ParticleType.AMINO_ALA, ParticleType.ENZYME_ALCOHOL, ParticleType.RIBOSOME_ALCOHOL, ParticleType.POISON_ALCOHOL:
			return Color("#fae06e")  # Yellow
		ParticleType.AMINO_LYS, ParticleType.ENZYME_LYE, ParticleType.RIBOSOME_LYE, ParticleType.POISON_LYE:
			return Color("#72daf2")  # Cyan
		ParticleType.AMINO_TYR, ParticleType.QUEEN:
			return Color("#6e00fa")  # Violet
		ParticleType.AMINO_PRO, ParticleType.PRO_QUEEN:
			return Color("#fa0090")  # Pink
		ParticleType.POISON_PLUTONIUM:
			return Color.black
	return Color.black

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
		CellType.UNDISCOVERED:
			return "Undiscovered"
	return "Unknown Cell Type"

static func get_enum_name(enu, value) -> String:
	for key in enu.keys():
		if enu[key] == value:
			return key
	return "<Unknown>"
