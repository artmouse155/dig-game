extends Resource
class_name PlayerData

@export var hull : Hull
@export var drill : DrillerComponentObject
@export var battery : DrillerComponentObject
@export var engine : DrillerComponentObject
@export var boost : DrillerComponentObject
@export var treads : DrillerComponentObject
@export var misc : DrillerComponentObject

@export var saved_component_data : Array[ComponentObjectSaveData]
@export var player_inventory : Array[ResourceData] = [
	ResourceData.new("ore", 0),
	ResourceData.new("red_gem", 0),
	ResourceData.new("green_gem", 0),
	ResourceData.new("blue_gem", 0),
	ResourceData.new("plasma", 0),
]

#STOP ALLOWING YOU TO INIT AFTER THIS LINE -->
#@export var record_depth : int = 0
#@export var day_number : int = 0
#@export var completed_tutorial : bool = false

@export var stats : Dictionary = {
	"all_time" : {
		"total_depth" : 0,
		"total_ore" : 0,
		"total_green_gems" : 0,
		"total_blue_gems" : 0,
		"total_red_gems" : 0,
		"total_plasma" : 0,
		"total_powerups_collected" : 0,
		"total_boosts_used" : 0,
		"total_blocks_broken" : 0,
		"total_speed" : 0,
		"total_time_mining" : 0 # in seconds
		},
	"per_day" : {
		"max_depth" : 0,
		"max_ore" : 0,
		"max_green_gems" : 0,
		"max_blue_gems" : 0,
		"max_red_gems" : 0,
		"max_plasma" : 0,
		"max_powerups_collected" : 0,
		"max_boosts_used" : 0,
		"max_blocks_broken" : 0,
		"max_speed" : 0,
		"max_time_mining" : 0 # in seconds
		},
	"other" : {
		"day_number" : 0,
		"completed_tutorial" : false,
		"ore_spent" : 0,
		"green_gems_spent" : 0,
		"blue_gems_spent" : 0,
		"red_gems_spent" : 0,
		"plasma_spent" : 0,
		"upgrades_bought" : 0
	}
}

@export var achievement_completed_data : Dictionary = {}

#func _init(p_hull = null, p_drill = null, p_battery = null, p_engine = null, p_boost = null, p_misc = null, p_saved_component_data : Array[ComponentObjectSaveData] = [], p_player_inventory : Array[ResourceData] = []):
#	hull = p_hull
#	drill = p_drill
#	battery = p_battery
#	engine = p_engine
#	boost = p_boost
#	misc = p_misc
#	saved_component_data = p_saved_component_data
#	player_inventory = p_player_inventory

func get_resource_amount(p_res_name : String):
	for i in range(len(player_inventory)):
		if player_inventory[i].res_name == p_res_name:
			return player_inventory[i].amount
	print("ERROR: resource \"" + p_res_name + "\" not found!")
	return null

func set_resource_amount(p_res_name : String, p_amount : int):
	for i in range(len(player_inventory)):
		if player_inventory[i].res_name == p_res_name:
			player_inventory[i].amount = p_amount
			return null
	print("ERROR: resource \"" + p_res_name + "\" not found!")

func add_resource_amount(p_res_name : String, p_amount : int):
	for i in range(len(player_inventory)):
		if player_inventory[i].res_name == p_res_name:
			player_inventory[i].amount += p_amount
			return null
	print("ERROR: resource \"" + p_res_name + "\" not found!")

func set_component_upgrade_level(obj : DrillerComponentObject, upgrade_list_index : int, level : int):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		component_save.unlocked_upgrade_nums[upgrade_list_index] = level
	else:
		print("ERROR: component \"" + obj.component_object_name + "\" not found!")

func get_component_upgrade_level(obj : DrillerComponentObject, upgrade_list_index : int):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		return component_save.unlocked_upgrade_nums[upgrade_list_index]
	else:
		print("ERROR: component \"" + obj.component_object_name + "\" not found!")
		return null

func get_component_unlock_status(obj : DrillerComponentObject):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		return component_save.unlocked
	else:
		print("ERROR: component \"" + str(obj) + "\" not found!")
		return null

func unlock_component(obj : DrillerComponentObject, p_unlock : bool = true):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		component_save.unlocked = p_unlock
	else:
		print("ERROR: component \"" + obj.component_object_name + "\" not found!")

func get_component_find_order(obj : DrillerComponentObject):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		return component_save.find_order
	else:
		print("ERROR: component \"" + str(obj) + "\" not found!")
		return null

func set_component_find_order(obj : DrillerComponentObject, p_find_order : int):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		component_save.find_order = p_find_order
	else:
		print("ERROR: component \"" + obj.component_object_name + "\" not found!")

