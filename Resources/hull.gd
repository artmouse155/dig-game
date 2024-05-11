extends DrillerComponentObject
class_name Hull

@export var drill_scale : float = 1

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_drill_scale = 0.0):
	drill_scale = p_drill_scale
