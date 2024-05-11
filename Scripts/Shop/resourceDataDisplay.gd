extends HBoxContainer

const COST_ICON_KEY : Dictionary = {
	"ore" : preload("res://Assets/Textures/UI/Resource_Icons/ore.tres"),
	"red_gem" : preload("res://Assets/Textures/UI/Resource_Icons/red_gem.tres"),
	"green_gem" : preload("res://Assets/Textures/UI/Resource_Icons/green_gem.tres"),
	"blue_gem" : preload("res://Assets/Textures/UI/Resource_Icons/blue_gem.tres"),
	"plasma" : preload("res://Assets/Textures/UI/Resource_Icons/plasma.tres"),
}

func cost_setup(cost : ResourceData):
	$Icon.texture = COST_ICON_KEY[cost.res_name]
	if ResourceData.compare_all([cost], Game.player_data.player_inventory):
		$Cost.text = "✅ "
	else:
		$Cost.text = "❌ "
	
	$Cost.text += str(cost.amount)
	

func buff_setup(buff : BuffItem):
	#$Icon = preload("res://Assets/Textures/UI/box.png")
	$Cost.text = str(buff.amount)

func amount_setup(data : ResourceData):
	$Icon.texture = COST_ICON_KEY[data.res_name]
	$Cost.text = str(data.amount)
