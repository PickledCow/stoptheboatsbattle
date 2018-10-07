extends Node2D

onready var root = get_node("../../")

onready var y = position.y
export var player_1 = 1
var lr = player_1*2-1
onready var ui = get_node("../UI")
var buttons = {}
var ar_fire_rate = 0.27
var boat_fire_rate = 2.0/3.0
var smg_fire_rate = 0.025
var explosive_fire_rate = 1
var burst = false
var minigun = false
var rpg = false
var heal_type = 0 #0:health, 1:shield, 2:fusion
var healing = false
onready var burst_timer = get_node("../burst")
var burst_fire = 0
var weapons = 0
var health = 300
var mats = 60
var MAX_MATS = 150
var shield_down = 0
var shield = 0#150
var is_switching = false
var ar_timer = 0
var smg_sound = false
var ar_first_shot = false
var smg_stack = 0
var smg_play_sound = true
var smg_sound_end = false
onready var smg_sound_node = get_node("../UI/Item1/shoot")
var boat_timer = 0
var boat_first_shot = false
var smg_timer = 0
var minigun_windup = 0
var explosive_timer = 0
var can_explosive = true
const minigun_windup_max = 1.5
onready var minigun_charge_se = get_node("../UI/Item1/charge")
onready var minigun_uncharge_se = get_node("../UI/Item1/uncharge")
var ammo =		[100, 200, 0, 0, 0]
var mag =		[ 30,  75, 1, 3, 3]
var MAG_LIMIT = [ 30,  75, 3, 3, 9]
var reloading = false
var reloading_weapon = -1
onready var reload_timer = get_node("../reload1")
export var wall_count = 0
onready var wall_ord = [get_node("/root/Node2D/wall1")]
var health_down = false
var health_count = false
var minigun_reload = 0
var minigun_overheat = false


var is_shining = false

onready var healthbar = get_node("../UI/TextureProgress")
onready var healthbar_under = get_node("../UI/TextureProgress2")
onready var shieldbar = get_node("../UI/shield")
onready var shieldbar_under = get_node("../UI/shield back")

var time = 0

func reload(timer, weapon):
	timer.start()
	reload_timer = timer
	reloading_weapon = weapon
	reloading = true



func _ready():
	if player_1:
		buttons["up"] = "up1"
		buttons["down"] = "down1"
		buttons["left"] = "left1"
		buttons["right"] = "right1"
		buttons["shoot"] = "shoot1"
		buttons["guard"] = "guard1"
		buttons["reload"] = "reload1"
		rotate(PI/2)
	else:
		buttons["up"] = "up2"
		buttons["down"] = "down2"
		buttons["left"] = "left2"	 
		buttons["right"] = "right2"
		buttons["shoot"] = "shoot2"
		buttons["guard"] = "guard2"
		buttons["reload"] = "reload2"
		rotate(-PI/2)
		wall_ord[0] = get_node("/root/Node2D/wall2")
	ar_timer = ar_fire_rate
	boat_timer = boat_fire_rate
	
