extends PanelContainer

@export var debug_v_box : VBoxContainer
@export var debug_check_box: CheckBox

var touching_mouse := false
var am_pressed := false
var am_dragging := false

var checkboxes_to_update: Array[CheckBox] = []

func _ready():
	debug_check_box.button_pressed = Debug.debug
	
	for i in range(len(Debug.settings.keys())):
		var h_box = HBoxContainer.new()
		var key := str(Debug.settings.keys()[i])
		#print(key + " is " + str(Debug.settings[key]))
		var label = Label.new()
		label.text = key.capitalize()
		var checkbox = CheckBox.new()
		checkbox.button_pressed = Debug.settings[key]
		checkbox.toggled.connect(set_debug_value_from_checkbox.bind(key))
		checkboxes_to_update.append(checkbox)
		h_box.add_child(checkbox)
		h_box.add_child(label)
		debug_v_box.add_child(h_box)
	update_self()

func set_debug_debug(value: bool):
	Debug.debug = value
	update_self()
	
func update_self():
	var debug_value = Debug.debug
	
	debug_v_box.modulate.a = 1 if debug_value else .5
	
	for box in checkboxes_to_update:
		box.disabled = not debug_value

func set_debug_value_from_checkbox( value: bool, setting_key: String):
	Debug.settings[setting_key] = value
	print(setting_key + " is set to " + str(value))

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
