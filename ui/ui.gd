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
		
	func iterate_tunnelState():
		state = (state + 1)%4

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
	# calculate state, save references to UI nodes
	for entry in possible_particle_types:
		var particle_type = entry[0]
		var color = entry[1]
		var state = _calculate_tunnel_state(particle_type, start_cell, end_cell)
		tunnels.append(Tunnel.new(particle_type, color, state))

	for x in range(tunnels.size()):
		# identical for each arrow
		var arrows = [preload("res://ui/arrow.tscn").instance(), preload("res://ui/arrow.tscn").instance()]
			
		tunnels[x].leftarrow = arrows[0]
		tunnels[x].rightarrow = arrows[1]
		tunnels[x].leftarrow.get_child(0).connect("button_down", self, "_iterate_state", [x])
		tunnels[x].rightarrow.get_child(0).connect("button_down", self, "_iterate_state", [x])
		
		for arrow in arrows:
			arrow.modulate = Color(tunnels[x].color)
			arrow.position.y += 44*x - 200
			arrow.scale.x = 2
			arrow.scale.y = 2
			add_child(arrow)
			
		# different for each arrow
		arrows[1].position.x += 32
		arrows[1].rotation += 3.14159
		
		_set_arrow_texture_based_on_tunnelState(x)
		
func _set_arrow_texture_based_on_tunnelState(tunnel_idx):
	var leftarrow_texture = tunnels[tunnel_idx].leftarrow.get_child(0) as TextureButton
	var rightarrow_texture = tunnels[tunnel_idx].rightarrow.get_child(0) as TextureButton

	if (tunnels[tunnel_idx].state == TunnelState.OPEN_LEFT or tunnels[tunnel_idx].state == TunnelState.OPEN_BOTH):
		leftarrow_texture.texture_normal = head_png # default
	else:
		leftarrow_texture.texture_normal = shaft_png

	if (tunnels[tunnel_idx].state == TunnelState.OPEN_RIGHT or tunnels[tunnel_idx].state == TunnelState.OPEN_BOTH):
		rightarrow_texture.texture_normal = head_png # default
	else:
		rightarrow_texture.texture_normal = shaft_png

func _iterate_state(h):
	# update internal ui tunnelState
	tunnels[h].iterate_tunnelState()
	# update graphics to match the state
	_set_arrow_texture_based_on_tunnelState(h)
	
	# update the output rules to match the state
	var global_particle_type = possible_particle_types[h][0]
	var tunnel_state = tunnels[h].state
	
	var left_to_right_is_open = (tunnel_state == TunnelState.OPEN_BOTH or tunnel_state == TunnelState.OPEN_RIGHT)
	start_cell.set_output_rule(global_particle_type, end_cell, left_to_right_is_open)
	
	var right_to_left_is_open = (tunnel_state == TunnelState.OPEN_BOTH or tunnel_state == TunnelState.OPEN_LEFT)
	end_cell.set_output_rule(global_particle_type, start_cell, right_to_left_is_open)

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
