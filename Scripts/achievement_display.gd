extends Node2D

@export var achievement_grid : GridContainer
@export var achievement_tile : PackedScene

@export var tooltip : Control

func _ready():
	var achievement_list = Game.get_all_achievements()
	for i in range(len(achievement_list)):
		var achievement_grid_icon = achievement_tile.instantiate()
		achievement_grid_icon.setup(achievement_list[i], false)
		achievement_grid_icon.tooltip = tooltip
		achievement_grid.add_child(achievement_grid_icon)

func _input(event):
	if event is InputEventMouseMotion:
		tooltip.position = get_local_mouse_position() + Vector2(1,1)
