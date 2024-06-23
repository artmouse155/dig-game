extends Node
# Toggle with action "toggle_debug"
@export var debug : bool = false:
	get: return debug
	set (value): debug = value

#var enabled : bool = !debug
var fullbright : bool = debug
var best_driller : bool = debug
var override_player_durability_and_energy : bool = debug
var infinite_boosts : bool = debug
var quickstart : bool = debug
var reset_saved_component_data = debug

func toggle():
	debug = !debug
	print("Debug is ", ( "on" if debug else "off"), "." )
