extends Node

var player_data : PlayerData# = preload("res://Resources/Player Data/sample_player_data.tres")
var save_load : SaveLoad = preload("res://Scripts/Saving Loading/save_load.gd").new()
var global_save_data : GlobalData

var save_name = SaveLoad.DEFAULT_PLAYER_SAVE_NAME

var all_data : AllData = preload("res://Resources/all_data.tres")

const TILE_WIDTH = 32
const PLAYER_STARTING_POS = Vector2(960,-200)

enum {MAIN_MENU, WORLD_1, SHOP, ACHIEVEMENTS}

const SCENES = {
	MAIN_MENU : preload("res://Scenes/main_menu.tscn"),
	WORLD_1 : preload("res://Scenes/world.tscn"),
	SHOP : preload("res://Scenes/upgrade_shop.tscn"),
	ACHIEVEMENTS : preload("res://Scenes/UI/achievement_display.tscn")
	
}

var paused = false
var is_transition_running = false

var resolution = Vector2(1920, 1080)

var tips = [
	"If you want to mine for longer, grab some upgrades from the shop!",
	"This game is not affiliated with \"Reach The Core.\"",
	"If you ever want to end a day early, you can reset with \"R\"."
]

var debug = false

var main_scene : MainScene

func save_global_data_to_file():
	save_load.save_player_data(player_data, save_name)

func load_global_save_data():
	var _data = save_load.get_global_save_data()
	if _data:
		global_save_data = _data

func save_player_data_to_file():
	save_load.save_player_data(player_data, save_name)

func load_player_save_data(_save_name : String):
	var _data = save_load.get_save_data_by_name(_save_name)
	if _data:
		save_name = _save_name
		player_data = _data
		
		if Debug.reset_saved_component_data:
			player_data.saved_component_data = []
	else:
		print("load player dave data failed")

func generate_new_save():
	save_name = save_load.save_new_player_data()
	load_player_save_data(save_name)

func get_save_names() -> PackedStringArray:
	return save_load.get_list_of_names_of_saves()

func get_main_scene():
	return main_scene

func new_day():
	player_data.increase_stat("day_number", 1)
	main_scene.switch_scene(WORLD_1, true, true)

func end_day():
	save_global_data_to_file() #so if you make a new game and then leave, it saves prev_name
	save_player_data_to_file()

func go_to_shop():
	main_scene.switch_scene(SHOP)

func go_to_main_menu():
	main_scene.switch_scene(MAIN_MENU)

func go_to_achievements():
	main_scene.switch_scene(ACHIEVEMENTS)

func start_from_main_menu():
	global_save_data.prev_save_name = save_name
	save_load.save_global_data(global_save_data)
	
	load_player_save_data(save_name)
	if player_data.get_stat("completed_tutorial"):
		go_to_shop()
	else:
		player_data.set_stat("completed_tutorial", true)
		new_day()

#TODO: Make Work!
func get_all_game_objects() -> Array[DrillerComponentObject]:
	var all_objects : Array[DrillerComponentObject] = []
	for group in all_data.all_driller_component_groups:
		for item in group.component_objects:
			all_objects.append(item)
	
	return all_objects

#TODO: Make Work!
func get_all_achievements()-> Array[Achievement]:
	return all_data.all_achievements

func _input(_ev):
	#NOTE "`/~" key
	if Input.is_action_just_pressed("toggle_debug"):
		Debug.toggle()
	if Input.is_key_pressed(KEY_ESCAPE):
		quit_game()

func quit_game():
	get_tree().quit()
