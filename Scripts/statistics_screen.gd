extends Control

@export var allTimeLabel: RichTextLabel
@export var perDayLabel: RichTextLabel

func _ready():
	if Game.player_data:
		allTimeLabel.text = ""
		for key in Game.player_data.stats["all_time"]:
			var stat_value = str(Game.player_data.stats["all_time"][key])
			allTimeLabel.append_text(key.capitalize() + ": " + stat_value + "\n")
			
		perDayLabel.text = ""
		for key in Game.player_data.stats["per_day"]:
			var stat_value = str(Game.player_data.stats["per_day"][key])
			perDayLabel.append_text(key.capitalize() + ": " + stat_value + "\n")

func _return_to_shop():
	Game.go_to_shop()
