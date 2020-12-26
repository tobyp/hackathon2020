extends Node2D

const hex_size = 1024.0
const size_y = hex_size * 3.0/4.0
const size_x = hex_size * sin(60.0 /360.0*2*PI)

var grid = {}

func _ready():
	create_cell(0,0)
	create_cell(2,0)
	create_cell(1,1)
	create_cell(0,-1)
	
	print(get_neighbours(0,0))

# Creates a new cell or returns if it already exists
func create_cell(x: int, y: int):
	var pos = Vector2(x, y)
	var cell = grid.get(pos, null)
	if cell == null:
		var node = preload("res://cells/cell.tscn").instance()
		cell = GridNode.new(node, Vector2(x,y))
		var pos_x = size_x * (float(x) + 0.5 if y % 2 != 0 else float(x))
		var pos_y = size_y * y - (size_y / 2)
		add_child(node)
		node.translate(Vector2(pos_x, pos_y))
		grid[pos] = cell
	return cell

func remove_cell(x: int, y: int):
	var pos = Vector2(x, y)
	if grid.has(pos):
		var cell = grid.get(pos)
		grid.remove(pos)
		remove_child(cell.node)

const neighbours = [Vector2(-1, -1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]
func get_neighbours(x: int, y: int):
	var cells = []
	for n in neighbours:
		var pos = Vector2(x, y) + n
		var cell = grid.get(pos, null)
		if cell != null:
			cells.append(cell)
	return cells

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

class GridNode:
	# The GD node element
	var node: Resource
	var pos: Vector2
	# Whether the cell is already visible
	var visible: bool = true

	func _init(node: Resource, pos: Vector2):
		self.node = node
		self.pos = pos
	
	func _to_string():
		return "Cell %s" % pos
