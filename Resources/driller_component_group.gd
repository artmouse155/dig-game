extends Resource
class_name DrillerComponentGroup

@export var component_group_name : String
@export var desc : String
@export var component_objects : Array[DrillerComponentObject]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_component_group_name = "Drill", p_desc = "", p_component_objects : Array[DrillerComponentObject]  = []):
	component_group_name = p_component_group_name
	desc = p_desc
	component_objects = p_component_objects
