extends Node2D

var _old_selection = []

func _ready():
	Rules.connect("selection_changed", self, "_selection_changed")

static func _add_particle_counts(dest: Dictionary, add: Dictionary):
	for t in add:
		dest[t] = dest.get(t, 0) + add[t]

func _selection_changed(new_selection):
	for cell in _old_selection:
		cell.disconnect("particle_count_changed", self, "_particle_count_change")
	_old_selection = new_selection
	var total = {}
	for cell in new_selection:
		cell.connect("particle_count_changed", self, "_particle_count_change")
		_add_particle_counts(total, cell.particle_counts)
	$HudLayer/Hud.set_particle_counts(total)
	
func _particle_count_change(cell, type, old_count, new_count):
	$HudLayer/Hud.update_particle_count(type, new_count - old_count)
