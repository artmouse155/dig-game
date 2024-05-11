extends ColorRect

var shader_material

const ANIM_DURATION = .2

signal anim_completed

@onready var tween

func _ready():
	# Check if the sprite has a shader material
	if self.material is ShaderMaterial:
		# Cast the material to ShaderMaterial
		shader_material = self.material as ShaderMaterial
		shader_material.set_shader_parameter("animation_duration", ANIM_DURATION)
		
	else:
		print("Sprite does not have a shader material applied.")

func fade_in():
	show()
	if tween:
		tween.kill()
	tween = create_tween()
	set_shader_flipped(false)
	tween.tween_method(set_shader_progress, 0.0, 1.0, ANIM_DURATION)#.set_trans(Tween.TRANS_SINE)
	tween.tween_callback(emit_completed_signal)
	await anim_completed

func instant_fade_in():
	show()
	set_shader_flipped(false)
	set_shader_progress(1.0)

func fade_out():
	if tween:
		tween.kill()
	tween = create_tween()
	set_shader_flipped(true)
	tween.tween_method(set_shader_progress, 1.0, 0.0, ANIM_DURATION)#.set_trans(Tween.TRANS_SINE)
	tween.tween_callback(emit_completed_signal)
	await anim_completed
	hide()

func set_shader_progress(p):
	if shader_material:
		shader_material.set_shader_parameter("progress", p)

func set_shader_flipped(b):
	if shader_material:
		shader_material.set_shader_parameter("flipped", b)

func emit_completed_signal():
	anim_completed.emit()
