extends TextureRect

var shader_material

func _ready():
	if self.material is ShaderMaterial:
		# Cast the material to ShaderMaterial
		shader_material = self.material as ShaderMaterial
		was_resized()
	else:
		print("Sprite does not have a shader material applied.")
	
func set_grid_offset(off: Vector2):
	if shader_material:
		shader_material.set_shader_parameter("tile_offset", off)

func set_light(radius: float, edge_size: float):
	if shader_material:
		shader_material.set_shader_parameter("light_radius", radius)
		shader_material.set_shader_parameter("light_edge_size", edge_size)

func set_shader_size(s: Vector2):
	if shader_material:
		shader_material.set_shader_parameter("pixel_resolution", s)
	
func set_light_pixel_center(c: Vector2):
	if shader_material:
		shader_material.set_shader_parameter("light_rect_pixel_center", c)

func was_resized():
	#set_grid_offset((size / -2) / Game.TILE_WIDTH)
	set_shader_size(size)
