extends VBoxContainer

var states = ["closed", "openLeft", "openRight", "openBoth"]
var state_index = 0



func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			state_index = (state_index + 1) % 4
			modulate = Color(1,state_index/4.0, 1)

