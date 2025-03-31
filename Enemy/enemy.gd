# enemy.gd

extends CharacterBody2D


var base_speed = 4500
var shooting_speed = base_speed / 2
var sprinting_speed = base_speed * 1.5
var jump_strength = -4500
var max_jumps: int = 2
var current_jumps: int = max_jumps
var ray
var is_shooting = false
var current_animation = "none"

var shoot_timer_base = 120
var shoot_timer = shoot_timer_base

var base_health = 100
var current_health = base_health
var direction = 0
var player_direction = 0

@onready var animation_player = $AnimationPlayer
@onready var player_group = get_tree().get_nodes_in_group("Player")
@onready var behavior_tree = $BehaviorTree
@onready var gun_holder = find_child("GunHolder")
@onready var skeleton = find_child("Skeleton2D")
var player



var player_position
var distance_to_player: float


func _ready() -> void:
	add_to_group("Enemies")
	floor_snap_length = 200
	if player_group.size() > 0:
		player = player_group[0]
	

func _physics_process(delta: float) -> void:
		
	
	
	if not is_on_floor():
		if current_jumps == max_jumps:
			current_jumps -= 1
		velocity += get_gravity() * delta
	if is_on_floor():
		current_jumps = max_jumps
	
	if $RightRay.is_colliding():
		ray = 1
	elif $LeftRay.is_colliding():
		ray = -1
	else:
		ray = 0

	if player and is_instance_valid(player):
		player_position = player.global_position
		distance_to_player = (player_position - global_position).length()
		if player_position.x > position.x:
			player_direction = 1
		elif player_position.x < position.x:
			player_direction = -1
		else:
			player_direction = 0
	
	if current_health <= 0:
		set_collision_layer_value(3, false)
		set_collision_mask_value(2, false)
		rotation_degrees = 90
		play_animation("stand")
		velocity.x = move_toward(velocity.x, 0, base_speed)
		#queue_free()
		#if distance_to_player > 8000:
			#queue_free()
	else:
		enemy_behavior()
	
	#if is_on_floor():
		#if direction:
			#velocity.x = direction * running_speed
		#else:
			#velocity.x = move_toward(velocity.x, 0, running_speed)
	#elif !is_on_floor():
		#if direction != 0:
			#velocity.x = move_toward(velocity.x, direction * running_speed, running_speed / 14)
		
	move_and_slide()
	
func _process(delta: float) -> void:
	pass
	
func shooting():
	if player_direction == 1:
		skeleton.transform.x.x = 1
	elif player_direction == -1:
		skeleton.transform.x.x = -1
	$Skeleton2D/Base/Body/ArmR.look_at(player.global_position)
	$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -90
	$Skeleton2D/Base/Body/Head.look_at(player.global_position)
	gun_holder.enemy_shoot()
	
func enemy_behavior():
	animation_player.speed_scale = 1
	if current_health <= 0: # Idle Dead
		#direction = 0
		player_direction = 0
		velocity.x = move_toward(velocity.x, 0, base_speed)

	elif 2000 <= distance_to_player and distance_to_player <= 4000: # Attack
		if distance_to_player > 3250:
			velocity.x = player_direction * shooting_speed
			play_animation("strafe")
		elif distance_to_player < 2750: 
			if is_on_wall():
				velocity.x = 0
				play_animation("stand")
			else:
				velocity.x = -player_direction * shooting_speed
				play_animation("strafe")
				animation_player.speed_scale = -1
		else:
			velocity.x = 0
			#direction = 0
			play_animation("stand")
			
		if shoot_timer <= 0:
			shoot_timer = shoot_timer_base
		else:
			shoot_timer -= 1
			if shoot_timer <= 60:
				shooting()
				
	elif distance_to_player < 2000: # Back Up
		#direction *= -1
		velocity.x = -player_direction * base_speed
		skeleton.transform.x.x = -player_direction
		play_animation("run")

	elif distance_to_player < 6000: # Approach
		velocity.x = player_direction * base_speed
		skeleton.transform.x.x = player_direction
		play_animation("run")
	else: # Idle 
		#direction = 0
		velocity.x = move_toward(velocity.x, 0, base_speed)
		play_animation("stand")
	
	
func play_animation(animation_name: String):
	if animation_name != current_animation:
		animation_player.play(animation_name)
		current_animation = animation_name
		
func take_damage(damage: int):
	current_health -= damage
