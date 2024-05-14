extends Resource
class_name DrillerComponentObject

@export var component_object_name : String
@export var parent_group_name : String
@export var component_object_tile_image : Texture2D = preload("res://Assets/Textures/UI/buy_tile_back.png")
@export var actual_texture : Texture2D
@export var offset : Vector2
@export var desc : String
@export var locked_desc : String
@export var upgrade_lists : Array[UpgradeList]
@export var base_buffs : Array[BuffItem]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_component_object_name = "TEST_DRILL", p_parent_group_name = "drill",  p_actual_texture = Texture2D.new(), p_offset = Vector2.ZERO, p_component_object_tile_image = Texture2D.new(), p_desc = "", p_locked_desc = "", p_upgrade_lists : Array[UpgradeList]  = [], p_base_buffs : Array[BuffItem] = []):
	component_object_name = p_component_object_name
	parent_group_name = p_parent_group_name
	component_object_tile_image = p_component_object_tile_image
	actual_texture = p_actual_texture
	offset = p_offset
	desc = p_desc
	locked_desc = p_locked_desc
	upgrade_lists = p_upgrade_lists
	base_buffs = p_base_buffs
