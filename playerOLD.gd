# playerOLD.gd

extends CharacterBody2D


var base_speed = 5000
var running_speed = base_speed
var shooting_speed = base_speed / 2
var jump_strength = -4500
var max_jumps: int = 2
var current_jumps: int = max_jumps
var upper_ray
var lower_ray

var base_health = 9999999999999
var current_health = base_health
var direction

@onready var leg_animation_player = $LegAnimationPlayer
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
	
	if $RightLowerRay.is_colliding():
		#print("RIGHT RAY")
		lower_ray = 1
	elif $LeftLowerRay.is_colliding():
		#print("LEFT RAY")
		lower_ray = -1
	else:
		lower_ray = 0
		
	
	if $RightUpperRay.is_colliding():
		upper_ray = 1
	elif $LeftUpperRay.is_colliding():
		upper_ray = -1
	else:
		upper_ray = 0
	
	if Input.is_action_just_pressed("jump"):
		#print(lower_ray)
		if !is_on_floor():
			if lower_ray == 1:
				velocity.y = jump_strength
				velocity.x = jump_strength
				current_jumps = max_jumps - 1
			elif lower_ray == -1:
				velocity.y = jump_strength
				velocity.x = - jump_strength
				current_jumps = max_jumps - 1
			elif current_jumps > 0:
				velocity.y = jump_strength
				current_jumps -= 1
		else:
			velocity.y = jump_strength
			current_jumps -= 1
	
	
	if Input.is_action_pressed("shoot"):
		running_speed = shooting_speed
	else:
		running_speed = base_speed
		
	gun_holder.player_shoot()
	
	if is_on_floor():
		if direction:
			velocity.x = direction * running_speed
		else:
			velocity.x = move_toward(velocity.x, 0, running_speed)
	elif !is_on_floor():
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * running_speed, running_speed / 20)
	


func _process(delta: float) -> void:
	if current_health > 0:
		process_input()
		
	#print(animation_player.current_animation)

func process_input():
	
	if is_on_floor():
		if Input.is_action_pressed("shoot"):
			shooting_visuals()
		elif Input.is_action_pressed("left"):
			skeleton.transform.x.x = -1
			leg_animation_player.play("run")
		elif Input.is_action_pressed("right"):
			skeleton.transform.x.x = 1
			leg_animation_player.play("run")
		else:
			leg_animation_player.play("stand")
	elif !is_on_floor():
		if Input.is_action_pressed("shoot"):
			leg_animation_player.play("run")
			shooting_visuals()
			
	
		
	



	
func take_damage(damage: int):
	current_health -= damage
	
func shooting_visuals():
	if global_position.x < get_global_mouse_position().x:
		skeleton.transform.x.x = 1
	elif global_position.x > get_global_mouse_position().x:
		skeleton.transform.x.x = -1
	$Skeleton2D/Base/Body/ArmR.look_at(get_global_mouse_position())
	#$Skeleton2D/Base/Body/ArmR/ForearmR.look_at(get_local_mouse_position())
	$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -90
	#$Skeleton2D/Base/Body/ArmL.look_at(get_global_mouse_position())
	#$Skeleton2D/Base/Body/ArmL.rotation_degrees += -90
	$Skeleton2D/Base/Body/Head.look_at(get_global_mouse_position())
