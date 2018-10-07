extends Light2D

var t = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if t > 0:
		queue_free()
	t += 1