 extends Node2D

export var explosion = preload("res://Explosion.tscn")

var damage = 155
var landed = false
var clear = false
var col = false
var explosion_done = false
var x = -220
var lr = 1
var first_half = true
var damage_done = 0
var walled = false
var stop = false
var reset = false

func second_half():
	first_half = false

func stop():
	stop = true
	get_node("AudioStreamPlayer2D").play()

func boom():
	col = true
	var explode = explosion.instance()
	get_node("/root/Node2D").add_child(explode)
	get_node("/root/Node2D").connect("reset", explode, "_on_reset")
	explode.position = position
	explode.emitting = true
	explode.speed_scale = 3

func _ready():
	get_node("AnimationPlayer").play("throw")
	x = position.x

func _on_reset():
	reset = true
	queue_free()

func _process(delta):
	if false: # AIM ASSIST DO NTO ENABLE
		var player
		if lr == 1:
			player = get_node("/root/Node2D/Player2/Player")
		else:
			player = get_node("/root/Node2D/Player1/Player")
	
		if position.y > player.position.y:
			position.y -= delta*1000
		if position.y < player.position.y:
			position.y += delta*1000
	var over = get_node("Area2D2").get_overlapping_bodies()
	for i in over:
		if not reset and (not get_node("/root/Node2D").winner) and (i.is_in_group("player") and not first_half):
			boom()
			get_node("AudioStreamPlayer").stop()
			col = true
			get_node("AudioStreamPlayer2D").stop()
			queue_free()
	over = get_node("Area2D").get_overlapping_bodies()
	for i in over:
		damage_done = 0
		var crit = 0
		if not reset and not get_node("/root/Node2D").winner and(i.is_in_group("player") or i.is_in_group("boat") or i.is_in_group("wall")) and col:
			i.health -= damage
			damage_done += damage
			if i.is_in_group("wall"):
				i.health -= damage
				damage_done += damage
				#crit = 1
			if i.is_in_group("player"):
				if i.shield > 0:
					crit = 2
				i.health += damage
				i.shield -= damage
				if i.shield < 0:
					i.health += i.shield
					i.shield = 0
			position = Vector2(0,0)
			if not (i.is_in_group("wall") and walled):
				get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
			if i.is_in_group("wall"):
				walled = true
			clear = true
	if col:
		clear = true
	if not stop:
		x += lr*delta*480
		position.x = x
	
	if clear:
		queue_free()