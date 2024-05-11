extends Resource
class_name ComponentObjectSaveData

@export var base_component : DrillerComponentObject

#is this component unlocked?
@export var unlocked : bool = false

#how many of the available upgrades from each list have been unlocked?
# size = length of super.upgrade_lists
@export var unlocked_upgrade_nums : Array[int] = []

func _init(p_base_component : DrillerComponentObject = null, p_unlocked : bool = true, p_unlocked_upgrade_nums : Array[int] = []):
	base_component = p_base_component
	unlocked = p_unlocked
	unlocked_upgrade_nums = []
	if base_component:
		for i in range(len(base_component.upgrade_lists)):
			if i < len(p_unlocked_upgrade_nums):
				unlocked_upgrade_nums.append(p_unlocked_upgrade_nums[i])
			else:
				unlocked_upgrade_nums.append(0)
