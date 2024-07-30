extends Control

@export var linear_curve: Curve
@export var bell_curve: Curve
@export var smooth_curve: Curve
@export var constant_curve: Curve
@export var randf_noise: Noise
@export var smooth_noise: Noise

const SMOOTH_NOISE_MIN = -.75
const SMOOTH_NOISE_MAX = .75

const LIGHT_RADIUS_CHANGE_SPEED = .02

const RANDF_NOISE_MIN = -1
const RANDF_NOISE_MAX = 1

#if the tile we want to mine will only be in our drill radius for less than MINE_DIST distance, disregard
const MINE_DIST: float = 1

@export var day_number_label: Label
const DAY_NUMBER_Y_OFFSET = -700

var score: float = 0.0

@export var gen_data: Array[Gen]

#used in structure placement
@export var air_gen: Gen

@onready var subviewport = $SubViewportContainer/SubViewport
@onready var gameover = $GameOver

@export var iconAndTextParticle: PackedScene
@export var notificationSystem: Node2D
@export var throttle: Control
#var tile_data = {}

var chunks = {}

#the radius of my chunk rendering distance
var render_distance = 4
var chunk_tick_rate = 1

#ID's of chunks to load when the game is first started.
var preloaded_chunks: Array[Vector2i] = [
	Vector2i(-4,0),
	Vector2i(-3,0),
	Vector2i(-2,0),
	Vector2i(-1,0),
	Vector2i(0,0),
	Vector2i(1,0),
	Vector2i(2,0),
	Vector2i(3,0),
	Vector2i(4,0),
]

#a constantly changing buffer of chunks to load
var chunks_to_load: Array[Vector2i] = []

var pregeneration_completed = false
var change_light_radius_tween

#TODO: make all resolution changes dynamic
const CHUNK_RESOLUTION: int = 16
var DEFAULT_CHUNK = CHUNK_RESOLUTION * Vector2i.ONE
#@export var noise_texture : NoiseTexture2D

#tm is tile map
@onready var bg_tm = %TileMap/Background
@onready var earth_tm = %TileMap/Earth
@onready var light_tm = %Light
@onready var structure_fg_tm = %TileMap/StructureFG
@onready var structure_bg_tm = %TileMap/StructureBG

#@onready var chunk_path = %Player/ChunkRegion/PathFollow2D

const BACKGROUND_LAYER = -1
const GROUND_LAYER = 0
const LIGHT_LAYER = 1

const DIM_LIGHT = Vector2i(1, 0)
const FULL_BRIGHT_LIGHT = Vector2i(0, 0)

var camera_pos = Vector2.ZERO # Vector2(1920,1080)

var ground_source_id = 1
var light_source_id = 2

#const GRASS_ATLAS = Vector2i(7, 3)

var light_radius = 9

var drill_radius = 1.8
var player_radius = 1.5
const BOMB_RADIUS = 12

#inside of light_radius
const LIGHT_EDGE_SIZE = 3

var background_atlas:
	get:
		return Vector2i(randi_range(3, 7), 2)

var per_day_resources: Array[ResourceData] = [
	ResourceData.new("ore", 0),
	ResourceData.new("red_gem", 0),
	ResourceData.new("green_gem", 0),
	ResourceData.new("blue_gem", 0),
	ResourceData.new("plasma", 0),
]
@onready var per_day_resources_key = per_day_resources.map(func(r_d): return r_d.res_name)

var day_has_been_saved: bool = false

#ALERT: THIS MUST BE SYNCED WITH THE STATS IN PLAYER_DATA.GD
var day_stats = {
	"max_depth": 0,
	"max_ore": 0,
	"max_green_gems": 0,
	"max_blue_gems": 0,
	"max_red_gems": 0,
	"max_plasma": 0,
	"max_powerups_collected": 0,
	"max_boosts_used": 0,
	"max_blocks_broken": 0,
	"max_speed": 0,
	"max_time_mining": 0
}

var component_triggers: Array[ComponentObjectSaveData] = []
var achievement_triggers: Array[Achievement] = []

var start_time_ms = 0

signal loaded
var is_loaded = false

