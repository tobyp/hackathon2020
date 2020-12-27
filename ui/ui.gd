extends Node2D

var tunnels = []
var head_png
var shaft_png

var start_cell
var end_cell

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
	# 	cell2.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell4, true)
	
	var possible_particle_types = [
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
	
	for x in range(tunnels.size()):
		var leftarrow = preload("res://ui/arrow.tscn").instance()
		tunnels[x].leftarrow = leftarrow
		leftarrow.modulate = Color(tunnels[x].color)
		leftarrow.position.y += 44*x
		add_child(leftarrow)
		var leftarrow_texture = leftarrow.get_child(0) as TextureButton
		
		if (tunnels[x].state == TunnelState.OPEN_RIGHT or tunnels[x].state == TunnelState.OPEN_BOTH):
			leftarrow_texture.texture_normal = head_png # default
		else:
			leftarrow_texture.texture_normal = shaft_png
		
		tunnels[x].leftarrow.get_child(0).connect("button_down", self, "_iterate_state", [x,"left"])
		
		var rightarrow = preload("res://ui/arrow.tscn").instance()
		tunnels[x].rightarrow = rightarrow
		rightarrow.modulate = Color(tunnels[x].color)
		rightarrow.rotation += 3.14159
		
		rightarrow.position.x += 32
		
		rightarrow.position.y += 44*x
		add_child(rightarrow)
		var rightarrow_texture = rightarrow.get_child(0) as TextureButton
		
		if (tunnels[x].state == TunnelState.OPEN_LEFT or tunnels[x].state == TunnelState.OPEN_BOTH):
			rightarrow_texture.texture_normal = head_png # default
		else:
			rightarrow_texture.texture_normal = shaft_png

func _iterate_state(h):
	print("button clicked")
	print(h)


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
