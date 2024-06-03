extends Node2D

@onready var particle_maker = $particles

func setup(text):
	$SubViewport/Label.text = text
