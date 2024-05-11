extends HBoxContainer

func cost_setup(cost : ResourceData):
	#$Icon = preload("res://Assets/Textures/UI/box.png")
	if ResourceData.compare_all([cost], Game.player_data.player_inventory):
		$Cost.text = "✅ "
	else:
		$Cost.text = "❌ "
	
	$Cost.text += str(cost.amount)
	

func buff_setup(buff : BuffItem):
	#$Icon = preload("res://Assets/Textures/UI/box.png")
	$Cost.text = str(buff.amount)

func amount_setup(data : ResourceData):
	$Cost.text = data.res_name + ": " + str(data.amount)
