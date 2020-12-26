extends Node2D

var Cell = preload("res://cells/cell.gd")

func _ready():
	var cell0 = $HexGrid.create_cell(0, 0) as Cell
	cell0.add_particles(Globals.ParticleType.PROTEIN_WHITE, 20)
	$HexGrid.create_cell(2,0)
	$HexGrid.create_cell(1,1)
	$HexGrid.create_cell(0,-1)
