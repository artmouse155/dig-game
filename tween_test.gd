extends TextureRect
#region variables
## Automatically kill tween when setting if it exists.
var tween : Tween:
	set(value):
		if tween:
			tween.kill()
		tween = value

## This is a "curve" resource file, which can be modified to anything you like
@export var TWEEN_CURVE: Curve = preload("res://tween_curve.tres")
const INIT_SCALE : Vector2 = Vector2.ONE
const HOVER_SCALE : Vector2 = Vector2.ONE * 1.2
const HOVER_TIME : float = 1
const SHRINK_TIME := 0.1
#endregion

## Use initial scale and center for rescaling
func _init(): 
	scale = INIT_SCALE
	pivot_offset = size / 2

## Connect signals for mouse hover
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
## When hovered, loop through growing and shrinking in a basic sine shape
func _on_mouse_entered():
	const LINEAR_TWEEN_RATIO : float = 4
	# Make animation loop until not hovered.
	# Note that tween.set auto kills it.
	tween = create_tween().set_loops()
	# Instead of set_trans and set_ease, instead use set_custom_interpolator.
	# Here I used a lambda to return a point along the curve.
	# General form is set_custom_interpolator(func(x): return PRELOADED_CURVE_TRES.sample_baked(x))
	tween.tween_property(self, "scale", HOVER_SCALE, HOVER_TIME).set_custom_interpolator(func(x): return TWEEN_CURVE.sample_baked(x))
	# Tweens run in series by default, add set_parallel() onto create_tween() to make them all run at once.
	tween.tween_property(self, "scale", INIT_SCALE, HOVER_TIME / LINEAR_TWEEN_RATIO).set_trans(Tween.TRANS_LINEAR)

	
func _on_mouse_exited():
	tween = create_tween()
	tween.tween_property(self, "scale", INIT_SCALE, SHRINK_TIME).set_trans(Tween.TRANS_BACK)
