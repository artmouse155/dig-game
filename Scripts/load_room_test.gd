extends Node2D

@export var structure_data: StructureData

@onready var bg_tiles: TileMapLayer
@onready var fg_tiles: TileMapLayer

func _ready():
	bg_tiles = TileMapLayer.new()
	bg_tiles.tile_set = structure_data.tile_set
	bg_tiles.set_pattern(structure_data.bg_origin, structure_data.bg_tiles)
	add_child(bg_tiles)
	fg_tiles = TileMapLayer.new()
	fg_tiles.tile_set = structure_data.tile_set
	fg_tiles.set_pattern(structure_data.fg_origin, structure_data.fg_tiles)
	add_child(fg_tiles)
