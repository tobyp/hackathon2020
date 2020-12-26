extends Camera2D

# Middle click
var dragging = false
var startPos
# Keyboard
var moveVec = Vector2(0, 0)

const CAM_MIN = 0.5
const CAM_MAX = 5.0
const KEY_MOVE = 20.0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			dragging = event.is_pressed()
			if event.is_pressed():
				startPos = event.position
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom /= 1.2
			if zoom.x < CAM_MIN:
				zoom = Vector2(CAM_MIN, CAM_MIN)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom *= 1.2
			if zoom.x > CAM_MAX:
				zoom = Vector2(CAM_MAX, CAM_MAX)
	elif event is InputEventMouseMotion and dragging:
		position += (startPos - event.position) * zoom
		startPos = event.position
	elif event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_W:
				moveVec.y = -KEY_MOVE
			elif event.get_scancode() == KEY_A:
				moveVec.x = -KEY_MOVE
			elif event.get_scancode() == KEY_S:
				moveVec.y = KEY_MOVE
			elif event.get_scancode() == KEY_D:
				moveVec.x = KEY_MOVE
		else:
			if event.get_scancode() == KEY_W or event.get_scancode() == KEY_S:
				moveVec.y = 0
			elif event.get_scancode() == KEY_A or event.get_scancode() == KEY_D:
				moveVec.x = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO use delta here
	position += moveVec * zoom
