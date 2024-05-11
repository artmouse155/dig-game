extends Resource
class_name UpgradeList

@export var upgrade_name : String
@export var desc : String
@export var upgrades : Array[Upgrade]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_upgrade_name = "Durability", p_desc = "", p_upgrades : Array[Upgrade]  = []):
	upgrade_name = p_upgrade_name
	desc = p_desc
	upgrades = p_upgrades
