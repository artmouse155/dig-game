extends Node2D

@export var linear_curve : Curve
@export var bell_curve : Curve
@export var smooth_curve : Curve
@export var constant_curve : Curve
@export var randf_noise : Noise
@export var smooth_noise : Noise

const SMOOTH_NOISE_MIN = -.75
const SMOOTH_NOISE_MAX = .75

const RANDF_NOISE_MIN = -1
const RANDF_NOISE_MAX = 1

#if the tile we want to mine will only be in our drill radius for less than MINE_DIST distance, disregard
const MINE_DIST : float = 1

@export var day_number_label : Label
const DAY_NUMBER_Y_OFFSET = -700

var score : float = 0.0

@export var gen_data : Array[Gen]

@onready var subviewport = $SubViewportContainer/SubViewport
@onready var gameover = $GameOver

@export var iconAndTextParticle : PackedScene
@export var notificationSystem : Node2D
#var tile_data = {}

var chunks = {}

#TODO: make all resolution changes dynamic
var resolution = Vector2(1920,1080)
const CHUNK_RESOLUTION : int= 16
var DEFAULT_CHUNK = CHUNK_RESOLUTION * Vector2i.ONE
#@export var noise_texture : NoiseTexture2D
@onready var tilemap = %TileMap
@onready var chunk_path = %Player/ChunkRegion/PathFollow2D

const BACKGROUND_LAYER = -1
const GROUND_LAYER = 0
const LIGHT_LAYER = 1

const DIM_LIGHT = 9

var camera_pos = Vector2.ZERO#Vector2(1920,1080)

var ground_source_id = 1
var light_source_id = 2

var light_radius = 9

var drill_radius = 1.8
var player_radius = 1.5
const BOMB_RADIUS = 9

#inside of light_radius
const LIGHT_EDGE_SIZE =  3

var background_atlas:
	get:
		return Vector2i(randi_range(3,7),2)

var per_day_resources : Array[ResourceData] = [
	ResourceData.new("ore", 0),
	ResourceData.new("red_gem", 0),
	ResourceData.new("green_gem", 0),
	ResourceData.new("blue_gem", 0),
	ResourceData.new("plasma", 0),
]
@onready var per_day_resources_key = per_day_resources.map(func(r_d): return r_d.res_name)

var day_has_been_saved : bool = false

#ALERT: THIS MUST BE SYNCED WITH THE STATS IN PLAYER_DATA.GD
var day_stats = {
	"max_depth" : 0,
	"max_ore" : 0,
	"max_green_gems" : 0,
	"max_blue_gems" : 0,
	"max_red_gems" : 0,
	"max_plasma" : 0,
	"max_powerups_collected" : 0,
	"max_boosts_used" : 0,
	"max_blocks_broken" : 0,
	"max_speed" : 0,
	"max_time_mining" : 0
}

var component_triggers : Array[ComponentObjectSaveData] = []
var achievement_triggers : Array[Achievement] = []

func _ready():

	#print("air: " + str(tilemap.get_cell_atlas_coords(GROUND_LAYER, Vector2i(0, -100))))
	
	%Player/ChunkRegion.scale = DEFAULT_CHUNK

	for i in gen_data:
		match i.noise:
			"randf":
				i.noise_res = randf_noise.duplicate()
			"smooth":
				i.noise_res = smooth_noise.duplicate()
		i.noise_res.seed = randi()

	tilemap.add_layer(LIGHT_LAYER)
	tilemap.set_layer_z_index(LIGHT_LAYER, LIGHT_LAYER)
	tilemap.add_layer(BACKGROUND_LAYER)
	tilemap.set_layer_z_index(BACKGROUND_LAYER, BACKGROUND_LAYER)
	
	day_number_label.text = "Day " + str(Game.player_data.get_stat("day_number"))
	day_number_label.position.y = DAY_NUMBER_Y_OFFSET
	
	if Game.player_data.get_stat("max_depth") != 0:
		%HFollow/PB.position.y = Game.player_data.get_stat("max_depth") * Game.TILE_WIDTH
	
	update_h_follow_pos()

	setup_triggers()

	generate_world()

