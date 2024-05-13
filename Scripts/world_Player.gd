extends Node2D

@export var world : Node2D
@export var player_texture : Node2D

@export var intermediate_damage_curve : Curve

#CONSTANTS
const ENERGY_DECAY_RATE = 10
const DURABILITY_DECAY_RATE = 10

const SCREENSHAKE_DURATION = .15

var starting_pos = Vector2(0,-500)

var resistance_acceleration_constant = 10 #resistance accel = CONSTANT * base_acceleration

var falling_acceleration = 6
var stop_acceleration = 99999

#pixels a second

#DETERMINED BY DRILLER MATERIALS

#agility
var degrees_of_freedom = deg_to_rad(50)
var base_rotational_velocity = deg_to_rad(40)
var turbo_rotational_velocity = deg_to_rad(20)

#max speed
var base_max_speed = 8
var turbo_max_speed = 6 #modifier

#acceleration
var base_acceleration : float = 3
var turbo_acceleration : float = 20 #modifier

#engine power
var base_engine_power = 1.5
var turbo_engine_power = 1.5 #modifier

#turbos
var turbo_duration : float = 2.0
var base_turbos : float = 1

#durability
var total_durability = 1000

#energy
var total_energy = 100

#DETERMINED AT RUNTIME
var rotational_velocity = base_rotational_velocity
var velocity : float = 0.0 # tiles per second
var max_speed = base_max_speed
var engine_power : float = base_engine_power #damage per second

var acceleration = base_acceleration # tiles per second per second


var turbos : float = base_turbos
var am_turboing

var driller_angle = 0

var camera_pos = Vector2.ZERO

var max_damage_ratio = 0
var complete_stop = false

var depth = 0

var energy = total_energy
var durability = total_durability

func _ready():
	
	position = starting_pos
	set_sprite_rotation()
	if not Debug.override_player_durability_and_energy:
		calc_base_variables()
	recalc_driller_variables()
	
	if Debug.best_driller:
		engine_power = 1000
		max_speed = 4000
		energy = 9999999999

func calc_base_variables():
	var drill_scale = Game.player_data.hull.drill_scale
	
	
	print("new drill radius: " + str(world.drill_radius))
	print("new player radius: " + str(world.player_radius))
	world.player_radius =  drill_scale * Game.player_data.hull.actual_texture.get_height() / float(Game.TILE_WIDTH)
	world.drill_radius = drill_scale * Game.player_data.drill.actual_texture.get_height() / float(Game.TILE_WIDTH)
	
	total_durability = Game.player_data.get_buff_amount("durability")
	total_energy = Game.player_data.get_buff_amount("energy")
	base_max_speed = Game.player_data.get_buff_amount("max_speed")
	base_turbos = Game.player_data.get_buff_amount("turbos")
	
	turbos = base_turbos
	durability = total_durability
	energy = total_energy

func recalc_driller_variables():
	if am_turboing:
		engine_power = base_engine_power + turbo_engine_power
		acceleration = base_acceleration + turbo_acceleration
		max_speed = base_max_speed + turbo_max_speed
		rotational_velocity = base_rotational_velocity + turbo_rotational_velocity
	else:
		engine_power = base_engine_power
		acceleration = base_acceleration
		max_speed = base_max_speed
		rotational_velocity = base_rotational_velocity

#func _process(delta):

func move(delta):
	if not Game.paused:
		if complete_stop:
			screenshake()
			velocity = clamp(velocity - (stop_acceleration * delta), 0, max_speed)
			durability -= DURABILITY_DECAY_RATE * delta
		#elif experiencing_resistance:
		#	velocity = clamp(velocity - (resistance_acceleration * delta), 0, max_speed)
		#	durability -= DURABILITY_DECAY_RATE * delta
		elif global_position.y < 0:
			velocity = clamp(velocity + (falling_acceleration * delta), 0, max_speed)
		else:
			#velocity = clamp(velocity + (acceleration * delta), 0, max_speed * (1 - intermediate_damage_curve.sample(max_damage_ratio)))
			velocity = clamp(velocity + ((acceleration - ((10 * base_acceleration) * max_damage_ratio)) * delta), 0, max_speed)
		position += (Vector2.DOWN * velocity * float(Game.TILE_WIDTH) * delta).rotated(driller_angle)
		if position.y > 0:
			if Input.is_action_pressed("player_turn_left"):
				driller_angle = clamp(driller_angle + (rotational_velocity * delta), -degrees_of_freedom, degrees_of_freedom)
			
			elif Input.is_action_pressed("player_turn_right"):
				driller_angle = clamp(driller_angle - (rotational_velocity * delta), -degrees_of_freedom, degrees_of_freedom)
			
			set_sprite_rotation()
		
		if (position.y > 0):
			energy -= ENERGY_DECAY_RATE * delta
		
		depth = floor(max(0,(player_texture.get_drill_center().global_position.y / Game.TILE_WIDTH)))
			
		update_bars()
		update_hud()
		if energy < 0:
			world.game_over("energy", true)
		if durability < 0:
			world.game_over("durability", true)

func screenshake(duration : float = SCREENSHAKE_DURATION):
	var tweener = create_tween()
	var loop_count = round(duration / .05)
	for i in range(loop_count):
		var angle = randf() * 2 * PI
		var v = 5 * Vector2(cos(angle), sin(angle))
		var new_pos = camera_pos + v
		tweener.tween_property($camera, "position", new_pos, .05)
	tweener.tween_property($camera, "position", camera_pos, .05)

func set_sprite_rotation():
	player_texture.rotation = driller_angle

func set_turbo_active(b : bool = true):
	am_turboing = b
	recalc_driller_variables()

func turbo():
	if (turbos > 0) and !am_turboing and (depth > 0):
		set_turbo_active(true)
		turbos = turbos - 1
		screenshake(turbo_duration)
		var turbo_tweener = create_tween()
		#turbo_tweener.tween_method($camera, "position", camera_pos, turbo_duration)
		turbo_tweener.tween_callback(set_turbo_active.bind(false)).set_delay(turbo_duration)

func update_bars():
	%Durability.value = (durability / float(total_durability)) * %Durability.max_value
	%Energy.value = (energy / float(total_energy)) * %Energy.max_value

func update_hud():
	%Depth.text = str(depth)
	%Speed.text = str(floor(10 * velocity) / 10.0)
	%Turbo.text = str(turbos)