func _ready():
	start_time_ms = Time.get_ticks_msec()
	
	#%Player/ChunkRegion.scale = DEFAULT_CHUNK
	if Debug.settings.smooth_lighting:
		%LightRect.set_tile_resolution(Vector2.ONE)
		%LightRect.set_light(Game.TILE_WIDTH * light_radius, Game.TILE_WIDTH * LIGHT_EDGE_SIZE)
	else:
		%LightRect.set_tile_resolution(Game.TILE_WIDTH * Vector2.ONE)
		%LightRect.set_light(light_radius, LIGHT_EDGE_SIZE)
	
		
	update_light_rect()
	%LightRect.visible = !Debug.settings.fullbright
	for i in gen_data:
		match i.noise:
			"randf":
				i.noise_res = randf_noise.duplicate()
			"smooth":
				i.noise_res = smooth_noise.duplicate()
		i.noise_res.seed = randi()
	
	day_number_label.text = "Day " + str(Game.player_data.get_stat("day_number"))
	day_number_label.position.y = DAY_NUMBER_Y_OFFSET
	
	if Game.player_data.get_stat("max_depth") != 0:
		%HFollow/PB.position.y = Game.player_data.get_stat("max_depth") * Game.TILE_WIDTH
	
	update_h_follow_pos()

	setup_triggers()
	generate_world()
	print("pregeneration_completed.")
	is_loaded = true
	loaded.emit()
	

func setup_triggers():
	var all_components: Array[DrillerComponentObject] = Game.get_all_game_objects()
	for i in range(len(all_components)):
		var comp_save_data = Game.player_data.find_component_object_save_data(all_components[i])
		if not comp_save_data.recipe_found:
			component_triggers.append(comp_save_data)
	
	var all_acheivements: Array[Achievement] = Game.get_all_achievements()
	for i in range(len(all_acheivements)):
		if not Game.player_data.is_acheivement_completed(all_acheivements[i]):
			achievement_triggers.append(all_acheivements[i])

func update_h_follow_pos():
	%HFollow.position.x = %Player.position.x - Game.RESOLUTION.x / 2

#TODO: Doesn't need to happen every single tick?
func check_chunk_regions():
	var player_chunk_coordinate = coords_to_chunk(pixel_coords_to_map_coords(%Player.position))
	for x in range((-1 * render_distance), 1 + (1 * render_distance)):
		for y in range((-1 * render_distance), 1 + (1 * render_distance)):
			var offset_chunk_coords = Vector2i(x,y)
			if offset_chunk_coords.length() <= render_distance:
				var chunk_coordinate = player_chunk_coordinate + Vector2i(x,y)
				if not chunk_has_data(chunk_coordinate):
					if not (chunk_coordinate in chunks_to_load):
						chunks_to_load.append(chunk_coordinate)
	
	for i in range(chunk_tick_rate):
		if not chunks_to_load.is_empty():
			#could be pop back to be more mem efficient but pop front keeps loaded chunks clustered
			generate_chunk(chunks_to_load.pop_front())
	#TODO: If you are moving so fast that a chunk actually leaves player proximity, either don't load it or unload it?

func generate_world():
	for chunk in preloaded_chunks:
		generate_chunk(chunk)
		
	generate_structure(preload("res://test_room.tres"), Vector2i(0,0), Vector2i(0,10))
	generate_structure(preload("res://test_room.tres"), Vector2i(-1,10), Vector2i(10,10))

func generate_chunk(chunk_coords: Vector2i):
	var start_time = Time.get_ticks_msec()
	
	var temp_chunk = get_chunk_data(chunk_coords, true)

	for i in gen_data:
		if ((DEFAULT_CHUNK.y * chunk_coords.y) >= i.min_depth) or ((DEFAULT_CHUNK.y * (chunk_coords.y + 1)) - 1 <= i.max_depth):
			var noise = i.noise_res
			var noise_min = 0
			var noise_max = 1
			var curve: Curve
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
					var function_input = float(y_cor - i.min_depth) / (1 + (i.max_depth - i.min_depth))
					var threshold_value = (curve.sample(function_input) * (i.max_freq - i.min_freq)) + i.min_freq
					for x in range(DEFAULT_CHUNK.x):
						var coords = Vector2i(x, y) + Vector2i(chunk_coords.x * DEFAULT_CHUNK.x, chunk_coords.y * DEFAULT_CHUNK.y)
						var noise_value = (noise.get_noise_2d(coords.x, coords.y) - noise_min) / (noise_max - noise_min)
						
						if (!temp_chunk[x][y]) and (noise_value <= threshold_value):
							#below line is for when there is already data within the chunks (specifically when there is a structure that already exists before the full chunk gen)
							#if !get_tile_data(coords):
							
								#this modifies the "chunks" dict because of pass by ref!
								#temp_chunk[x][y] = {"health" = i.health, "gen" = i}
								set_tile_data(coords, {"health" = i.health, "gen" = i}, false)
						elif temp_chunk[x][y]:
							print(temp_chunk[x][y]["gen"].name)
							
	var mid_time = Time.get_ticks_msec()
	var mid_elapsed_time = mid_time - start_time

	draw_chunk(chunk_coords)
	#print("drew chunk at ", chunk_coords)
	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	print("Chunk generated in ", elapsed_time, "ms (", mid_elapsed_time, "ms + ", (end_time - mid_time), "ms)")