func _process(delta):
	time += delta
	if time >= TAU:
		time -= TAU
	ar_timer += delta
	boat_timer += delta
	smg_timer += delta
	minigun_reload += 1
	explosive_timer += delta
	
	if ar_timer >= ar_fire_rate:
		ar_timer -= ar_fire_rate
		ar_first_shot = false
	if boat_timer >= boat_fire_rate:
		boat_timer -= boat_fire_rate
		boat_first_shot = false
	while smg_timer >= smg_fire_rate:
		smg_timer -= smg_fire_rate
		if weapons == 1 and Input.is_action_pressed(buttons["shoot"]) and not (minigun and minigun_windup < minigun_windup_max) and not reloading and not is_switching:
			smg_stack += 1
		else:
			smg_stack = 1
		if smg_stack > mag[1]:
			smg_stack = mag[1]
	
	if explosive_timer >= explosive_fire_rate:
		can_explosive = true
		explosive_timer = 0
	
	
	if minigun and minigun_reload >= 6 and (minigun_overheat or (not(weapons == 1 and Input.is_action_pressed(buttons["shoot"])))) and mag[1] < MAG_LIMIT[1]:
		mag[1] += 1
		minigun_reload = 0
	
	if health > 300:
		health = 300
	if shield > 150:
		shield = 150
	if health < 0:
		health = 0
	if shield < 0:
		shield = 0
	
	healthbar.set_value(health)
	shieldbar.set_value(shield)
	get_node("../UI/health text").text = str(health)+"/300"
	get_node("../UI/shield text").text = str(shield)+"/150"
	
	for i in range(0,5):
			if mag[i] > MAG_LIMIT[i]:
				mag[i] = MAG_LIMIT[i]
			get_node("../UI/Item" + str(i) + "/Ammo").text = str(mag[i])
	if not root.paused and health > 0: 
		var y_movement = 0
		if Input.is_action_pressed(buttons["up"]):
			y_movement += -1
		if Input.is_action_pressed(buttons["down"]):
			y_movement += 1
		
		if Input.is_action_pressed(buttons["shoot"]) and weapons == 1 or boat_first_shot or ar_first_shot:
			y_movement *= 0.7
		if Input.is_action_pressed(buttons["shoot"]) and weapons == 1 and minigun and not (minigun and minigun_windup < minigun_windup_max):
			y_movement *= 0.7
			y_movement += rand_range(-0.1,0.1)
		
		y += 132 * delta * y_movement
		if y < -120:
			y = -120
		if y > 120:
			y = 120
		position.y = y
		
		var weapon_switched = false
		if Input.is_action_just_pressed(buttons["left"]):
			weapon_switched = true
			weapons -= 1
			smg_sound = false
		if Input.is_action_just_pressed(buttons["right"]):
			weapon_switched = true
			weapons += 1
			smg_sound = false
		
		if weapon_switched:
			get_node("../switch").stop()
			get_node("../switch").start()
			if has_node("../UI/reload"+str(weapons)):
				get_node("../UI/reload"+str(weapons)).set_value(0)
			weapons = (weapons + 5) % 5
			if ar_timer >= ar_fire_rate:
				ar_timer = 0
			if boat_timer >= boat_fire_rate:
				boat_timer = 0
			if smg_timer >= 2:
				smg_timer = 0
			minigun_windup = 0
			minigun_charge_se.stop()
			minigun_uncharge_se.stop()
			
			if mag[weapons] == 0 and weapons in [0,1]:
				reload(get_node("../reload"+str(weapons)), weapons)
				get_node("../UI/Item"+str(weapons)+"/reload audio").play()
				smg_sound = false
		
		if get_node("../switch").is_stopped():
			if has_node("../UI/Item" +str(weapons) + "/reload"):
				get_node("../UI/Item" +str(weapons) + "/reload").set_value(0)
			if Input.is_action_pressed(buttons["shoot"]) and is_switching:
				if weapons == 0 and not ar_first_shot:
					ar_timer = 0
				if weapons == 1:
					boat_timer = 0
			is_switching = false
		else:
			is_switching = true
			if has_node("../UI/Item" +str(weapons) + "/reload"):
				get_node("../UI/Item" +str(weapons) + "/reload").set_value(get_node("../switch").time_left / get_node("../switch").wait_time)	

		if get_node("../heal").is_stopped() and healing:
			healing = false
			if heal_type == 1:
				shield += 50
			elif heal_type == 0:
				health += 50
			else:
				shield += 20
				health += 20
			mag[4] -= 1
		
		if Input.is_action_just_pressed(buttons["shoot"]) and burst_fire == 0:
			if not is_switching:
				if weapons == 1 and mag[1] > 0:
					smg_timer = 0
					smg_stack = 1
					smg_play_sound = false
				
				if can_explosive and weapons == 3 and mag[3] > 0:
					if not rpg:
						root.grenade(position.x, position.y, player_1, self)
					else:
						root.rpg(position.x, position.y, player_1, self)
					mag[3] -= 1
					can_explosive = false
					explosive_timer = 0
			if weapons == 4 and mag[4] > 0:
				if ((heal_type == 1 or heal_type == 2) and shield < 150) or ((heal_type == 0 or heal_type == 2) and health < 300):
					if get_node("../heal").is_stopped():
						get_node("../heal").start()
						healing = true
					
		
		if weapons == 4:
			get_node("../UI/Item4/reload").value = get_node("../heal").time_left
		else:
			get_node("../UI/Item4/reload").value == 0
			get_node("../heal").stop()
			healing = false

		if minigun_overheat or (weapons == 1 and not Input.is_action_pressed(buttons["shoot"]) and minigun_windup > 0):
			smg_sound = false
			if not minigun_uncharge_se.playing:
				if minigun_windup < 0.75:
					minigun_uncharge_se.play((0.75-minigun_windup)*2)
				else:
					minigun_uncharge_se.play()
			minigun_charge_se.stop()
			if minigun_windup > 0.75:
				minigun_windup = 0.75
			minigun_windup -= delta*0.5
			if minigun_windup < 0:
				minigun_windup = 0
				minigun_uncharge_se.stop()
		
		if Input.is_action_pressed(buttons["shoot"]) and not reloading_weapon == weapons and burst_fire == 0 and not is_switching:
			if weapons == 0 and mag[0] > 0 and not ar_first_shot:
				ar_first_shot = true
				ar_timer = 0

				if burst:
					root.shoot(Vector2(position.x+(player_1*2-1)*16, position.y), 0, 50, 1200, self, player_1 ,"rifle")
					burst_fire = 2
					#print(burst_fire)
					burst_timer.start()
				else:
					root.shoot(Vector2(position.x+(player_1*2-1)*16, position.y), 0, 50, 1200, self, player_1 ,"rifle")
					root.flash(self,true)
				mag[0] -= 1
	
			if weapons == 1 and mag[1] > 0:
				var shoot = false
				if minigun and not minigun_overheat:
					minigun_uncharge_se.stop()
					if minigun_windup < minigun_windup_max:
						minigun_windup += delta
						if not minigun_charge_se.playing:
							minigun_charge_se.play(minigun_windup)
					if minigun_windup >= minigun_windup_max:
						minigun_charge_se.stop()
						shoot = true
				else: shoot = not minigun
				if shoot:
					var spread = 0.2
					if minigun:
						spread = 0.25
					var ud = 1
					var smg_damage = 6
					if Input.is_action_pressed(buttons["up"]) or Input.is_action_pressed(buttons["down"]):
						spread *= 1.1
					smg_play_sound = not smg_play_sound
					smg_sound = true
					smg_sound_end = false
					while smg_stack > 0:
						if randi()%2 == 0:
							ud *= -1
						root.flash(self,true)
						root.shoot(Vector2(position.x+(player_1*2-1)*6, position.y+(6.5*((randi()%2*2)-1))), ud*(pow(rand_range(0,spread),1.5)), smg_damage, 1200, self, player_1, "SMG", smg_play_sound)
						mag[1] -= 1
						smg_stack -= 1
				
			if weapons == 2 and not boat_first_shot and mag[2] > 0:
				boat_first_shot = true
				boat_timer = 0
				root.spawn_boat(position,true,self,player_1)
				mag[2] -= 1
			
				
		if burst_fire > 0:
			if burst_timer.is_stopped() and (mag[0] > 0):
				var spread = 0.02
				if burst_fire == 1:
					spread *= 1.1
				if Input.is_action_pressed(buttons["up"]) or Input.is_action_pressed(buttons["down"]):
					spread *= 1.3
				else:
					spread = 0.02
				root.shoot(Vector2(position.x+(player_1*2-1)*16, position.y), rand_range(-spread,spread), 45, 1200, self, player_1 ,"rifle")
				root.flash(self,true)
				burst_fire -= 1
				burst_timer.start()
				mag[0] -= 1
			elif mag[0] <= 0:
				burst_fire = 0
	
		if mag[weapons] <= 0 and not reloading and (weapons in [0,1]) and not(weapons == 1 and minigun):
			get_node("../switch").stop()
			reload(get_node("../reload" +str(weapons)),weapons)
			get_node("../UI/Item" +str(weapons) + "/reload audio").play()
			reloading_weapon = weapons
			
		if (weapons == 1 and minigun) and mag[1] == 0:
			get_node("../overheat").start()
			minigun_overheat = true
	
		if Input.is_action_just_pressed(buttons["reload"]) and not is_switching and not(weapons == 1 and minigun):
			if (not reloading) and (mag[weapons] != MAG_LIMIT[weapons]) and (weapons in [0,1]):
				reload(get_node("../reload" +str(weapons)), weapons)
				get_node("../UI/Item" +str(weapons) + "/reload audio").play()
				reloading_weapon = weapons
		
		if reloading:
			get_node("../UI/Item" +str(weapons) + "/reload").set_value(reload_timer.time_left / reload_timer.wait_time)
			var reloaded = false
			smg_sound = false
			if reload_timer.is_stopped():
				mag[reloading_weapon] = MAG_LIMIT[reloading_weapon]
				get_node("../UI/Item" +str(weapons) + "/reload").set_value(0)
				reload_timer.stop()
				if has_node("../UI/Item" +str(weapons) + "/reload audio"):
					get_node("../UI/Item" +str(weapons) + "/reload audio").stop()
				reloading = false
				reloading_weapon = -1
				reloaded = true
				if Input.is_action_pressed(buttons["shoot"]):
					ar_timer = 0
					boat_timer = 0
			if reloading_weapon != weapons and not reloaded and reload_timer.time_left > 0.2:
				get_node("../UI/Item" +str(weapons) + "/reload").set_value(0)
				reload_timer.stop()
				get_node("../UI/Item" +str(reloading_weapon) + "/reload audio").stop()
				reloading = false
				reloading_weapon = -1
				is_switching = false
		
		if Input.is_action_just_released(buttons["shoot"]) or health <= 0:
			smg_sound = false
		
		if not smg_sound_node.playing and smg_sound:
			smg_sound_node.play()
		if smg_sound_node.playing and smg_sound and smg_sound_node.get_playback_position() > 0.764:
			smg_sound_node.play(0.005)
		if not smg_sound_end and smg_sound_node.playing and not smg_sound:
			smg_sound_end = true
			smg_sound_node.play(0.764+(fmod((smg_sound_node.get_playback_position()-0.005),smg_fire_rate)))

		if not smg_sound_node.playing:
			smg_sound_end = false
		
		var heal = false
		for i in get_node("Area2D").get_overlapping_areas():
			if i.is_in_group("wall"):
				heal = true
		if Input.is_action_just_pressed(buttons["guard"]):
			if wall_count < 3 and get_node("../build").is_stopped() and not heal and mats >= 10:
				wall_count += 1
				mats -= 10
				root.build(position.x, position.y, player_1, self)
				get_node("../build").start()

	get_node("../UI/build/RichTextLabel").text = str(mats)
	
	if shieldbar_under.value > shieldbar.value:
		if not shield_down == 1:
			get_node("../UI/healthtimer").start()
			shield_down = 1
		if get_node("../UI/healthtimer").is_stopped():
			shieldbar_under.value -= 75*delta
			if shieldbar_under.value <= shieldbar.value:
				shieldbar_under.value = shieldbar.value
				shield_down = 2
	elif shieldbar_under.value <= shieldbar.value:
		shieldbar_under.value = shieldbar.value
		#shield_down = 2
	
	if shield_down != 1 and healthbar_under.value > healthbar.value:
		if not health_down:
			get_node("../UI/healthtimer").start()
			health_down = true
		if get_node("../UI/healthtimer").is_stopped() or shield_down == 2:
			healthbar_under.value -= 150*delta
			if healthbar_under.value <= healthbar.value:
				healthbar_under.value = healthbar.value
				shield_down = 0
				health_down = false

	if mats > MAX_MATS:
		mats = MAX_MATS

	if ui.overlaps_body(self):
		if ui.modulate.a > 0.5:
			ui.modulate.a -= 0.1
	else: 
		if ui.modulate.a < 1:
			ui.modulate.a += 0.1


