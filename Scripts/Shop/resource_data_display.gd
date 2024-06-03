extends HBoxContainer

const COST_ICON_KEY : Dictionary = {
	"ore" : preload("res://Assets/Textures/UI/Resource_Icons/ore.tres"),
	"red_gem" : preload("res://Assets/Textures/UI/Resource_Icons/red_gem.tres"),
	"green_gem" : preload("res://Assets/Textures/UI/Resource_Icons/green_gem.tres"),
	"blue_gem" : preload("res://Assets/Textures/UI/Resource_Icons/blue_gem.tres"),
	"plasma" : preload("res://Assets/Textures/UI/Resource_Icons/plasma.tres"),
}

const BUFF_ICON_KEY : Dictionary = {
	"durability" : preload("res://Assets/Textures/UI/Buff_Icons/durability.tres"),
	"agility" : preload("res://Assets/Textures/UI/Buff_Icons/energy.tres"),
	"energy" : preload("res://Assets/Textures/UI/Buff_Icons/energy.tres"),
	"turbos" : preload("res://Assets/Textures/UI/Buff_Icons/turbo.tres"),
	"turbo_duration" : preload("res://Assets/Textures/UI/Buff_Icons/turbo.tres"),
	"max_speed" : preload("res://Assets/Textures/UI/Buff_Icons/speed.tres"),
	"engine_power" : preload("res://Assets/Textures/UI/Buff_Icons/speed.tres"),
}

const POWERUP_ICON_KEY : Dictionary = {
	"extra_durability" : preload("res://Assets/Textures/UI/Buff_Icons/durability.tres"),
	"extra_energy" : preload("res://Assets/Textures/UI/Buff_Icons/energy.tres"),
	"extra_turbo" : preload("res://Assets/Textures/UI/Buff_Icons/turbo.tres"),
	"extra_speed" : preload("res://Assets/Textures/UI/Buff_Icons/speed.tres"),
}

func cost_setup(cost : ResourceData):
	$Icon.texture = COST_ICON_KEY[cost.res_name]
	if ResourceData.compare_all([cost], Game.player_data.player_inventory):
		$Cost.text = "✅ "
	else:
		$Cost.text = "❌ "
	
	$Cost.text += str(cost.amount)

func gem_setup(cost : ResourceData):
	$Icon.texture = COST_ICON_KEY[cost.res_name]
	$Cost.text = "+ "
	
	$Cost.text += str(cost.amount)


func buff_setup(buff : BuffItem):
	$Icon.texture = BUFF_ICON_KEY[buff.buff_name]
	$Cost.text = str(buff.amount)
	
func powerup_setup(buff : BuffItem):
	$Icon.texture = POWERUP_ICON_KEY[buff.buff_name]
	$Cost.text = "+" + str(buff.amount)

func amount_setup(data : ResourceData):
	$Icon.texture = COST_ICON_KEY[data.res_name]
	$Cost.text = str(data.amount)
