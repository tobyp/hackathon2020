extends Node2D
class_name HexGrid

const hex_size = 1024.0
const size_y = hex_size * 3.0/4.0
const size_x = hex_size * sin(60.0 /360.0*2*PI)

var grid = {}
var timer: Timer

onready var CellTscn = load("res://cells/cell.tscn")
onready var TunnelsTscn = load("res://ui/ui.tscn")

func _ready():
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = Globals.SIMULATION_TICK_PERIOD
	timer.one_shot = false
	timer.connect("timeout", self, "_simulate_tick")
	add_child(timer)

func _simulate_tick():
	for cell in self.grid.values():
		cell.simulate(timer.wait_time) # TODO: can we get the actual elapsed time?

func draw_tunnels(position, rotation):
	var tunnelCollection = TunnelsTscn.instance()
	# completely ignore the passed position?!
	tunnelCollection.translate(Vector2(position.x, position.y))
	tunnelCollection.rotate(rotation)
	add_child(tunnelCollection)

func get_undirected_node_connections():
	# mappings of all "(start_x, start_y)" to lists of Vector2s [(end_x, end_y), (end_x2, end_y2)]]
	var known_connections = {}
	# lists of unique tuples (okay, lists) of Vector2s
	var undirected_connections = []
	for cell in self.grid.values():
		var node_coords = cell.pos
		known_connections[node_coords] = []
		var local_neighbors = get_neighbors_coord(node_coords.x, node_coords.y)
		for neigh_coords in local_neighbors:
			if neigh_coords in grid: # if the neighbor actually exists
				# print(str(cell) + " is connected to " + str(neigh_coords) + ".")
				known_connections[node_coords].append(neigh_coords)
				var already_known = false
				for vector_tuple in undirected_connections:
					if neigh_coords in vector_tuple and node_coords in vector_tuple:
						already_known = true
				if not already_known:
					undirected_connections.append([node_coords, neigh_coords])
	# print("starts and stops:", known_connections)
	print("unique edges: ",undirected_connections)
	return undirected_connections

# Creates a new cell or returns if it already exists
func create_cell(x: int, y: int):
	var pos = Vector2(x, y)
	var cell = grid.get(pos, null)
	if cell == null:
		cell = CellTscn.instance()
		cell.pos = pos
		var pos_x = size_x * (float(x) + 0.5 if y % 2 != 0 else float(x))
		var pos_y = size_y * y - (size_y / 2)
		add_child(cell)
		cell.translate(Vector2(pos_x, pos_y))
		grid[pos] = cell
	var to_update = get_neighbors_coord(x,y)
	to_update.append(pos)
	_update_neighbors(to_update)
	return cell

# Returns the cell or null if empty
func get_cell(x: int, y: int):
	var pos = Vector2(x, y)
	return grid.get(pos, null)

func _update_neighbors(cells_idx: Array):
	for cell_idx in cells_idx:
		var cell = get_cell(cell_idx.x, cell_idx.y)
		if cell == null:
			continue
		cell.neighbors = get_neighbors(cell_idx.x, cell_idx.y)

func remove_cell(x: int, y: int):
	var pos = Vector2(x, y)
	if grid.has(pos):
		var cell = grid.get(pos)
		grid.remove(pos)
		remove_child(cell)
		
		var to_update = get_neighbors_coord(x,y)
		_update_neighbors(to_update)

func get_neighbors(x: int, y: int) -> Array:
	var cells = []
	for pos in get_neighbors_coord(x, y):
		var cell = grid.get(pos, null)
		if cell != null:
			cells.append(cell)
	return cells

enum Dirs {
	R
	TR
	TL
	L
	BL
	BR
}
const oddr_directions = [
	[[+1,  0], [ 0, -1], [-1, -1],
	 [-1,  0], [-1, +1], [ 0, +1]],
	[[+1,  0], [+1, -1], [ 0, -1],
	 [-1,  0], [ 0, +1], [+1, +1]],
]
func get_neighbors_coord(x: int, y: int) -> Array:
	var parity = y & 1
	var cells = []
	for n in oddr_directions[parity]:
		cells.append(Vector2(n[0] + x, n[1] + y))
	return cells


func _cube_to_oddr(cube: Cube) -> Hex:
	var col = cube.x + (cube.z - (cube.z&1)) / 2
	var row = cube.z
	return Hex.new(col, row)

func _oddr_to_cube(hex: Hex) -> Cube:
	var x = hex.col - (hex.row - (hex.row&1)) / 2
	var z = hex.row
	var y = -x-z
	return Cube.new(x, y, z)

func generate_grid():
	#var rng = RandomNumberGenerator.new()
	#rng.randomize()
	#var start = rng.randi_range(0, 5)
	for dir in Dirs.values():
		var pos = Hex.new(0, 0)
		for star in range(6):
			pos = pos.plus(dir)
			create_cell(pos.row, pos.col)

class Hex:
	var row
	var col
	func _init(_row, _col):
		self.row = _row
		self.col = _col
	func as_vec() -> Vector2:
		return Vector2(self.row, self.row)
	func plus(dir: int) -> Hex:
		var mset = oddr_directions[col & 1]
		var vec = mset[dir]
		return Hex.new(row + vec[0], col + vec[1])

class Cube:
	var x
	var y
	var z
	func _init(_x, _y, _z):
		self.x = _x
		self.y = _y
		self.z = _z
