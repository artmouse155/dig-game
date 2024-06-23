extends PanelContainer

var touching_mouse := false
var am_pressed := false
var am_dragging := false

func _ready():
	pass

func mouse_entered_func():
	touching_mouse = true
	
func mouse_exited_func():
	touching_mouse = false
	
func gui_input_func(ev : InputEvent):
	if ev is InputEventMouseButton:
		am_pressed = ev.pressed
		am_dragging = am_pressed and touching_mouse
	if ev is InputEventMouseMotion:
		if am_dragging:
			position += ev.relative

func _input(_event):
	if Input.is_action_just_pressed("toggle_debug_screen"):
		visible = !visible
