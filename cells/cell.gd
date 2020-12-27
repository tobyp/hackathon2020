extends Node2D
class_name Cell

### SIGNALS
signal particle_count_changed(cell, type, old_count, new_count)
signal output_rule_changed(cell, neighbor, type, old_rule, new_rule)  # rule is a boolean, whether type is allowed to travel cell -> neighbor or not
# Gets called when a cell gets visible, so that the hexgrid manager can
# initialize it with the tech scripting engine
signal discover(cell)
signal selected(cell, status)

### MEMBERS
# Own index position. Just for debugging
var pos = Vector2.ZERO
# How far away the cell is from the root cell
var ring_level = 0
# A list of all existing neighbors (Will be modified from the hexgrid manager)
var neighbors = []
# Amino acid counts include a transporter, transporter count only means free transporter
var particle_counts = {}  # Dict[ParticleType, int]
var output_rules = {}  # Dict[ParticleType, Dict[Cell, bool]], output_rules[PARTICLE_*][<Neighbor Cell>] = true/false, default false
var _input_allowed = {}  # Dict[ParticleType, bool], default true
var poisons: Dictionary = {Globals.PoisonType.ANTI_BIOMASS: 1.0}  # Dict[PoisonType, float]
var poison_recoveries: Dictionary = {}  # Dict[PoisonType, [float rate, float ceiling]]
# 0 = Ready
var auto_recipe_cooldown = 0
var auto_recipe_cooldown_max = 0
var auto_recipe_material: ShaderMaterial = load(Globals.PROGRESS_MATERIAL).duplicate()
export var type = Globals.CellType.UNDISCOVERED setget _set_type, _get_type
var selected: bool = false setget _set_selected, _get_selected

### PRIVATE MEMBERS
# since transferring an integer number of particles each tick makes it impossible to see any changes,
# and random()-gating any transfers is sad, this will keep track of "partial" transfers, letting them
# accumulate, and then transferring while numbers whenever the counter >= 1.
var _output_valves = {}  # Dict[Cell, float]

### API
# Are particles of type `type` allowed to be pushed to `neighbor`?
# Note, there is no `input_rule(type, neighbor)`, use `neighbor.output_rule(type, self)` instead
func output_rule(type: int, neighbor: Cell) -> bool:
	if not self.output_rules.has(type):
		return false  # default is closed
	return self.output_rules[type].get(neighbor, false)

func input_allowed(type: int) -> bool:
	return self._input_allowed.get(type, true)
	
func set_input_allowed(type: int, allowed: bool):
	self._input_allowed[type] = allowed

func output_allowed(type: int, neighbor: Cell) -> bool:
	return self.neighbors.has(neighbor) and neighbor.input_allowed(type)

# returns the new stat eof the rule
func set_output_rule(type: int, neighbor: Cell, rule: bool) -> bool:
	if not self.neighbors.has(neighbor):
		print("%s: Invalid output rule! %s is not a neighbor" % [self, neighbor])
		return false
	if not neighbor.input_allowed(type):
		print("%s: Invalid output rule! %s does not allow %s as input" % [self, neighbor, Globals.particle_type_get_name(type)])
		return false
	if not self.output_rules.has(type):
		self.output_rules[type] = {}
	var old_rule = self.output_rules[type].get(neighbor, false)
	if old_rule != rule:
		emit_signal("output_rule_changed", self, neighbor, type, old_rule, rule)
	self.output_rules[type][neighbor] = rule
	return rule

func set_poison(poison: int, value: float):
	if value <= 0.0:
		if poisons.has(poison):
			var poison_particle_type = Globals.poison_type_get_particle_type(poison)
			if poison_particle_type != -1:
				self.remove_particles(poison_particle_type, 1)
		self.poisons.erase(poison)
		self.poison_recoveries.erase(poison)
	else:
		if not self.poisons.has(poison):
			var poison_particle_type = Globals.poison_type_get_particle_type(poison)
			if poison_particle_type != -1:
				self.add_particles(poison_particle_type, 1)
		self.poisons[poison] = value
	if poison == Globals.PoisonType.ANTI_BIOMASS:
		$Gfx.material.set_shader_param("percentage", 1.0 - clamp(value, 0, 1.0))

