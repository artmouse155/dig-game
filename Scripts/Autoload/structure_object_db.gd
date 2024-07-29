extends Node

var data = {
	"crate" : {
		"breakable" : true,
		"lootable" : true,
		"loot_table" : {},
		"sprite" : preload("res://Resources/Structures/Objects/Lootable/crate.tscn")
	},
	"pot" : {
		"breakable" : true,
		"lootable" : true,
		"loot_table" : {},
		"sprite" : preload("res://Resources/Structures/Objects/Lootable/pot.tscn")
	},
	"vase" : {
		"breakable" : true,
		"lootable" : true,
		"loot_table" : {},
		"sprite" : preload("res://Resources/Structures/Objects/Lootable/vase.tscn")
	},
	"torch" : {
		"breakable" : false,
		"lootable" : false,
		"loot_table" : {},
		"sprite" : preload("res://Resources/Structures/Objects/Lights/torch.tscn")
	},
}

func get_sprite_scene(obj_name: String):
	if obj_name in data.keys():
		return data[obj_name]["sprite"]
	else:
		print("ERROR: Object ", obj_name, " NOT FOUND IN OBJECT DB")
		return null
