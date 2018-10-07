extends Node2D

var stop = false
var sway = 0
var height = 0
var x = 0
var y = 0

func stop():
	stop = true

func die():
	queue_free()

func _ready():
	get_node("AnimationPlayer").play("spawn")
	sway = rand_range(-0.1,0.1)

func _process(delta):
	if not stop:
		y -= 200*delta*cos(sway)
		position.y = y
		x -= 800*delta*sin(sway)
		position.x = x

func _on_reset():
	queue_free()