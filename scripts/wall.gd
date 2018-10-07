extends KinematicBody2D

const MAXHEALTH = 250
export var health = 180
export var health_building = 180
export var built = false
var heal = true
var start = true

onready var crack = $AnimatedSprite
export var player = "/root/Node2D/Player1/Player"
export var player_1 = true
onready var player_node = get_node(player)

onready var sprite = [get_node("Sprite"), get_node("Sprite2"), get_node("Sprite3")]

func heal():
	print(get_node("Light2D").range_item_cull_mask)
	get_node("RichTextLabel2").show()
	health_building = health
	built = false
	heal = true

func _ready():
	z_index = 1

func _process(delta):
	if health_building < MAXHEALTH and not built:
		var hell = 1
		if heal:
			hell = 2
		health_building += 1*hell
		health += 1*hell
	if health_building >= MAXHEALTH:
		built = true
		heal = false
		start = false
		get_node("RichTextLabel").show()
	else:
		get_node("RichTextLabel").hide()
		get_node("RichTextLabel2").hide()
	#print(player_1)
	if health <= 0:
		queue_free()
		player_node.wall_count -= 1
	if not heal or start:
		if MAXHEALTH+(health-health_building) == MAXHEALTH:
			crack.play("perfect")
		elif MAXHEALTH+(health-health_building) >= MAXHEALTH*4/5:
			crack.play("barely damaged")
		elif MAXHEALTH+(health-health_building) >= MAXHEALTH*3/5:
			crack.play("slightly damaged")
		elif MAXHEALTH+(health-health_building) >= MAXHEALTH*2/5:
			crack.play("damaged")
		elif MAXHEALTH+(health-health_building) >= MAXHEALTH*1/5:
			crack.play("very damaged")
		elif health_building+(health-health_building) > 0:
			crack.play("ultra damaged")
		for i in range(3):
			var colr = pow(health_building/float(MAXHEALTH),0.5)
			sprite[i].modulate = Color(colr,colr,1,colr)
	else:
		if health == MAXHEALTH:
			crack.play("perfect")
		elif health >= MAXHEALTH*4/5:
			crack.play("barely damaged")
		elif health >= MAXHEALTH*3/5:
			crack.play("slightly damaged")
		elif health >= MAXHEALTH*2/5:
			crack.play("damaged")
		elif health >= MAXHEALTH*1/5:
			crack.play("very damaged")
		elif health > 0:
			crack.play("ultra damaged")
	if health < MAXHEALTH and not heal and player_node in get_node("Area2D").get_overlapping_bodies():
		if (not player_1 and Input.is_action_just_pressed("guard2")) or (player_1 and Input.is_action_just_pressed("guard1")):
			if not player_node.mats < ceil((1-float(health)/float(MAXHEALTH))*10):
				heal()
				player_node.mats -= ceil((1-float(health)/float(MAXHEALTH))*10)

func _on_reset():
	#player_node.wall_count -= 1
	queue_free()

func _on_Node2D_reset():
	#player_node.wall_count -= 1
	queue_free() # replace with function body
