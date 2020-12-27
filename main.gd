extends Node2D

var Cell = preload("res://cells/cell.gd")

func _ready():
	OS.set_window_title("Hackathon 2020")

	var cell0 = $HexGrid.create_cell(0, 0) as Cell
	# remove poison first, else any particles you add will just die :(
	cell0.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell0.add_particles(Globals.ParticleType.PROTEIN_WHITE, 40)
	cell0.add_particles(Globals.ParticleType.QUEEN, 1)
	cell0.add_particles(Globals.ParticleType.AMINO_PHE, 1)

	var cell1 = $HexGrid.create_cell(1,0)

	var cell2 = $HexGrid.create_cell(0,1)
	cell2.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell2.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)

	var cell3 = $HexGrid.create_cell(0,-1)
	cell3.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell3.add_particles(Globals.ParticleType.PROTEIN_WHITE, 60)

	cell0.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell1, true)
	cell0.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell2, true)
	cell3.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell0, true)

	var edges = $HexGrid.get_undirected_node_connections()
	for connection in edges:
		var start_pos = $HexGrid.create_cell(connection[0].x, connection[0].y).position
		var end_pos = $HexGrid.create_cell(connection[1].x, connection[1].y).position
		var middle = 0.5 * (start_pos + end_pos)
		var the_angle = (start_pos.direction_to(end_pos)).angle()
		print("the middle of "+str(start_pos)+" and "+str(end_pos)+" is "+str(middle)+ ", angl "+str(the_angle))
		$HexGrid.draw_tunnels(middle, the_angle)
