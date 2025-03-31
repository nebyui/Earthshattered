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
	
	if entity.current_health <= 0:
		current_behavior = idle
	elif 2000 <= distance_to_player and distance_to_player <= 4000:
		current_behavior = attack
	elif distance_to_player < 2000:
		current_behavior = back_up
	elif distance_to_player < 6000:
		current_behavior = approach
	else:
		current_behavior = idle
	
	
	current_behavior.behavior_process(entity, distance_to_player)
		
