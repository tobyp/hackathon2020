extends Control
class_name Hud

func _ready():
	for t in Globals.ParticleType.values():
		if Rules.particle_type_rendered_in_hud(t):
			var t_entry = preload("res://hud_info_entry.tscn").instance()
			t_entry.particle_type = t
			t_entry.count = 0
			$VBoxContainer.add_child(t_entry)


func set_particle_counts(counts: Dictionary):
	for entry in $VBoxContainer.get_children():
		entry.count = counts.get(entry.particle_type, 0)

func update_particle_count(type: int, count: int):
	for entry in $VBoxContainer.get_children():
		if entry.particle_type == type:
			entry.count += count
			break