func _on_Node2D_reset():
	show()
	health = 300
	shield = 0
	wall_count = 1
	reloading = false
	reloading_weapon = -1
	ar_timer = 0
	smg_play_sound = 0
	smg_stack = 0
	boat_timer = 0
	smg_timer = 0
	minigun_charge_se.stop()
	minigun_uncharge_se.stop()
	get_node("../overheat").stop()
	minigun_overheat = false
	smg_sound_end = false
	smg_sound_node.stop()
	smg_sound = false
	ar_first_shot = false
	boat_first_shot = false
	burst_fire = 0
	get_node("../UI/TextureProgress").value = 300
	get_node("../UI/TextureProgress2").value = 300
	get_node("../UI/shield back").value = 0
	get_node("../UI/shield").value = 0
	for i in range(5):
		get_node("../UI/Item" +str(i) + "/reload").set_value(0)
		get_node("../UI/Item"+str(i)+"/Ammo").text = str(mag[i])
	for i in [0,1]:
		get_node("../UI/Item" +str(i) + "/reload audio").stop()
	weapons = 0
	position.y = 0
	y = 0
	position.x = -220
	mag = [30, 75, 2, 1,3]
	mats = 60
	if minigun:
		mag[1] = 300
	if not player_1:
		position.x = 220
	get_node("../heal").stop()
	healing = false
	

func _on_overheat_timeout():
	minigun_overheat = false
