extends Node2D

signal reset
signal reset_2

var language = "en"

var t = 0

var best_of = 5

onready var bullet = preload("res://bullet.tscn")
onready var wall = preload("res://wall.tscn")
onready var grenade = preload("res://grenade.tscn")
onready var damage = preload("res://damage.tscn")
onready var the_boom = preload("res://Explosion.tscn")
onready var rpg = preload("res://rpg.tscn")
onready var boat = preload("res://boat.tscn")
onready var flash = preload("res://flash.tscn")

var paused = true
var winner = 0
var wins = [0,0]
var boomed = 0
onready var player_1 = get_node("Player1/Player")
onready var player_2 = get_node("Player2/Player")

var boat_int = 5

var dialogue = parse_dialogue("res://"+language+"-weapon.json")
var weapon_data = parse_dialogue("res://weapon-data.json")

func parse_dialogue(script_path):
	var json_file = File.new()
	json_file.open(script_path, json_file.READ)
	var json_text = json_file.get_as_text()
	json_file.close()
	return parse_json(json_text)
	

func reset():
	if wins[0] >= (best_of+1)/2 or wins[1] >= (best_of+1)/2:
		wins = [0,0]
		get_node("Menu").start = false
		get_node("Menu").hide = false
		get_node("Menu").player_1_ready = false
		get_node("Menu").player_2_ready = false
		get_node("Menu/Items").show()
		get_node("Menu/Items/player 1").is_start = false
		get_node("Menu/Items/player 2").is_start = false
		get_node("Menu/Items/player 1").reset = true
		get_node("Menu/Items/player 2").reset = true
	else:
		get_node("start").start()
		get_node("toasty").play("ready")
	paused = true
	get_node("Player2/UI/WIN").hide()
	get_node("Player1/UI/WIN").hide()
	emit_signal("reset")
	build(-220, 0, true, player_1, true)
	winner = 0
	t = 0
	boat_int = rand_range(5,10)

func shoot(pos, spread, damage, speed, player, player_1, type, sound = true):
	var shot = bullet.instance()
	add_child(shot)
	connect("reset", shot, "_on_reset")
	if type == "SMG":
		shot.get_node("AudioStreamPlayer2D").stop()
		shot.get_node("AudioStreamPlayer").play()
		shot.smg = true
		shot.scale *= 1/1.5
	if type == "boat":
		shot.is_from_boat = true
	if type == "sound":
		shot.clear = true
	if not sound:
		shot.get_node("AudioStreamPlayer2D").stop()
		shot.get_node("AudioStreamPlayer").stop()
	shot.position = pos
	shot.dir = spread
	shot.damage = damage
	shot.speed = speed
	shot.player = player
	shot.enemy = get_node("/root/Node2D/Player2/Player")
	shot.rotate(spread)
	if player_1==1:
		shot.enemy = get_node("/root/Node2D/Player2/Player")
		shot.rotate(PI/2)
		shot.lr = 1
		shot.get_node("Sprite").light_mask = 2
	elif player_1==0:
		shot.rotate(-PI/2)
		shot.lr = -1
		shot.enemy = get_node("/root/Node2D/Player1/Player")
		shot.get_node("Sprite").light_mask = 8

func flash(parent, player):
	var shoot = flash.instance()
	parent.add_child(shoot)
	if player:
		shoot.position.y -= 18
		shoot.position.x -= 4


func build(x,y,player_1,player_node,reset = false):
	var building = wall.instance()
	add_child(building)
	connect("reset", building, "_on_reset")
	if y < -107.5:
		building.position.y = -107.5
	elif y > 107.5:
		building.position.y = 107.5
	else:
		building.position.y = y
	if player_1:
		building.position.x = x+32
	else:
		#(building.get_node("CollisionShape2D")).position.x = -8
		building.position.x = x-32
		building.scale.x = -building.scale.x
		building.player_1 = false
		building.get_node("Light2D").range_item_cull_mask = 8
		building.get_node("Light2D2").range_item_cull_mask = 2
	#building.player = player_node
	building.player_node = player_node
	building.show()
	if reset:
		var building_2 = wall.instance()
		add_child(building_2)
		connect("reset", building_2, "_on_reset")
		#(building_2.get_node("CollisionShape2D")).position.x = -8
		building_2.get_node("Light2D").range_item_cull_mask = 8
		building_2.get_node("Light2D2").range_item_cull_mask = 2
		building_2.position.x = 220-32
		building_2.scale.x = -building_2.scale.x
		building_2.player_node = player_2
		building_2.player_1 = false
		building_2.health = 250
		building_2.health_building = 250
		building_2.built = true
		building.health = 250
		building.health_building = 250
		building.built = true

