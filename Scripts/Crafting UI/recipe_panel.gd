extends PanelContainer

@export var icons_center: Control
@export var left_button: Button
@export var right_button: Button

@export var left_gear: Sprite2D
@export var right_gear: Sprite2D

@export var scale_curve: Curve

const RECIPE_SCENE = preload("res://Scenes/Crafting/recipe.tscn")

const SCROLL_STRENGTH = 50
const DRAG_STRENGTH = 1
const RECIPE_SIZE = Vector2(150,150)
const RECIPE_SEPARATION = 200

const SCALE_EFFECT_RADIUS = 300

const GLIDE_SPEED: float = 1000.0

var current_recipe_index: int:
	get:
		return current_recipe_index
	set(value):
		print("current recipe index is ", value)
		current_recipe_index = value
var recipe_progress: float = 0 #in pixels

var recipe_icons: Array[Node] = []

#dragging
var touching_mouse = false
var dragging_with_mouse = false

var glide_tween: Tween
var glide_amt = 0.0

func _ready():
	init_with_recipes(range(5))
	mouse_entered.connect(set_touching_mouse.bind(true))
	mouse_exited.connect(set_touching_mouse.bind(false))
	left_button.pressed.connect(left_button_pressed)
	right_button.pressed.connect(right_button_pressed)

func set_touching_mouse(b):
	touching_mouse = b

func init_with_recipes(recipe_list):
	for i in range(len(recipe_list)):
		var temp_recipe_icon = RECIPE_SCENE.instantiate()
		temp_recipe_icon.clicked.connect(jump_to_recipe_index.bind(i))
		temp_recipe_icon.show_glow(i == 2 or i == 3)
		#var random_color = Color(randf(), randf(), randf(), 1) # Generating random color
		#temp_recipe_icon.color = random_color
		
		#temp_recipe_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#temp_recipe_icon.size = RECIPE_SIZE
		#temp_recipe_icon.pivot_offset = temp_recipe_icon.size * 0.5
		#temp_recipe_icon.position = temp_recipe_icon.size * -0.5
		temp_recipe_icon.position.x += RECIPE_SEPARATION * i
		
		var pos_along: float = recipe_progress + (i * RECIPE_SEPARATION)
		#print("pos_along:", pos_along)
		if (pos_along < SCALE_EFFECT_RADIUS) and (pos_along > -SCALE_EFFECT_RADIUS):
			var x_val = 1 - abs(pos_along / SCALE_EFFECT_RADIUS)
			#print("x_val:", x_val)
			temp_recipe_icon.scale = Vector2.ONE * scale_curve.sample(x_val)
		else:
			temp_recipe_icon.scale = Vector2.ONE
		
		icons_center.add_child(temp_recipe_icon)
		recipe_icons.append(temp_recipe_icon)

func _input(event):
	if event is InputEventMouseMotion:
		if dragging_with_mouse:
			scroll_recipe_progress(DRAG_STRENGTH * event.relative.x)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#scroll_recipe_progress(-SCROLL_STRENGTH)
			if event.pressed:
				left_button_pressed()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#scroll_recipe_progress(SCROLL_STRENGTH)
			if event.pressed:
				right_button_pressed()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if touching_mouse:
					dragging_with_mouse = true
			else:
				dragging_with_mouse = false
				current_recipe_index = -round(recipe_progress / RECIPE_SEPARATION)
				jump_to_recipe_index(current_recipe_index)

func start_new_glide():
	glide_amt = 0.0

func scroll_recipe_progress_internal_glide(amt):
	var change = amt - glide_amt
	glide_amt = amt
	scroll_recipe_progress(change)

func scroll_recipe_progress(pixels, glide: bool = false):
	if glide:
		if glide_tween:
			glide_tween.kill()
		glide_tween = create_tween()
		start_new_glide()
		glide_tween.tween_method(scroll_recipe_progress_internal_glide, 0, pixels, abs(pixels / GLIDE_SPEED)).set_trans(Tween.TRANS_SINE)
		glide_tween.tween_callback(glide_tween.kill)
	else:
		var new_pos = clamp(recipe_progress + pixels, -RECIPE_SEPARATION * (len(recipe_icons) - 1), 0)
		var change = new_pos - recipe_progress
		recipe_progress = new_pos
		for i in range(len(recipe_icons)):
			var node = recipe_icons[i]
			node.position.x += change
			var pos_along: float = recipe_progress + (i * RECIPE_SEPARATION)
			#print("pos_along:", pos_along)
			if (pos_along < SCALE_EFFECT_RADIUS) and (pos_along > -SCALE_EFFECT_RADIUS):
				var x_val = 1 - abs(pos_along / SCALE_EFFECT_RADIUS)
				#print("x_val:", x_val)
				node.scale = Vector2.ONE * scale_curve.sample(x_val)
			else:
				node.scale = Vector2.ONE
		left_gear.rotation_degrees += change
		right_gear.rotation_degrees += change

func jump_to_recipe_index(index):
	var change =  -(index * RECIPE_SEPARATION) - recipe_progress
	current_recipe_index = index
	scroll_recipe_progress(change, true)

func left_button_pressed():
	if current_recipe_index > 0:
		jump_to_recipe_index(current_recipe_index - 1)
		
func right_button_pressed():
	if current_recipe_index < (len(recipe_icons) - 1):
		jump_to_recipe_index(current_recipe_index + 1)
