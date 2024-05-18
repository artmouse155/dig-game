@tool

@icon("res://Animated Button/animated_button_icon.svg")
## An animated button with customizable color and text.
class_name AnimatedButton extends MarginContainer

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var top_panel : PanelContainer = $BaseTopMargin/TopMargin/TopPanel
@onready var bottom_trim : Panel = $BaseBottomMargin/BottomTrim
@onready var text_box : RichTextLabel = $BaseTopMargin/TopMargin/TopPanel/TextMargin/CenterContainer/ButtonText

@export_multiline var button_text : String = "Animated Button?":
	get:
		return button_text
	set(value):
		#push_warning("text!", name, value)
		button_text = value
		if Engine.is_editor_hint():
			update_text()
		

@export_flags("Bold", "Italic") var spell_elements : int = 0:
	get:
		return spell_elements
	set(value):
		spell_elements = value
		if Engine.is_editor_hint():
			update_text()

@export var text_color : Color = Color.WHITE:
	get:
		return text_color
	set(value):
		text_color = value
		if Engine.is_editor_hint():
			#print("button color set to: ", button_color)
			update_text()

@export var font_size : int = 16:
	get:
		return font_size
	set(value):
		font_size = value
		if Engine.is_editor_hint():
			update_text()

@export var button_color : Color = Color(0.66796875, 0, 0):
	get:
		return button_color
	set(value):
		button_color = value
		if Engine.is_editor_hint():
			#print("button color set to: ", button_color)
			update_button_color()

@export var disabled_color : Color = Color.WEB_GRAY:
	get:
		return disabled_color
	set(value):
		disabled_color = value
		if Engine.is_editor_hint():
			#print("button color set to: ", button_color)
			update_button_color()

var the_style_box : StyleBoxFlat
var the_dark_style_box : StyleBoxFlat

@export var disabled : bool = false:
	get:
		return disabled
	set(value):
		disabled = value
		update_button_color()
		if disabled:
			play_anim("pressed")
		else:
			play_anim("pressed_and_exit")

#@export_category("Reference")
#@export var base_scene : PackedScene

var touching_mouse : bool = false
var am_pressed : bool = false

signal pressed

func _ready():
	update_text()
	update_button_color()

func update_text():
	if text_box:
		var temp_text = "[color=#" + text_color.to_html(false) + "][font_size={" + str(font_size) +"}]" + button_text + "[/font_size][/color]"
		#print("bold is ", (spell_elements >> 0) % 2)
		#print("italic is ", (spell_elements >> 1) % 2)
		if ((spell_elements >> 0) % 2):
			temp_text = "[b]" + temp_text + "[/b]"
		if ((spell_elements >> 1) % 2):
			temp_text = "[i]" + temp_text + "[/i]"
		text_box.text = temp_text

func update_button_color():
	var the_color = button_color if (not disabled) else disabled_color
	
	if top_panel and bottom_trim:
				the_style_box = top_panel.get("theme_override_styles/panel").duplicate()
				the_style_box.bg_color = the_color
				top_panel.set("theme_override_styles/panel", the_style_box)
				the_dark_style_box = the_style_box.duplicate()
				the_dark_style_box.bg_color = the_color.darkened(.2)
				bottom_trim.set("theme_override_styles/panel", the_dark_style_box)

func mouse_entered_func():
	touching_mouse = true
	if !disabled:
		play_anim("hover")
	
func mouse_exited_func():
	touching_mouse = false
	if !disabled:
		if not am_pressed:
			play_anim("hover_exit")
	
func gui_input_func(ev : InputEvent):
	if ev is InputEventMouseButton:
		am_pressed = ev.pressed
		if !disabled:
			if am_pressed:
				play_anim("pressed")
			else:
				if not touching_mouse:
					play_anim("pressed_and_exit")
				else:
					play_anim("released")
					pressed.emit()

func play_anim(anim_name : String):
	#print(anim_name)
	if not (anim_name == anim_player.get_current_animation()):
		anim_player.stop(true)
	anim_player.play(anim_name)

func _set_disabled(d : bool = true):
	disabled = d
