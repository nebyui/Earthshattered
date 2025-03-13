# behavior_tree.gd

extends Node

var entity
var current_behavior
var behavior_lock = false

signal pressed

@onready var approach = $Approach
@onready var attack = $Attack
@onready var back_up = $BackUp
@onready var idle = $Idle


func _ready() -> void:
	entity = get_parent()

func behavior_decision(distance_to_player):
	#print("--- BEHAVIOR START --- ")
	
	if entity.current_health <= 0:
		current_behavior = idle
	elif 2000 <= distance_to_player and distance_to_player <= 4000:
		#print("ATTACK TRUE")
		current_behavior = attack
	elif distance_to_player < 2000:
		#print("BACK UP TRUE")
		current_behavior = back_up
	elif distance_to_player < 6000:
		#print("APPROACH TRUE")
		current_behavior = approach
	else:
		#print("IDLE TRUE")
		current_behavior = idle
	
	#print(current_behavior)
	#print(distance_to_player)
	
	current_behavior.behavior_process(entity, distance_to_player)
		
