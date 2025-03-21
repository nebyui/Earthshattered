# attack.gd

extends Node

var shoot_timer_base = 120
var shoot_timer = shoot_timer_base

func behavior_process(entity, distance_to_player):
	#print("ATTACK ACTIVE")
	if distance_to_player > 3250:
		entity.velocity.x = entity.direction * entity.shooting_speed
	elif distance_to_player < 2750: 
		entity.velocity.x = -entity.direction * entity.shooting_speed
	else:
		entity.velocity.x = 0
		entity.direction = 0
	if shoot_timer <= 0:
		shoot_timer = shoot_timer_base
	else:
		shoot_timer -= 1
		if shoot_timer <= 60:
			entity.shooting()
	
	#print(entity.shooting_speed)
	
