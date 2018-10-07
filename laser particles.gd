extends Particles2D

var slow_down = false

func _process(delta):
	if slow_down and emitting:
		speed_scale -= delta*0.5
		get_node("Particles2D").speed_scale -= delta*0.5
	if speed_scale < 0:
		emitting = false
		get_node("Particles2D").emitting = false
		get_node("Timer").start()

func _on_laser():
	slow_down = true

func _stop():
	emitting = false
	get_node("Particles2D").emitting = false

func _on_Timer_timeout():
	queue_free()
