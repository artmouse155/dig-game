extends PanelContainer

@export var tex : TextureRect
@export var title_text : RichTextLabel
@export var sub_title_text : RichTextLabel
@export var desc_text : RichTextLabel

func unlock_setup(obj : DrillerComponentObject):
	tex.texture = obj.component_object_tile_image
	sub_title_text.text = obj.component_object_name
	title_text.text = "New Driller Upgrade Unlocked"
	desc_text.text = ""
	
func achievement_setup(icon : Texture2D, a_name : String, a_desc : String):
	tex.texture = icon
	sub_title_text.text = a_name
	title_text.text = "New Achievement Unlocked"
	desc_text.text = a_desc
