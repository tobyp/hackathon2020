extends Node2D

##############################
# TODO own Resources here (?)
##############################

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		# More biomass
		var cur = $Gfx.material.get_shader_param("percentage")
		if event.button_index == BUTTON_LEFT:
			$Gfx.material.set_shader_param("percentage", min(1.0, cur + 0.2))
		else:
			$Gfx.material.set_shader_param("percentage", max(0.0, cur - 0.2))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
