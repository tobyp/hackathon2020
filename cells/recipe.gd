class_name Recipe

var inputs = {}
var outputs = {}
var catalysators = {}
var automatic: bool
# Cooldown of the recipe in seconds
var cooldown: float

static func matches(cell) -> Array:
	var rs = []
	for r in Rules.ALL_RECIPES:
		if r.recipe_matches(cell):
			rs.push_back(r)
	return rs

func _init(input: Dictionary, output: Dictionary, catalysators: Dictionary = {}, auto: bool = false, cooldown: float = 1):
	self.inputs = input
	self.outputs = output
	self.catalysators = catalysators
	self.automatic = auto
	self.cooldown = cooldown

func recipe_matches(cell) -> bool:
	for t in Globals.ParticleType.values():
		if inputs.has(t) and cell.particle_counts.get(t, 0) < inputs[t]:
			return false
		if catalysators.has(t) and cell.particle_counts.get(t, 0) < catalysators[t]:
			return false
		# Only one factory type per cell is allowed
		if outputs.has(t) and not Rules.particle_type_craft_allowed_in_cell(t, cell):
			return false
	return true

func get_name() -> String:
	for t in outputs:
		return Globals.particle_type_get_name(t)
	return "multiple things"
