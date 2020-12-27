class_name Tech

# The tech enum entry which it unlocks
var tech_type: int
var amount_min: int
var amount_max: int
var probability: float
var is_final: bool
var current: int = 0

func _init(_tech_type: int, _amount_min: int, _amount_max: int, _probability: float, _is_final: bool = false):
	self.tech_type = _tech_type
	self.amount_min = _amount_min
	self.amount_max = _amount_max
	self.probability = _probability
	self.is_final = _is_final

func _to_string():
	return "%s %d of [%d:%d] %d%%" % [Globals.get_enum_name(Globals.TechType, self.tech_type), self.current, self.amount_min, self.amount_max, int(self.probability * 100)]
