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

func create_tunnels(position, rotation, start_cell, end_cell):
	var tunnelCollection = TunnelsTscn.instance()
	tunnelCollection.translate(Vector2(position.x, position.y))
	tunnelCollection.rotate(rotation)
	tunnelCollection.start_cell = start_cell
	tunnelCollection.end_cell = end_cell
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
	print("We have " + str(grid.size()) + " cells, " + str(undirected_connections.size()) + " connections, and 99 problems.")
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

var tech_tree;
func generate_grid(size: int):
	tech_tree = Rules.new_tech_tree()

	# Generate Basic Space
	var root = create_cell(0,0)

	for s in range(1, size):
		var ring = _get_ring(s)
		for hex in ring:
			var cell = create_cell(hex.x, hex.y)
			cell.ring_level = s
			cell.connect("selected", self, "_cell_selected")
			cell.connect("type_changed", self, "_cell_type_changed")
	
	discover_cell(root)

func _cell_selected(cell, selection_state):
	if Rules.cell_is_discoverable(cell):
		discover_cell(cell)

func _cell_type_changed(cell, old_type, new_type):
	var win = true
	for cell in grid.values():
		if Rules.cell_blocks_win(cell):
			win = false
			break
	if win:
		print("You win!")

func discover_cell(cell):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if cell.type != Globals.CellType.UNDISCOVERED:
		print("Cell %s already discovered" % [cell])
		return

	print("Discovered %s on ring %d" % [cell, cell.ring_level])
	# Set empty by default, the tech events can override this
	cell.type = Globals.CellType.EMPTY
	
	if cell.ring_level >= tech_tree.size():
		print("No tech for ", cell)
		return # we are out of technologies
	var tech_ring = tech_tree[cell.ring_level]
	var fields_in_ring = _ring_size(cell.ring_level)
	var discovered = 0
	var to_fill = 0
	for tech in tech_ring:
		discovered += tech.current
		if tech.current < tech.amount_min:
			to_fill += tech.amount_min - tech.current
	var remaining_empty = fields_in_ring - discovered
	for tech in tech_ring:
		if tech.amount_max != -1 and tech.current >= tech.amount_max:
			continue
		if to_fill >= remaining_empty or rng.randf() <= tech.probability:
			tech.current += 1
			Rules.apply_tech(tech.tech_type, cell)
			print("Applying %s to cell %s" % [tech, cell])
			if tech.is_final:
				break
	print("Tech on %s done" % cell)

func _get_ring(size: int) -> Array:
	if size == 0:
		return []
	var coords = []
	var hex = Hex.new(0,0)
	for r in range(size):
		hex = hex.plus(Dirs.BL)
	for dir in Dirs.values():
		for _r in range(size):
			coords.append(hex.as_vec())
			hex = hex.plus(dir)
	return coords

func _ring_size(size: int) -> int:
	return size * 6

class Hex:
	var x
	var y
	func _init(_x, _y):
		self.x = _x
		self.y = _y
	func as_vec() -> Vector2:
		return Vector2(self.x, self.y)
	func plus(dir: int) -> Hex:
		var mset = oddr_directions[y & 1]
		var vec = mset[dir]
		return Hex.new(x + vec[0], y + vec[1])
