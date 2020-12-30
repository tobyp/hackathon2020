extends Node2D

var Cell = preload("res://cells/cell.gd")

func _ready():
	OS.set_window_title("Hackathon 2020")

	$HexGrid.generate_grid(2)
	# $HexGrid.discover_cell($HexGrid.create_cell(1,0))
	# $HexGrid.discover_cell($HexGrid.create_cell(2,0))
	# $HexGrid.discover_cell($HexGrid.create_cell(1,1))

	debug_populate()

	var edges = $HexGrid.get_undirected_node_connections()
	for connection in edges:
		var start_cell = $HexGrid.create_cell(connection[0].x, connection[0].y)
		var start_pos = start_cell.position
		var end_cell = $HexGrid.create_cell(connection[1].x, connection[1].y)
		var end_pos = end_cell.position
		var middle = 0.5 * (start_pos + end_pos)
		var the_angle = (start_pos.direction_to(end_pos)).angle()
		# print("the middle of "+str(start_pos)+" and "+str(end_pos)+" is "+str(middle)+ ", angl "+str(the_angle))
		$HexGrid.create_tunnels(middle, the_angle, start_cell, end_cell)
		
	$AnimationPlayer.play("CameraZoomIn")

func debug_populate():
	var cell1 = $HexGrid.create_cell(0, 0)  # 1-indexed becase that matches the names in _to_string
	cell1.init_captured()
	cell1.add_particles(Globals.ParticleType.PROTEIN_WHITE, 400)
	cell1.add_particles(Globals.ParticleType.AMINO_PHE, 1)

	var cell2 = $HexGrid.create_cell(1,0)
	cell2.init_empty()
	cell2.toxin_recoveries = {Globals.ToxinType.ANTI_BIOMASS: [0.001, 1.0]}

	var cell3 = $HexGrid.create_cell(0,1)
	cell3.init_captured()
	cell3.add_particles(Globals.ParticleType.PROTEIN_WHITE, 40)
	cell3.add_particles(Globals.ParticleType.AMINO_TYR, 1)
	#cell3.add_particles(Globals.ParticleType.QUEEN, 1)

	var cell4 = $HexGrid.create_cell(0,-1)
	cell4.init_captured()
	cell4.add_particles(Globals.ParticleType.PROTEIN_WHITE, 60)
	cell4.add_particles(Globals.ParticleType.AMINO_ALA, 1)
	cell4.add_particles(Globals.ParticleType.ENZYME_ALCOHOL, 52)
	#cell4.add_particles(Globals.ParticleType.RIBOSOME_ALCOHOL, 1)

	var cell5 = $HexGrid.create_cell(-1,-1)
	cell5.init_toxin(Globals.ToxinType.ALCOHOL)

	var cell6 = $HexGrid.create_cell(-1,0)
	cell6.init_resource(Globals.ParticleType.ANTI_MITOCHONDRION)

	# "A Diffusion of Whites"
	#cell1.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell2, true)
	#cell1.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell3, true)
	#cell2.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell4, true)
	#cell3.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell2, true)
	#cell4.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell1, true)

	# Sugar production
	#cell1.set_output_rule(Globals.ParticleType.PROTEIN_TRANSPORTER, cell6, true)
	#cell6.set_output_rule(Globals.ParticleType.SUGAR, cell1, true)
	# Sugar transport
	#cell1.set_output_rule(Globals.ParticleType.SUGAR, cell2, true)
	#cell2.set_output_rule(Globals.ParticleType.SUGAR, cell1, true)
	#cell1.set_output_rule(Globals.ParticleType.SUGAR, cell3, true)
	#cell3.set_output_rule(Globals.ParticleType.SUGAR, cell1, true)
	#cell1.set_output_rule(Globals.ParticleType.SUGAR, cell4, true)
	#cell4.set_output_rule(Globals.ParticleType.SUGAR, cell1, true)
	#cell2.set_output_rule(Globals.ParticleType.PROTEIN_TRANSPORTER, cell1, true)
	#cell3.set_output_rule(Globals.ParticleType.PROTEIN_TRANSPORTER, cell1, true)
	#cell4.set_output_rule(Globals.ParticleType.PROTEIN_TRANSPORTER, cell1, true)

	# Breaking down the Alcohol
	#cell4.set_output_rule(Globals.ParticleType.ENZYME_ALCOHOL, cell5, true)
	#cell4.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell5, true)