func grenade(x, y, player,playernode):
	var throw = grenade.instance()
	add_child(throw)
	connect("reset", throw, "_on_reset")
	if player == 0:
		throw.lr = -1
	throw.x = x
	throw.position.x = x
	throw.position.y = y

func rpg(x, y, player, playernode):
	var boom = rpg.instance()
	add_child(boom)
	connect("reset", boom, "_on_reset")
	if player == 0:
		boom.lr = -1
		boom.rotate(PI)
	if player:
		boom.x = x+30
		boom.position.x = x+30
	else:
		boom.x = x-30
		boom.position.x = x-30
	boom.position.y = y
	boom.player = playernode

func damage(x,y,value,crit):
	var counter = damage.instance()
	add_child(counter)
	connect("reset", counter, "_on_reset")
	counter.position.y = y-24
	counter.position.x = x#-32
	counter.y = y-24
	counter.x = x#-32
	counter.get_node("Inside").text = str(value)
	counter.get_node("Outline").text = str(value)
	if crit == 1:
		counter.get_node("Inside").modulate = Color(0.92,0.83,0.2,1)
	if crit == 2:
		counter.get_node("Inside").modulate = Color(0.35,0.67,0.93,1)

func spawn_boat(pos=Vector2(0,0), attack_bypass=false, player=get_node("."),player_1=2):
	var immigrant = boat.instance()
	add_child(immigrant)
	connect("reset", immigrant, "_on_reset")
	if not attack_bypass:
		immigrant.position.x = rand_range(-170,170)
		immigrant.dir = rand_range(-1,1)
	else:
		immigrant.position = pos
		immigrant.player_spawned = true
		immigrant.player = player
		if player_1 == 1:
			immigrant.position.x += 48
			immigrant.dir = PI/2
		else:
			immigrant.position.x -= 48
			immigrant.dir = -PI/2
	if randi()%4 == 1 or attack_bypass:
		if attack_bypass:
			immigrant.health -= 25
			immigrant.speed *= 1.25
		immigrant.boom = true
		immigrant.health *= 2
		immigrant.speed *= 0.5
		immigrant.get_node("cannon").show()
		immigrant.get_node("AnimatedSprite").play("boom")

func _ready():
	paused = true

func _process(delta):
	if get_node("Player1/Player").health <= 0 and winner==0:
		get_node("toasty").play("toasty")
		winner = 1
		get_node("Player1/Player").hide()
		get_node("Player2/UI/WIN").show()
		var explosion = the_boom.instance()
		add_child(explosion)
		connect("reset", explosion, "_on_reset")
		explosion.position = get_node("Player1/Player").position
		explosion.emitting = true
		explosion.speed_scale = 3
		explosion.get_node("AudioStreamPlayer2D").stop()
		get_node("Player1/Player").position.x = -300
		wins[1] += 1
		if get_node("Player2/Player").health > 0:
			get_node("Player2/UI").win()
	if get_node("Player2/Player").health <= 0 and (winner == 0 or (get_node("Player1/Player").health <= 0 and winner == 1)):
		get_node("toasty").play("toasty")
		if winner == 1:
			winner = 3
		else:
			winner = 2
		get_node("Player2/Player").hide()
		get_node("Player1/UI/WIN").show()
		var explosion = the_boom.instance()
		add_child(explosion)
		connect("reset", explosion, "_on_reset")
		explosion.position = get_node("Player2/Player").position
		explosion.emitting = true
		explosion.speed_scale = 3
		explosion.get_node("AudioStreamPlayer2D").stop()
		get_node("Player2/Player").position.x = 300
		if get_node("Player1/Player").health > 0:
			get_node("Player1/UI").win()
		if winner == 2:
			wins[0] += 1
		elif winner == 3:
			wins[1] -= 1
			winner = 4
			get_node("restart").wait_time = 2.5
			get_node("restart").start()
			print("oh")

	if not paused:
		t += delta
		if t >= boat_int:
			spawn_boat(Vector2(0,0),false,get_node("."),3)
			t = 0
			boat_int = rand_range(5,10)


func _on_restart_timeout():
	get_node("restart").wait_time = 1
	reset()

func _on_start_timeout():
	paused = false
	for i in[player_1,player_2]:
		i.health = 300
	
