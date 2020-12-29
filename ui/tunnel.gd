extends Node2D

var particle_type: int
var color: Color
var start_cell: Cell
var end_cell: Cell

const DISABLED_ARROW_ALPHA = 0.35

func setup():
	self.color = Globals.particle_type_get_color(particle_type)
	$in_arrow.modulate = self.color
	$out_arrow.modulate = self.color
	
	$in_arrow.connect("button_down", self, "toggle_output_rule", [end_cell, particle_type, start_cell])
	$out_arrow.connect("button_down", self, "toggle_output_rule", [start_cell, particle_type, end_cell])
	start_cell.connect("output_rule_changed", self, "output_rule_changed")
	end_cell.connect("output_rule_changed", self, "output_rule_changed")

	var in_rule = end_cell.output_rule(particle_type, start_cell)
	self.output_rule_changed(start_cell, end_cell, particle_type, in_rule, in_rule)
	var out_rule = start_cell.output_rule(particle_type, end_cell)
	self.output_rule_changed(end_cell, start_cell, particle_type, out_rule, out_rule)

func toggle_output_rule(cell: Cell, type: int, neighbor: Cell):
	var old = cell.output_rule(type, neighbor)
	cell.set_output_rule(type, neighbor, not old)

func output_rule_changed(cell, neighbor, type, old_rule, new_rule):
	if type != particle_type:
		return
	var tex: TextureButton = null;
	if cell == start_cell and neighbor == end_cell:
		tex = get_node("out_arrow")
	elif cell == end_cell and neighbor == start_cell:
		tex = get_node("in_arrow")
	else:
		return
	var reverse_rule = neighbor.output_rule(type, cell)
	if not new_rule and not reverse_rule:
		$in_arrow.modulate.a = DISABLED_ARROW_ALPHA
		$out_arrow.modulate.a = DISABLED_ARROW_ALPHA
	elif new_rule:
		$in_arrow.modulate.a = 1.0
		$out_arrow.modulate.a = 1.0
	if new_rule:
		tex.texture_normal = preload("res://ui/arrowhead.png")
	else:
		tex.texture_normal = preload("res://ui/arrowshaft.png")

func _to_string():
	return "Tunnel for %s" % [Globals.particle_type_get_name(particle_type)]
