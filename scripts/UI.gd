extends Area2D

onready var player = get_node("../Player")
onready var root = get_node("../../")
onready var stamp = preload("res://stamp.tscn")
onready var stamper = preload("res://stamper.tscn")

export var player_id = 0 # 0 is p1, 1 is p2

var ui_default_pos = [-213, -182, -151, -120, -89]
var ui_pos =		 [-213, -182, -151, -120, -89]
onready var items = [get_node("Item0"),get_node("Item1"),get_node("Item2"),get_node("Item3"),get_node("Item4")]

var stamp_start = 0

onready var passport = get_node("../passport")

export var initial_x = -445
var spread_distance = 0
var spread_angle = 0
var rot = 0

func win():
	stamp_start = 1

func stamp():
	var new_stamper = stamper.instance()
	passport.add_child(new_stamper)
	spread_distance = rand_range(0,10)
	spread_angle = rand_range(0,TAU)
	rot = rand_range(-0.3,0.3)
	new_stamper.position.x = -(880-((root.best_of+1)/2 - root.wins[player_id])*256+spread_distance*cos(spread_angle))*(player_id*2-1)
	new_stamper.position.y = spread_distance*sin(spread_angle)
	new_stamper.rotation = rot

func create_stamp():
	var new_stamp = stamp.instance()
	passport.add_child(new_stamp)
	root.connect("reset_2", new_stamp, "_on_reset_2")
	new_stamp.position.x = -(880-((root.best_of+1)/2 - root.wins[player_id])*256+spread_distance*cos(spread_angle))*(player_id*2-1)
	new_stamp.position.y = spread_distance*sin(spread_angle)
	new_stamp.rotation = rot
	stamp_start = 3
	
func hide_passport():
	stamp_start = 4

func _ready():
	if not player.player_1:
		ui_default_pos = [-191, -160, -129, -98, -67]
		ui_pos =         [-191, -160, -129, -98, -67]

func _process(delta):
	for i in range(0,5):
		if player.weapons == i:
			items[i].position.x = ui_pos[i]
			if ui_pos[i] < ui_default_pos[i]:
				ui_pos[i] += 2.75
			if ui_pos[i] > ui_default_pos[i]:
				ui_pos[i] -= 2.75
			items[i].z_index = 4
			if items[i].scale.y < 1.6:
				items[i].scale.y += 0.2
				if player.player_1:
					items[i].scale.x += 0.2
				else:
					items[i].scale.x += -0.2
		if not player.weapons == i:
			get_node("Item"+str(i)+"/reload").value = 0
			items[i].z_index = 3
			if items[i].scale.y > 01:
				items[i].scale.y -= 0.2
				if player.player_1:
					items[i].scale.x -= 0.2
				else:
					items[i].scale.x -= -0.2
		if player.weapons > i:
			if ui_pos[i] > ui_default_pos[i]-8.25:
				ui_pos[i] -= 2.75
		elif player.weapons < i:
			if ui_pos[i] < ui_default_pos[i]+8.25:
				ui_pos[i] += 2.75
		get_node("Item"+str(i)).position.x = ui_pos[i]
	
	if stamp_start == 1 and abs(passport.position.x) > abs(initial_x-2*(player_id*2-1)-(((root.best_of+1)/2)*52)*(player_id*2-1)):
		passport.position.x -= delta*500*(player_id*2-1)
	if stamp_start == 1 and abs(passport.position.x) <= abs(initial_x-2*(player_id*2-1)-(((root.best_of+1)/2)*52)*(player_id*2-1)):
		stamp_start = 2
		stamp()
		passport.position.x = abs(initial_x-2*(player_id*2-1)-(((root.best_of+1)/2)*52)*(player_id*2-1))*(player_id*2-1)
	if stamp_start == 4 and abs(passport.position.x) < abs(initial_x):
		passport.position.x += delta*500*(player_id*2-1)
	if stamp_start == 4 and abs(passport.position.x) >= abs(initial_x):
		passport.position.x = initial_x
		stamp_start = 0
		root.get_node("restart").start()