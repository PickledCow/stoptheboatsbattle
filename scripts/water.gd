extends Sprite

var t = 0

func _process(delta):
	t += delta
	if t >= PI*6:
		t = 0
	position = Vector2((sin(t/3) * 20), (cos(t/3) * 36))
