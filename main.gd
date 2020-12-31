extends Node2D

onready var hex_grid = $Game.get_node("HexGrid")

func _ready():
	hex_grid.connect("cell_selection_state_changed", self, "_grid_cell_selection_state_changed")

func _grid_cell_selection_state_changed(grid, cell, selection_state):
	if selection_state:
		$HudLayer/Hud.track_cell(cell)
	else:
		$HudLayer/Hud.untrack_cell(cell)

func _grid_cell_type_changed(grid, cell, old_type, new_type):
	var win = true
	for cell in hex_grid.cells.values():
		if Rules.cell_blocks_win(cell):
			win = false
			break
	if win:
		print("You win!")
