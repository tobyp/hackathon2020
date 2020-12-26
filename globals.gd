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

	# Uses the energy of your pc to create sugar, lives in sugar cells
	ANTI_MITOCHONTRION,
}

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
	return "Unknown"

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
		ParticleType.ANTI_MITOCHONTRION:
			return true
	return false
