extends PanelContainer

@export var tex : TextureRect
@export var title_text : RichTextLabel
@export var sub_title_text : RichTextLabel
@export var desc_text : RichTextLabel

func recipe_found_setup(obj : DrillerComponentObject):
	tex.texture = obj.recipe_image
	sub_title_text.text = obj.component_object_name
	title_text.text = "New Recipe Found"
	desc_text.text = ""
	
func achievement_setup(achievement : Achievement):
	tex.texture = achievement.icon
	sub_title_text.text = achievement.achievement_name
	title_text.text = "New Achievement Unlocked"
	desc_text.text = achievement.achievement_desc