func get_component_recipe_found_status(obj : DrillerComponentObject):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		return component_save.recipe_found
	else:
		print("ERROR: component \"" + str(obj) + "\" not found!")
		return null

func set_found_recipe_for_component(obj : DrillerComponentObject, p_recipe_found : bool = true):
	var component_save : ComponentObjectSaveData = find_component_object_save_data(obj)
	if component_save:
		component_save.recipe_found = p_recipe_found
	else:
		print("ERROR: component \"" + obj.component_object_name + "\" not found!")

func find_component_object_save_data(obj : DrillerComponentObject, create_new_if_missing : bool = true):
	if obj:
		for i in range(len(saved_component_data)):
			if obj.component_object_name == saved_component_data[i].base_component.component_object_name:
				return saved_component_data[i]
		if create_new_if_missing:
			var component_save = ComponentObjectSaveData.new(obj)
			saved_component_data.append(component_save)
			print("Created save data for \"" + obj.component_object_name + "\". Length of saved component data: " + str(len(saved_component_data)))
			return component_save
	return null

func get_buffs_list():
	var unmerged_buffList : Array[BuffItem] = []
	
	#first, just get all the buffs. then, combine them.
	for obj in [hull, drill, battery, engine, boost, misc]:
		if obj:
			#first grab base buffs
			for i in range(len(obj.base_buffs)):
				unmerged_buffList.append(obj.base_buffs[i])
				
			#next, grab individual buffs
			for i in range(len(obj.upgrade_lists)):
				var upgrade_list = obj.upgrade_lists[i].upgrades
				var max_upgrade = get_component_upgrade_level(obj, i)
				for j in range(max_upgrade):
					var inner_buff_list = upgrade_list[j].buff_list
					for k in range(len(inner_buff_list)):
						unmerged_buffList.append(inner_buff_list[k])
	
	#finally, merge!
	var buffList : Array[BuffItem] = []
	for i in range(len(unmerged_buffList)):
		var b_name = unmerged_buffList[i].buff_name
		var b_amount = unmerged_buffList[i].amount
		var dup_index = -1
		for j in range(len(buffList)):
			var inner_name = buffList[j].buff_name
			if b_name == inner_name:
				dup_index = j
				break
		if dup_index == -1:
			buffList.append(unmerged_buffList[i])
		else:
			buffList[dup_index] = BuffItem.new(b_name, b_amount + buffList[dup_index].amount)
	
	return buffList

func get_equipped_component(group_name : String) -> DrillerComponentObject:
	match group_name:
		"hull":
			return hull
		"drill":
			return drill
		"battery":
			return battery
		"engine":
			return engine
		"boost":
			return boost
		"misc":
			return misc
	print("ERROR: couldn't get equipped component from the group \"" + group_name + "\".")
	return null

func set_equipped_component(obj : DrillerComponentObject, group_name : String):
	match group_name:
		"hull":
			hull = obj as Hull
		"drill":
			drill = obj
		"battery":
			battery = obj
		"engine":
			engine = obj
		"boost":
			boost = obj
		"misc":
			misc = obj
		_:
			print("ERROR: couldn't set equipped component from the group \"" + group_name + "\".")

func get_buff_amount(p_buff_name : String):
	var buffList = get_buffs_list()
	for i in range(len(buffList)):
		if buffList[i].buff_name == p_buff_name:
			#print("Buff \"" + p_buff_name + "\" found! Returning " + str(buffList[i].amount))
			return buffList[i].amount
	print("Buff \"" + p_buff_name + "\" not found. Returning 0.")
	return 0

func get_stat(stat_name : String):
	for i in range(len(stats.keys())):
		if stat_name in stats[stats.keys()[i]].keys():
			return stats[stats.keys()[i]][stat_name]
	print("stat not found: " + stat_name)
	return null
	
func set_stat(stat_name : String, value):
	for i in range(len(stats.keys())):
		if stat_name in stats[stats.keys()[i]].keys():
			stats[stats.keys()[i]][stat_name] = value
			return 0
	print("stat not found: " + stat_name)
	return null
	
func increase_stat(stat_name : String, value):
	set_stat(stat_name, get_stat(stat_name) + value)

func is_acheivement_completed(achievement : Achievement):
	if achievement in achievement_completed_data.keys():
		return achievement_completed_data[achievement]
	achievement_completed_data[achievement] = false
	return false

func award_achievement(achievement : Achievement, give_prizes : bool = false):
	achievement_completed_data[achievement] = true
	if give_prizes:
		for reward in achievement.resource_rewards:
			add_resource_amount(reward.res_name, reward.amount)
