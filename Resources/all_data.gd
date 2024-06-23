extends Resource
class_name AllData

@export var all_driller_component_groups : Array[DrillerComponentGroup] = [
	preload("res://Resources/Shop Data/all_hulls.tres"),
	preload("res://Resources/Shop Data/all_drills.tres"),
	preload("res://Resources/Shop Data/all_batteries.tres"),
	preload("res://Resources/Shop Data/all_engines.tres"),
	preload("res://Resources/Shop Data/all_boosts.tres"),
	preload("res://Resources/Shop Data/all_miscs.tres"),
]
@export var all_achievements : Array[Achievement] = [
	preload("res://Resources/Achievements/go_fast.tres"),
]
