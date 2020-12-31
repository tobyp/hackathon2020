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
	
	RESOURCE_AMINO_PHE,
	RESOURCE_AMINO_ALA,
	RESOURCE_AMINO_LYS,
	RESOURCE_AMINO_TYR,
	RESOURCE_AMINO_PRO,
}

enum CellType {
	UNDISCOVERED,
	RESOURCE,
	TOXIC,
	EMPTY,
	CAPTURED,
}

enum ToxinType {
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
		ParticleType.RESOURCE_AMINO_PHE:
			return "Penylalanin Resource"
		ParticleType.RESOURCE_AMINO_ALA:
			return "Alanin Resource"
		ParticleType.RESOURCE_AMINO_LYS:
			return "Lysin Resource"
		ParticleType.RESOURCE_AMINO_TYR:
			return "Tyrosin Resource"
		ParticleType.RESOURCE_AMINO_PRO:
			return "Prolin Resource"
	return "Unknown Particle"

static func particle_type_get_res(particle: int, outline: bool = false) -> Texture:
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
		ParticleType.AMINO_PHE, ParticleType.RESOURCE_AMINO_PHE:
			image_name = "green_amino"
		ParticleType.AMINO_ALA, ParticleType.RESOURCE_AMINO_ALA:
			image_name = "yellow_amino"
		ParticleType.AMINO_LYS, ParticleType.RESOURCE_AMINO_LYS:
			image_name = "blue_amino"
		ParticleType.AMINO_TYR, ParticleType.RESOURCE_AMINO_TYR:
			image_name = "purple_amino"
		ParticleType.AMINO_PRO, ParticleType.RESOURCE_AMINO_PRO:
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
			image_name = "toxin_flammable"
		ParticleType.POISON_LYE:
			image_name = "toxin_corrosive"
		ParticleType.POISON_PLUTONIUM:
			image_name = "toxin_radioactive"

	if "ribosome" in image_name and outline:
		image_name += "_outline"

	return load("res://textures/%s.png" % image_name) as Texture

static func particle_type_get_color(particle: int) -> Color:
	match particle:
		ParticleType.PROTEIN_WHITE:
			return Color.gray
		ParticleType.SUGAR, ParticleType.ANTI_MITOCHONDRION:
			return Color.white
		ParticleType.AMINO_PHE, ParticleType.PROTEIN_TRANSPORTER, ParticleType.RIBOSOME_TRANSPORTER, ParticleType.RESOURCE_AMINO_PHE:
			return Color("#72f281")  # Green
		ParticleType.AMINO_ALA, ParticleType.ENZYME_ALCOHOL, ParticleType.RIBOSOME_ALCOHOL, ParticleType.POISON_ALCOHOL, ParticleType.RESOURCE_AMINO_ALA:
			return Color("#fae06e")  # Yellow
		ParticleType.AMINO_LYS, ParticleType.ENZYME_LYE, ParticleType.RIBOSOME_LYE, ParticleType.POISON_LYE, ParticleType.RESOURCE_AMINO_LYS:
			return Color("#72daf2")  # Cyan
		ParticleType.AMINO_TYR, ParticleType.QUEEN, ParticleType.RESOURCE_AMINO_TYR:
			return Color("#6e00fa")  # Violet
		ParticleType.AMINO_PRO, ParticleType.PRO_QUEEN, ParticleType.RESOURCE_AMINO_PRO:
			return Color("#fa0090")  # Pink
		ParticleType.POISON_PLUTONIUM:
			return Color.black
	return Color.black

static func toxin_type_get_name(toxin: int) -> String:
	match toxin:
		ToxinType.ALCOHOL:
			return "Alcohol"
		ToxinType.LYE:
			return "Lye"
		ToxinType.PLUTONIUM:
			return "Plutonium"
		ToxinType.ANTI_BIOMASS:
			return "Anti-Biomass"
	return "Unknown Toxin"

static func toxin_type_get_particle_type(toxin: int) -> int:
	match toxin:
		ToxinType.ALCOHOL:
			return ParticleType.POISON_ALCOHOL
		ToxinType.LYE:
			return ParticleType.POISON_LYE
		ToxinType.PLUTONIUM:
			return ParticleType.POISON_PLUTONIUM
	return -1

static func cell_type_get_name(type: int) -> String:
	match type:
		CellType.UNDISCOVERED:
			return "Undiscovered"
		CellType.RESOURCE:
			return "Resource"
		CellType.TOXIC:
			return "Toxic"
		CellType.EMPTY:
			return "Empty"
		CellType.CAPTURED:
			return "Captured"
	return "Unknown Cell Type"

static func get_enum_name(enu, value) -> String:
	for key in enu.keys():
		if enu[key] == value:
			return key
	return "<Unknown>"
