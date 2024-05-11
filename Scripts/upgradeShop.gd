extends Node2D

const RESOURCE_DISPLAY = preload("res://Scenes/resourceDataDisplay.tscn")

@export var all_driller_component_groups : Array[DrillerComponentGroup]

@onready var tooltip = $Tooltip
@export var shop_tab_container : TabContainer# = $Container/VBoxContainer/PanelContainer2/HBoxContainer/MarginContainer/UpgradeGroupsTabContainer
@export var buff_label : RichTextLabel
@export var resource_display_container : HBoxContainer
@export var extra_scale_node : Control
@export var player : Node2D

var extra_scale : float = 1.5

func _ready():
	for i in range(len(all_driller_component_groups)):
		var driller_component_group_panel = preload("res://Scenes/drillerComponentGroupPanel.tscn").instantiate()
		shop_tab_container.add_child(driller_component_group_panel)
		driller_component_group_panel.tooltip = tooltip
		driller_component_group_panel.name = all_driller_component_groups[i].component_group_name
		driller_component_group_panel.setup(all_driller_component_groups[i])
		driller_component_group_panel.shop_update.connect(update_shop)
	shop_tab_container.tab_changed.connect(update_shop.bind())
	update_shop()

func _input(event):
	if Input.is_action_just_pressed("new day (from shop)"):
			Game.new_day()
	
	if event is InputEventMouseMotion:
		tooltip.position = get_local_mouse_position() + Vector2(1,1)

func update_shop(tab_index : int = 0):
	#save current data
	Game.save_player_data_to_file()
	
	update_resource_display_container()
	update_buff_label()
	update_player()
	
	extra_scale_node.scale = Vector2.ONE * extra_scale
	
	#update all children
	var children = shop_tab_container.get_children()
	for i in range(len(children)):
		children[i].update_self((i == tab_index))

func update_buff_label():
	buff_label.text = "ORE: " + str(Game.player_data.get_resource_amount("ore"))
	var the_string = ""
	var buff_list : Array[BuffItem] = Game.player_data.get_buffs_list()
	for i in range(len(buff_list)):
		the_string += buff_list[i].buff_name + ": " + str(buff_list[i].amount) + "\n"
	buff_label.text = the_string

func update_resource_display_container():
	for child in resource_display_container.get_children():
		child.queue_free()
	
	for i in range(len(Game.player_data.player_inventory)):
		var display = RESOURCE_DISPLAY.instantiate()
		resource_display_container.add_child(display)
		display.amount_setup(Game.player_data.player_inventory[i])

func update_player():
	player.build_player()

func new_day():
	Game.new_day()

func return_to_main_menu():
	Game.go_to_main_menu()

func quit_game():
	Game.quit_game()
