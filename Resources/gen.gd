extends Resource
class_name Gen

@export var name : String = ""
@export var health : int = 50
@export var value : float = 0
@export var atlas : Array[Vector2i] = []
@export var min_depth : int = 0
@export var max_depth : int = 99999
@export var min_freq : float = 0
@export var max_freq : float = 1
@export_enum("linear", "bell", "smooth", "constant") var curve: String = "constant"
@export_enum("randf", "smooth") var noise: String = "smooth"
@export var group : String = ""

var noise_res : Noise
