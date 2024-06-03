extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update(speed : int):
	#$ThrottleKnob.position.y = 190 - (50 * speed)
	$ThrottleKnob.position = $ThrottleKnob.position.lerp(Vector2(0, 190 - (50 * speed)), 1)
