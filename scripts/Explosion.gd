extends Particles2D

var time = 0

func _process(delta):
	time += delta
	if time > 10:
		queue_free()

func _on_reset():
	queue_free()