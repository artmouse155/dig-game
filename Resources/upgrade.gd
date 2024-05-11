extends Resource
class_name Upgrade

@export var cost_list: Array[ResourceData]
@export var buff_list: Array[BuffItem]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_cost_list : Array[ResourceData] = [], p_buff_list : Array[BuffItem] = []):
	cost_list = p_cost_list
	buff_list = p_buff_list
