extends Node2D
class_name HexGrid

const hex_size = 1024.0
const size_y = hex_size * 3.0/4.0
const size_x = hex_size * sin(60.0 /360.0*2*PI)

var grid = {}
var timer

onready var CellTscn = load("res://cells/cell.tscn")

func _ready():
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.1
	timer.one_shot = false
	timer.connect("timeout", self, "_simulate_tick")
	add_child(timer)

func _simulate_tick():
	for node in self.grid.values():
		node.cell.simulate()

# Creates a new cell or returns if it already exists
func create_cell(x: int, y: int):
	var pos = Vector2(x, y)
	var node = grid.get(pos, null)
	if node == null:
		var cell = CellTscn.instance()
		node = GridNode.new(cell, Vector2(x,y))
		var pos_x = size_x * (float(x) + 0.5 if y % 2 != 0 else float(x))
		var pos_y = size_y * y - (size_y / 2)
		add_child(cell)
		cell.translate(Vector2(pos_x, pos_y))
		grid[pos] = node
	var to_update = get_neighbors_coord(x,y)
	to_update.append(pos)
	_update_neighbors(to_update)
	return node.cell

# Returns the cell or null if empty
func get_cell(x: int, y: int):
	var pos = Vector2(x, y)
	var node = grid.get(pos, null)
	if node == null:
		return null
	return node.cell

func _update_neighbors(cells_idx: Array):
	for cell_idx in cells_idx:
		var cell = get_cell(cell_idx.x, cell_idx.y)
		if cell == null:
			continue
		cell.neighbors = get_neighbors(cell_idx.x, cell_idx.y)

func remove_cell(x: int, y: int):
	var pos = Vector2(x, y)
	if grid.has(pos):
		var node = grid.get(pos)
		grid.remove(pos)
		remove_child(node.cell)
		
		var to_update = get_neighbors_coord(x,y)
		_update_neighbors(to_update)

const neighbors = [Vector2(-1, -1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]
func get_neighbors(x: int, y: int) -> Array:
	var cells = []
	for n in neighbors:
		var pos = Vector2(x, y) + n
		var node = grid.get(pos, null)
		if node != null:
			cells.append(node.cell)
	return cells

func get_neighbors_coord(x: int, y: int):
	var cells = []
	for n in neighbors:
		cells.append(Vector2(x, y) + n)
	return cells

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

class GridNode:
	# The GD node element
	var cell  # : Cell
	var pos: Vector2

	func _init(cell: Node, pos: Vector2):
		self.cell = cell
		self.pos = pos

	func _to_string():
		return "Cell %s" % pos
