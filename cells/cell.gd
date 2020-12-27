extends Node2D
class_name Cell

### SIGNALS
signal particle_count_changed(type, old_count, new_count)

# Allow one automatic recipe every 10 ticks
const AUTO_RECIPE_COOLDOWN = 10

### MEMBERS
# Own index position. Just for debugging
var pos = Vector2.ZERO
# A list of all existing neighbors (Will be modified from the hexgrid manager)
var neighbors = []
# Amino acid counts include a transporter, transporter count only means free transporter
var particle_counts = {}  # Dict[ParticleType, int]
var output_rules = {}  # Dict[ParticleType, Dict[Cell, bool]], output_rules[PARTICLE_*][<Neighbor Cell>] = true/false
var discovered: bool = true
var poisons = {Globals.PoisonType.ANTI_BIOMASS: 1.0}  # Dict[PoisonType, float]
var poison_recoveries = {}  # Dict[PoisonType, [float rate, float ceiling]]
# 0 = Ready
var auto_recipe_cooldown = 0

### PRIVATE MEMBERS
# since transferring an integer number of particles each tick makes it impossible to see any changes,
# and random()-gating any transfers is sad, this will keep track of "partial" transfers, letting them
# accumulate, and then transferring while numbers whenever the counter >= 1.
var output_valves = {}  # Dict[Cell, float]

### API
# Are particles of type `type` allowed to be pushed to `neighbor`?
# Note, there is no `input_rule(type, neighbor)`, use `neighbor.output_rule(type, self)` instead
func output_rule(type: int, neighbor: Cell) -> bool:
	return self.output_rules[type].get(neighbor, false)

func set_output_rule(type: int, neighbor: Cell, rule: bool):
	if not self.neighbors.has(neighbor):
		print("%s: Invalid output rule! %s is not a neighbor" % [self, neighbor])
		return
	if not self.output_rules.has(type):
		self.output_rules[type] = {}
	self.output_rules[type][neighbor] = rule

func set_poison(poison: int, value: float):
	if value <= 0.0:
		self.poisons.erase(poison)
		self.poison_recoveries.erase(poison)
	else:
		self.poisons[poison] = value
	if poison == Globals.PoisonType.ANTI_BIOMASS:
		$Gfx.material.set_shader_param("percentage", 1.0 - clamp(value, 0, 1.0))

func get_poison(poison: int) -> float:
	return self.poisons.get(poison, 0.0)

### UTILTIY/PRIVATE
# Add new particles
func add_particles(type, count: int = 1):
	var type_name = Globals.particle_type_get_name(type)
	# print("%s got %d %s" % [self, count, type_name])
	if self.poisons.size() > 0:
		for poison_type in self.poisons:
			var potency = Globals.particle_type_get_potency(type, poison_type)
			if potency <= 0.0:
				continue
			var poison_name = Globals.poison_type_get_name(poison_type)
			var poison_value = self.poisons[poison_type]
			var delta_poison = min(poison_value, count * potency)
			self.set_poison(poison_type, poison_value - delta_poison)
			var delta_particles = max(count, ceil(delta_poison / potency))  # rounding sometimes makes the max necessary
			# print("%s %d %s breaking down %f %s" % [self, delta_particles, type_name, delta_poison, poison_name])
			count -= delta_particles
	if self.poisons.size() > 0:
		# print("%s %d %s died due to %s" % [self, count, type_name, self.poisons])
		return  # they dead :(
	var old_count = particle_counts.get(type, 0)
	var new_count = old_count + count
	self._create_particles(type, count)
	particle_counts[type] = new_count
	emit_signal("particle_count_changed", type, old_count, new_count)

func remove_particles(type: int, count: int) -> int:
	var old_count = particle_counts.get(type, 0)
	count = min(old_count, count) as int  # don't remove more than we have
	var new_count = old_count - count;
	for c in $Particles.get_children():
		if c is CellParticle and c.type == type:
			$Particles.remove_child(c)
			count -= 1
		if count == 0:
			break
	particle_counts[type] = new_count
	emit_signal("particle_count_changed", type, old_count, new_count)
	return old_count - new_count

# Called every game step.
func simulate(delta):
	_process_poison_recovery(delta)
	_process_pressure(delta)
	_process_recipes()
	_display_debug()

### PRIVATE/UTILITY FUNCTIONS
# Generate a random coordinate inside a cell (relative to its center)
# this doesn't reach the corners, but that's okay for now
# clearance is how far inside the edge the point must be (to avoid generating particles intersecting the cell border)
static func _random_coord_in_cell(clearance: float) -> Vector2:
	var phi = Rules.rng.randf_range(0, 2*PI)
	var dist = Rules.rng.randf_range(0, sqrt(HexGrid.size_x / 2 - clearance))
	return Vector2(dist * cos(phi), dist * sin(phi));

