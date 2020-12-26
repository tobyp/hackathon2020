extends Node2D
class_name Cell

var rng = RandomNumberGenerator.new()

### SIGNALS
signal particle_count_changed(type, old_count, new_count)

### MEMBERS
# A list of all existing neighbors (Will be modified from the hexgrid manager)
var neighbors = []
# Amino acid counts include a transporter, transporter count only means free transporter
var particle_counts = {}
var output_rules = {}  # Dict[ParticleType, Dict[Cell, bool]], output_rules[PARTICLE_*][<Neighbor Cell>] = true/false
var discovered: bool = true

### API
# Are particles of type `type` allowed to be pushed to `neighbor`?
# Note, there is no `input_rule(type, neighbor)`, use `neighbor.output_rule(type, self)` instead
func output_rule(type, neighbor: Cell) -> bool:
	return output_rules[type].get(neighbor, false)

func set_output_rule(type, neighbor: Cell, rule: bool):
	output_rules[type][neighbor] = rule

### UTILTIY/PRIVATE
# Add new particles
func add_particles(type, count: int = 1):
	var old_count = particle_counts.get(type, 0)
	var new_count = old_count + count
	for i in count:
		var particle = preload("res://cells/particle.tscn").instance()
		particle.translate(_random_coord_in_cell(particle.collision_radius))
		add_child(particle)
	particle_counts[type] = new_count
	emit_signal("particle_count_changed", type, old_count, new_count)

func remove_particles(type, count: int):
	var old_count = particle_counts.get(type, 0)
	count = min(old_count, count)  # don't remove more than we have
	var new_count = old_count - count;
	for c in self.get_children():
		if c is CellParticle:
			self.remove_child(c)
			count -= 1
		if count == 0:
			break
	particle_counts[type] = new_count
	emit_signal("particle_count_changed", type, old_count, new_count)

# Transfer `count` particles of type `type` from this cell to `dest`.
# This should take care of updating the particle_count dicts on both cells, and any actual particle 
func _push_particles(type: int, dest: Cell, count: int):
	pass  # TODO

# Called every game step.
func simulate():
	_process_pressure()
	_process_potential_recipes()
	_display_debug()

# Generate a random coordinate inside a cell (relative to its center)
# this doesn't reach the corners, but that's okay for now
func _random_coord_in_cell(clearance: float):
	var phi = rng.randf_range(0, 2*PI)
	var dist = rng.randf_range(0, sqrt(HexGrid.size_x / 2 - clearance))
	return Vector2(dist * cos(phi), dist * sin(phi));

### OVERRIDES
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$Gfx.set_material($Gfx.get_material().duplicate())
	for t in Globals.ParticleType:
		self.particle_counts[t] = 0
		self.output_rules[t] = {}

# Called every game step.
#func simulate(): # TODO use this declaration instead of _physics_process once i know how to call it
func _physics_process(delta):
	_process_pressure()
	_process_potential_recipes()
	_display_debug()

func _process_pressure():
	for t in Globals.ParticleType:
		var supply_own = self.particle_counts.get(t, 0)
		var demand_total = 0
		var demand_neighbors = {}
		for n in self.neighbors:
			if not self.output_rule(t, n):
				continue
			var supply_neighbor = n.particle_counts.get(t, 0)
			if supply_neighbor > supply_own:  # do they even want any?
				continue
			# The "demand" of a neighbor equals how many cells we would need to give them to end up equal.
			var demand_neighbor = (supply_own - supply_neighbor) / 2
			demand_neighbors[n] = demand_neighbor
			demand_total += demand_neighbor
		var budget = min(demand_total, supply_own)  # don't send more than the neighbors want, but also not more than we have
		for n in demand_neighbors.keys():
			var demand_neighbor = demand_neighbors[n]
			self._push_particles(t, n, round(budget * demand_neighbor / demand_total) as int)

func _process_potential_recipes():
	var recipes = Recipe.matches(particle_counts)
	for c in $RecipeButtons.get_children():
		var found = false
		var i = 0
		var found_i = 0
		for r in recipes:
			if str(r.output) == c.name:
				found = true
				found_i = i
				break
			i += 1
		if not found:
			$RecipeButtons.remove_child(c)
		else:
			recipes.remove(found_i)
	for r in recipes:
		# Add
		var button = Button.new()
		button.text = "Craft " + Recipe.get_particle_type_name(r.output)
		button.connect("pressed", self, "_craft", [r])
		$RecipeButtons.add_child(button)

func _craft(r: Recipe):
	print("Crafting " + Globals.get_particle_type_name(r.output))
	r.subtract_resources(particle_counts)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# More biomass
			var cur = $Gfx.material.get_shader_param("percentage")
			if event.button_index == BUTTON_LEFT:
				$Gfx.material.set_shader_param("percentage", min(1.0, cur + 0.2))
			elif  event.button_index == BUTTON_RIGHT:
				$Gfx.material.set_shader_param("percentage", max(0.0, cur - 0.2))

func _display_debug():
	var dbg = "";
	for particle in Globals.ParticleType:
		dbg += "[b][u]%s:[/u][/b] %s\n" % [particle, particle_counts.get(particle, 0)]
	$DebugLabel.bbcode_text = dbg
