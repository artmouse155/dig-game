extends Node2D

@export var player_data: PlayerData

@export var hull_node: TextureRect
@export var drill_node: TextureRect
#the height of the drill texture is our drill radius

@export var treads_node: TextureRect

@export var battery_node: TextureRect
@export var engine_node: TextureRect
@export var boost_node: TextureRect

@export var drill_center: Control
@export var polygon: Polygon2D

@export var turbo_particles: GPUParticles2D
@export var animation_player: AnimationPlayer
#@export var intermediate_damage_curve : Curve
@export var area_2d: Area2D
@export var collision_shape: CollisionShape2D

var player_scale = 1

var current_driller_mode: int = Game.DrillerMode.DRILL

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
	set_component_visual_data(treads_node, player_data.treads)

func get_drill_center() -> Control:
	return drill_center

func set_component_visual_data(component: Node, data: DrillerComponentObject):
	if component and data:
		var offset = data.offset
		component.texture = data.actual_texture
		component.get_parent().position = offset
		if data is Hull:
			collision_shape.shape.size = component.texture.get_size()

func set_player_scale(_scale: float):
	player_scale = _scale
	if hull_node:
		scale = player_scale * Vector2.ONE

func is_global_point_in_polygon(pt: Vector2):
	return Geometry2D.is_point_in_polygon(pt - polygon.global_position, polygon.polygon)

func set_driller_mode(mode: int):
	if mode != current_driller_mode:
		current_driller_mode = mode
		if mode == Game.DrillerMode.DRILL:
			animation_player.play("treads_to_drill")
		elif mode == Game.DrillerMode.TREADS:
			animation_player.play("drill_to_treads")
