extends Node2D

export(NodePath) var player_path
onready var player = get_node(player_path)
export var player_1 = true

onready var root = get_node("../../../")

onready var cursor_node = get_node("cursor")

var is_start = false

var reset = false

var cursor = 0
var options = [0,0,0,0,0]
const max_option = [1,1,1,1,2]
var buttons = {}

onready var title_node = get_node("Title")
onready var title_timer = get_node("Timer")
onready var titles = root.dialogue["titles"]

onready var description_node = get_node("Description")
onready var description_timer = get_node("Timer2")
onready var description = root.dialogue["descriptions"]

onready var damage_node = get_node("damage")
onready var damage_text_node = get_node("damagetext")
onready var damage = root.weapon_data["damage"]

onready var firerate_node = get_node("firerate")
onready var firerate_text_node = get_node("fireratetext")
onready var firerate = root.weapon_data["firerate"]

onready var dps_node = get_node("dps")
onready var dps_text_node = get_node("dpstext")
onready var dps = root.weapon_data["dps"]

onready var texts = [get_node("firerate bar text"), get_node("dps bar text"), get_node("damage bar text")]

func _ready():
	if player_1:
		buttons["up"] = "up1"
		buttons["down"] = "down1"
		buttons["left"] = "left1"
		buttons["right"] = "right1"
		buttons["shoot"] = "shoot1"
		buttons["guard"] = "guard1"
		buttons["reload"] = "reload1"
	else:
		buttons["up"] = "up2"
		buttons["down"] = "down2"
		buttons["left"] = "left2"	 
		buttons["right"] = "right2"
		buttons["shoot"] = "shoot2"
		buttons["guard"] = "guard2"
		buttons["reload"] = "reload2"
func _process(delta):
	
	var player_1_ready = get_node("../../").player_1_ready
	var player_2_ready = get_node("../../").player_2_ready
	var start = get_node("../../").start
	if Input.is_action_just_pressed(buttons["left"]) and not start and not Input.is_action_pressed(buttons["right"]) and not((player_1_ready and player_1) or (player_2_ready and not player_1)):
		cursor -= 1
		title_node.set_visible_characters(0)
		description_node.set_visible_characters(0)
		title_timer.start()
		description_timer.start()
	if Input.is_action_just_pressed(buttons["right"]) and not start and not Input.is_action_pressed(buttons["left"]) and not((player_1_ready and player_1) or (player_2_ready and not player_1)):
		cursor += 1
		title_node.set_visible_characters(0)
		description_node.set_visible_characters(0)
		title_timer.start()
		description_timer.start()
	cursor = (cursor+5)%5
	
	cursor_node.position.x = (cursor-2)*32
	
	if Input.is_action_just_pressed(buttons["up"]) and not start and not Input.is_action_pressed(buttons["down"]) and not((player_1_ready and player_1) or (player_2_ready and not player_1)):
		title_node.set_visible_characters(0)
		description_node.set_visible_characters(0)
		title_timer.start()
		description_timer.start()
		options[cursor] += 1
		options[cursor] = (max_option[cursor]+1+options[cursor]) % (max_option[cursor]+1)
		
		if options[cursor] == 1:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play("0>1up")
		elif options[cursor] == 0 and cursor != 4:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play("1>0up")
		elif options[cursor] == 2 and cursor == 4:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play("1>2up")
		elif options[cursor] == 0 and cursor == 4:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play("2>0up")
	if Input.is_action_just_pressed(buttons["down"]) and not start and not Input.is_action_pressed(buttons["up"]) and not((player_1_ready and player_1) or (player_2_ready and not player_1)):
		title_node.set_visible_characters(0)
		description_node.set_visible_characters(0)
		title_timer.start()
		description_timer.start()
		
		options[cursor] -= 1
		options[cursor] = (max_option[cursor]+1+options[cursor]) % (max_option[cursor]+1)
		
		if options[cursor] == 1 and cursor != 4:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play_backwards("1>0up")
		elif options[cursor] == 0:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play_backwards("0>1up")
		elif options[cursor] == 2 and cursor == 4:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play_backwards("2>0up")
		elif options[cursor] == 1 and cursor == 4:
			get_node("Item"+str(cursor)+"/AnimationPlayer").play_backwards("1>2up")

	title_node.set_bbcode(titles[str(cursor)+str(options[cursor])])
	damage_text_node.set_bbcode("[right]"+str(damage[str(cursor)+str(options[cursor])])+"[/right]")
	firerate_text_node.set_bbcode("[right]"+str(firerate[str(cursor)+str(options[cursor])])+"[/right]")
	dps_text_node.set_bbcode("[right]"+str(dps[str(cursor)+str(options[cursor])])+"[/right]")
	description_node.set_bbcode(description[str(cursor)+str(options[cursor])])
	
	if cursor != 4:
		damage_text_node.show()
		firerate_text_node.show()
		dps_text_node.show()
		for i in texts:
			i.show()
		description_node.rect_position.y = 96
	else:
		damage_text_node.hide()
		firerate_text_node.hide()
		dps_text_node.hide()
		for i in texts:
			i.hide()
		description_node.rect_position.y = 61

	damage_node.value = damage[str(cursor)+str(options[cursor])]
	firerate_node.value = firerate[str(cursor)+str(options[cursor])]
	dps_node.value = dps[str(cursor)+str(options[cursor])]

func _on_Node2D_reset():
	if not is_start and not reset:
		root.emit_signal("reset_2")
		is_start = true
		player.burst = options[0] == 1
		if player.burst:
			player.ar_fire_rate = 13.0/15.0
		else:
			player.ar_fire_rate = 4/15.0
		player.minigun = options[1] == 1
		player.rpg = options[3] == 1
		if options[3] == 1:
			player.explosive_fire_rate = 65.0/60.0
		player.heal_type = options[4]
		if options[1] == 1:
			player.MAG_LIMIT[1] = 300
			player.mag[1] = 300
		else:
			player.MAG_LIMIT[1] = 75
			player.mag[1] = 75
			
	if reset:
		reset = false
func _on_Timer_timeout():
	title_node.set_visible_characters(title_node.get_visible_characters()+1)

func _on_Timer2_timeout():
	description_node.set_visible_characters(description_node.get_visible_characters()+3)
