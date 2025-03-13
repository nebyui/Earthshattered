# enemy.gd

extends CharacterBody2D


var base_speed = 5000
var running_speed = base_speed
var shooting_speed = base_speed / 2
var jump_strength = -4500
var max_jumps: int = 2
var current_jumps: int = max_jumps
var upper_ray
var lower_ray
var is_shooting = false

var base_health = 100
var current_health = base_health
var direction = 0

@onready var animation_player = $LegAnimationPlayer
@onready var player_group = get_tree().get_nodes_in_group("Player")
@onready var behavior_tree = $BehaviorTree
@onready var gun_holder = find_child("GunHolder")
var player



var player_position
var distance_to_player: float


func _ready() -> void:
	floor_snap_length = 300
	if player_group.size() > 0:
		player = player_group[0]
	

func _physics_process(delta: float) -> void:
	
		
	if not is_on_floor():
		if current_jumps == max_jumps:
			current_jumps -= 1
		velocity += get_gravity() * delta
	if is_on_floor():
		current_jumps = max_jumps
	
	if $RightLowerRay.is_colliding():
		lower_ray = 1
	elif $LeftLowerRay.is_colliding():
		lower_ray = -1
	else:
		lower_ray = 0
		
	
	if $RightUpperRay.is_colliding():
		upper_ray = 1
	elif $LeftUpperRay.is_colliding():
		upper_ray = -1
	else:
		upper_ray = 0

	if player:
		player_position = player.global_position
		distance_to_player = (player_position - global_position).length()
		if player_position.x >= position.x + 100:
			direction = 1
		elif player_position.x < position.x - 100:
			direction = -1
		else:
			direction = 0
	
	if current_health <= 0:
		#print("DEADd")
		set_collision_layer_value(3, false)
		set_collision_mask_value(2, false)
		rotation_degrees = 90
	
	behavior_tree.behavior_decision(distance_to_player)
	
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
	
	if is_on_floor():
		if direction == -1:
			transform.x.x = -1
			animation_player.play("run")
		elif direction == 1:
			transform.x.x = 1
			animation_player.play("run")
		else:
			animation_player.play("RESET")
			
			

	
func take_damage(damage: int):
	current_health -= damage
	
func shooting():
	#if global_position.x < get_global_mouse_position().x:
		#transform.x.x = 1
	#elif global_position.x > get_global_mouse_position().x:
		#transform.x.x = -1
	$Skeleton2D/Base/Body/ArmR.look_at(player.global_position)
	#$Skeleton2D/Base/Body/ArmR/ForearmR.look_at(get_local_mouse_position())
	$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -90
	#$Skeleton2D/Base/Body/ArmL.look_at(get_global_mouse_position())
	#$Skeleton2D/Base/Body/ArmL.rotation_degrees += -90
	$Skeleton2D/Base/Body/Head.look_at(player.global_position)
	gun_holder.enemy_shoot()
	
	
func jump():
	if !is_on_floor():
		if lower_ray == 1:
			velocity.y = jump_strength
			velocity.x = jump_strength * transform.x.x
			current_jumps = max_jumps - 1
		elif lower_ray == -1:
			velocity.y = jump_strength
			velocity.x = - jump_strength * transform.x.x
			current_jumps = max_jumps - 1
		elif current_jumps > 0:
			velocity.y = jump_strength
			current_jumps -= 1
		else:
			velocity.y = jump_strength
			current_jumps -= 1
