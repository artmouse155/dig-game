extends Node2D

@export var player_data : PlayerData

@export var hull_node : TextureRect
@export var drill_node : TextureRect
@export var battery_node : TextureRect
@export var engine_node : TextureRect
@export var boost_node : TextureRect

var player_scale = 1

func _ready():
	player_data = Game.player_data
	if player_data:
		build_player()
	
func build_player():
	set_player_scale(player_data.hull.drill_scale)
	#set_component_visual_data(hull_node, player_data.hull.offset)
	set_component_visual_data(hull_node, player_data.hull)
	set_component_visual_data(drill_node, player_data.drill)
	set_component_visual_data(battery_node, player_data.battery)
	set_component_visual_data(engine_node, player_data.engine)
	set_component_visual_data(boost_node, player_data.boost)

func set_component_visual_data(component : Node, data : DrillerComponentObject):
	if component:
		var offset = data.offset
		component.texture = data.actual_texture
		component.get_parent().position = offset
		

func set_player_scale(_scale : float):
	player_scale = _scale
	if hull_node:
		scale = player_scale * Vector2.ONE
