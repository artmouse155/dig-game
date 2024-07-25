extends Control
class_name MainScene

@onready var fade_node = $FadeWipe

@onready var current_scene = -1

func _ready():
	Game.main_scene = self
	
	Game.validate_global_save_data()
	
	if Game.global_save_data:
		match Game.global_save_data.display_mode:
			"Windowed":
				set_fullscreen(false)
			"Fullscreen":
				set_fullscreen(true)
	
	if Debug.settings.quickstart and (len(Game.get_save_names()) > 0):
		Game.load_player_save_data(Game.get_save_names()[0])
		Game.new_day()
	else:
		switch_scene(Game.MAIN_MENU)
	#Game.new_day()

func get_current_scene():
	return get_tree().get_nodes_in_group("scenes")[0]
	#if you get an error here, it is because the scene you tried to load isn't in the group "scenes". Fix this in the editor and you should be fine.

func switch_scene(scene, trans_type: int = Game.TRANSITION_TYPES.TRANSITION, force_reload=false):
	if (scene != current_scene) or (force_reload):
		if (trans_type == Game.TRANSITION_TYPES.TRANSITION) or (trans_type == Game.TRANSITION_TYPES.TRANSITION_WITH_LOAD):
			#fade_node.position = Game.FADE_OFFSET[current_scene]
			Game.is_transition_running = true
			Game.paused = true
			if (current_scene == -1):
				await fade_node.instant_fade_in()
			else:
				await fade_node.fade_in()
		var old_scene = get_current_scene()
		var new_scene = await Game.SCENES[scene].instantiate()
		
		#var new_scene = load("res://Scenes/main_menu.tscn").instantiate()
		add_child(new_scene)
		move_child(new_scene, 0)
		if (trans_type == Game.TRANSITION_TYPES.NO_TRANSITION_WITH_LOAD) or (trans_type == Game.TRANSITION_TYPES.TRANSITION_WITH_LOAD):
			if not new_scene.is_loaded:
				await new_scene.loaded
		old_scene.queue_free()
		await old_scene.tree_exited
		current_scene = scene
		
		if (trans_type == Game.TRANSITION_TYPES.TRANSITION) or (trans_type == Game.TRANSITION_TYPES.TRANSITION_WITH_LOAD):
			#fade_node.position = Game.FADE_OFFSET[current_scene]
			await fade_node.fade_out()
			Game.is_transition_running = false
			Game.paused = false

func get_camera_center():
	var cameras = get_tree().get_nodes_in_group("camera")
	if len(cameras) > 0:
		return cameras[0].position
	return Game.RESOLUTION / 2.0

#from logic gate game!
func set_fullscreen(mode: bool = true):
	var f = (DisplayServer.WINDOW_MODE_FULLSCREEN if mode else DisplayServer.WINDOW_MODE_WINDOWED)
	var w = DisplayServer.window_get_mode()
	ProjectSettings.set_setting("display/window/size/mode", f)
	if (w != f):
		ProjectSettings.save()
		DisplayServer.window_set_mode(f)
		if (f == DisplayServer.WINDOW_MODE_WINDOWED):
			DisplayServer.window_set_size(Game.RESOLUTION * Game.WINDOWED_SCALE)
			#This code is from https://ask.godotengine.org/485/how-to-center-game-window
			DisplayServer.window_set_position(Vector2(DisplayServer.screen_get_position()) + DisplayServer.screen_get_size()*0.5 - DisplayServer.window_get_size()*0.5)
