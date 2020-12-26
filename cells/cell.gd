extends Node2D

### TYPES
enum ParticleType {
	PARTICLE_PROTEIN_WHITE,
	PARTICLE_ENZYME_PINK,
	PARTICLE_ENZYME_PURPLE,
	PARTICLE_ENZYME_GREEN,
	PARTICLE_ENZYME_YELLOW,
	PARTICLE_LAST,
}

### SIGNALS
signal particle_count_changed(type, old_count, new_count)

### MEMBERS
var particle_counts = {}
var output_rules = []  # List[Dict[Cell, bool]]

### UTILITY
# Are particles of type `type` allowed to be pushed to `neighbor`?
# Note, there is no `input_rule(type, neighbor)`, use `neighbor.output_rule(type, self)` instead
func output_rule(type, neighbor) -> bool:
	return output_rules[type].get(neighbor, false)


# Obtain a list of all existing neighbors (does not create any that might be missing)
func neighbors() -> Array:
	return []  # Splamy, this is your turf! Probably use get_node to grab hold of the main scene and access the grid from there?


# Transfer `coun` particles of type `type` from this cell to `dest`.
# This should take care of updating the particle_count dicts on both cells, and any actual particle nodes flying around.
func push_particles(type: int, dest: Object, count: int):
	pass  # TODO
	


### OVERRIDES
# Called when the node enters the scene tree for the first time.
func _ready():
	$Gfx.set_material($Gfx.get_material().duplicate())
	for t in ParticleType.PARTICLE_LAST:
		self.particle_counts[t] = 0
		self.output_rules.append({})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_process_pressure(delta)


func _process_pressure(delta: float):
	for t in ParticleType.PARTICLE_LAST:
		var supply = self.particle_counts.get(t, 0)
		var demand_total = 0
		var demand_neighbors = {}
		for n in self.neighbors():
			if not self.output_rule(t, n):
				continue
			var supply_neighbor = n.particle_counts.get(t, 0)
			if supply_neighbor > supply:
				continue
			var demand_neighbor = supply - supply_neighbor
			demand_neighbors[n] = demand_neighbor
			demand_total += demand_neighbor
		# TODO: tobyp
		

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# More biomass
			var cur = $Gfx.material.get_shader_param("percentage")
			if event.button_index == BUTTON_LEFT:
				$Gfx.material.set_shader_param("percentage", min(1.0, cur + 0.2))
			elif  event.button_index == BUTTON_RIGHT:
				$Gfx.material.set_shader_param("percentage", max(0.0, cur - 0.2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
