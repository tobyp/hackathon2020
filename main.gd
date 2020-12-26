extends Node2D

var Cell = preload("res://cells/cell.gd")

func _ready():
	var cell0 = $HexGrid.create_cell(0, 0) as Cell
	cell0.add_particles(Globals.ParticleType.PROTEIN_WHITE, 40)
	cell0.biomass = 1.0
	var cell1 = $HexGrid.create_cell(1,0)
	cell1.biomass = 1.0
	var cell2 = $HexGrid.create_cell(0,1)
	cell2.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)
	cell2.biomass = 1.0
	var cell3 = $HexGrid.create_cell(1,1)
	cell3.add_particles(Globals.ParticleType.PROTEIN_WHITE, 60)
	cell3.biomass = 1.0
	
	cell0.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell1, true)
	cell0.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell2, true)
	cell0.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell3, true)
	
	var edges = $HexGrid.get_undirected_node_connections()
	for connection in edges:
		var start_pos = $HexGrid.create_cell(connection[0].x, connection[0].y).global_position
		var end_pos = $HexGrid.create_cell(connection[1].x, connection[1].y).global_position
		var middle = 0.5 * (start_pos + end_pos)
		$HexGrid.draw_tunnels(middle, 0.0)