func setup_triggers():
	var all_components : Array[DrillerComponentObject] = Game.get_all_game_objects()
	for i in range(len(all_components)):
		var comp_save_data = Game.player_data.find_component_object_save_data(all_components[i])
		if not comp_save_data.unlocked:
			component_triggers.append(comp_save_data)
	
	var all_acheivements : Array[Achievement] = Game.get_all_achievements()
	for i in range(len(all_acheivements)):
		if not Game.player_data.is_acheivement_completed(all_acheivements[i]):
			achievement_triggers.append(all_acheivements[i])

func update_h_follow_pos():
	%HFollow.position.x = %Player.position.x - resolution.x/2

#TODO: Doesn't need to happen every single tick?
func check_chunk_regions():
	for ratio in [0.0, 1/8.0, 0.25, 3/8.0, 0.5, 5/8.0, 0.75, 7/8.0]:
		#get the point, then tile coordinate, then chunk
		chunk_path.set_progress_ratio(ratio)
		var chunk_coordinate = coords_to_chunk(pixel_coords_to_map_coords(chunk_path.global_position))
		if not chunk_has_data(chunk_coordinate):
			generate_chunk(chunk_coordinate)


func generate_world():
	generate_chunk(Vector2.ZERO)

func generate_chunk(chunk_coords : Vector2i):
	var start_time = Time.get_ticks_msec()
	
	var temp_chunk = []

	for x in range(DEFAULT_CHUNK.x):
		temp_chunk.append([])
		for y in range(DEFAULT_CHUNK.y):
			temp_chunk[x].append(null)
	
	#print("Generating chunk: " + str(chunk_coords))
	if !(chunk_coords.x in chunks.keys()):
		chunks[chunk_coords.x] = {}
	if !(chunk_coords.y in chunks[chunk_coords.x].keys()):
		chunks[chunk_coords.x][chunk_coords.y] = temp_chunk

	for i in gen_data:
		if ((DEFAULT_CHUNK.y * chunk_coords.y) >= i.min_depth) or ((DEFAULT_CHUNK.y * (chunk_coords.y + 1)) - 1 <= i.max_depth):
			var noise = i.noise_res
			var noise_min = 0
			var noise_max = 1
			var curve : Curve
			match i.curve:
				"linear":
					curve = linear_curve
				"bell":
					curve = bell_curve
				"smooth":
					curve = smooth_curve
				"constant":
					curve = constant_curve

			match noise.noise_type:
				FastNoiseLite.TYPE_SIMPLEX_SMOOTH:
					noise_min = SMOOTH_NOISE_MIN
					noise_max = SMOOTH_NOISE_MAX
				FastNoiseLite.TYPE_VALUE:
					noise_min = RANDF_NOISE_MIN
					noise_max = RANDF_NOISE_MAX

			#var atlas_size = i.atlas.size()

			for y in range(DEFAULT_CHUNK.y):
				var y_cor = y + (DEFAULT_CHUNK.y * chunk_coords.y)
				if (y_cor >= i.min_depth) and (y_cor <= i.max_depth):
					var function_input = float(y_cor - i.min_depth) / (i.max_depth - i.min_depth)
					var threshold_value = (curve.sample(function_input) * (i.max_freq - i.min_freq)) + i.min_freq
					for x in range(DEFAULT_CHUNK.x):
						var coords = Vector2i(x,y) + Vector2i(chunk_coords.x * DEFAULT_CHUNK.x, chunk_coords.y * DEFAULT_CHUNK.y)
						var noise_value = (noise.get_noise_2d(coords.x,coords.y) - noise_min) / (noise_max - noise_min)
						if (!temp_chunk[x][y]) and (noise_value <= threshold_value):
							#tilemap.set_cell(GROUND_LAYER, coords, ground_source_id, i.atlas[randi_range(0,atlas_size-1)])
							temp_chunk[x][y] = {"health" = i.health, "gen" = i}
							set_tile_data(coords, temp_chunk[x][y])
						#if !Debug.fullbright:
							#tilemap.set_cell(LIGHT_LAYER, coords, light_source_id, Vector2i(0,0))
	var mid_time = Time.get_ticks_msec()
	var mid_elapsed_time = mid_time - start_time

	draw_chunk(chunk_coords)
	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	print("Chunk generated in ", elapsed_time, "ms (",mid_elapsed_time, "ms + ", (end_time - mid_time), "ms)")

