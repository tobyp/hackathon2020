class_name Tech

# The tech enum entry which it unlocks
var tech: int
var unlocks: Array

func _init(tech_this: int, tech_unlocks: Array):
	self.tech = tech_this
	self.unlocks = tech_unlocks
