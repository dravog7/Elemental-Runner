extends CanvasLayer

var left_touch_id = -1
var right_touch_id = -1

var left_center = Vector2(200, 520)
var right_center = Vector2(1080, 520)
var joy_radius = 100.0

var move_vector = Vector2.ZERO
var aim_vector = Vector2.ZERO
var is_aiming = false

@onready var left_knob = $LeftKnob
@onready var right_knob = $RightKnob
@onready var element_buttons = $ElementButtons

func _ready():
	if not OS.has_feature("mobile") and not DisplayServer.is_touchscreen_available():
		hide()
		set_process_input(false)
		return
	
	$ElementButtons/FireBtn.pressed.connect(func(): get_tree().call_group("player", "set_active_element", 1))
	$ElementButtons/WaterBtn.pressed.connect(func(): get_tree().call_group("player", "set_active_element", 2))
	$ElementButtons/IceBtn.pressed.connect(func(): get_tree().call_group("player", "set_active_element", 3))
	
	$LeftBase.position = left_center - Vector2(100, 100)
	$RightBase.position = right_center - Vector2(100, 100)
	left_knob.position = left_center - Vector2(50, 50)
	right_knob.position = right_center - Vector2(50, 50)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().size.x / 2.0:
				if left_touch_id == -1:
					left_touch_id = event.index
					left_center = event.position
					$LeftBase.position = left_center - Vector2(100, 100)
					left_knob.position = left_center - Vector2(50, 50)
					move_vector = Vector2.ZERO
			else:
				if is_touching_buttons(event.position):
					return
					
				if right_touch_id == -1:
					right_touch_id = event.index
					right_center = event.position
					$RightBase.position = right_center - Vector2(100, 100)
					right_knob.position = right_center - Vector2(50, 50)
					aim_vector = Vector2.ZERO
					is_aiming = true
		else:
			if event.index == left_touch_id:
				left_touch_id = -1
				move_vector = Vector2.ZERO
				Input.action_release("ui_left")
				Input.action_release("ui_right")
				Input.action_release("ui_up")
				Input.action_release("ui_down")
				left_knob.position = left_center - Vector2(50, 50)
			elif event.index == right_touch_id:
				right_touch_id = -1
				if is_aiming and aim_vector.length() > 0.1:
					get_tree().call_group("player", "shoot_from_virtual", aim_vector)
				is_aiming = false
				aim_vector = Vector2.ZERO
				right_knob.position = right_center - Vector2(50, 50)

	elif event is InputEventScreenDrag:
		if event.index == left_touch_id:
			var dir = event.position - left_center
			if dir.length() > joy_radius:
				dir = dir.normalized() * joy_radius
			left_knob.position = left_center + dir - Vector2(50, 50)
			move_vector = dir / joy_radius
			update_left_input()
		elif event.index == right_touch_id:
			var dir = event.position - right_center
			if dir.length() > joy_radius:
				dir = dir.normalized() * joy_radius
			right_knob.position = right_center + dir - Vector2(50, 50)
			aim_vector = dir / joy_radius

func is_touching_buttons(pos: Vector2) -> bool:
	for btn in element_buttons.get_children():
		var rect = Rect2(btn.global_position, btn.size)
		if rect.has_point(pos):
			btn.pressed.emit()
			return true
	return false

func update_left_input():
	var threshold = 0.3
	if move_vector.x < -threshold:
		Input.action_press("ui_left")
		Input.action_release("ui_right")
	elif move_vector.x > threshold:
		Input.action_press("ui_right")
		Input.action_release("ui_left")
	else:
		Input.action_release("ui_left")
		Input.action_release("ui_right")

	if move_vector.y < -threshold:
		Input.action_press("ui_up")
		Input.action_release("ui_down")
	elif move_vector.y > threshold:
		Input.action_press("ui_down")
		Input.action_release("ui_up")
	else:
		Input.action_release("ui_up")
		Input.action_release("ui_down")