func draw_chunk(chunk_coords : Vector2i):
	#print("CHUNK: " + str(chunks[0][0]))
	
	for x in range(DEFAULT_CHUNK.x):
		for y in range(DEFAULT_CHUNK.y):
			var coords = Vector2i(x,y) + Vector2i(chunk_coords.x * DEFAULT_CHUNK.x, chunk_coords.y * DEFAULT_CHUNK.y)
			if tile_has_data(coords):
				if get_tile_data(coords):
					var gen = get_chunk_data(chunk_coords)[x][y]["gen"]
					tilemap.set_cell(GROUND_LAYER, coords, ground_source_id, gen.atlas[randi_range(0,gen.atlas.size()-1)])
					if !Debug.fullbright:
						tilemap.set_cell(LIGHT_LAYER, coords, light_source_id, Vector2i(0,0))

func _process(delta):
	
	if not Game.paused:
		
		update_h_follow_pos()
		mine(delta)
		check_chunk_regions()

		check_triggers()

		day_stats["max_speed"] = max(day_stats["max_speed"], %Player.velocity)
		day_stats["max_depth"] = max(day_stats["max_depth"], %Player.depth)
		#damage_tile(center_tile, %Player.drill_speed * delta)
		#tile_break_particle.position = get_global_mouse_position()

func mine(delta):
		#Code for mining
		#%Sky.position.x = %Player.position.x - resolution.x/2
		
		var center_tile = tilemap.local_to_map(%Player.position)
		light_up_around_coords(center_tile)
		
		var drill_tile = tilemap.local_to_map(%Player.player_texture.get_drill_center().global_position)
		
		#stop if we can't break it in .5 seconds.
		#slow if we can't break it in .1 seconds.
		#var t_slow = .1
		#var t_stop = .5
		
		#var drill_acceleration_constant = 1
		
		#var slow_down_threshold_met = false
		var complete_stop_threshold_met = false


		var damage = %Player.engine_power * 100
		#var tiles = []
		
		# a value of 1 means that we should stop completely. A value of 0 means keep accelerating. between is determined with a exponential graph.
		var max_damage_ratio : float = 0.0
		var max_accel : float = 0.0
		for x in range(ceil(2 * drill_radius)):
			for y in range(ceil(2 * drill_radius)):
				var tile_pos = drill_tile - Vector2i(x,y) + Vector2i(Vector2i.ONE * round(drill_radius))
				if get_tile_data(tile_pos):
					var tile_distance = ((Vector2(tile_pos) + Vector2(.5, .5)) * Game.TILE_WIDTH).distance_to(%Player.player_texture.get_drill_center().global_position) / float(Game.TILE_WIDTH)
					if tile_distance <= (drill_radius):
						var normalized_x_y = (((Vector2(tile_pos) + Vector2(.5, .5)) * Game.TILE_WIDTH) - %Player.player_texture.get_drill_center().global_position).rotated(%Player.driller_angle)  / float(Game.TILE_WIDTH)
						
						var health : float = get_tile_data(tile_pos)["health"]
						
						var eqn_dist = (sqrt(pow(drill_radius, 2) + pow(normalized_x_y.x, 2)) - normalized_x_y.y)
						if (eqn_dist >= MINE_DIST):
							var t = (health / damage)
							#print(get_tile_data(tile_pos)["health"])
							var needed_decel = (2 * pow(t,2)) * (eqn_dist - (%Player.velocity * t))
							max_accel = max(max_accel, needed_decel)
							var complete_stop_threshold : float = (damage * eqn_dist / (%Player.velocity))
							if health > complete_stop_threshold:
								print("stopped! eqn dist:" + str(eqn_dist))
								#print("health:  " + str(health) + " thrshld: " + str(complete_stop_threshold))
								complete_stop_threshold_met = true
							else:
								#print("health:  " + str(health))
								max_damage_ratio = max(max_damage_ratio, float(health) / complete_stop_threshold)

						damage_tile(tile_pos, damage * delta)

				#damage_tile(temp_tile_pos, damage * delta)
		%Player.max_damage_ratio = max_damage_ratio
		%DEBUG.text = "max_damage_ratio:  " + str(max_damage_ratio)
		%Player.complete_stop = complete_stop_threshold_met
		%Player.move(delta)
		
