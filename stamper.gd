extends Node2D

func create_stamp():
	get_parent().get_parent().get_node("UI").create_stamp()

func die():
	get_parent().get_parent().get_node("UI").hide_passport()
	queue_free()

func _ready():
	get_node("AnimationPlayer").play("stamp")