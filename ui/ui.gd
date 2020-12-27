extends Node2D

var tunnels = []
var head_png
var shaft_png

var start_cell
var end_cell

var possible_particle_types

enum TunnelState {
	OPEN_LEFT,
	OPEN_RIGHT,
	OPEN_BOTH,
	CLOSED
}

class Tunnel:
	var particle_type: int
	var color: Color
	var state: int
	var leftarrow
	var rightarrow

	func _init(_name: int, _color: Color, _state:int):
		self.particle_type = _name
		self.color = _color
		self.state = _state

	func _to_string():
		return "Tunnel for %s, colored %s " % [Globals.particle_type_get_name(particle_type), color]


# Called when the node enters the scene tree for the first time.
func _ready():
	head_png = preload("res://ui/arrowhead.png")
	shaft_png = preload("res://ui/arrowshaft.png")
	
	possible_particle_types = [
		[Globals.ParticleType.PROTEIN_WHITE, Color.gray],
		[Globals.ParticleType.PROTEIN_TRANSPORTER, Color.green],
		[Globals.ParticleType.ENZYME_ALCOHOL, Color.yellow],
		[Globals.ParticleType.ENZYME_LYE, Color.cyan],
		[Globals.ParticleType.AMINO_PHE, Color.green],
		[Globals.ParticleType.AMINO_ALA, Color.yellow],
		[Globals.ParticleType.AMINO_LYS, Color.cyan],
		[Globals.ParticleType.AMINO_TYR, Color.violet],
		[Globals.ParticleType.AMINO_PRO, Color.pink],
		[Globals.ParticleType.SUGAR, Color.white]
	]
	for entry in possible_particle_types:
		var particle_type = entry[0]
		var color = entry[1]
		var state = _calculate_tunnel_state(particle_type, start_cell, end_cell)
		tunnels.append(Tunnel.new(particle_type, color, state))
	# for x in range(tunnels.size()):
	for x in range(tunnels.size()):
		var leftarrow = preload("res://ui/arrow.tscn").instance()
		tunnels[x].leftarrow = leftarrow
		leftarrow.modulate = Color(tunnels[x].color)
		leftarrow.position.y += 44*x - 200
		leftarrow.scale.x = 2
		leftarrow.scale.y = 2
		add_child(leftarrow)
		var leftarrow_texture = leftarrow.get_child(0) as TextureButton
		
		if (tunnels[x].state == TunnelState.OPEN_RIGHT or tunnels[x].state == TunnelState.OPEN_BOTH):
			leftarrow_texture.texture_normal = head_png # default
		else:
			leftarrow_texture.texture_normal = shaft_png
		
		tunnels[x].leftarrow.get_child(0).connect("button_down", self, "_iterate_state", [x])
		
		var rightarrow = preload("res://ui/arrow.tscn").instance()
		tunnels[x].rightarrow = rightarrow
		rightarrow.modulate = Color(tunnels[x].color)
		rightarrow.rotation += 3.14159
		
		rightarrow.position.x += 32
		rightarrow.scale.x = 3
		rightarrow.scale.y = 2
		
		rightarrow.position.y += 44*x - 200
		add_child(rightarrow)
		var rightarrow_texture = rightarrow.get_child(0) as TextureButton
		
		if (tunnels[x].state == TunnelState.OPEN_LEFT or tunnels[x].state == TunnelState.OPEN_BOTH):
			rightarrow_texture.texture_normal = head_png # default
		else:
			rightarrow_texture.texture_normal = shaft_png

func _iterate_state(h):
	# todo use toby's fancy getter instead of illegally accessing the dict directly
	print("inverting the output rule from ",start_cell," to ",end_cell," for type ",h)
	var global_particle_type = possible_particle_types[h][0]
	# print("particle type is ", global_particle_type)
	print(start_cell.output_rules[global_particle_type])

	var rules_for_type = start_cell.output_rules[global_particle_type]
	# if there are no rules for the particle type, or no rule for the end_cell, we add one
	if rules_for_type == {} or not rules_for_type.has(end_cell):
		start_cell.set_output_rule(global_particle_type, end_cell, false)
	else: # flip it! (for now..) TODO: iterate state, don't just flip the bools
		start_cell.set_output_rule(global_particle_type, end_cell, !rules_for_type[end_cell])
	print("  value is now ",start_cell.output_rules[global_particle_type][end_cell])
	print("todo: update the opposite output rule (from end to start)")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# print("start cell: ",start_cell.output_rules.size())
	pass


func _calculate_tunnel_state(particle_type, start_cell, end_cell):
	var state
	var open_left = false
	var open_right = false
	if (end_cell in start_cell.output_rules[particle_type]):
		open_right = true
	if (start_cell in end_cell.output_rules[particle_type]):
		open_left = true
	if (open_right and open_left):
		state = TunnelState.OPEN_BOTH
	elif (open_right):
		state = TunnelState.OPEN_RIGHT
	elif (open_left):
		state = TunnelState.OPEN_LEFT
	else:
		state = TunnelState.CLOSED
	return state
