# idle.gd

extends Node

func behavior_process(entity, distance_to_player):
	#print("IDLE ACTIVE")
	
	entity.direction = 0
	
	entity.velocity.x = move_toward(entity.velocity.x, 0, entity.running_speed)
