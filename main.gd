extends Node2D

var Cell = preload("res://cells/cell.gd")

func _ready():
	var cell0 = $HexGrid.create_cell(0, 0) as Cell
	cell0.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)
	var cell1 = $HexGrid.create_cell(1,0)
	cell0.set_output_rule(Globals.ParticleType.PROTEIN_WHITE, cell1, true)
