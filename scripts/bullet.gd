extends Area2D

export var dir = 0
export var damage = 100
export var speed = 5
onready var root = get_tree().get_root().get_children()[0]
var lr = 1
var sound = true
var clear = false
var smg = false
var touched_wall = false
var player
var enemy
var is_from_boat = false
var sway = 0
var shined = false
var offed = false

func _ready():
	if sound:
		get_node("AudioStreamPlayer2D").play()

func _process(delta):
	if not is_from_boat:
		if position.y > enemy.position.y + 5 and sway > -1.5:
			sway += -0.1
		elif position.y < enemy.position.y - 5 and sway < 1.5:
			sway += 0.1
		else:
			if sway > 0:
				sway -= 0.1
			elif sway < 0:
				sway += 0.1
	
	rotation = PI*lr/2+lr*dir+sway*0.025
	show()
	
	if not clear:
		position += Vector2(speed*delta*cos(dir+sway*0.025) *lr,delta*sin(dir+sway*0.025)*speed)
	
	var over = get_overlapping_bodies()
	var crit = 0
	
	for i in over:
		var damage_done = 0
		
		if i.is_in_group("wall") and not i.is_in_group("boat"):
			clear = true
			i.health -= damage
			damage_done += damage
			if smg:
				i.health -= damage
				damage_done += damage
			if not touched_wall:
				touched_wall = true
				get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)

	for i in over:
		var damage_done = 0
		if get_node("/root/Node2D").winner == 0 and i.is_in_group("player") and i != player and not touched_wall:
			clear = true
			if i.shield > 0:
				crit = 2
			damage_done += damage
			i.shield -= damage
			if not offed:
				get_node("AudioStreamPlayer2D2").play()
				offed = true
			if randi()%8 == 0 and false:
				crit = 1
				damage_done += damage
				i.shield -= damage
			if i.shield < 0:
				i.health += i.shield
				i.shield = 0
			get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
		if i.is_in_group("boat") and not i.is_in_group("wall") and not (is_from_boat and i == player):
			if (is_from_boat and i.player != player) or not is_from_boat:
				if not offed:
					get_node("AudioStreamPlayer2D2").play()
					offed = true
				clear = true
				i.health -= damage
				damage_done += damage
				get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
				if not i.player_spawned:
					i.player = player
	if abs(position.x) > 300:
		clear = true
	if clear:
		position = Vector2(500,0)
	if clear and not (get_node("AudioStreamPlayer2D").playing or get_node("AudioStreamPlayer").playing) and not (get_node("AudioStreamPlayer2D2").playing):
		queue_free()
func _on_reset():
	queue_free()