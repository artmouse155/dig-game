extends PanelContainer

@onready var texture_panel = $MarginContainer/TextureRect
@onready var button = $Button

@onready var tile_texture : Texture2D
@onready var locked_texture : Texture2D = preload("res://Assets/Textures/UI/locked_tile.png")

var obj : DrillerComponentObject
var obj_name : String
var desc : String
var locked_desc : String

var tooltip : Control
var unlocked = true
var selected = false

var part_of_active_group = false

func setup(_obj : DrillerComponentObject, p_unlocked : bool = true, p_selected : bool = false):
	obj = _obj
	obj_name = obj.component_object_name
	desc = obj.desc
	locked_desc = obj.locked_desc
	tile_texture = obj.component_object_tile_image
	set_unlocked(p_unlocked)
	set_selected(p_selected)
	set_icon()

func _input(event):
	if part_of_active_group:
		if event is InputEventMouseMotion:
			var pos = get_local_mouse_position()
			if Rect2(Vector2.ZERO, get_size()).has_point(pos):
				setup_tooltip()
				show_tooltip()
			elif have_tooltip_control():
				lose_tooltip_control()
				hide_tootip()

func update_self():
	pass

func set_unlocked(p_unlocked : bool = true):
	unlocked = p_unlocked
	button.disabled = !unlocked

func set_selected(p_selected : bool = false):
	selected = p_selected
	$selected.visible = selected

func set_icon():
	if unlocked:
		texture_panel.texture = tile_texture
	else:
		texture_panel.texture = locked_texture

func show_tooltip():
	if tooltip != null:
		tooltip.show()
		
func hide_tootip():
	if tooltip != null:
		tooltip.hide()

func have_tooltip_control():
	if tooltip != null:
		return tooltip.active_control == self
	return false

func lose_tooltip_control():
	tooltip.active_control = null

func setup_tooltip():
	var _desc = obj_name + "\n"
	_desc += desc if unlocked else locked_desc
	if tooltip != null:
		tooltip.tile_setup(self, _desc)
