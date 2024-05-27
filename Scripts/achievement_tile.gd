extends PanelContainer

@export var texture_panel : TextureRect

@export var tile_texture : Texture2D = preload("res://Assets/Textures/UI/buy_tile_back.png")
@export var locked_modulate : Color

var achievement : Achievement
var a_name : String
var desc : String

var tooltip : Control
var unlocked = true

var part_of_active_group = true

func setup(_achievement : Achievement, p_unlocked : bool = true, _p_selected : bool = false):
	achievement = _achievement
	a_name = _achievement.achievement_name
	desc = _achievement.achievement_desc
	tile_texture = _achievement.icon
	set_unlocked(p_unlocked)
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
	if unlocked:
		modulate = Color.WHITE
	else:
		modulate = locked_modulate

func set_icon():
	texture_panel.texture = tile_texture

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
	if tooltip != null:
		tooltip.achievement_setup(self, achievement)
