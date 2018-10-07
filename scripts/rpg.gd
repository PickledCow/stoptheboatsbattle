extends Area2D

var explosion = preload("res://Explosion.tscn")

var initial = 100
var lr = 1
var speed = 5
const MAX_SPEED = 1600
var x = 0
var col = false
var start = false
var damage = 160
var clear = false
var walled = false
var wall = false
var reset = false
var player
var playered = false
var boomed = false

func boom(backwall, x=0, y=0):
	var explode = explosion.instance()
	get_node("/root/Node2D").add_child(explode)
	get_node("/root/Node2D").connect("reset", explode, "_on_reset")
	get_node("whhoh").stop()
	get_node("tonk").stop()
	if backwall == 1:
		position.x = 240*lr
	else:
		pass
	explode.position = Vector2(position.x,position.y)
	explode.position = position
	explode.emitting = true
	explode.speed_scale = 3
	
	#clear = true

func _ready():
	get_node("Timer").start()
	x = position.x

func _on_reset():
	reset = true
	queue_free()

func _process(delta):
	if false and start: # AIM ASSIST DO NTO ENABLE
		var player
		if lr == 1:
			player = get_node("/root/Node2D/Player2/Player")
		else:
			player = get_node("/root/Node2D/Player1/Player")
	
		if position.y > player.position.y:
			position.y -= delta*400
		if position.y < player.position.y:
			position.y += delta*00
	if not start:
		x += initial*lr*delta
		position.x = x
		if abs(initial) >= 3:
			initial -= 3*lr
		else:
			initial = 0
	else:
		if speed < MAX_SPEED:
			speed += 90
		if speed >= MAX_SPEED:
			speed = MAX_SPEED
		x += lr*speed*delta
		position.x = x
	
	var over = get_node("Collision").get_overlapping_bodies()
	var boom = [0, 0, 0]
	if not col:
		for i in over:
			if not reset and not col and (i.is_in_group("player") or i.is_in_group("wall") or i.is_in_group("boat")):
				col = true
				if i.is_in_group("wall") and not i.is_in_group("boat"):
					wall = true
				elif not wall and i.is_in_group("player"):
					boom[0] = 1
					boom[1] = i.position.x
					boom[2] = i.position.y
					playered = true
				elif not playered and i.is_in_group("wall") and i.is_in_group("boat"):
					boom[0] = 1
			elif col:
				break
	if col and not boomed:
		boom(boom[0],boom[1],boom[2])
		boomed = true
	
	if col:
		over = get_overlapping_bodies()
		
		for i in over:
			var crit = 0
			var damage_done = 0
			if not reset and (i.is_in_group("boat") or i.is_in_group("wall") or (get_node("/root/Node2D").winner == 0 and i.is_in_group("player"))) and col:
				if i.is_in_group("boat") and not i.is_in_group("wall"):
					i.player = player
				
				i.health -= damage
				damage_done += damage
				if i.is_in_group("player"):
					if i.shield > 0:
						crit = 2
					i.health += damage
					i.shield -= damage
					if i.shield < 0:
						i.health += i.shield
						i.shield = 0
				if not (i.is_in_group("wall") and walled):
					get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
				if i.is_in_group("wall"):
					i.health -= damage
					damage_done += damage
					walled = true
				queue_free()
	
func _on_Timer_timeout():
	get_node("Particles2D").emitting = true
	get_node("whhoh").play()
	speed = initial
	start = true