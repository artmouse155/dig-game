extends Sprite2D
#poe = point of interest in PIXELS (not tile coords)
var poe_list: Array = [Vector2(500, 300)]
var dot_list: Array[Sprite2D] = []

var circle_radius = 100

func update_radar_circles():
	for i in range(len(poe_list)):
		if (len(dot_list) - 1) < i:
			var temp_circle = Sprite2D.new()
			temp_circle.texture = preload("res://Assets/Textures/Driller/Radar/radar_dot.png")
			add_child(temp_circle)
			dot_list.append(temp_circle)
		#var angle = global_position.angle_to(poe_list[i])
		dot_list[i].position = circle_radius * (poe_list[i] - global_position).normalized()
