extends Node2D

func _ready():
	var structure_data = StructureData.new()
	#TODO: also use bg tiles size
	#var structure_size: Vector2i = $Tiles/Front.get_used_rect().size
	structure_data.bg_origin = $Tiles/Back.get_used_rect().position
	structure_data.fg_origin = $Tiles/Front.get_used_rect().position
	
	var bg_pattern = $Tiles/Back.get_pattern($Tiles/Back.get_used_cells())
	structure_data.bg_tiles = bg_pattern
	var fg_pattern = $Tiles/Front.get_pattern($Tiles/Front.get_used_cells())
	structure_data.fg_tiles = fg_pattern
	structure_data.tile_set = $Tiles/Front.tile_set
	
	for child in ($Items.get_children() + $Lights.get_children()):
		if child is StructureObjectNode:
			var temp_structure_object = StructureObject.new(child.position, child.structure_object_name)
			structure_data.room_objects.append(temp_structure_object)
	
	ResourceSaver.save(structure_data, "res://test_room.tres")
