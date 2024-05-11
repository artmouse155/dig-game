extends PanelContainer

@export var save_data_container : Control

signal name_picked(save_name : String)

func setup(save_names : PackedStringArray):
	remove_children(save_data_container)
	
	for i in range(len(save_names)):
		var temp_button = Button.new()
		temp_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		save_data_container.add_child(temp_button)
		var temp_data : PlayerData = Game.save_load.get_save_data_by_name(save_names[i])
		var temp_days = temp_data.day_number
		var temp_ore = temp_data.get_resource_amount("ore")
		temp_button.text = save_names[i] + "\nDay " + str(temp_days) + "\nOre: " + str(temp_ore)
		#temp_button.text = "Save " + str(i + 1) + "\nDay " + str(temp_days) + "\nOre: " + str(temp_ore)
		temp_button.pressed.connect(name_picked_func.bind(save_names[i]))

func name_picked_func(n : String):
	name_picked.emit(n)

func remove_children(node):
	for child in node.get_children():
		child.queue_free()