func get_poison(poison: int) -> float:
	return self.poisons.get(poison, 0.0)

# Add *new* particles - particle nodes will be created as necessary
func add_particles(type: int, count: int = 1, anywhere: bool = true):
	var recv_result = self._recv_particles(type, count)
	if recv_result[1] > 0:
		var type_name = Globals.particle_type_get_name(type)
		print("%s: tried to add %d %s particles, but they were destroyed (by poison etc.)" % [self, count, type_name])
	count = recv_result[0]
	var old_count = particle_counts.get(type, 0)
	var new_count = old_count + count
	particle_counts[type] = new_count
	if self.type == Globals.CellType.NORMAL or Globals.particle_type_is_factory(type):
		self._put_particle_nodes(self._create_particle_nodes(type, count, anywhere))
	emit_signal("particle_count_changed", self, type, old_count, new_count)

func remove_particles(type: int, count: int) -> int:
	var old_count = particle_counts.get(type, 0)
	count = min(old_count, count) as int  # don't remove more than we have
	var new_count = old_count - count;
	particle_counts[type] = new_count
	emit_signal("particle_count_changed", self, type, old_count, new_count)
	if self.type == Globals.CellType.NORMAL or not Globals.particle_type_is_factory(type):
		self._free_particle_nodes(self._take_particle_nodes(type, count))
	return old_count - new_count

func _get_type() -> int:
	return type

func _set_type(type_: int):
	if type == type_:
		return
	type = type_

	$Gfx.visible = type == Globals.CellType.NORMAL
	$GfxResource.visible = type == Globals.CellType.RESOURCE
	if type != Globals.CellType.NORMAL:
		_free_particle_nodes(_take_nonfactory_nodes())
	else:
		for t in self.particle_counts:
			if not Globals.particle_type_is_factory(t):
				self.add_particles(t, self.particle_counts[t])

# Called every game step.
func simulate(delta):
	if type != Globals.CellType.UNDISCOVERED:
		if type == Globals.CellType.NORMAL:
			_process_poison_recovery(delta)
			_process_sugar_usage(delta)
		_process_pressure(delta)
		_process_recipes(delta)
	_display_debug()

### PRIVATE/UTILITY FUNCTIONS
# Generate a random coordinate inside a cell (relative to its center)
# with anywhere=true, anywhere in the cell, and with anywhere=false, near the center (moving outwards)
# this doesn't reach the corners, but that's okay for now
# clearance is how far inside the edge the point must be (to avoid generating particles intersecting the cell border)
static func _random_coord_in_cell(clearance: float, anywhere: bool = true) -> Vector2:
	var phi = Rules.rng.randf_range(0, 2*PI)
	var dist = 0
	if anywhere:
		Rules.rng.randf_range(0, sqrt(HexGrid.size_x / 2 - clearance))
		dist = dist * dist
	return Vector2(dist * cos(phi), dist * sin(phi));

static func _random_velocity() -> Vector2:
	var phi = Rules.rng.randf_range(0, 2*PI)
	var dist = Rules.rng.randf_range(100, 250)
	return Vector2(dist * cos(phi), dist * sin(phi));

### UTILTIY/PRIVATE
func _particle_init(particle: CellParticle, anywhere: bool = true):
	if Globals.particle_type_is_factory(particle.type):
		particle.translate(Vector2.ZERO)
		particle.velocity = Vector2.ZERO
		particle.set_texture_material(auto_recipe_material)
	else:
		particle.translate(_random_coord_in_cell(particle.collision_radius, anywhere))
		particle.velocity = _random_velocity()

## PARTICLE NODE FUNCTIONS - these do not modify `particle_counts`!
func _create_particle_nodes(type: int, count: int = 1, anywhere: bool = true) -> Array:
	var particles = []
	for i in count:
		var particle = preload("res://cells/particle.tscn").instance()
		particle.type = type
		_particle_init(particle, anywhere)
		particles.append(particle)
	return particles

