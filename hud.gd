extends Control
class_name Hud

func _ready():
	for t in Globals.ParticleType.values():
		if Rules.particle_type_rendered_in_hud(t):
			var t_entry = preload("res://hud_info_entry.tscn").instance()
			t_entry.particle_type = t
			t_entry.count = 0
			$VBoxContainer.add_child(t_entry)

func track_cell(cell):
	for entry in $VBoxContainer.get_children():
		entry.count += cell.particle_counts.get(entry.particle_type, 0)
	cell.connect("particle_count_changed", self, "_cell_particle_count_changed")

func untrack_cell(cell):
	cell.disconnect("particle_count_changed", self, "_cell_particle_count_changed")
	for entry in $VBoxContainer.get_children():
		entry.count -= cell.particle_counts.get(entry.particle_type, 0)

func _cell_particle_count_changed(cell, particle_type, old_count, new_count):
	for entry in $VBoxContainer.get_children():
		if entry.particle_type == particle_type:
			entry.count -= old_count
			entry.count += new_count
			break
