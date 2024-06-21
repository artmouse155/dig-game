extends Node2D
class_name MainScene

@onready var fade_node = $FadeWipe

@onready var current_scene = -1

func _ready():
	Game.main_scene = self
	
	Game.load_global_save_data()
	
	Game.validate_global_save_data()
	
	if Debug.quickstart and (len(Game.get_save_names()) > 0):
		Game.load_player_save_data(Game.get_save_names()[0])
		Game.new_day()
	else:
		switch_scene(Game.MAIN_MENU)
	#Game.new_day()

func get_current_scene():
	return get_tree().get_nodes_in_group("scenes")[0]
	#if you get an error here, it is because the scene you tried to load isn't in the group "scenes". Fix this in the editor and you should be fine.

func switch_scene(scene, do_transition=true, force_reload=false):
	if (scene != current_scene) or (force_reload):
		if do_transition:
			#fade_node.position = Game.FADE_OFFSET[current_scene]
			Game.is_transition_running = true
			Game.paused = true
			if (current_scene == -1):
				await fade_node.instant_fade_in()
			else:
				await fade_node.fade_in()
		var old_scene = get_current_scene()
		var new_scene = await Game.SCENES[scene].instantiate()
		add_child(new_scene)
		move_child(new_scene, 0)
		old_scene.queue_free()
		await old_scene.tree_exited
		current_scene = scene
		if do_transition:
			#fade_node.position = Game.FADE_OFFSET[current_scene]
			await fade_node.fade_out()
			Game.is_transition_running = false
			Game.paused = false

func get_camera_center():
	var cameras = get_tree().get_nodes_in_group("camera")
	if len(cameras) > 0:
		return cameras[0].position
	return Game.resolution / 2.0
