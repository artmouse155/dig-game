extends Node2D

@export var data_display : Control
@export var particles : GPUParticles2D

var pos : Vector2

func gem_setup(_p : Vector2, data : ResourceData):
	pos = _p
	data_display.gem_setup(data)

func powerup_setup(_p : Vector2, data : BuffItem):
	pos = _p
	data_display.powerup_setup(data)

func _ready():
	global_position = pos
	particles.emitting = true
	var tweener = create_tween()
	tweener.tween_callback(queue_free).set_delay(1)
