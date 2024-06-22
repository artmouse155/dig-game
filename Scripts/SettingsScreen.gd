extends PanelContainer

@export var display_mode_node: OptionButton

func show_save_data_settings():
	if Game.global_save_data:
		match Game.global_save_data.display_mode:
			"Windowed":
				display_mode_node.selected = 0

			"Fullscreen":
				display_mode_node.selected = 1

func display_mode_selected(_index: int):
	var display_mode: String = display_mode_node.get_item_text(_index)
	Game.global_save_data.display_mode = display_mode
	match display_mode:
		"Windowed":
			Game.main_scene.set_fullscreen(false)
			pass
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			#DisplayServer.window_set_size(Game.RESOLUTION * Game.WINDOWED_SCALE)
			#DisplayServer.window_set_position((DisplayServer.screen_get_size() / 2) - (DisplayServer.window_get_size() / 2))
			#DisplayServer.window_set_position(Vector2i.ZERO)
		"Fullscreen":
			Game.main_scene.set_fullscreen(true)
			pass
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			#DisplayServer.window_set_size(DisplayServer.screen_get_size())
			#DisplayServer.window_set_position(Vector2i.ZERO)
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Game.save_global_data_to_file()
