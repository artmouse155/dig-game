extends Node2D

const FADE_AMOUNT = .2

@export var special_fx: Node2D
@export var particles : GPUParticles2D
@export var sprite : Sprite2D

var faded: bool = false

signal clicked

func show_glow(b: bool):
	if faded:
		b = false
	special_fx.visible = b
	particles.visible = b

func set_faded(b: bool):
	faded = b
	if b:
		modulate.a = FADE_AMOUNT
		show_glow(false)
	else:
		modulate.a = 1

func set_texture(t: Texture2D):
	sprite.texture = t

func _input(event):
	if event is InputEventMouseButton\
	and event.button_index == MOUSE_BUTTON_LEFT\
	and event.pressed\
	and sprite.get_rect().has_point(get_local_mouse_position()):
		pass
		#clicked.emit()
