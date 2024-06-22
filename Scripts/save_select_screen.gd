extends PanelContainer

@export var save_data_container : Control

@export var delete_button : Button
@export var trashcan_texture: Texture2D
@export var ok_texture: Texture2D

@export var confirmation_box: Control

@export var save_panel_template : PackedScene

var delete_mode: bool = false
var name_to_delete: String

signal name_picked(save_name : String)

func setup():
	delete_mode = false
	delete_button.icon = trashcan_texture
	
	var save_names : PackedStringArray = Game.get_save_names()
	remove_children(save_data_container)
	
	for i in range(len(save_names)):
		var temp_panel = save_panel_template.instantiate()
		save_data_container.add_child(temp_panel)
		var temp_data : PlayerData = Game.save_load.get_save_data_by_name(save_names[i])
		var temp_days = temp_data.get_stat("day_number")
		var seconds_played = temp_data.get_stat("total_time_mining")
		var temp_seconds_played = ""
		if seconds_played < 60:
			temp_seconds_played = str(floor(seconds_played)) + " Sec"
		elif seconds_played < (60 * 60):
			temp_seconds_played = str(floor(seconds_played / 60.0)) + " Min"
		else:
			temp_seconds_played = str(floor(seconds_played / (60 * 60))) + " Hrs"
		
		
		var temp_money = temp_data.get_resource_amount("ore")
		
		#TODO: Make functional
		temp_panel.planet.text = "Yambinkus"
		temp_panel.day_number.text = str(temp_days)
		
		temp_panel.time.text = ""
		temp_panel.time.push_font_size(temp_panel.TIME_FONT_SIZE)
		temp_panel.time.append_text(temp_seconds_played)
		temp_panel.time.pop()
		
		temp_panel.money.text = ""
		temp_panel.money.push_font_size(temp_panel.MONEY_FONT_SIZE)
		temp_panel.money.append_text(str(temp_money))
		temp_panel.money.pop()
		
		#temp_button.text = "Save " + str(i + 1) + "\nDay " + str(temp_days) + "\nOre: " + str(temp_ore)
		temp_panel.button.pressed.connect(name_picked_func.bind(save_names[i]))

func name_picked_func(n : String):
	if delete_mode:
		name_to_delete = n
		setup_confirmation_box()
	else:
		name_picked.emit(n)

func remove_children(node):
	for child in node.get_children():
		child.queue_free()

func delete_save(s: String):
	if s == Game.save_name:
		Game.player_data = null
	Game.delete_player_data_file(s)

func setup_confirmation_box():
	var printed_save_name = name_to_delete
	
	confirmation_box.title.text = "Please Confirm!"
	confirmation_box.description.text = "You are about to delete " + printed_save_name + " FOREVER. Are you sure that you want this to happen?"
	confirmation_box.confirm_button.text = "Yes, Delete!"
	confirmation_box.back_button.text = "Uhh, Nevermind."
	
	confirmation_box.show()
	
	#TODO: add this code every time confimation box is used to make the code more adaptable
	for c in confirmation_box.confirm_button.pressed.get_connections():
		confirmation_box.confirm_button.pressed.disconnect(c["callable"])

	confirmation_box.confirm_button.pressed.connect(delete_confirm_button_pressed)

func delete_confirm_button_pressed():
	delete_save(name_to_delete)
	Game.validate_global_save_data()
	confirmation_box.hide()
	
	if len(Game.get_save_names()) == 0:
		name_picked.emit(SaveLoad.DEFAULT_PLAYER_SAVE_NAME)
	else:
		setup()
		delete_button_pressed()

func delete_button_pressed():
	delete_mode = !delete_mode
	print(delete_mode)
	delete_button.icon = ok_texture if delete_mode else trashcan_texture
