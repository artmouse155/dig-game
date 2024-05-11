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

@export var day_number_label : Label
const DAY_NUMBER_Y_OFFSET = -1200

var score = 0

var default_tile_data = {
	"health" : 5,
	"points" : 0
}

@export var gen_data : Array[Gen]

@onready var subviewport = $SubViewportContainer/SubViewport
@onready var gameover = $GameOver

var tile_data = {}

var chunks = {}

var resolution = Vector2(1920,1080)
const CHUNK_RESOLUTION = 32
var chunk = CHUNK_RESOLUTION * Vector2.ONE
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

const LIGHT_RADIUS = 9

var drill_radius = 1.8
var player_radius = 1.5
const BOMB_RADIUS = 9

#inside of light_radius
const LIGHT_EDGE_RADIUS = LIGHT_RADIUS - 3

var dirt_atlas:
	get:
		return Vector2i(randi_range(0,7),randi_range(0,1))
		
var coal_atlas:
	get:
		return Vector2i(randi_range(0,2),2)

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

var day_has_been_saved : bool = false

func _ready():
	#var noise_list = []
	#for x in range(1280):
	#	for y in range(1280):
	#		noise_list.append(smooth_noise.get_noise_2d(x,y))
	#print("Noise List Min: " + str(noise_list.min()))
	#print("Noise List Max: " + str(noise_list.max()))
	%Player/ChunkRegion.scale = chunk

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
	
	day_number_label.text = "Day " + str(Game.player_data.day_number)
	day_number_label.position.y += DAY_NUMBER_Y_OFFSET
	
	if Game.player_data.record_depth != 0:
		%HFollow/PB.position.y = Game.player_data.record_depth * Game.TILE_WIDTH
	
	generate_world()


#TODO: Doesn't need to happen every single tick?
func check_chunk_regions():
	for ratio in [0.0, 1/8.0, 0.25, 3/8.0, 0.5, 5/8.0, 0.75, 7/8.0]:
		#get the point, then tile coordinate, then chunk
		chunk_path.set_progress_ratio(ratio)
		var chunk_coordinate = coords_to_chunk(pixel_coords_to_map_coords(chunk_path.global_position))
		if not chunk_exists(chunk_coordinate):
			generate_chunk(chunk_coordinate)


func generate_world():
	generate_chunk(Vector2.ZERO)

func generate_chunk(chunk_coords):
	var start_time = Time.get_ticks_msec()

	#print("Generating chunk: " + str(chunk_coords))
	if !(chunk_coords.x in chunks.keys()):
		chunks[chunk_coords.x] = {}
	if !(chunk_coords.y in chunks[chunk_coords.x].keys()):
		chunks[chunk_coords.x][chunk_coords.y] = true

	for i in gen_data:
		if ((chunk.y * chunk_coords.y) >= i.min_depth) or ((chunk.y * (chunk_coords.y + 1)) - 1 <= i.max_depth):
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

			var atlas_size = i.atlas.size()
			for y in range(chunk.y):
				var y_cor = y + (chunk.y * chunk_coords.y)
				if (y_cor >= i.min_depth) and (y_cor <= i.max_depth):
					var function_input = float(y_cor - i.min_depth) / (i.max_depth - i.min_depth)
					var threshold_value = (curve.sample(function_input) * (i.max_freq - i.min_freq)) + i.min_freq
					for x in range(chunk.x):
						var coords = Vector2i(x,y) + Vector2i(chunk_coords * chunk)
						var noise_value = (noise.get_noise_2d(coords.x,coords.y) - noise_min) / (noise_max - noise_min)
						if !tile_exists(coords) and (noise_value <= threshold_value):
							tilemap.set_cell(GROUND_LAYER, coords, ground_source_id, i["atlas"][randi_range(0,atlas_size-1)])
						if !Debug.fullbright:
							tilemap.set_cell(LIGHT_LAYER, coords, light_source_id, Vector2i(0,0))
	var end_time = Time.get_ticks_msec()
	var elapsed_time = end_time - start_time
	print("Chunk generated in ", elapsed_time, "ms")

func _process(delta):
	
	if not Game.paused:
		
		#Code for mining
		%HFollow.position.x = %Player.position.x - resolution.x/2
		
		var center_tile = tilemap.local_to_map(%Player.position)
		light_up_around_coords(center_tile)
		
		center_tile = tilemap.local_to_map(%Player.player_texture.get_drill_center().global_position)
		var resistance = false
		var colliding = false

		var min_damage = %Player.drill_speed
		var max_damage = min_damage * %Player.player_closeness_drill_speed_multiplier

		for x in range(1 + (2 * drill_radius)):
			for y in range(1 + (2 * drill_radius)):
				var tile_pos = center_tile - Vector2i(x,y) + Vector2i(Vector2i.ONE * floor(drill_radius))
				var tile_distance = ((Vector2(tile_pos) + Vector2(.5, .5)) * Game.TILE_WIDTH).distance_to(%Player.player_texture.get_drill_center().global_position) / Game.TILE_WIDTH

				#the ratio of closeness to center of driller: 0 is outside, 1 is inside
				#var closeness_ratio = 1 - (tile_distance - player_radius) / float(drill_radius - player_radius)
				var closeness_ratio = 0
				var damage = (closeness_ratio * (max_damage - min_damage)) + min_damage

				if tile_distance <= (drill_radius):
				#if %Player/Player.is_global_point_in_polygon((Vector2(tile_pos) + Vector2(.5, .5)) * Game.TILE_WIDTH):
					if tile_exists(tile_pos):
						resistance = true
						if tilemap.map_to_local(tile_pos).distance_to(%Player.player_texture.global_position) / Game.TILE_WIDTH <= (player_radius):
							colliding = true
					damage_tile(tile_pos, damage * delta)
		%Player.experiencing_resistance = resistance
		%Player.colliding = colliding
		
		check_chunk_regions()

		Game.player_data.record_depth = max(Game.player_data.record_depth, floor(max(0,%Player.position.y) / Game.TILE_WIDTH))
		#damage_tile(center_tile, %Player.drill_speed * delta)
		#tile_break_particle.position = get_global_mouse_position()