func generate_structure(structure: StructureData, chunk_coords: Vector2i, tile_coords: Vector2i):
	pass
	#structure = preload("res://Scenes/Rooms/ro.tscn")
	#check if structure can be placed at the location
	#check if structure intersects with any existing structures
	if not structure_fg_tm.tile_set == structure.tile_set:
		print("ERROR: Tileset of StructureFG is different from the one is the room we want to load")
	
	var real_coords: Vector2i = (chunk_coords * CHUNK_RESOLUTION) + tile_coords
	
	structure_bg_tm.set_pattern(real_coords + structure.bg_origin, structure.bg_tiles)
	structure_fg_tm.set_pattern(real_coords + structure.fg_origin, structure.fg_tiles)
	for cell in structure.bg_tiles.get_used_cells():
		var coords = real_coords + structure.bg_origin + cell
		var cell_chunk_coords = coords_to_chunk(coords)
		if !chunk_has_data(cell_chunk_coords):
			generate_chunk(cell_chunk_coords)

		set_tile_data(coords, {"health" = 0, "gen" = air_gen}, true, true)
		#print("just made a structure! ", get_tile_data(coords))
		earth_tm.erase_cell(coords)
		light_tm.set_cell(real_coords + structure.bg_origin + cell, light_source_id, FULL_BRIGHT_LIGHT)
	for cell in structure.fg_tiles.get_used_cells():
		var coords = real_coords + structure.fg_origin + cell
		var cell_chunk_coords = coords_to_chunk(coords)
		if !chunk_has_data(cell_chunk_coords):
			generate_chunk(cell_chunk_coords)
		
		set_tile_data(coords, {"health" = 0, "gen" = air_gen}, true, true)
		earth_tm.erase_cell(coords)
		light_tm.set_cell(coords, light_source_id, FULL_BRIGHT_LIGHT)
	
	
		#finally, add objects
		for object in structure.room_objects:
			var temp_object = StructureObjectDB.get_sprite_scene(object.name).instantiate()
			temp_object.position = object.position + (Game.TILE_WIDTH * Vector2(real_coords))
			%StructureObjects.add_child(temp_object)
		
func draw_chunk(chunk_coords: Vector2i):
	print("CHUNK: " + str(chunk_coords))
	
	if (chunk_coords.y < 0):
		print("chunk coords less than zero")
	
	for x in range(DEFAULT_CHUNK.x):
		for y in range(DEFAULT_CHUNK.y):
			var coords = Vector2i(x, y) + Vector2i(chunk_coords.x * DEFAULT_CHUNK.x, chunk_coords.y * DEFAULT_CHUNK.y)
			if tile_has_data(coords):
				if get_tile_data(coords):
					var gen: Gen = get_chunk_data(chunk_coords)[x][y]["gen"]
					earth_tm.set_cell(coords, ground_source_id, gen.atlas[randi_range(0, gen.atlas.size() - 1)])
					if !Debug.settings.fullbright:
						#dont put light on topmost layer
						if coords.y == 0:
							light_tm.set_cell(coords, light_source_id, FULL_BRIGHT_LIGHT)
							
						if Debug.settings.see_ores and (gen.group == "ore"):
							light_tm.set_cell(coords, light_source_id, FULL_BRIGHT_LIGHT)
						
						if Debug.settings.see_powerups and (gen.group == "powerup"):
							light_tm.set_cell(coords, light_source_id, FULL_BRIGHT_LIGHT)
			
			if (chunk_coords.y < 0) and (coords.y < 0):
				light_tm.set_cell(coords, light_source_id, FULL_BRIGHT_LIGHT)

