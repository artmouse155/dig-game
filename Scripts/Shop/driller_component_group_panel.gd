extends Control

@onready var upgrade_panel_container = $VBoxContainer/Upgrades/PanelContainer/VBoxContainer
@onready var component_object_tile_container = $VBoxContainer/Icons/PanelContainer/GridContainer

@export var componentObjectGroup : DrillerComponentGroup
var currentComponentObjectGroupIndex = 0

@export var tooltip : Tooltip

var componentObjectUpgradeListList : Array[VBoxContainer] = []

var all_tooltip_able_elements : Array[Control] = [] 
var all_tiles : Array[Control] = []

signal shop_update

func _ready():
	pass
	
func setup(shopdata : DrillerComponentGroup):
	componentObjectGroup = shopdata
	name = componentObjectGroup.component_group_name
	var active_component_index = 0
	for componentObjectGroupIndex in range(len(componentObjectGroup.component_objects)): 
		#add icon
		var temp_icon_tile = preload("res://Scenes/componentObjectTile.tscn").instantiate()
		component_object_tile_container.add_child(temp_icon_tile)
		all_tiles.append(temp_icon_tile)
		var obj = componentObjectGroup.component_objects[componentObjectGroupIndex]
		
		if (obj == Game.player_data.get_equipped_component(componentObjectGroup.component_group_name)):
			active_component_index = componentObjectGroupIndex
		
		temp_icon_tile.setup(obj, Game.player_data.get_component_unlock_status(obj))
		temp_icon_tile.tooltip = tooltip
		all_tooltip_able_elements.append(temp_icon_tile)
		temp_icon_tile.button.pressed.connect(switch_active_component_object.bind(componentObjectGroupIndex))
		
		#add upgrade lists
		var upgrade_lists = obj.upgrade_lists
		var temp_upgrade_panel_container = VBoxContainer.new()
		componentObjectUpgradeListList.append(temp_upgrade_panel_container)
		upgrade_panel_container.add_child(temp_upgrade_panel_container)
		for i in range(len(upgrade_lists)):
			var temp_upgrade_panel = preload("res://Scenes/upgradepanel.tscn").instantiate()
			
			
			temp_upgrade_panel_container.add_child(temp_upgrade_panel)
			temp_upgrade_panel.tooltip = tooltip
			var temp_level = Game.player_data.get_component_upgrade_level(obj,i)
			temp_upgrade_panel.setup(obj, i, temp_level)
			temp_upgrade_panel.tooltip = tooltip
			temp_upgrade_panel.parent_vbox = temp_upgrade_panel_container
			temp_upgrade_panel.shop_update.connect(emit_shop_update)
			all_tooltip_able_elements.append(temp_upgrade_panel)
		
	switch_active_component_object(active_component_index)

func emit_shop_update():
	shop_update.emit()

func update_self(tab_visible : bool = true):
	#var active_component_index = 0
	#for componentObjectGroupIndex in range(len(componentObjectGroup.component_objects)): 
	#	#add icon
	#	var obj = componentObjectGroup.component_objects[componentObjectGroupIndex]
	#	
	#	if (obj == Game.player_data.get_equipped_component(componentObjectGroup.component_group_name)):
	#		active_component_index = componentObjectGroupIndex
	#switch_active_component_object(active_component_index)
	
	for i in range(len(all_tooltip_able_elements)):
		all_tooltip_able_elements[i].update_self()
		all_tooltip_able_elements[i].part_of_active_group = tab_visible

func switch_active_component_object(index : int):
	#NOTICE: this should maybe be a different place perhaps?
	Game.player_data.set_equipped_component(componentObjectGroup.component_objects[index], componentObjectGroup.component_group_name)
	
	for i in range(len(componentObjectGroup.component_objects)): 
		all_tiles[i].set_selected(index == i)
	
	for i in range(len(componentObjectUpgradeListList)):
		componentObjectUpgradeListList[i].visible = (index == i)
	
	emit_shop_update()
