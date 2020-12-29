extends Node2D

var tunnels = []
var start_cell
var end_cell

# Called when the node enters the scene tree for the first time.
func _ready():
	# calculate state, save references to UI nodes
	var i = 0
	for particle_type in Rules.TUNNEL_TYPES:
		var color = Globals.particle_type_get_color(particle_type)
		var tunnel = preload("res://ui/tunnel.tscn").instance()
		tunnel.particle_type = particle_type
		tunnel.start_cell = start_cell
		tunnel.end_cell = end_cell
		tunnel.setup()
		tunnel.position.y += 44*i - 200
		add_child(tunnel)
		i += 1
