extends Control

const ANIM_TIME: float = 0.1

var throttle_tweener : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update(speed : int):
	if throttle_tweener:
		throttle_tweener.kill()
	throttle_tweener = create_tween()
	#$ThrottleKnob.position.y = 190 - (50 * speed)
	var new_knob_pos = $ThrottleKnob.position.lerp(Vector2(0, 190 - (50 * speed)), 1)
	throttle_tweener.tween_property($ThrottleKnob, "position", new_knob_pos, ANIM_TIME).set_trans(Tween.TRANS_BOUNCE)
