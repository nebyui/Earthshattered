# back_up.gd

extends Node

func behavior_process(entity, distance_to_player):
	entity.direction *= -1
	
	entity.velocity.x = entity.direction * entity.running_speed
