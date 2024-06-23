extends Resource
class_name ComponentObjectSaveData

@export var base_component : DrillerComponentObject

#is this component unlocked?
@export var unlocked : bool = false

#is the recipe found?
@export var recipe_found : bool = false

#in what order was this component's recipe found?
@export var found_order: int = 0
#how many of the available upgrades from each list have been unlocked?
# size = length of super.upgrade_lists
@export var unlocked_upgrade_nums : Array[int] = []

func _init(p_base_component : DrillerComponentObject = null, p_unlocked : bool = false, p_recipe_found : bool = false, p_found_order : bool = 0, p_unlocked_upgrade_nums : Array[int] = []):
	found_order = p_found_order
	
	if p_base_component:
		base_component = p_base_component
		if p_recipe_found or (not base_component.recipe_found_trigger):
			recipe_found = true
		if base_component.recipe_found_trigger:
			if base_component.recipe_found_trigger.is_null:
				recipe_found = true
		if p_unlocked or (base_component.crafting_recipe == []):
			unlocked = true
		
		if not unlocked:
			print(base_component.component_object_name + " began NOT unlocked.")
		if not recipe_found:
			print(base_component.component_object_name + "'s recipe began NOT found.")

		unlocked_upgrade_nums = []
		if base_component:
			for i in range(len(base_component.upgrade_lists)):
				if i < len(p_unlocked_upgrade_nums):
					unlocked_upgrade_nums.append(p_unlocked_upgrade_nums[i])
				else:
					unlocked_upgrade_nums.append(0)
