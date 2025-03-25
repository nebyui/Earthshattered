# player.gd

extends CharacterBody2D


var base_speed = 4500
var shooting_speed = base_speed / 1.8
var sprinting_speed = base_speed * 1.5
var jump_strength = -4500
var max_jumps: int = 2
var current_jumps: int = max_jumps
var ray
var current_animation = "none"
var jump_from_ground = false

var base_health = 9999999999999
var current_health = base_health
var direction

@onready var animation_player = $AnimationPlayer
#@onready var arm_animation_player = $ArmAnimationPlayer
@onready var gun_holder = find_child("GunHolder")
@onready var skeleton = find_child("Skeleton2D")


func _ready() -> void:
	floor_snap_length = 300
	pass


func _physics_process(delta: float) -> void:
	
	if current_health <= 0:
		set_collision_layer_value(2, false)
		set_collision_mask_value(3, false)
		rotation_degrees = 90
	else:
		physics_input()
		
	if not is_on_floor():
		if current_jumps == max_jumps:
			current_jumps -= 1
		velocity += get_gravity() * delta
	if is_on_floor():
		current_jumps = max_jumps
		
	move_and_slide()
	
	
func physics_input():
	#print("INPUT")
	direction = Input.get_axis("left", "right")
	
	if direction > 0:
		direction = 1
	elif direction < 0:
		direction = -1
	
	if $RightRay.is_colliding():
		#print("RIGHT RAY")
		ray = 1
	elif $LeftRay.is_colliding():
		#print("LEFT RAY")
		ray = -1
	else:
		ray = 0

	
	if Input.is_action_just_pressed("jump"):
		jump_from_ground = false
		#print(lower_ray)
		if !is_on_floor():
			if ray == 1:
				velocity.y = jump_strength
				velocity.x = jump_strength
				current_jumps = max_jumps - 1
			elif ray == -1:
				velocity.y = jump_strength
				velocity.x = - jump_strength
				current_jumps = max_jumps - 1
			elif current_jumps > 0:
				if direction == 1:
					velocity.x = base_speed
				elif direction == -1:
					velocity.x = -base_speed
				#elif direction == 0:
					#velocity.x = 0
				velocity.y = jump_strength
				current_jumps -= 1
		else:
			jump_from_ground = true
			velocity.y = jump_strength
			current_jumps -= 1
	
	
	if Input.is_action_pressed("shoot"):
		gun_holder.player_shoot()

	
	if is_on_floor():
		if direction:
			if Input.is_action_pressed("shoot"):
				velocity.x = direction * shooting_speed
			elif Input.is_action_pressed("sprint"):
				velocity.x = direction * sprinting_speed
			else:
				velocity.x = direction * base_speed
		else:
			velocity.x = move_toward(velocity.x, 0, base_speed)
	elif !is_on_floor():
		if direction != 0:
			if (velocity.x > base_speed and direction > 0) or \
			(velocity.x < -base_speed and direction < 0):
				pass
			else:
				velocity.x = move_toward(velocity.x, direction * base_speed, base_speed / 20)
	


func _process(delta: float) -> void:
	if current_health > 0:
		process_input()
		
	#print(animation_player.current_animation)

func process_input():
	animation_player.speed_scale = 1
	
	if is_on_floor():
		if Input.is_action_pressed("shoot"): 
			if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				play_animation("straf")
			else:
				play_animation("stand_shoot")
			shooting_visuals()
		elif Input.is_action_pressed("left"):
			skeleton.transform.x.x = -1
			if Input.is_action_pressed("sprint"):
				play_animation("sprint")
			else:
				play_animation("run")
		elif Input.is_action_pressed("right"):
			skeleton.transform.x.x = 1
			if Input.is_action_pressed("sprint"):
				play_animation("sprint")
			else:
				play_animation("run")
		else:
			play_animation("stand")
		
	elif !is_on_floor():
		
		if Input.is_action_pressed("jump"):
			if jump_from_ground == false:
				animation_player.play("air_jump")
				#arm_animation_player.play("air_jump")
			else:
				animation_player.play("jump")
				#arm_animation_player.play("jump")
		
		if ray != 0:
			if ray == 1:
				if skeleton.transform.x.x == 1:
					play_animation("front_wall_cling")
				elif skeleton.transform.x.x == -1:
					play_animation("back_wall_cling")
			elif ray == -1:
				if skeleton.transform.x.x == -1:
					play_animation("front_wall_cling")
				elif skeleton.transform.x.x == 1:
					play_animation("back_wall_cling")
		elif animation_player.current_animation != "jump":
			play_animation("air")
			
		if Input.is_action_pressed("shoot"):
			shooting_visuals()
		else:
			pass

	
func take_damage(damage: int):
	current_health -= damage
	
func shooting_visuals():
	if global_position.x < get_global_mouse_position().x:
		skeleton.transform.x.x = 1
		if Input.is_action_pressed("left"):
			animation_player.speed_scale = -1
	elif global_position.x > get_global_mouse_position().x:
		skeleton.transform.x.x = -1
		if Input.is_action_pressed("right"):
			animation_player.speed_scale = -1

	$Skeleton2D/Base/Body/ArmR.look_at(get_global_mouse_position())
	#$Skeleton2D/Base/Body/ArmR/ForearmR.look_at(get_local_mouse_position())
	$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -90
	#$Skeleton2D/Base/Body/ArmL.look_at(get_global_mouse_position())
	#$Skeleton2D/Base/Body/ArmL.rotation_degrees += -90
	$Skeleton2D/Base/Body/Head.look_at(get_global_mouse_position())
	
func play_animation(animation_name: String):
	if animation_name != current_animation:
		animation_player.play(animation_name)
		current_animation = animation_name
	#print(current_leg_animation)
	
