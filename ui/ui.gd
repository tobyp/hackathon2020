extends Node2D

var tunnels = []
var head_png
var shaft_png

enum TunnelState {
	OPEN_LEFT,
	OPEN_RIGHT,
	OPEN_BOTH,
	CLOSED
}

class Tunnel:
	var name
	var color: Color
	var state: int

	func _init(_name: String, _color: Color, _state:int):
		self.name = _name
		self.color = _color
		self.state = _state

	func _to_string():
		return "Tunnel for %s, colored %s " % [name, color]

# Called when the node enters the scene tree for the first time.
func _ready():
	head_png = preload("res://ui/arrowhead.png")
	shaft_png = preload("res://ui/arrowshaft.png")
	tunnels.append((Tunnel.new(Globals.particle_type_get_name(Globals.ParticleType.AMINO_PHE), Color.green, TunnelState.OPEN_LEFT)))
	tunnels.append((Tunnel.new(Globals.particle_type_get_name(Globals.ParticleType.AMINO_ALA), Color.yellow, TunnelState.OPEN_BOTH)))
	tunnels.append((Tunnel.new(Globals.particle_type_get_name(Globals.ParticleType.AMINO_LYS), Color.cyan, TunnelState.OPEN_RIGHT)))
	tunnels.append((Tunnel.new(Globals.particle_type_get_name(Globals.ParticleType.AMINO_TYR), Color.violet, TunnelState.OPEN_BOTH)))
	tunnels.append((Tunnel.new(Globals.particle_type_get_name(Globals.ParticleType.AMINO_PRO), Color.pink, TunnelState.CLOSED)))

func _iterate_state(x):
	print("button clicked")
	print(x)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for x in range(tunnels.size()):
		
		var leftarrow = preload("res://ui/arrow.tscn").instance()
		leftarrow.modulate = Color(tunnels[x].color)
		leftarrow.position.y += 44*x
		add_child(leftarrow)
		var leftarrow_texture = leftarrow.get_child(0) as TextureButton
		
		if (tunnels[x].state == TunnelState.OPEN_LEFT or tunnels[x].state == TunnelState.OPEN_BOTH):
			leftarrow_texture.texture_normal = head_png # default
		else:
			leftarrow_texture.texture_normal = shaft_png
		
		leftarrow_texture.connect("button_down", self, "_iterate_state")
		
		var rightarrow = preload("res://ui/arrow.tscn").instance()
		rightarrow.modulate = Color(tunnels[x].color)
		rightarrow.rotation += 3.14159
		
		rightarrow.position.x += 32
		
		rightarrow.position.y += 44*x
		add_child(rightarrow)
		var rightarrow_texture = rightarrow.get_child(0) as TextureButton
		
		if (tunnels[x].state == TunnelState.OPEN_RIGHT or tunnels[x].state == TunnelState.OPEN_BOTH):
			rightarrow_texture.texture_normal = head_png # default
		else:
			rightarrow_texture.texture_normal = shaft_png
