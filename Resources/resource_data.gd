extends Resource
class_name ResourceData

@export var res_name: String
@export var amount: int

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_res_name = "ore", p_amount = 10):
	res_name = p_res_name
	amount = p_amount

func changed_by(a : int) -> ResourceData:
	return ResourceData.new(res_name, amount + a)

static func compare(shop_r_d : ResourceData, player_r_d : ResourceData):
	if shop_r_d.res_name != player_r_d.res_name:
		return null
	return player_r_d.amount >= shop_r_d.amount

#returns true only if the player can afford every part of the cost.
static func compare_all(shop_r_ds : Array[ResourceData], player_r_ds : Array[ResourceData]):
	for i in range(len(shop_r_ds)):
		var shop_data = shop_r_ds[i]
		var found = false
		for j in range(len(player_r_ds)):
			var player_data = player_r_ds[j]
			if shop_data.res_name == player_data.res_name:
				if compare(shop_data, player_data):
					found = true
					break
				else:
					return false
		if not found:
			return false
				
	return true
