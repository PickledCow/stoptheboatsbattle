extends KinematicBody2D

var t = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	t += 1
	if t < 60:
		position.x += delta*500