static func _random_velocity() -> Vector2:
	var phi = Rules.rng.randf_range(0, 2*PI)
	var dist = Rules.rng.randf_range(350, 500)
	return Vector2(dist * cos(phi), dist * sin(phi));

# Transfer `count` particles of type `type` from this cell to `dest`.
# This should take care of updating the particle_count dicts on both cells, and any actual particle 
func _push_particles(type: int, dest: Cell, count: int):
	count = remove_particles(type, count)
	dest.add_particles(type, count)

static func _particle_init(particle: CellParticle):
	if Globals.particle_type_is_factory(particle.type):
		particle.translate(Vector2.ZERO)
		particle.velocity = Vector2.ZERO
	else:
		particle.translate(_random_coord_in_cell(particle.collision_radius))
		particle.velocity = _random_velocity()

func _create_particles(type: int, count: int = 1):
	for i in count:
		var particle = preload("res://cells/particle.tscn").instance()
		particle.type = type
		_particle_init(particle)
		$Particles.add_child(particle)

### OVERRIDES
func _ready():
	$Gfx.set_material($Gfx.get_material().duplicate())
	for t in Globals.ParticleType.values():
		self.particle_counts[t] = 0
		self.output_rules[t] = {}

func _to_string():
	return "Cell_%s @ %s" % [self.get_index(), pos]

func _process_poison_recovery(delta):
	for t in self.poison_recoveries:
		var rate_and_ceil = self.poison_recoveries[t]
		self.set_poison(t, min(self.get_poison(t) + delta * rate_and_ceil[0], rate_and_ceil[1]))
	pass

func _process_pressure(delta):
	for t in Globals.ParticleType.values():
		var particle_name = Globals.particle_type_get_name(t)
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
			var demand_neighbor = ceil((supply_own - supply_neighbor) / 2)
			# print("%s neighbor %s has %d demand %d" % [self, n, supply_neighbor, demand_neighbor])
			demand_neighbors[n] = demand_neighbor
			demand_total += demand_neighbor
		var budget = min(demand_total, supply_own)  # don't send more than the neighbors want, but also not more than we have
		if demand_total > 0:
			for n in demand_neighbors.keys():
				var demand_neighbor = demand_neighbors[n] / demand_total
				if demand_neighbor > 0:
					var transfer = Globals.diffuse_func(budget, demand_neighbor, delta)
					# print("%s neighbor %s demands %f %s, transfer %f" % [self, n, demand_neighbor, particle_name, transfer])
					var valve_transfer = output_valves.get(n, 0) + transfer
					if valve_transfer >= 1.0:
						self._push_particles(t, n, floor(valve_transfer) as int)
						valve_transfer -= floor(valve_transfer)
					output_valves[n] = valve_transfer

func _process_recipes():
	auto_recipe_cooldown = max(0, auto_recipe_cooldown - 1)
	var buttonContainer = $RecipeButtons.get_child(0)
	var recipes = Recipe.matches(particle_counts)
	for c in buttonContainer.get_children():
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
			buttonContainer.remove_child(c)
		else:
			recipes.remove(found_i)
	for r in recipes:
		if r.automatic:
			if auto_recipe_cooldown == 0:
				auto_recipe_cooldown = AUTO_RECIPE_COOLDOWN
				# Run recipe
				_craft(r)
		else:
			# Add button
			var button = Button.new()
			button.text = "Craft " + Globals.particle_type_get_name(r.output)
			button.connect("pressed", self, "_craft", [r])
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.name = str(r.output)
			buttonContainer.add_child(button)

func _craft(r: Recipe):
	for t in r.inputs:
		if particle_counts[t] < r.inputs[t]:
			print("Cannot craft…")
			return
		elif !Globals.particle_type_is_factory(t):
			# Factories are not used
			remove_particles(t, r.inputs[t])
	for t in r.outputs:
		add_particles(t, r.outputs[t])

func _display_debug():
	var dbg = "[b][i]%s[/i][/b]\n" % [self];
	dbg += "[i]Neighbors:[/i] %s\n" % [self.neighbors];
	for poison in Globals.PoisonType:
		dbg += "[b][u]%s:[/u][/b] %f\n" % [poison, self.poisons.get(Globals.PoisonType[poison], 0)]
	for particle in Globals.ParticleType:
		dbg += "[b][u]%s:[/u][/b] %d\n" % [particle, self.particle_counts.get(Globals.ParticleType[particle], 0)]
	$DebugLabel.bbcode_text = dbg
