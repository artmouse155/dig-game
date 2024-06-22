extends Control

@export var continue_button : Button
@export var new_game_button : Button

@export var load_save_button : Button

@export var menu_buttons : Control
@export var save_select_screen : Control
@export var settings_screen : Control

func _ready():
	show_menu_buttons()

func show_menu_buttons():
	if (Game.save_name == SaveLoad.DEFAULT_PLAYER_SAVE_NAME):
		continue_button.disabled = true
		continue_button.text = "Continue"
	else:
		continue_button.disabled = false
		continue_button.text = "Continue (" + Game.save_name + ")"
	
	var num_saves: int = len(Game.get_save_names())
	
	load_save_button.disabled = num_saves == 0
	
	new_game_button.disabled = (num_saves == SaveLoad.MAX_NUM_SAVES)
	
	menu_buttons.show()
	settings_screen.hide()
	save_select_screen.hide()

func show_save_select_screen():
	save_select_screen.show()
	menu_buttons.hide()

func name_picked(n : String):
	Game.save_name = n
	show_menu_buttons()

func start_game():
	#try to load game data
	Game.start_from_main_menu()

func new_game():
	Game.generate_new_save()
	Game.start_from_main_menu()

func load_save_button_pressed():
	save_select_screen.setup()
	show_save_select_screen()
	
func show_settings():
	settings_screen.show_save_data_settings()
	settings_screen.show()
	menu_buttons.hide()
	
func show_credits():
	pass
	
func quit_game():
	Game.quit_game()
