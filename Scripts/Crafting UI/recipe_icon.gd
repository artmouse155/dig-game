extends Node2D

@export var special_fx: Node2D
@export var particles : GPUParticles2D
@export var sprite : Sprite2D

signal clicked

func show_glow(b: bool):
	special_fx.visible = b
	particles.visible = b

func _input(event):
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT\
	and event.pressed\
	and sprite.get_rect().has_point(get_local_mouse_position()):
		pass
		#clicked.emit()
