extends Resource
class_name StructureObject
#TODO: This is simple enough to maybe just be a dictionary?
@export var position: Vector2
@export var name: String

func _init(p_position: Vector2 = Vector2.ZERO, p_name: String = ""):
	position = p_position
	name = p_name
