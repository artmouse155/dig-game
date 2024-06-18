extends Node
class_name SaveLoad

const DEFAULT_GLOBAL_SAVE_DATA: GlobalData = preload ("res://Resources/Global Save Data/default_global_save_data.tres")
const DEFAULT_PLAYER_SAVE_DATA: PlayerData = preload ("res://Resources/Player Data/default_player_data.tres")

const USER_DIR = "user://"
const PLAYER_SAVE_DATA_DIR_NAME = "save_data"
const FULL_PLAYER_SAVE_DATA_DIR = USER_DIR	 + PLAYER_SAVE_DATA_DIR_NAME

const GLOBAL_SAVE_DATA_NAME = "global_data"

const SAVE_PREFIX = "save_"
const SAVE_SUFFIX = ".tres"

const MAX_NUM_SAVES = 100

const DEFAULT_PLAYER_SAVE_NAME = ""
#save filenames start with save_0, and go on numerically. if save_0 and save_2 exist, the next save created will be save_1.tres.

func save_new_player_data():
	check_for_player_save_data()
	var save_names = get_list_of_names_of_saves()
	var valid_name: bool = false
	var i = 0
	var save_name: String
	while !valid_name:
		var temp_filename = SAVE_PREFIX + str(i) + SAVE_SUFFIX
		if !(temp_filename in save_names):
			save_name = temp_filename
			valid_name = true
		i += 1
		if i == MAX_NUM_SAVES:
			print("YOU HAVE TOO MANY SAVES!!!!!!!!!!!")
			return ""
	ResourceSaver.save(DEFAULT_PLAYER_SAVE_DATA, FULL_PLAYER_SAVE_DATA_DIR + "/" + save_name)
	return save_name

func save_player_data(data: PlayerData, save_name: String):
	check_for_player_save_data()
	var dir = DirAccess.open(FULL_PLAYER_SAVE_DATA_DIR)
	if dir.file_exists(save_name):
		ResourceSaver.save(data, FULL_PLAYER_SAVE_DATA_DIR + "/" + save_name)
	else:
		print("Couldn't save to " + save_name)
		return null

func get_list_of_names_of_saves() -> PackedStringArray:
	check_for_player_save_data()
	print(FULL_PLAYER_SAVE_DATA_DIR)
	var dir = DirAccess.open(FULL_PLAYER_SAVE_DATA_DIR)
	return dir.get_files()

func get_save_data_by_name(save_name: String) -> PlayerData:
	check_for_player_save_data()
	var dir = DirAccess.open(FULL_PLAYER_SAVE_DATA_DIR)
	if dir.file_exists(save_name):
		return ResourceLoader.load(FULL_PLAYER_SAVE_DATA_DIR + "/" + save_name)
	else:
		print("Couldn't find " + save_name)
		return null

#makes sure the filestructure we want exists
func check_for_player_save_data() -> bool:
	var dir = DirAccess.open(USER_DIR)
	if !dir.dir_exists(PLAYER_SAVE_DATA_DIR_NAME):
		dir = null
		init_player_save_data()
	return true

#called the very first time that this game is loaded
func init_player_save_data():
	var dir = DirAccess.open(USER_DIR)
	dir.make_dir(PLAYER_SAVE_DATA_DIR_NAME)

func check_for_global_save_data():
	#print(ResourceSaver.get_recognized_extensions(ResourceData))
	var dir = DirAccess.open(USER_DIR)
	if !dir.file_exists(GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX):
		dir = null
		init_global_save_data()
	return true

func init_global_save_data():
	print("created new global save data.")
	ResourceSaver.save(DEFAULT_GLOBAL_SAVE_DATA, USER_DIR + "/" + GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX)

func save_global_data(data: GlobalData):
	check_for_global_save_data()
	ResourceSaver.save(data, USER_DIR + "/" + GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX)

func get_global_save_data() -> GlobalData:
	check_for_global_save_data()
	return ResourceLoader.load(USER_DIR + "/" + GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX)
