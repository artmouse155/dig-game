extends Node

# Toggle with action "toggle_debug"
@export var debug : bool = false:
	get: return debug
	set (value):
		debug = value
		print("Debug is ", ( "on" if debug else "off"), "." )
		base_debug_updated.emit(value)
		debug_settings_updated.emit()

var DEFAULT_SETTINGS: Dictionary = {
	fullbright = false,
	see_ores = false,
	see_powerups = false,
	smooth_lighting = false,
	best_driller = false,
	override_player_durability_and_energy = false,
	infinite_boosts = false,
	quickstart = false,
	reset_saved_component_data = false,
}

var settings: Dictionary = DEFAULT_SETTINGS.duplicate():
	get: return settings if debug else DEFAULT_SETTINGS
	set (value): 
		debug_settings_updated.emit()
		settings = value

signal base_debug_updated(value : bool)
signal debug_settings_updated

func toggle():
	debug = !debug
