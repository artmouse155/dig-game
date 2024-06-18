extends PanelContainer

@export var icons_center: Control
@export var left_button: Button
@export var right_button: Button

@export var left_gear: Sprite2D
@export var right_gear: Sprite2D

@export var scale_curve: Curve

@export var sort_method_node: OptionButton
@export var show_prev_crafted_Node: CheckBox

@export var ingredient_list_node: VBoxContainer
@export var recipe_name_node: Label
@export var desc_node: Label
@export var craft_button: Button

@export var all_recipes_crafted_node: Label

const RECIPE_SCENE = preload("res://Scenes/Crafting/recipe.tscn")
const RESOURCE_DISPLAY = preload("res://Scenes/resource_data_display.tscn")

const SCROLL_STRENGTH = 50
const DRAG_STRENGTH = 1
const RECIPE_SIZE = Vector2(150,150)
const RECIPE_SEPARATION = 200

const SCALE_EFFECT_RADIUS = 300

const GLIDE_SPEED: float = 1000.0

enum SORT_METHODS {NONE, DATE_FOUND, AGE}

var current_recipe_index: int:
	get:
		return current_recipe_index
	set(value):
		#print("current recipe index is ", value)
		current_recipe_index = value
var recipe_progress: float = 0 #in pixels

#the objects that can be crafted
var recipe_driller_component_objects: Array[DrillerComponentObject] = []

var recipe_icons: Array[Node] = []

#dragging
var touching_mouse = false
var dragging_with_mouse = false

var glide_tween: Tween
var glide_amt = 0.0

func _ready():
	update_all()
	mouse_entered.connect(set_touching_mouse.bind(true))
	mouse_exited.connect(set_touching_mouse.bind(false))
	left_button.pressed.connect(left_button_pressed)
	right_button.pressed.connect(right_button_pressed)

func set_touching_mouse(b):
	touching_mouse = b

func set_current_recipe_index(value):
	if value != current_recipe_index:
		current_recipe_index = value
		display_recipe_info()

func init_with_recipes(recipe_list: Array[DrillerComponentObject]):
	recipe_driller_component_objects = recipe_list
	for i in icons_center.get_children():
		i.queue_free()
	recipe_icons = []
	for i in range(len(recipe_list)):
		var temp_recipe_icon = RECIPE_SCENE.instantiate()
		temp_recipe_icon.clicked.connect(jump_to_recipe_index.bind(i))
		#var random_color = Color(randf(), randf(), randf(), 1) # Generating random color
		#temp_recipe_icon.color = random_color
		
		#temp_recipe_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		#temp_recipe_icon.size = RECIPE_SIZE
		#temp_recipe_icon.pivot_offset = temp_recipe_icon.size * 0.5
		#temp_recipe_icon.position = temp_recipe_icon.size * -0.5
		temp_recipe_icon.set_texture(recipe_list[i].recipe_image)
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
	update_all_glow_and_fade()

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
				set_current_recipe_index(-round(recipe_progress / RECIPE_SEPARATION))
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

func jump_to_recipe_index(index, glide: bool = true):
	var change =  -(index * RECIPE_SEPARATION) - recipe_progress
	set_current_recipe_index(index)
	scroll_recipe_progress(change, glide)

func left_button_pressed():
	if current_recipe_index > 0:
		jump_to_recipe_index(current_recipe_index - 1)
		
func right_button_pressed():
	if current_recipe_index < (len(recipe_icons) - 1):
		jump_to_recipe_index(current_recipe_index + 1)

func display_recipe_info():
	for i in ingredient_list_node.get_children():
			i.queue_free()
	
	if len(recipe_driller_component_objects) > 0:
		var obj: DrillerComponentObject = recipe_driller_component_objects[current_recipe_index]
		
		recipe_name_node.text = obj.component_object_name
		desc_node.text = "\"" + obj.desc + "\""
		all_recipes_crafted_node.visible = false
		left_button.disabled = false
		right_button.disabled = false
		
		#only can craft if NOT crafted before AND sufficient materials
		var sufficient_materials = ResourceData.compare_all(obj.crafting_recipe, Game.player_data.player_inventory)
		var crafted_before = Game.player_data.get_component_unlock_status(obj)
		craft_button.disabled = (crafted_before) or (not sufficient_materials)
			
		for i in obj.crafting_recipe:
			var temp_resource_display = RESOURCE_DISPLAY.instantiate()
			ingredient_list_node.add_child(temp_resource_display)
			temp_resource_display.cost_setup(i)
	else:
		recipe_name_node.text = ""
		desc_node.text = ""
		all_recipes_crafted_node.visible = true
		left_button.disabled = true
		right_button.disabled = true

#TODO: Call this every time a recipe is crafted.
func update_all_glow_and_fade():
	for i in range(len(recipe_driller_component_objects)):
		recipe_icons[i].set_faded(Game.player_data.get_component_unlock_status(recipe_driller_component_objects[i]))
		recipe_icons[i].show_glow(ResourceData.compare_all(recipe_driller_component_objects[i].crafting_recipe, Game.player_data.player_inventory))

#NOTE: We say a recipe is crafted if it has been unlocked. TODO: Change this behavior.
func get_game_objects_list(sort: SORT_METHODS = SORT_METHODS.NONE, show_previously_crafted = true) -> Array[DrillerComponentObject]:
	var game_objects: Array[DrillerComponentObject] = Game.get_all_game_objects()
	var temp: Array[DrillerComponentObject] = []
	if show_previously_crafted:
		temp = game_objects
	else:
		for i in range(len(game_objects)):
			if not Game.player_data.get_component_unlock_status(game_objects[i]):
				temp.append(game_objects[i])
	
	var temp_2: Array[DrillerComponentObject] = []
	
	for i in range(len(temp)):
		if Game.player_data.get_component_recipe_found_status(game_objects[i]):
			temp_2.append(temp[i])
	
	temp = temp_2
	match sort:
		SORT_METHODS.NONE:
			temp = Sort.multi_merge_sort(temp, [])
	
	return temp

#called when sorting changes, something is crafted, or anything critical changes.
func update_all():
	var sort_method: SORT_METHODS = SORT_METHODS.NONE
	match sort_method_node.get_item_text(sort_method_node.selected):
		"Date Found":
			sort_method = SORT_METHODS.DATE_FOUND
		"Age":
			sort_method = SORT_METHODS.AGE
	var show_prev_crafted: bool = show_prev_crafted_Node.button_pressed
	jump_to_recipe_index(0, false)
	init_with_recipes(get_game_objects_list(sort_method, show_prev_crafted))
	display_recipe_info()
	

func sort_item_selected(_index: int):
	update_all()
	
func checkbox_toggled(_toggle: bool):
	update_all()

func go_to_shop():
	Game.go_to_shop()

func craft_current_recipe():
	Game.player_data.unlock_component(recipe_driller_component_objects[current_recipe_index])
	
	var recipe_list = recipe_driller_component_objects[current_recipe_index].crafting_recipe
	for i in range(len(recipe_list)):
		Game.player_data.add_resource_amount(recipe_list[i].res_name, -1 * recipe_list[i].amount)
	
	Game.save_player_data_to_file()
	update_all()