func _input(ev):

	if not Game.paused:
		if Input.is_action_just_pressed("shop"):
			shop_button_pressed()
		
		if Input.is_action_just_pressed("reset_day"):
			new_day_button_pressed()
		
		if Input.is_action_just_pressed("kill"):
			game_over("durability", true)
			
		if Input.is_action_just_pressed("debug"):
			notificationSystem.add_unlock_notification(Game.player_data.hull)

		if Input.is_action_pressed("turbo"):
			%Player.turbo()

		if ev is InputEventMouseButton:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var center_tile = tilemap.local_to_map(%Player.get_local_mouse_position() + %Player.position)
				%Player.screenshake()
				
				for x in range(1 + (2 * BOMB_RADIUS)):
					for y in range(1 + (2 * BOMB_RADIUS)):
						var tile_pos = center_tile - Vector2i(x,y) + Vector2i(Vector2i.ONE * floor(BOMB_RADIUS))
						var tile_distance = Vector2(tile_pos).distance_to(Vector2(center_tile))

						if tile_distance <= (BOMB_RADIUS):
							damage_tile(tile_pos, 999)

func mine_tile(coords, tileGen : Gen):
	if tile_exists(coords):
		var particle = preload("res://Scenes/tileBreakParticle.tscn").instantiate()
		subviewport.add_child(particle)
		particle.position = tilemap.map_to_local(coords)
		particle.restart()
		particle.finished.connect(particle.queue_free)
		
		if (tileGen.group == "ore"):
			var points_indicator = preload("res://Scenes/labelParticle.tscn").instantiate()
			points_indicator.setup(str(tileGen.value))
			subviewport.add_child(points_indicator)
			points_indicator.position = tilemap.map_to_local(coords)
			points_indicator.particle_maker.restart()
			points_indicator.particle_maker.finished.connect(points_indicator.queue_free)
		
		elif (tileGen.group == "gem"):
			var temp_particle = iconAndTextParticle.instantiate()
			temp_particle.gem_setup(tilemap.map_to_local(coords), ResourceData.new(tileGen.name, floor(tileGen.value)))
			subviewport.add_child(temp_particle)
		
		elif (tileGen.group == "powerup"):
			var temp_particle = iconAndTextParticle.instantiate()
			temp_particle.powerup_setup(tilemap.map_to_local(coords), BuffItem.new(tileGen.name, tileGen.value))
			subviewport.add_child(temp_particle)
		
		day_stats["max_blocks_broken"] = day_stats["max_blocks_broken"] + 1
		tilemap.set_cell(BACKGROUND_LAYER, coords, ground_source_id, background_atlas)
		tilemap.erase_cell(GROUND_LAYER, coords)

func light_up_around_coords(coords):
	var light_edge_radius = light_radius - LIGHT_EDGE_SIZE
	var center_tile = coords
	for x in range(1 + (2 * light_radius)):
		for y in range(1 + (2 * light_radius)):
			var tile_pos = center_tile - Vector2i(x,y) + Vector2i(Vector2i.ONE * floor(light_radius))
			var tile_distance = Vector2(tile_pos).distance_to(Vector2(center_tile))
			var light_level = 7
			if tile_distance <= (light_radius - light_edge_radius):
				light_level = 15
			else:
				light_level = 15 - floor(min(((tile_distance - (light_radius + 1 - light_edge_radius)) / light_edge_radius),1) * 15)
			
			light_level = max(light_level, min(DIM_LIGHT,tilemap.get_cell_atlas_coords(LIGHT_LAYER, tile_pos, light_source_id).x))
			if tilemap.get_cell_source_id(LIGHT_LAYER, tile_pos) != -1:
				tilemap.set_cell(LIGHT_LAYER, tile_pos, light_source_id, Vector2i(light_level,0))

#TODO: figure out why this doesn't work for dirt!
func tile_has_data(coords):
	return chunk_has_data(coords_to_chunk(coords))
	#if !(coords.x in tile_data.keys()):
	#		return false
	#if !(coords.y in tile_data[coords.x].keys()):
	#		return false
	#return true

func get_tile_data(coords):
	if tile_has_data(coords):
		var adjusted_coords = Vector2(int(coords.x) % DEFAULT_CHUNK.x, int(coords.y) % DEFAULT_CHUNK.y)
		return get_chunk_data(coords_to_chunk(coords))[adjusted_coords.x][adjusted_coords.y]
	else:
		return null

func set_tile_data(coords, data):
	if tile_has_data(coords):
		var adjusted_coords = Vector2(int(coords.x) % DEFAULT_CHUNK.x, int(coords.y) % DEFAULT_CHUNK.y)
		get_chunk_data(coords_to_chunk(coords))[adjusted_coords.x][adjusted_coords.y] = data
	else:
		print("ERROR: NO TILE DATA FOUND")
	
