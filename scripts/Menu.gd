extends Node2D

signal start
var player_1_ready = false
var player_2_ready = false
var start = false
var hide = false

func _process(delta):
	if Input.is_action_just_pressed("shoot1"):
		player_1_ready = !player_1_ready
	if Input.is_action_just_pressed("shoot2"):
		player_2_ready = !player_2_ready

	if not hide and (player_1_ready and not start or (get_parent().paused and start)): get_node("Items/player 1 ready").show()
	else: get_node("Items/player 1 ready").hide()
	if not hide and (player_2_ready and not start or (get_parent().paused and start)): get_node("Items/player 2 ready").show()
	else: get_node("Items/player 2 ready").hide()

	if player_1_ready and player_2_ready and not start:
		get_node("Timer").start()
		start = true

func _on_Timer_timeout():
	get_parent().reset()
	hide = true
	get_node("../AudioStreamPlayer").play()
	get_node("Items").hide()
