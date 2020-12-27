extends AudioStreamPlayer

const MUSIC_LIST = [
	# Echo by Crowander under CC-BY-NC 4.0, https://freemusicarchive.org/music/crowander/cinematic-minimals/echo-1
	"Crowander_Echo",
	# Soft Freeze by Crowander under CC-BY-NC 4.0, https://freemusicarchive.org/music/crowander/cinematic-minimals/soft-freeze
	"Crowander_Soft-Freeze",
]

var cur_index = 0

func _set_stream(i: int):
	stream = load("res://sounds/%s.ogg" % MUSIC_LIST[i])
	play()

func _next_song():
	cur_index = (cur_index + 1) % len(MUSIC_LIST)
	_set_stream(cur_index)

func _ready():
	connect("finished", self, "_next_song")
	_set_stream(cur_index)
