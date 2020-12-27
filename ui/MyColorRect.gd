extends ColorRect



var states = ["closed", "openLeft", "openRight", "openBoth"]
var state_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			state_index = (state_index + 1) % 4
			color = Color(1,state_index/4.0,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
