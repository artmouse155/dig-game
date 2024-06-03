extends Control
class_name Tooltip

@onready var costContainer = $PanelContainer/MarginContainer/VBoxContainer/CostContainer
@onready var buffContainer = $PanelContainer/MarginContainer/VBoxContainer/BuffContainer
@onready var descNode = $PanelContainer/MarginContainer/VBoxContainer/Desc
var resourceDataDisplay = preload("res://Scenes/resource_data_display.tscn")

@export var cost_label : Control
@export var buff_label : Control

var active_control = null

func upgrade_setup(_active_control : Control, desc : String, upgrade : Upgrade):
	cost_label.show()
	buff_label.show()
	
	active_control = _active_control
	
	descNode.text = desc
	remove_children(costContainer)
	remove_children(buffContainer)
	for cost in upgrade.cost_list:
		var temp_display = resourceDataDisplay.instantiate()
		temp_display.cost_setup(cost)
		costContainer.add_child(temp_display)
		
	for buff in upgrade.buff_list:
		var temp_display = resourceDataDisplay.instantiate()
		temp_display.buff_setup(buff)
		buffContainer.add_child(temp_display)

func tile_setup(_active_control : Control, desc : String):
	cost_label.hide()
	buff_label.hide()
	
	active_control = _active_control
	
	descNode.text = desc
	remove_children(costContainer)
	remove_children(buffContainer)

func achievement_setup(_active_control : Control, a : Achievement):
	cost_label.hide()
	buff_label.hide()
	
	active_control = _active_control
	
	descNode.text = a.achievement_name + "\n" +a.achievement_desc

func remove_children(node):
	for child in node.get_children():
		child.queue_free()
