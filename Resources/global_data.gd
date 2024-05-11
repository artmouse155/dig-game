extends Resource
class_name GlobalData

@export var prev_save_name : String = ""

func _init(p_prev_save_name : String = ""):
    prev_save_name = p_prev_save_name