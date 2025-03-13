# approach.gd

extends Node

func behavior_process(entity, distance_to_player: int):
	#print("APPROACH ACTIVE")
	
	entity.velocity.x = entity.direction * entity.running_speed
