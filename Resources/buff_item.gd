extends Resource
class_name BuffItem

@export var buff_name: String
@export var amount: float

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_buff_name = "ore", p_amount = 10.0):
	buff_name = p_buff_name
	amount = p_amount