static func _free_particle_nodes(particles: Array):
	for p in particles:
		p.free()

func _put_particle_nodes(particles: Array):
	# print("%s: adding %d particles" % [self, particles.size()])
	for p in particles:
		# assert(p.type == type)
		$Particles.add_child(p)

func _take_particle_nodes(type: int, count: int = 1) -> Array:
	var result = [];
	for c in $Particles.get_children():
		if result.size() >= count:
			break
		if c is CellParticle and c.type == type:
			$Particles.remove_child(c)
			result.append(c)
	# print("%s: taking %d %s" % [self, count, Globals.particle_type_get_name(type)])
	return result

func _take_nonfactory_nodes() -> Array:
	# print("%s: taking %d %s" % [self, count, Globals.particle_type_get_name(type)])
	var result = [];
	for c in $Particles.get_children():
		if c is CellParticle and not Globals.particle_type_is_factory(c.type):
			$Particles.remove_child(c)
			result.append(c)
	return result

# PARTICLE TRANSFER FUNCTIONS
# Called by process_pressure when that has calculated which particles need to be transferred where.
# returns [number_accepted, number_destroyed] (where n_accepted doesn't include n_destroyed, even they are technically "accepted")
# number_accepted + number_destroyed <= count
# **NOTE this does NOT update any particle counts or particle nodes**
func _recv_particles(type: int, count: int = 1) -> Array:
	var n_destroyed = 0
	var type_name = Globals.particle_type_get_name(type)
	# print("%s got %d %s" % [self, count, type_name])
	var susceptible = false
	if self.poisons.size() > 0:
		for poison_type in self.poisons:
			if not Rules.particle_type_poison_susceptible(type, poison_type):
				continue
			susceptible = true
			var potency = Rules.particle_type_get_poison_potency(type, poison_type, self.poisons)
			if potency <= 0.0:
				continue
			var poison_name = Globals.poison_type_get_name(poison_type)
			var poison_value = self.poisons[poison_type]
			var delta_poison = min(poison_value, count * potency)
			if delta_poison >= poison_value:
				susceptible = false
			self.set_poison(poison_type, poison_value - delta_poison)
			var delta_particles = max(count, ceil(delta_poison / potency))  # rounding sometimes makes the max necessary
			# print("%s %d %s breaking down %f %s" % [self, delta_particles, type_name, delta_poison, poison_name])
			n_destroyed = delta_particles
	var n_accepted = count - n_destroyed
	if susceptible:
		# print("%s %d %s died due to %s" % [self, count, type_name, self.poisons])
		n_accepted = 0
		n_destroyed = count
	# print("%s recv %d %s: %d accept, %d destroyed" % [self, count, type_name, n_accepted, n_destroyed])
	return [n_accepted, n_destroyed]

# Transfer `count` particles of type `type` from this cell to `dest`.
# This DOES update the particle_count dicts on both cells, and moves/creates/deletes particle nodes as needed.
func _send_particles(type: int, dest: Cell, count: int):
	# print("Send %d %s from %s to %s" % [count, Globals.particle_type_get_name(type), self, dest])
	var src_old_count = self.particle_counts.get(type, 0)
	var dst_old_count = dest.particle_counts.get(type, 0)
	count = min(src_old_count, count)
	var recv_result = dest._recv_particles(type, min(src_old_count, count))
	var src_new_count = src_old_count - recv_result[0] - recv_result[1]
	var dst_new_count = dst_old_count + recv_result[0]
	self.particle_counts[type] = src_new_count
	dest.particle_counts[type] = dst_new_count
	self.emit_signal("particle_count_changed", self, type, src_old_count, src_new_count)
	dest.emit_signal("particle_count_changed", self, type, dst_old_count, dst_new_count)
	var particles_transfer = []
	if self.type == Globals.CellType.NORMAL:
		_free_particle_nodes(self._take_particle_nodes(type, recv_result[1]))
		particles_transfer = self._take_particle_nodes(type, recv_result[0])
	if dest.type == Globals.CellType.NORMAL:
		dest._put_particle_nodes(particles_transfer)
		dest._put_particle_nodes(_create_particle_nodes(type, recv_result[0] - particles_transfer.size()))

