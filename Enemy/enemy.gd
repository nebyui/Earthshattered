# enemy.gd

extends CharacterBody2D


var base_speed = 4500
var shooting_speed = base_speed / 2
var sprinting_speed = base_speed * 1.5
var jump_strength = -5000
var max_jumps: int = 2
var current_jumps: int = max_jumps
var ray
var enemy_ray
var floor_ray
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
var ragdoll = preload("res://player_ragdoll.tscn")
var ragdoll_spawn = false
var respawn_timer = 120
var respawn_countdown = respawn_timer

var player
var behavior_lock_timer = 0
var random_behavior_timer_base = 120
var random_behavior_timer = random_behavior_timer_base
var random_behavior_number = 0
var sound_player

var player_position
var distance_to_player: float

func _ready() -> void:
	add_to_group("Enemies")
	floor_snap_length = 200
	if player_group.size() > 0:
		player = player_group[0]
	sound_player = $SoundEffects.get_child(0)
	

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
	
	
	
	if $EnemyRayLeft.is_colliding() and $EnemyRayRight.is_colliding():
		enemy_ray = 0
	elif $EnemyRayLeft.is_colliding():
		enemy_ray = -1
	elif $EnemyRayRight.is_colliding():
		enemy_ray = 1
	else:
		enemy_ray = 0
	
	if $LeftFloorRay.is_colliding() and $RightFloorRay.is_colliding():
		floor_ray = 2
	elif $LeftFloorRay.is_colliding():
		floor_ray = -1
	elif $RightFloorRay.is_colliding():
		floor_ray = 1
	else:
		floor_ray = 0
		
	#print(floor_ray)
	
	
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
		play_animation("stand")
		visible = false
		set_collision_layer_value(3, false)
		if ragdoll_spawn == false:
			ragdoll_spawn = true
			var ragdoll_instance = ragdoll.instantiate()
			ragdoll_instance.global_position = global_position
			
			var segment_group = ragdoll_instance.get_children()
			
			ragdoll_instance.modulate = Color.from_hsv(0.97, 0.5, 1, 1 )
			
			for segment in segment_group:
				if segment is RigidBody2D:
					segment.linear_velocity = velocity 
					var vector_temp: Vector2 = Vector2(0, randf_range(-1000, 0))
					#var position_temp: Vector2 = Vector2(randf_range(-500, 500), randf_range(-500, 500))
					segment.apply_impulse(vector_temp * 4, Vector2.ZERO)
				
			get_tree().current_scene.add_child(ragdoll_instance)
			
			if skeleton.transform.x.x == -1:
				var children = ragdoll_instance.get_children()
				for child in children:
					var grandchildren = child.get_children()
					for grandchild in grandchildren:
						if grandchild is Sprite2D:
							if grandchild.name == "HeadSprite":
								grandchild.scale.x = -0.6
							else:
								grandchild.scale.x = -1
		
			$SoundEffects/Explosion.play_explosion()
		velocity = Vector2.ZERO
		
		if respawn_countdown == 0:
			respawn_countdown = -1
			queue_free()
		else:
			respawn_countdown -= 1
		
		
		
		
		
		#queue_free()
		#if distance_to_player > 8000:
			#queue_free()
	else:
		enemy_behavior()

	move_and_slide()
	
func _process(delta: float) -> void:
	pass

func enemy_behavior():
	
	if random_behavior_timer <= 0:
		random_behavior_timer = 120
		random_behavior_number = randi_range(1, 2)
		match random_behavior_number:
			1: # Jump
				if is_on_floor():
					velocity.y = jump_strength
					play_animation("jump_ground")
					return
	else:
		random_behavior_timer -= 1
	
	if behavior_lock_timer > 0:
		behavior_lock_timer -= 1
		return
		
	animation_player.speed_scale = 1
	
	if is_on_floor():

		if floor_ray != 2:
			if floor_ray == 1:
				velocity.y = jump_strength
				velocity.x = jump_strength
				play_animation("jump_floor")
			elif floor_ray == -1:
				velocity.y = jump_strength
				velocity.x = -jump_strength
				play_animation("jump_floor")
			elif floor_ray == 2:
				velocity.y = jump_strength
				play_animation("jump_floor")
			else:
				pass
		
		elif distance_to_player <= 5100: # Attack
			if distance_to_player >= 5000:
				velocity.x = player_direction * shooting_speed
				play_animation("strafe")
			elif distance_to_player < 2750: 
				velocity.x = -player_direction * shooting_speed
				play_animation("strafe")
			#else:
				#velocity.x = 0
				##direction = 0
				#play_animation("stand")	
					
			if (velocity.x > 0 and player_direction == -1)\
			 or (velocity.x < 0 and player_direction == 1):
				animation_player.speed_scale = -1
				
			if player_direction == 1:
				skeleton.transform.x.x = 1
			elif player_direction == -1:
				skeleton.transform.x.x = -1
			
			if player and is_instance_valid(player):
				$Skeleton2D/Base/Body/ArmR.look_at(player.global_position)
				$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -90
				$Skeleton2D/Base/Body/Head.look_at(player.global_position)
			
			if shoot_timer <= 0:
				shoot_timer = shoot_timer_base
			else:
				shoot_timer -= 1
				if shoot_timer <= 90:
					if player.current_health > 0:
						gun_holder.enemy_shoot()
					
		elif distance_to_player < 2000: # Back Up
			#direction *= -1
			velocity.x = -player_direction * sprinting_speed
			skeleton.transform.x.x = -player_direction
			play_animation("sprint")
			arm_position()
			behavior_lock_timer = 20

		elif distance_to_player < 10000: # Approach
			velocity.x = player_direction * base_speed
			skeleton.transform.x.x = player_direction
			play_animation("run")
			arm_position()
		else: # Idle 
			velocity.x = move_toward(velocity.x, 0, base_speed)
			play_animation("stand")
			arm_position()
			
	elif !is_on_floor():
		
		if ray != 0:
			if ray == 1:
				velocity.y = jump_strength
				velocity.x = jump_strength
				if skeleton.transform.x.x == 1:
					play_animation("front_wall_jump")
				elif skeleton.transform.x.x == -1:
					play_animation("back_wall_jump")
			elif ray == -1:
				velocity.y = jump_strength
				velocity.x = -jump_strength
				if skeleton.transform.x.x == 1:
					play_animation("back_wall_jump")
				elif skeleton.transform.x.x == -1:
					play_animation("front_wall_jump")
		else:
			if current_animation != "jump_ground" and current_animation != "jump_air"\
			and current_animation != "back_wall_jump" and current_animation != "front_wall_jump":
				play_animation("falling")
				
				
		if distance_to_player <= 5100: # Attack	
			if shoot_timer <= 0:
				shoot_timer = shoot_timer_base
			else:
				shoot_timer -= 1
				if shoot_timer <= 90:
					if player.current_health > 0:
						gun_holder.enemy_shoot()
	
	
func play_animation(animation_name: String):
	if animation_name != current_animation:
		animation_player.play(animation_name)
		current_animation = animation_name
		
func take_damage(damage: int):
	current_health -= damage
	$SoundEffects/Hit.play_hit("low", current_health)


func arm_position():
	$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -85
	$Skeleton2D/Base/Body/ArmR.rotation_degrees = 16
	$Skeleton2D/Base/Body/Head.rotation_degrees = 0
