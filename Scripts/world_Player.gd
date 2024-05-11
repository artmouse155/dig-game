extends Node2D

@export var world : Node2D

#pixels a second

var starting_pos = Vector2(960,-500)
var acceleration = 500
var resistance_acceleration = 150
var stop_acceleration = 3000
var velocity = 0
var rotational_velocity = .5
var max_speed = 400
var base_angle = deg_to_rad(90)
var max_angle = deg_to_rad(50)
var drill_speed = 60

# as you get closer to the center of the driller, you get up to this many times more better at drilling
var player_closeness_drill_speed_multiplier = 2

var turbos = 1

var camera_pos = Vector2.ZERO

var experiencing_resistance = false
var colliding = false

var BASE_ENERGY = 100
const ENERGY_DECAY_RATE = 10
var energy = BASE_ENERGY

var BASE_DURABILITY = 1000
const DURABILITY_DECAY_RATE = 10
var durability = BASE_DURABILITY

var fake_velocity = 40

func _ready():
	position = starting_pos
	$Sprite.rotation = base_angle
	if not Debug.override_player_durability_and_energy:
		BASE_DURABILITY = Game.player_data.get_buff_amount("durability")
		BASE_ENERGY = Game.player_data.get_buff_amount("energy")
		durability = BASE_DURABILITY
		energy = BASE_ENERGY
		
	
	if Debug.best_driller:
		drill_speed = 1000
		max_speed = 4000
		energy = 9999999999

func _process(delta):
	if not Game.paused:
		if colliding:
			velocity = clamp(velocity - (stop_acceleration * delta), 0, max_speed)
			durability -= DURABILITY_DECAY_RATE * delta
		elif experiencing_resistance:
			velocity = clamp(velocity - (resistance_acceleration * delta), 0, max_speed)
			durability -= DURABILITY_DECAY_RATE * delta
		else:	
			velocity = clamp(velocity + (acceleration * delta), 0, max_speed)
		position += Vector2(cos($Sprite.rotation),sin($Sprite.rotation)) * velocity * delta
		if position.y > 0:
			if Input.is_action_pressed("player_turn_left"):
				$Sprite.rotation = clamp($Sprite.rotation + (rotational_velocity * delta), $Sprite.rotation, base_angle + max_angle)
			elif Input.is_action_pressed("player_turn_right"):
				$Sprite.rotation = clamp($Sprite.rotation - (rotational_velocity * delta), base_angle - max_angle, $Sprite.rotation)
			$Sprite.rotation = fmod($Sprite.rotation,2*PI)
		
		if (position.y > 0):
			energy -= ENERGY_DECAY_RATE * delta
		update_bars()
		update_hud()
		if energy < 0:
			world.game_over("energy", true)
		if durability < 0:
			world.game_over("durability", true)

func screenshake():
	var tweener = create_tween()
	for i in range(3):
		var angle = randf() * 2 * PI
		var v = 5 * Vector2(cos(angle), sin(angle))
		var new_pos = camera_pos + v
		tweener.tween_property($camera, "position", new_pos, .05)
	tweener.tween_property($camera, "position", camera_pos, .05)

func update_bars():
	%Durability.value = (durability / float(BASE_DURABILITY)) * %Durability.max_value
	%Energy.value = (energy / float(BASE_ENERGY)) * %Energy.max_value

func update_hud():
	%Depth.text = str(floor(max(0,position.y) / Game.TILE_WIDTH))
	%Speed.text = str(floor(10 * (velocity / fake_velocity)) / 10.0)
	%Turbo.text = str(turbos)