### OVERRIDES
func _ready():
	$ClickArea.connect("input_event", self, "_on_cell_click")
	$Gfx.visible = false
	$Gfx.set_material($Gfx.get_material().duplicate())
	for t in Globals.ParticleType.values():
		self.particle_counts[t] = 0
		self.output_rules[t] = {}

func _process(delta):
	if auto_recipe_cooldown != 0:
		auto_recipe_cooldown = max(0, auto_recipe_cooldown - delta)
		_update_recipe_cooldown()

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
		var pressure_total = 0
		var pressure_neighbors = {}
		for n in self.neighbors:
			if not self.output_rule(t, n):
				continue
			var supply_neighbor = n.particle_counts.get(t, 0)
			var pressure_neighbor = Rules.pressure_func(supply_own, supply_neighbor)
			# print("%s neighbor %s has pressure %d" % [self, n, pressure_neighbor])
			if pressure_neighbor <= 0:
				continue  # well, if they don't want anything...
			pressure_neighbors[n] = pressure_neighbor
			pressure_total += pressure_neighbor
		var budget = Rules.budget_func(supply_own, pressure_total)
		for n in pressure_neighbors.keys():
			var pressure_neighbor = pressure_neighbors[n] / pressure_total
			var transfer = Rules.diffuse_func(budget, pressure_neighbor, delta)
			# print("%s neighbor %s normalized pressure %f %s, transfer %f" % [self, n, pressure_neighbor, particle_name, transfer])
			var valve_transfer = self._output_valves.get(n, 0) + transfer
			if valve_transfer >= 1.0:
				self._send_particles(t, n, floor(valve_transfer) as int)
				valve_transfer -= floor(valve_transfer)
			self._output_valves[n] = valve_transfer

func _process_sugar_usage(delta):
	var sugar_required = 0
	for t in particle_counts:
		sugar_required += particle_counts[t] * Rules.sugar_requirement(t) * delta
	if sugar_required == 0:
		_enable_sugar_warning(false)
		return
	var sugar_used = int(sugar_required)
	# For fractional sugars, use probability
	if sugar_required - float(sugar_used) > Rules.rng.randf():
		sugar_used += 1
	if sugar_used == 0:
		if particle_counts[Globals.ParticleType.SUGAR] > 0:
			_enable_sugar_warning(false)
		return

	# Kill things according to order
	var notEnoughSugar = false
	for t in Rules.SUGAR_DEATH_ORDER:
		if sugar_used == 0:
			break
		notEnoughSugar = t != Globals.ParticleType.SUGAR
		var old_t_count = particle_counts[t]
		if old_t_count == 0:
			continue
		var removing = min(old_t_count, sugar_used)
		sugar_used -= removing
		if Globals.particle_type_is_in_transporter(t):
			# Change type instead
			var new_t_count = old_t_count - removing
			particle_counts[t] = new_t_count
			emit_signal("particle_count_changed", self, t, old_t_count, new_t_count)
			var old_transporter_count = particle_counts[Globals.ParticleType.PROTEIN_TRANSPORTER]
			var new_transporter_count = old_transporter_count + removing
			emit_signal("particle_count_changed", self, Globals.ParticleType.PROTEIN_TRANSPORTER, old_transporter_count, new_transporter_count)
			particle_counts[Globals.ParticleType.PROTEIN_TRANSPORTER] = new_transporter_count
			for c in $Particles.get_children():
				if removing == 0:
					break
				if c is CellParticle and c.type == t:
					c.type = Globals.ParticleType.PROTEIN_TRANSPORTER
					removing -= 1
			if removing != 0:
				print("Changed t from ", old_t_count, " to ", new_t_count, " and transporter from ", old_transporter_count, " to ", new_transporter_count)
				assert(removing == 0, "Did not find particles to change")
		else:
			remove_particles(t, removing)
	_enable_sugar_warning(notEnoughSugar)
	if notEnoughSugar:
		_add_sound(Globals.PARTICLE_DIE_SOUND)

