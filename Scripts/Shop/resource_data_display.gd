extends HBoxContainer

@export var iconNode: TextureRect
@export var costLabel: RichTextLabel

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

const RED : Color = Color.DARK_RED
const GREEN : Color = Color.MEDIUM_SEA_GREEN
const WHITE : Color = Color.WHITE
const BLUE : Color = Color.DARK_TURQUOISE

func cost_setup(cost : ResourceData):
	iconNode.texture = COST_ICON_KEY[cost.res_name]
	var s = ""
	var color = WHITE
	if ResourceData.compare_all([cost], Game.player_data.player_inventory):
		s = "✅ "
		color = GREEN
	else:
		s = "❌ "
		color = RED
	
	set_text(s + str(cost.amount), color)

func gem_setup(cost : ResourceData):
	iconNode.texture = COST_ICON_KEY[cost.res_name]
	set_text("+ " + str(cost.amount))


func buff_setup(buff : BuffItem):
	iconNode.texture = BUFF_ICON_KEY[buff.buff_name]
	set_text(str(buff.amount), BLUE)
	
func powerup_setup(buff : BuffItem):
	iconNode.texture = POWERUP_ICON_KEY[buff.buff_name]
	set_text("+" + str(buff.amount))

func amount_setup(data : ResourceData):
	iconNode.texture = COST_ICON_KEY[data.res_name]
	set_text(str(data.amount))

func set_text(t : String, c : Color = Color.WHITE):
	costLabel.text = ""
	costLabel.push_color(c)
	costLabel.append_text(t)
	costLabel.pop()
