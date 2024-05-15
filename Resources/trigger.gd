extends Resource
class_name Trigger

@export var trigger_stat_name : String = "max_depth"
@export_enum("greater_than", "equal_to", "less_than", "greater_than_or_equal_to", "less_than_or_equal_to") var trigger_stat_comparison: String = "greater_than"
@export var trigger_stat_value : float = 10

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