func _enable_sugar_warning(enable: bool):
	if $WarningAnimationSprite.visible != enable:
		$WarningAnimationSprite.visible = enable
		if enable:
			$WarningAnimationPlayer.play("Warning")
		else:
			$WarningAnimationPlayer.stop()

func _process_recipes(delta):
	var buttonContainer = $RecipeButtons/Container
	var recipes = Recipe.matches(particle_counts)
	for c in buttonContainer.get_children():
		var found = false
		var i = 0
		var found_i = 0
		for r in recipes:
			if r.get_name() == c.name:
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
				auto_recipe_cooldown = r.cooldown
				auto_recipe_cooldown_max = r.cooldown
				_update_recipe_cooldown()
				# Run recipe
				_craft(r)
		else:
			# Add button
			var button = TextureButton.new()
			var texture = load(Globals.particle_type_get_res(r.outputs.keys()[0], true))
			button.texture_normal = texture
			button.expand = true
			button.rect_min_size = 0.2 * texture.get_size()
			button.self_modulate.a = 0.5
			button.connect("pressed", self, "_manual_craft", [r])
			button.connect("mouse_entered", self, "_icon_enter", [button])
			button.connect("mouse_exited", self, "_icon_exit", [button])
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.name = r.get_name()
			buttonContainer.add_child(button)

func _icon_enter(b: TextureButton):
	b.self_modulate.a = 1

func _icon_exit(b: TextureButton):
	b.self_modulate.a = 0.5

func _manual_craft(r: Recipe):
	_craft(r)
	_add_sound(Globals.PARTICLE_CRAFT_SOUND)

func _craft(r: Recipe):
	for t in r.inputs:
		assert(particle_counts[t] >= r.inputs[t], "Cannot craft…")
		if !Globals.particle_type_is_factory(t):
			# Factories are not used
			remove_particles(t, r.inputs[t])
	for t in r.outputs:
		add_particles(t, r.outputs[t], false)

func _update_recipe_cooldown():
	if auto_recipe_cooldown == 0:
		auto_recipe_material.set_shader_param("percentage", 1.0)
	else:
		auto_recipe_material.set_shader_param("percentage", 1 - auto_recipe_cooldown / auto_recipe_cooldown_max)

func _on_cell_click(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			print("Clicked: %s ev: %s" % [self, event])
			Rules.select_cell(self)
			emit_signal("discover", self) # TODO this is only for debugginh
			
func _set_selected(_selected: bool):
	if _selected != self.selected:
		emit_signal("selected", self, _selected)
		selected = _selected
	$CellSelector.visible = _selected

func _get_selected() -> bool:
	return selected

func _add_sound(path: String):
	var sound = AudioStreamPlayer2D.new()
	sound.stream = load(path)
	sound.play()
	sound.connect("finished", self, "_remove_sound", [sound])
	add_child(sound)

func _remove_sound(sound: AudioStreamPlayer2D):
	remove_child(sound)
	sound.stop()
	sound.queue_free()

func _display_debug():
	$DebugLabel.visible = Rules.debug_visual
	if Rules.debug_visual:
		var dbg = "[b][i]%s[/i][/b] (%s)\n" % [self, Globals.cell_type_get_name(type)];
		dbg += "[i]Neighbors:[/i] %s\n" % [self.neighbors];
		for poison in Globals.PoisonType:
			dbg += "[b][u]%s:[/u][/b] %f\n" % [poison, self.poisons.get(Globals.PoisonType[poison], 0)]
		for particle in Globals.ParticleType:
			dbg += "[b][u]%s:[/u][/b] %d\n" % [particle, self.particle_counts.get(Globals.ParticleType[particle], 0)]
		$DebugLabel.bbcode_text = dbg
