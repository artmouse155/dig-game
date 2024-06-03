extends Node
class_name SaveLoad

# when you boot up the game, the default global settings are given by the following file
const DEFAULT_GLOBAL_SAVE_DATA: GlobalData = preload ("res://Resources/Global Save Data/default_global_save_data.tres")

# when you create new player data, the default player settings are given by the following file
const DEFAULT_PLAYER_SAVE_DATA: PlayerData = preload ("res://Resources/Player Data/default_player_data.tres")

# the base directory for user save data. See https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
const USER_DIR = "user://"

# the name of the folder where player save data is stored.
const PLAYER_SAVE_DATA_DIR_NAME = "save_data"

# the full directory where player save data is stored.
const FULL_PLAYER_SAVE_DATA_DIR = USER_DIR + "/" + PLAYER_SAVE_DATA_DIR_NAME

# the name of the resource 
const GLOBAL_SAVE_DATA_NAME = "global_data"

# the prefix for player save data files. followed by a numeric identifier
const SAVE_PREFIX = "save_"

# the suffix for player save data files. ".tres" is text based and good for debugging, but in final game state we will use ".res".
const SAVE_SUFFIX = ".tres"

# setting an arbitrary limit so that the player doesn't crash their computer with new saves. 100 is just a random placeholder. Might pick a power of 2?
const MAX_NUM_SAVES = 100

const DEFAULT_PLAYER_SAVE_NAME = ""


# save filenames start with save_0, and go on numerically. if save_0 and save_2 exist, the next save created will be save_1.tres.

# creates a save_(?).tres file which represents player data. saves it in the user://save_data folder.
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

# saves player data to a save file that already exists.
func save_player_data(data: PlayerData, save_name: String):
	check_for_player_save_data()
	var dir = DirAccess.open(FULL_PLAYER_SAVE_DATA_DIR)
	if dir.file_exists(save_name):
		ResourceSaver.save(data, FULL_PLAYER_SAVE_DATA_DIR + "/" + save_name)
	else:
		print("Couldn't save to " + save_name)
		return null

# get a list of filenames of all saves in the user://save_data folder. includes the suffix.
func get_list_of_names_of_saves() -> PackedStringArray:
	check_for_player_save_data()
	print(FULL_PLAYER_SAVE_DATA_DIR)
	var dir = DirAccess.open(FULL_PLAYER_SAVE_DATA_DIR)
	return dir.get_files()

# returns a PlayerData resource by loading the given save name. Used when booting up the game for example.
func get_save_data_by_name(save_name: String) -> PlayerData:
	check_for_player_save_data()
	var dir = DirAccess.open(FULL_PLAYER_SAVE_DATA_DIR)
	if dir.file_exists(save_name):
		return ResourceLoader.load(FULL_PLAYER_SAVE_DATA_DIR + "/" + save_name)
	else:
		print("Couldn't find " + save_name)
		return null

# makes sure the filestructure we want exists
func check_for_player_save_data() -> bool:
	var dir = DirAccess.open(USER_DIR)
	if !dir.dir_exists(PLAYER_SAVE_DATA_DIR_NAME):
		dir = null
		init_player_save_data()
	return true

# called the very first time that this game is loaded. Creates a new folder called save_data in user://.
func init_player_save_data():
	var dir = DirAccess.open(USER_DIR)
	dir.make_dir(PLAYER_SAVE_DATA_DIR_NAME)

# makes sure that global save data exists in user://. This should look for global_data.tres. If not found, creates a default one.
func check_for_global_save_data():
	#print(ResourceSaver.get_recognized_extensions(ResourceData))
	var dir = DirAccess.open(USER_DIR)
	if !dir.file_exists(GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX):
		dir = null
		init_global_save_data()
	return true

# creates default global save data
func init_global_save_data():
	print("created new global save data.")
	ResourceSaver.save(DEFAULT_GLOBAL_SAVE_DATA, USER_DIR + "/" + GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX)

# overrides the current global save data with a new change
func save_global_data(data: GlobalData):
	check_for_global_save_data()
	ResourceSaver.save(data, USER_DIR + "/" + GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX)

# access saved global save data. used when the exe is first launched.
func get_global_save_data() -> GlobalData:
	check_for_global_save_data()
	return ResourceLoader.load(USER_DIR + "/" + GLOBAL_SAVE_DATA_NAME + SAVE_SUFFIX)
