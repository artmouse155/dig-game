extends Resource
class_name Trigger

@export var trigger_stat_name : String = "max_depth"
@export_enum("greater_than", "equal_to", "less_than", "greater_than_or_equal_to", "less_than_or_equal_to") var trigger_stat_comparison: String = "greater_than"
@export var trigger_stat_value : float = 10

# NOTE: This exists because of the bug report I had earlier. basically this is the only
# way that I can assign null triggers to components.
@export var is_null: bool = false

func is_met(val) -> bool:
	match trigger_stat_comparison:
		"greater_than":
			return (val > trigger_stat_value)
		"equal_to":
			return (val == trigger_stat_value)
		"less_than":
			return (val < trigger_stat_value)
		"greater_than_or_equal_to":
			return (val >= trigger_stat_value)
		"less_than_or_equal_to":
			return (val <= trigger_stat_value)
	print("error, trigger_stat_comparison not found:" + trigger_stat_comparison)
	return false

func init(p_trigger_stat_name: String = "max_depth", p_trigger_stat_comparison: String = "greater_than", p_trigger_stat_value: float = 10):
	trigger_stat_name = p_trigger_stat_name
	trigger_stat_comparison = p_trigger_stat_comparison
	trigger_stat_value = p_trigger_stat_value