func _input(ev):

	if not Game.paused:
		if Input.is_action_just_pressed("shop"):
			shop_button_pressed()
		
		if Input.is_action_just_pressed("reset_day"):
			new_day_button_pressed()
		
		if Input.is_action_just_pressed("kill"):
			game_over("durability", true)

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

func mine_tile(coords, points):
	if tile_exists(coords):
		var particle = preload("res://Scenes/tileBreakParticle.tscn").instantiate()
		subviewport.add_child(particle)
		particle.position = tilemap.map_to_local(coords)
		particle.restart()
		particle.finished.connect(particle.queue_free)
		
		if (points >= 1):
			var points_indicator = preload("res://Scenes/labelParticle.tscn").instantiate()
			points_indicator.setup(str(points))
			subviewport.add_child(points_indicator)
			points_indicator.position = tilemap.map_to_local(coords)
			points_indicator.particle_maker.restart()
			points_indicator.particle_maker.finished.connect(points_indicator.queue_free)
			
		tilemap.set_cell(BACKGROUND_LAYER, coords, ground_source_id, background_atlas)
		tilemap.erase_cell(GROUND_LAYER, coords)

func light_up_around_coords(coords):
	var center_tile = coords
	for x in range(1 + (2 * LIGHT_RADIUS)):
		for y in range(1 + (2 * LIGHT_RADIUS)):
			var tile_pos = center_tile - Vector2i(x,y) + Vector2i(Vector2i.ONE * floor(LIGHT_RADIUS))
			var tile_distance = Vector2(tile_pos).distance_to(Vector2(center_tile))
			var light_level = 7
			if tile_distance <= (LIGHT_RADIUS - LIGHT_EDGE_RADIUS):
				light_level = 15
			else:
				light_level = 15 - floor(min(((tile_distance - (LIGHT_RADIUS + 1 - LIGHT_EDGE_RADIUS)) / LIGHT_EDGE_RADIUS),1) * 15)
			
			light_level = max(light_level, min(DIM_LIGHT,tilemap.get_cell_atlas_coords(LIGHT_LAYER, tile_pos, light_source_id).x))
			if tilemap.get_cell_source_id(LIGHT_LAYER, tile_pos) != -1:
				tilemap.set_cell(LIGHT_LAYER, tile_pos, light_source_id, Vector2i(light_level,0))

func ensure_tile_has_data(coords):
	if !(coords.x in tile_data.keys()):
		tile_data[coords.x] = {}
	if !(coords.y in tile_data[coords.x].keys()):
		tile_data[coords.x][coords.y] = default_tile_data.duplicate()
		for i in gen_data:
			for atlas in i.atlas:
				if tilemap.get_cell_atlas_coords(GROUND_LAYER, coords) == atlas:
					tile_data[coords.x][coords.y]["health"] = i.health
					tile_data[coords.x][coords.y]["points"] = i.value

func get_tile_data(coords):
	ensure_tile_has_data(coords)
	return tile_data[coords.x][coords.y]

func damage_tile(coords, amount):
	if tile_exists(coords):
		ensure_tile_has_data(coords)
		#print(tile_data[coords.x][coords.y]["health"])
		tile_data[coords.x][coords.y]["health"] -= amount
		if get_tile_data(coords)["health"] <= 0:
			var points = tile_data[coords.x][coords.y]["points"]
			get_points(points)
			tile_data[coords.x].erase(coords.y)
			if tile_data[coords.x].is_empty():
				tile_data.erase(coords.x)
			mine_tile(coords, points)
			

func tile_exists(coords):
	return (tilemap.get_cell_source_id(GROUND_LAYER, coords) != -1) and coords.y >= 0

func get_points(added_points):
	score += added_points
	%Score.text = str(floor(score))

func pixel_coords_to_map_coords(pixel_coords):
	return tilemap.local_to_map(pixel_coords)

func coords_to_chunk(coords):
	return floor(Vector2(coords) / chunk)

func chunk_exists(chunk_coords):
	if chunk_coords.y < 0:
		return true
	elif chunk_coords.x in chunks.keys():
		if chunk_coords.y in chunks[chunk_coords.x].keys():
			return true
		else:
			return false
	else:
		return false

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
	per_day_resources[0].amount = score
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
