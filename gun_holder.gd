# gun_holder.gd

extends Node2D

var current_gun

var enemy_trigger_speed_base = 10
var enemy_trigger_cooldown = enemy_trigger_speed_base

func _ready() -> void:
	current_gun = get_child(0)


func player_shoot():
	if Input.is_action_pressed("shoot"):
		current_gun.trigger_pressed("player")
	elif Input.is_action_just_released("shoot"):
		current_gun.trigger_released()

func enemy_shoot():
	if current_gun.is_automatic == true:
		current_gun.trigger_pressed("enemy")
	else:
		if enemy_trigger_cooldown <= 0:
			current_gun.trigger_pressed("enemy")
			current_gun.trigger_released()
		else:
			enemy_trigger_cooldown -= 1