func _process(delta):
	
	if not Game.paused:
		if is_loaded:
			if Input.is_action_just_pressed("accelerate"):
				%Player.change_speed()
			elif Input.is_action_just_pressed("decelerate"):
				%Player.change_speed(-1)
			update_h_follow_pos()
			mine_and_move(delta)

			check_chunk_regions()
			%Player/Radar.update_radar_circles()
			check_triggers()

			day_stats["max_speed"] = max(day_stats["max_speed"], %Player.velocity)
			day_stats["max_depth"] = max(day_stats["max_depth"], %Player.depth)
			#damage_tile(center_tile, %Player.drill_speed * delta)
			#tile_break_particle.position = get_global_mouse_position()

func mine_and_move(delta):
		#Code for mining
		#%Sky.position.x = %Player.position.x - resolution.x/2
		
		#var center_tile = earth_tm.local_to_map( %Player.position)
		light_up_around_pixel_coords(%Player.position)
		
		var drill_tile = earth_tm.local_to_map( %Player.player_texture.get_drill_center().global_position)
		
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
		var max_damage_ratio: float = 0.0
		var max_accel: float = 0.0
		for x in range(ceil(2 * drill_radius)):
			for y in range(ceil(2 * drill_radius)):
				var tile_pos = drill_tile - Vector2i(x, y) + Vector2i(Vector2i.ONE * round(drill_radius))
				if get_tile_data(tile_pos):
					var tile_distance = ((Vector2(tile_pos) + Vector2(.5, .5)) * Game.TILE_WIDTH).distance_to( %Player.player_texture.get_drill_center().global_position) / float(Game.TILE_WIDTH)
					if tile_distance <= (drill_radius):
						var normalized_x_y = (((Vector2(tile_pos) + Vector2(.5, .5)) * Game.TILE_WIDTH) - %Player.player_texture.get_drill_center().global_position).rotated( %Player.driller_angle) / float(Game.TILE_WIDTH)
						
						var health: float = get_tile_data(tile_pos)["health"]
						
						var eqn_dist = (sqrt(pow(drill_radius, 2) + pow(normalized_x_y.x, 2)) - normalized_x_y.y)
						if (eqn_dist >= MINE_DIST):
							var t = (health / damage)
							var needed_decel = (2 * pow(t, 2)) * (eqn_dist - (%Player.velocity * t))
							max_accel = max(max_accel, needed_decel)
							var complete_stop_threshold: float = (damage * eqn_dist / (%Player.velocity))
							if health > complete_stop_threshold:
								print("stopped! eqn dist:" + str(eqn_dist))
								complete_stop_threshold_met = true
							else:
								max_damage_ratio = max(max_damage_ratio, float(health) / complete_stop_threshold)

						damage_tile(tile_pos, damage * delta)

				#damage_tile(temp_tile_pos, damage * delta)
		%Player.max_damage_ratio = max_damage_ratio
		%DEBUG.text = "max_damage_ratio:  " + str(max_damage_ratio)
		%Player.complete_stop = complete_stop_threshold_met
		%Player.move(delta)
		update_light_rect()

func update_light_rect():
	#%LightRect.set_grid_offset((%LightRect.size / 1))
	%LightRect.set_grid_offset(((%LightRect.size / -2) + %Player/camera.global_position) / Game.TILE_WIDTH)
	%LightRect.set_light_pixel_center(%LightRect.size / 2)

func change_light_radius(new_light_radus: float, do_tweening: bool = true):
	if change_light_radius_tween:
		change_light_radius_tween.kill()
	change_light_radius_tween = create_tween()
	if do_tweening:
		change_light_radius_tween.tween_method(internal_set_light_radius, light_radius, new_light_radus, (LIGHT_RADIUS_CHANGE_SPEED * abs(new_light_radus - light_radius))).set_trans(Tween.TRANS_SINE)
	else:
		internal_set_light_radius(new_light_radus)
#only for use by tween!
func internal_set_light_radius(radius: float):
	light_radius = radius
	%LightRect.set_light(light_radius, LIGHT_EDGE_SIZE)

