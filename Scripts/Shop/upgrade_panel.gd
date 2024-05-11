extends Control

@onready var bar_container = $VBoxContainer/HBoxContainer/BarContainer
@onready var full_bar_container = $VBoxContainer/HBoxContainer/BarContainer/FullBarContainer
@onready var upgrade_name_label = $VBoxContainer/HBoxContainer/MarginContainer2/UpgradeName
@onready var add_button = $VBoxContainer/HBoxContainer/AddButton

const BAR_WIDTH = 16
const BAR_HEIGHT = 32

@export var parent_vbox : VBoxContainer
@export var obj : DrillerComponentObject
@export var upgrade_list_index : int
@export var upgrade_list : UpgradeList
var num_upgrades
var max_num_upgrades
var resources

#for tooltip
var tooltip_selected_num = null

var part_of_active_group = false

var tooltip : Tooltip = null

var sample_upgrade_tree = {
	"upgrade_name" : "Durability",
	"desc" : "Increases your drill's durability.",
	"upgrades" : [
		{
			"buffs" : [
				{
					"name" : "durability",
					"amount" : 100
				}
			],
			"costs" : [
				{
					"name" : "ore",
					"cost" : 1000
				},
				{
					"name" : "red_gem",
					"cost" : 1
				},
			]
		}
	]
}

signal shop_update

func _ready():
	#setup(upgrade_list, 0)
	add_button.pressed.connect(add_button_pressed)

func setup(_obj : DrillerComponentObject, _upgrade_list_index : int, _num_upgrades : int):
	obj = _obj
	upgrade_list_index = _upgrade_list_index
	upgrade_list = obj.upgrade_lists[upgrade_list_index]
	num_upgrades = _num_upgrades
	
	upgrade_name_label.text = upgrade_list.upgrade_name
	max_num_upgrades = len(upgrade_list.upgrades)
	update_bars()
	update_button()

func _input(event):
	if (upgrade_list and parent_vbox):
		if (parent_vbox.visible && part_of_active_group):
			if event is InputEventMouseMotion:
				var pos = bar_container.get_local_mouse_position()
				var selected_num = -1
				#if ((0 <= pos.y) and (pos.y <= BAR_HEIGHT)) and ((0 <= pos.x) and (pos.x < (max_num_upgrades * BAR_WIDTH))):
				if Rect2(Vector2.ZERO, bar_container.get_size()).has_point(bar_container.get_local_mouse_position()):
					selected_num = floor(pos.x / BAR_WIDTH)
				elif Rect2(Vector2.ZERO, add_button.get_size()).has_point(add_button.get_local_mouse_position()):
					selected_num = num_upgrades
				if (selected_num != -1) and selected_num < len(upgrade_list.upgrades):
					#$Label.text = "Bar #" + str(selected_num) + ": " + str(upgrade_list.upgrades[selected_num].cost_list[0].res_name)
					if selected_num != tooltip_selected_num:
						setup_tooltip(upgrade_list.desc, upgrade_list.upgrades[selected_num])
						tooltip_selected_num = selected_num
						show_tooltip()
				else:
					#$Label.text = "None Selected."
					tooltip_selected_num = -1
					
					if have_tooltip_control():
						lose_tooltip_control()
						hide_tootip()
		

func update_bars():
	bar_container.custom_minimum_size.x = BAR_WIDTH * max_num_upgrades
	full_bar_container.custom_minimum_size.x = BAR_WIDTH * num_upgrades

func update_button():
	if num_upgrades == max_num_upgrades:
		add_button.hide()
		lose_tooltip_control()
		hide_tootip()
	else:
		add_button.disabled = not ResourceData.compare_all(upgrade_list.upgrades[num_upgrades].cost_list, Game.player_data.player_inventory)
	

func add_button_pressed():
	var cost_list = upgrade_list.upgrades[num_upgrades].cost_list
	for i in range(len(cost_list)):
		Game.player_data.add_resource_amount(cost_list[i].res_name, -1 * cost_list[i].amount)
	num_upgrades += 1
	
	
	Game.player_data.set_component_upgrade_level(obj, upgrade_list_index, num_upgrades)
	
	update_self()
	update_bars()
	update_button()
	
	shop_update.emit()

func update_self():
	update_bars()
	update_button()

func show_tooltip():
	if tooltip != null:
		tooltip.show()
		
func hide_tootip():
	if tooltip != null:
		tooltip.hide()

func have_tooltip_control():
	if tooltip != null:
		return tooltip.active_control == self
	return false

func lose_tooltip_control():
	tooltip.active_control = null

func setup_tooltip(_desc, _upgrades):
	if tooltip != null:
		tooltip.upgrade_setup(self, _desc, _upgrades)
