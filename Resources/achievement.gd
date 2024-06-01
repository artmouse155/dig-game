extends Resource
class_name Achievement

@export var icon : Texture2D = preload("res://Assets/Textures/UI/buy_tile_back.png")
@export var achievement_name : String
@export var achievement_desc : String
@export var achievement_trigger : Trigger
@export var resource_rewards : Array[ResourceData]