func _input(ev):
	
	if Input.is_key_pressed(KEY_8):
		loaded.emit()
	
	if not Game.paused:
		if Input.is_action_just_pressed("shop"):
			shop_button_pressed()
		
		if Input.is_action_just_pressed("reset_day"):
			new_day_button_pressed()
		
		if Input.is_action_just_pressed("kill"):
			game_over("durability", true)
			
		if Input.is_action_just_pressed("debug_trigger"):
			notificationSystem.add_recipe_found_notification(Game.player_data.hull)

		if Input.is_action_pressed("turbo"):
			%Player.turbo()
			
		if Input.is_action_just_pressed("debug_increase_light"):
			change_light_radius(light_radius + 3)
			
		if Input.is_action_just_pressed("debug_decrease_light"):
			change_light_radius(light_radius - 3)

		if ev is InputEventMouseButton:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				var center_tile = earth_tm.local_to_map( %Player.get_local_mouse_position() + %Player.position)
				%Player.screenshake()
				
				for x in range(1 + (2 * BOMB_RADIUS)):
					for y in range(1 + (2 * BOMB_RADIUS)):
						var tile_pos = center_tile - Vector2i(x, y) + Vector2i(Vector2i.ONE * floor(BOMB_RADIUS))
						var tile_distance = Vector2(tile_pos).distance_to(Vector2(center_tile))

						if tile_distance <= (BOMB_RADIUS):
							damage_tile(tile_pos, 999)

func mine_tile(coords, tileGen: Gen):
	if tile_exists(coords):
		var particle = preload ("res://Scenes/tile_break_particle.tscn").instantiate()
		subviewport.add_child(particle)
		particle.position = earth_tm.map_to_local(coords)
		particle.restart()
		particle.finished.connect(particle.queue_free)
		
		if (tileGen.group == "ore"):
			var points_indicator = preload ("res://Scenes/label_particle.tscn").instantiate()
			points_indicator.setup(str(tileGen.value))
			subviewport.add_child(points_indicator)
			points_indicator.position = earth_tm.map_to_local(coords)
			points_indicator.particle_maker.restart()
			points_indicator.particle_maker.finished.connect(points_indicator.queue_free)
		
		elif (tileGen.group == "gem"):
			var temp_particle = iconAndTextParticle.instantiate()
			temp_particle.gem_setup(earth_tm.map_to_local(coords), ResourceData.new(tileGen.name, floor(tileGen.value)))
			subviewport.add_child(temp_particle)
		
		elif (tileGen.group == "powerup"):
			var temp_particle = iconAndTextParticle.instantiate()
			temp_particle.powerup_setup(earth_tm.map_to_local(coords), BuffItem.new(tileGen.name, tileGen.value))
			subviewport.add_child(temp_particle)
		
		day_stats["max_blocks_broken"] = day_stats["max_blocks_broken"] + 1
		bg_tm.set_cell(coords, ground_source_id, background_atlas)
		earth_tm.erase_cell(coords)

func light_up_around_pixel_coords(pixel_coords):
	var light_edge_radius = light_radius - LIGHT_EDGE_SIZE
	var center_tile = pixel_coords_to_map_coords(pixel_coords)
	for x in range(1 + (2 * light_radius)):
		for y in range(1 + (2 * light_radius)):
			var tile_pos = center_tile - Vector2i(x, y) + Vector2i(Vector2i.ONE * floor(light_radius))
			var tile_distance = Vector2(earth_tm.map_to_local(tile_pos)).distance_to(Vector2(pixel_coords))
			#var light_level = 15 - floor(min(((tile_distance - (light_radius + 1 - light_edge_radius)) / light_edge_radius), 1) * 15)
			
			#light_level = max(light_level, min(DIM_LIGHT, light_tm.get_cell_atlas_coords(tile_pos).x))
			if (tile_distance / Game.TILE_WIDTH) <= light_edge_radius:
				if light_tm.get_cell_atlas_coords(tile_pos) != FULL_BRIGHT_LIGHT:
					light_tm.set_cell(tile_pos, light_source_id, DIM_LIGHT)

#TODO: figure out why this doesn't work for dirt!
func tile_has_data(coords, force_chunk_generation: bool = false):
	return chunk_has_data(coords_to_chunk(coords), force_chunk_generation)
	#if !(coords.x in tile_data.keys()):
	#		return false
	#if !(coords.y in tile_data[coords.x].keys()):
	#		return false
	#return true

