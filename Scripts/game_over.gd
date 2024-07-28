extends Control

const INIT_Y = 500
const FINAL_Y = -75

@onready var box = $Control/Box
@onready var message = $Control/Control/Message

func game_over(reason):
	
	match reason:
		"durability":
			message.texture = preload("res://Assets/Textures/UI/drill_broken.png")
		"energy":
			message.texture = preload("res://Assets/Textures/UI/out_of_energy.png")
	
	%Tip.text = Game.tips[randi_range(0,Game.tips.size() - 1)]
	Game.paused = true
	var size_tweener = create_tween()
	
	size_tweener.tween_property(message, "scale", Vector2.ONE,.2).from(10 * Vector2.ONE).set_trans(Tween.TRANS_CIRC)
	size_tweener.tween_callback(%Player.screenshake)
	
	var box_tweener = create_tween()
	box_tweener.tween_property(box, "position:y", FINAL_Y,1).from(INIT_Y).set_trans(Tween.TRANS_SINE)
	
	var fade_tweener = create_tween()
	fade_tweener.tween_property($Fade, "modulate:a", 1.0,1).from(0.0).set_trans(Tween.TRANS_SINE)
	show()
