extends Node2D
class_name Cell

### SIGNALS
signal particle_count_changed(type, old_count, new_count)

### MEMBERS
# A list of all existing neighbors (Will be modified from the hexgrid manager)
var neighbors = []
# Amino acid counts include a transporter, transporter count only means free transporter
var particle_counts = {}
var output_rules = []  # List[Dict[Cell, bool]]
var discovered: bool = true

### UTILITY
# Are particles of type `type` allowed to be pushed to `neighbor`?
# Note, there is no `input_rule(type, neighbor)`, use `neighbor.output_rule(type, self)` instead
func output_rule(type, neighbor) -> bool:
	return output_rules[type].get(neighbor, false)


# Transfer `count` particles of type `type` from this cell to `dest`.
# This should take care of updating the particle_count dicts on both cells, and any actual particle nodes flying around.
func push_particles(type: int, dest: Object, count: int):
	pass  # TODO

# Called every game step.
func simulate():
	_process_pressure()
	_process_potential_recipes()
	_display_debug()

### OVERRIDES
# Called when the node enters the scene tree for the first time.
func _ready():
	$Gfx.set_material($Gfx.get_material().duplicate())
	for t in Globals.ParticleType:
		self.particle_counts[t] = 0
		self.output_rules.append({})


func _process_pressure():
	for t in Globals.ParticleType:
		var supply = self.particle_counts.get(t, 0)
		var demand_total = 0
		var demand_neighbors = {}
		for n in self.neighbors:
			if not self.output_rule(t, n):
				continue
			var supply_neighbor = n.particle_counts.get(t, 0)
			if supply_neighbor > supply:
				continue
			var demand_neighbor = supply - supply_neighbor
			demand_neighbors[n] = demand_neighbor
			demand_total += demand_neighbor
		# TODO: tobyp


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
