extends KinematicBody2D

signal slow_laser
signal stop_laser

var fire_rate = 1.25
var dir = 1
var health = 150
var speed = 100
var player
var boom = false
var touched_wall = false
var damage = 100
var crit = 0
onready var death_laser = get_node("Area2D")
var lasered = false
var player_spawned = false
var laser_shrunk = false
onready var laser_particle = preload("res://laser particles.tscn")
var lr = 1

var mats = 0
var mag = [0,0,0,0,0]

onready var player1 = get_node("/root/Node2D/Player1/Player")
onready var player2 = get_node("/root/Node2D/Player2/Player")

onready var enemy = get_node("/root/Node2D/Player1/Player")

var t = 0
var spread = 0

func _process(delta):
	if boom:
		t += delta
		
		var player1_distance = pow(pow(position.x-player1.position.x,2)+pow(position.y-player1.position.y,2),0.5)
		var player2_distance = pow(pow(position.x-player2.position.x,2)+pow(position.y-player2.position.y,2),0.5)
		
		if not player_spawned:
			if player1_distance > player2_distance:
				enemy = player2
			else:
				enemy = player1
		else:
			if player == player1:
				enemy = player2
			else:
				enemy = player1
				lr = -1
		
		if player_spawned:
			spread = (get_angle_to(enemy.position))-lr*PI/2
		else:
			spread = (get_angle_to(enemy.position))-dir
		
		if t >= fire_rate:
			if (player_spawned or position.y > -100) and health > 0:
				t -= fire_rate
				get_node("/root/Node2D").shoot(position, spread,20,500,player,3,"boat")
				get_node("/root/Node2D").flash(self, false)
			else:
				t = 0
	if not player_spawned:
		if (dir/abs(dir))*position.x > 175:
			dir = -dir
	elif (player == player1 and position.x > 170) or (player == player2 and position.x < -170):
		speed = 0
	
	rotation = -dir
	show()
	if health > 0:
		position += Vector2(delta*speed*sin(dir),delta*speed*cos(dir))
		if player_spawned:
			get_node("cannon").rotation = get_angle_to(enemy.position)+dir*lr
		else:
			get_node("cannon").rotation = get_angle_to(enemy.position)+PI/2
	death_laser.rotation = -rotation
	
	if health <= 0:
		if player_spawned:
			queue_free()
		elif boom:
			if get_node("wait").is_stopped() and not lasered:
				get_node("wait").start()
				lasered = true
				death_laser.show()
		elif not player_spawned and player != null:
			player.mats += 10+randi()%10
			if boom:
				player.mats += 10
				var drop = randi()%5
				player.mag[2] += 1
				if drop > 2:
					player.mag[3] += 1
				if drop < 3:
					player.mag[4] += 1
			else:
				var drop = randi()%6
				if drop % 2 == 0:
					player.mag[2] += 1
				if drop == 2 or drop == 4:
					player.mag[3] += 1
				if drop == 1 or drop == 5:
					player.mag[4] += 1
			queue_free()
	if laser_shrunk:
		get_node("Area2D/Light2D").scale.y -= delta*1.5
	if get_node("Area2D/Light2D").scale.y <= 0:
		get_node("Area2D/Light2D").hide()
		emit_signal("stop_laser")
	if get_node("Area2D/Light2D").scale.y <= 0.3:
		emit_signal("slow_laser")

	if position.y > 170:
		queue_free()
func _on_reset():
	queue_free()

func _on_Timer_timeout():
	if not player_spawned:
		player.mats += 20+randi()%10
		if boom:
			player.mag[2] += 1
			player.mats += 20+randi()%10
			player.mag[3] += 1
			player.mag[4] += 1
		else:
			var drop = randi()%6
			if drop % 2 == 0:
				player.mag[2] += 1
			if drop == 2 or drop == 4:
				player.mag[3] += 1
			if drop == 1 or drop == 5:
				player.mag[4] += 1
	queue_free()

func spawn_laser():
	var bwaaa = laser_particle.instance()
	get_node("/root/Node2D").add_child(bwaaa)
	bwaaa.position = position
	bwaaa.position.x += 18
	connect("slow_laser", bwaaa, "_on_laser")
	connect("stop_laser", bwaaa, "_stop")

func _on_wait_timeout():
	if get_node("Timer").is_stopped():
		get_node("Timer").start()
	get_node("Area2D/Light2D").scale.y = 1
	spawn_laser()
	get_node("laser shrink").start()
	var over = death_laser.get_overlapping_bodies()
	for i in over:
		var damage_done = 0
		if i.is_in_group("wall"):
			i.health -= damage*2
			damage_done += damage*2
			if not touched_wall:
				get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
	for i in over:
		var damage_done = 0
		if get_node("/root/Node2D").winner == 0 and i.is_in_group("player"):
			if i.shield > 0:
				crit = 2
			damage_done += damage
			i.shield -= damage
			if i.shield < 0:
				i.health += i.shield
				i.shield = 0
			get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
			#already_damaged.append(i)
		if i != self and i.is_in_group("boat") and not i.is_in_group("wall"):
			i.health -= damage * 3
			damage_done += damage * 3
			get_node("/root/Node2D").damage(i.position.x,i.position.y,damage_done,crit)
			#already_damaged.append(i)
			i.boom = false
			i.queue_free()


func _on_laser_shrink_timeout():
	laser_shrunk = true