func damage_tile(coords, amount):
	var tile_data = get_tile_data(coords)
	if tile_exists(coords):
		if tile_has_data(coords):
			#print(tile_data[coords.x][coords.y]["health"])
			tile_data["health"] -= amount
			if tile_data["health"] <= 0:
				
				
				#get tile reward based on the type of tile
				var tile_name = tile_data["gen"].name
				var tile_group = tile_data["gen"].group
				var points = tile_data["gen"].value
				match tile_group:
					"ore":
						get_points(points)
					"dirt":
						get_points(points)
					"gem":
						var index = per_day_resources_key.find(tile_name)
						if index != -1:
							per_day_resources[index] = per_day_resources[index].changed_by(tile_data["gen"].value)
					"powerup":
						match tile_name:
							"extra_speed":
								%Player.temporarily_gain_extra_max_speed(points)
							"extra_turbo":
								%Player.turbos = %Player.turbos + points
							"extra_durability":
								%Player.gain_durability(points)
							"extra_energy":
								%Player.gain_energy(points)
				mine_tile(coords, tile_data["gen"])
			

func tile_exists(coords):
	return (tilemap.get_cell_source_id(GROUND_LAYER, coords) != -1) and coords.y >= 0

func get_points(added_points):
	score += added_points
	%Score.text = str(floor(score))

func pixel_coords_to_map_coords(pixel_coords):
	return tilemap.local_to_map(pixel_coords)

func coords_to_chunk(coords : Vector2i):
	return floor(Vector2(coords) / Vector2(DEFAULT_CHUNK))

func chunk_has_data(chunk_coords : Vector2i):
	#if chunk_coords.y < 0:
		#return true
	if chunk_coords.x in chunks.keys():
		if chunk_coords.y in chunks[chunk_coords.x].keys():
			return true
		else:
			return false
	else:
		return false

func get_chunk_data(chunk_coords : Vector2i) -> Array:
	if chunk_has_data(chunk_coords):
		return chunks[chunk_coords.x][chunk_coords.y]
	print("error: chunk had no data!")
	return []

func check_triggers():
	var rem = []
	for i in range(len(component_triggers)):
		var trigger : Trigger = component_triggers[i].base_component.unlock_trigger
		if trigger.is_met(day_stats[trigger.trigger_stat_name]):
			rem.append(component_triggers[i])
	
	for component_save in rem:
		notificationSystem.add_unlock_notification(component_save.base_component)
		Game.player_data.unlock_component(component_save.base_component)
		component_triggers.erase(component_save)

	rem = []
	for i in range(len(achievement_triggers)):
		var trigger : Trigger = achievement_triggers[i].achievement_trigger
		if trigger.is_met(day_stats[trigger.trigger_stat_name]):
			rem.append(achievement_triggers[i])

	for achievement in rem:
		notificationSystem.add_achievement_notification(achievement)
		Game.player_data.award_achievement(achievement)
		for reward in achievement.resource_rewards:
			var total = reward.amount
			match reward.res_name:
				"ore":
					score += total
				"red_gem":
					Game.player_data.add_resource_amount(reward.res_name, total)
				"blue_gem":
					Game.player_data.add_resource_amount(reward.res_name, total)
				"green_gem":
					Game.player_data.add_resource_amount(reward.res_name, total)
				"plasma":
					Game.player_data.add_resource_amount(reward.res_name, total)
				
		
		achievement_triggers.erase(achievement)

func new_day_button_pressed():
	game_over()
	Game.new_day()

func shop_button_pressed():
	game_over()
	Game.go_to_shop()

func main_menu_button_pressed():
	game_over()
	Game.go_to_main_menu()

#append per-day saved resources to player data
func append_res_to_save_data():
	#TODO: make more robust!
	for key in day_stats.keys():
		Game.player_data.set_stat(key, max(Game.player_data.get_stat(key), day_stats[key]))
	
	per_day_resources[0].amount = int(score)
	for i in range(len(per_day_resources)):
		Game.player_data.add_resource_amount(per_day_resources[i].res_name, per_day_resources[i].amount)

func save_day_to_file():
	if !day_has_been_saved:
		day_has_been_saved = true
		append_res_to_save_data()
		Game.end_day()

func game_over(reason : String = "none", show_game_over_screen : bool = false):
	save_day_to_file()
	if show_game_over_screen:
		gameover.game_over(reason)
