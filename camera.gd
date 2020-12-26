extends Camera2D

# Middle click
var dragging = false
var startPos
# Keyboard
var moveVec = Vector2.ZERO
# Edge panning
var edgePanVec = Vector2.ZERO

const ZOOM_MIN = 1.0
const ZOOM_MAX = 5.0
const KEY_PAN_SPEED = 1970.0 / 2.0  # 2.0 is default zoom
const EDGE_PAN_SPEED = KEY_PAN_SPEED

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			dragging = event.is_pressed()
			if event.is_pressed():
				startPos = event.position
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom /= 1.2
			if zoom.x < ZOOM_MIN:
				zoom = Vector2(ZOOM_MIN, ZOOM_MIN)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom *= 1.2
			if zoom.x > ZOOM_MAX:
				zoom = Vector2(ZOOM_MAX, ZOOM_MAX)
	elif event is InputEventMouseMotion:
		if dragging:
			position += (startPos - event.position) * zoom
			startPos = event.position
		edgePanVec = Vector2.ZERO
		if OS.window_fullscreen:
			if event.position.x == 0:
				 edgePanVec.x = -EDGE_PAN_SPEED
			elif event.position.x >= OS.window_size.x - 1:
				edgePanVec.x = EDGE_PAN_SPEED
			if event.position.y == 0:
				 edgePanVec.y = -EDGE_PAN_SPEED
			elif event.position.y >= OS.window_size.y - 1:
				edgePanVec.y = EDGE_PAN_SPEED
	elif event is InputEventKey:
		if event.is_pressed():
			if event.get_scancode() == KEY_W:
				moveVec.y = -KEY_PAN_SPEED
			elif event.get_scancode() == KEY_A:
				moveVec.x = -KEY_PAN_SPEED
			elif event.get_scancode() == KEY_S:
				moveVec.y = KEY_PAN_SPEED
			elif event.get_scancode() == KEY_D:
				moveVec.x = KEY_PAN_SPEED
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
	position += moveVec * zoom * delta
	position += edgePanVec * zoom * delta
