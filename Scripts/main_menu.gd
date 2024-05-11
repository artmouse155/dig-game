extends Node2D

@export var continue_button : Button
@export var new_game_button : Button
@export var menu_buttons : Control
@export var save_select_screen : Control

func _ready():
	show_menu_buttons()

func show_menu_buttons():
	if (Game.save_name == SaveLoad.DEFAULT_PLAYER_SAVE_NAME):
		continue_button.disabled = true
	else:
		continue_button.disabled = false
		continue_button.text = "Continue (" + Game.save_name + ")"
	
	menu_buttons.show()
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
	save_select_screen.setup(Game.get_save_names())
	show_save_select_screen()
	
func show_settings():
	pass
	
func show_credits():
	pass
	
func quit_game():
	Game.quit_game()