func get_tile_data(coords):
	if tile_has_data(coords):
		var adjusted_coords = Vector2(int(coords.x) % DEFAULT_CHUNK.x, int(coords.y) % DEFAULT_CHUNK.y)
		var data_to_return = get_chunk_data(coords_to_chunk(coords))[adjusted_coords.x][adjusted_coords.y]
		#if data_to_return:
		#	print("Data to return: ", data_to_return, data_to_return["gen"].name)
		return data_to_return
	else:
		return null

func set_tile_data(coords, data, override: bool = true, force_chunk_generation: bool = false):
	if tile_has_data(coords, force_chunk_generation):
		if not override:
			if get_tile_data(coords):
				print("NO TILE DATA SET, SOME ALREADY EXISTED")
				return null
		var adjusted_coords = Vector2(int(coords.x) % DEFAULT_CHUNK.x, int(coords.y) % DEFAULT_CHUNK.y)
		get_chunk_data(coords_to_chunk(coords))[adjusted_coords.x][adjusted_coords.y] = data
	else:
		print("ERROR: NO TILE DATA FOUND")
	
func damage_tile(coords, amount):
	var tile_data = get_tile_data(coords)
	if tile_exists(coords):
		if tile_has_data(coords):
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
						if index != - 1:
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
	return (earth_tm.get_cell_source_id(coords) != - 1) and coords.y >= 0

func get_points(added_points):
	score += added_points
	%Score.text = str(floor(score))

func pixel_coords_to_map_coords(pixel_coords):
	return earth_tm.local_to_map(pixel_coords)

func coords_to_chunk(coords: Vector2i):
	return Vector2i(floor(Vector2(coords) / Vector2(DEFAULT_CHUNK)))

func chunk_has_data(chunk_coords: Vector2i, force_chunk_data: bool = false):
	#if chunk_coords.y < 0:
		#return true
	if chunk_coords.x in chunks.keys():
		if chunk_coords.y in chunks[chunk_coords.x].keys():
			return true
		else:
			if force_chunk_data:
				create_empty_chunk_data(chunk_coords)
				return true
			return false
	else:
		if force_chunk_data:
			create_empty_chunk_data(chunk_coords)
			return true
		
		return false

func create_empty_chunk_data(chunk_coords):
	var temp_chunk = []
	
	for x in range(DEFAULT_CHUNK.x):
		temp_chunk.append([])
		for y in range(DEFAULT_CHUNK.y):
			temp_chunk[x].append(null)

	if !(chunk_coords.x in chunks.keys()):
		chunks[chunk_coords.x] = {}
	if !(chunk_coords.y in chunks[chunk_coords.x].keys()):
		chunks[chunk_coords.x][chunk_coords.y] = temp_chunk

func get_chunk_data(chunk_coords: Vector2i, force_chunk_generation: bool = false) -> Array:
	if chunk_has_data(chunk_coords, force_chunk_generation):
		return chunks[chunk_coords.x][chunk_coords.y]
	print("error: chunk had no data!")
	return []

func check_triggers():
	var rem = []
	for i in range(len(component_triggers)):
		var trigger: Trigger = component_triggers[i].base_component.recipe_found_trigger
		if trigger.is_met(day_stats[trigger.trigger_stat_name]):
			rem.append(component_triggers[i])
	
	for component_save in rem:
		notificationSystem.add_recipe_found_notification(component_save.base_component)
		Game.player_data.set_found_recipe_for_component(component_save.base_component)
		component_triggers.erase(component_save)

	rem = []
	for i in range(len(achievement_triggers)):
		var trigger: Trigger = achievement_triggers[i].achievement_trigger
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

func game_over(reason: String="none", show_game_over_screen: bool=false):
	#TODO: Make this happen for every stat
	day_stats["max_time_mining"] = ((Time.get_ticks_msec() - start_time_ms) / 1000.0)
	Game.player_data.stats["all_time"]["total_time_mining"] = Game.player_data.stats["all_time"]["total_time_mining"] + day_stats["max_time_mining"]
	Game.player_data.stats["per_day"]["max_time_mining"] = max(Game.player_data.stats["per_day"]["max_time_mining"], day_stats["max_time_mining"])
	save_day_to_file()
	if show_game_over_screen:
		gameover.game_over(reason)
