class_name Tech

# The tech enum entry which it unlocks
var tech: int
var unlocks: Array

func _init(tech_this: int, tech_unlocks: Array):
	self.tech = tech_this
	self.unlocks = tech_unlocks

# Gets called to initialize an undiscovered/uncaptured Cell
func apply_tech_on_init(cell: Cell):
	match self.tech:
		Globals.TechType.A:
			cell.add_particles(Globals.ParticleType.QUEEN, 1) # example

# Gets called when 
func apply_tech_on_capture(cell: Cell):
	match self.tech:
		Globals.TechType.A:
			cell.add_particles(Globals.ParticleType.PRO_QUEEN, 1) # example
