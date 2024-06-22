extends Resource
class_name GlobalData

@export var prev_save_name : String = ""
@export_enum("Windowed", "FullScreen") var display_mode: String = "Windowed"
#@export var window_coords: Vector2i = Vector2i.ZERO

func _init(p_prev_save_name : String = ""):
	prev_save_name = p_prev_save_name
