extends Node2D

var Cell = preload("res://cells/cell.gd")

func _ready():
	OS.set_window_title("Hackathon 2020")

	$HexGrid.generate_grid(5)

	$HexGrid.discover_cell($HexGrid.create_cell(1,0))
	$HexGrid.discover_cell($HexGrid.create_cell(2,0))
	$HexGrid.discover_cell($HexGrid.create_cell(1,1))

	# debug_populate()

	var edges = $HexGrid.get_undirected_node_connections()
	for connection in edges:
		var start_pos = $HexGrid.create_cell(connection[0].x, connection[0].y).position
		var end_pos = $HexGrid.create_cell(connection[1].x, connection[1].y).position
		var middle = 0.5 * (start_pos + end_pos)
		var the_angle = (start_pos.direction_to(end_pos)).angle()
		# print("the middle of "+str(start_pos)+" and "+str(end_pos)+" is "+str(middle)+ ", angl "+str(the_angle))
		$HexGrid.draw_tunnels(middle, the_angle)

func debug_populate():
	var cell1 = $HexGrid.create_cell(0, 0)  # 1-indexed becase that matches get_index() on the cells, in this case

	# remove poison first, else any particles you add will just die :(
	cell1.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell1.add_particles(Globals.ParticleType.PROTEIN_WHITE, 40)
	cell1.add_particles(Globals.ParticleType.AMINO_PHE, 1)

	var cell2 = $HexGrid.create_cell(1,0)
	cell2.poison_recoveries = {Globals.PoisonType.ANTI_BIOMASS: [0.001, 1.0]}

	var cell3 = $HexGrid.create_cell(0,1)
	cell3.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell3.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)

	var cell4 = $HexGrid.create_cell(0,-1)
	cell4.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell4.add_particles(Globals.ParticleType.PROTEIN_WHITE, 60)
	cell4.add_particles(Globals.ParticleType.RIBOSOME_ALCOHOL, 1)

	var cell5 = $HexGrid.create_cell(-1,-1)
	cell5.set_poison(Globals.PoisonType.ALCOHOL, 1.0)
	
	var cell6 = $HexGrid.create_cell(-1,0)
	cell6.set_poison(Globals.PoisonType.ANTI_BIOMASS, 0.0)
	cell6.add_particles(Globals.ParticleType.ANTI_MITOCHONDRION, 1)
	cell6.type = Globals.CellType.RESOURCE

	cell1.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell2, true)
	cell1.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell3, true)
	cell2.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell4, true)
	cell3.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell2, true)
	cell4.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell1, true)
	cell4.set_output_rule(Globals.ParticleType.ENZYME_ALCOHOL, cell5, true)
	cell1.set_output_rule(Globals.ParticleType.PROTEIN_TRANSPORTER, cell6, true)
	cell6.set_output_rule(Globals.ParticleType.SUGAR, cell1, true)
