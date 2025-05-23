# player.gd

extends CharacterBody2D


var base_speed = 4500
var shooting_speed = base_speed / 1.8
var sprinting_speed = base_speed * 1.5
var jump_strength = -5000
var max_jumps: int = 2
var current_jumps: int = max_jumps
var ray
var current_animation = "none"
var respawn_timer = 120
var respawn_countdown = respawn_timer

var base_health = 600
var current_health = base_health
var direction
var ragdoll = preload("res://player_ragdoll.tscn")
var ragdoll_spawn = false
var wall_cling_sound_played = false

@onready var animation_player = $AnimationPlayer
@onready var gun_holder = find_child("GunHolder")
@onready var skeleton = find_child("Skeleton2D")

signal player_dead


func _ready() -> void:
	floor_snap_length = 200
	pass


func _physics_process(delta: float) -> void:
		
	if not is_on_floor():
			velocity += get_gravity() * delta
		
	if current_health <= 0:
		play_animation("stand")
		visible = false
		set_collision_layer_value(2, false)
		if ragdoll_spawn == false:
			ragdoll_spawn = true
			var ragdoll_instance = ragdoll.instantiate()
			ragdoll_instance.global_position = global_position
			
			var segment_group = ragdoll_instance.get_children()
			
			
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
			player_dead.emit()
		else:
			respawn_countdown -= 1
	else:
		physics_input(delta)
	
		
	move_and_slide()
	
	
func physics_input(delta: float):
	animation_player.speed_scale = 1
	direction = Input.get_axis("left", "right")
	
	if direction > 0:
		direction = 1
	elif direction < 0:
		direction = -1
	
	if $RightRay.is_colliding():
		ray = 1
	elif $LeftRay.is_colliding():
		ray = -1
	else:
		ray = 0



	if is_on_floor():
		current_jumps = max_jumps
		if direction:
			if Input.is_action_pressed("crouch"):
				play_animation("crouch_walk")
				velocity.x = direction * shooting_speed
			elif Input.is_action_pressed("shoot"):
				play_animation("strafe")
				velocity.x = direction * shooting_speed
			elif Input.is_action_pressed("sprint"):
				play_animation("sprint")
				velocity.x = move_toward(velocity.x, sprinting_speed * direction, sprinting_speed / 6)
			else:
				play_animation("run")
				velocity.x = move_toward(velocity.x, base_speed * direction, sprinting_speed / 6)
			if direction > 0:
				skeleton.transform.x.x = 1
			elif direction < 0:
				skeleton.transform.x.x = -1
		else:
			if Input.is_action_pressed("crouch"):
				play_animation("crouch")
			else:
				play_animation("stand")
			velocity.x = move_toward(velocity.x, 0, base_speed / 3)
		if Input.is_action_just_pressed("jump"):
			$SoundEffects/Jump.play_jump("low")
			play_animation("jump_ground")
			velocity.y = jump_strength
			current_jumps -= 1
			
	elif !is_on_floor():
		if current_jumps == max_jumps:
			current_jumps -= 1
		if ray != 0:
			if wall_cling_sound_played == false:
				$SoundEffects/WallGrab.play_wall_grab()
			wall_cling_sound_played = true
			if ray == 1:
				if skeleton.transform.x.x == 1:
					play_animation("front_wall_cling")
				elif skeleton.transform.x.x == -1:
					play_animation("back_wall_cling")
			elif ray == -1:
				if skeleton.transform.x.x == 1:
					play_animation("back_wall_cling")
				elif skeleton.transform.x.x == -1:
					play_animation("front_wall_cling")
		else:
			wall_cling_sound_played = false
			if current_animation != "jump_ground" and current_animation != "jump_air"\
			and current_animation != "back_wall_jump" and current_animation != "front_wall_jump":
				play_animation("falling")
		
		if Input.is_action_just_pressed("jump"):
			if ray == 1:
				$SoundEffects/Jump.play_jump("low")
				velocity.y = jump_strength
				velocity.x = jump_strength
				current_jumps = max_jumps - 1
				if skeleton.transform.x.x == 1:
					play_animation("front_wall_jump")
				elif skeleton.transform.x.x == -1:
					play_animation("back_wall_jump")
			elif ray == -1:
				$SoundEffects/Jump.play_jump("low")
				velocity.y = jump_strength
				velocity.x = - jump_strength
				current_jumps = max_jumps - 1
				if skeleton.transform.x.x == 1:
					play_animation("back_wall_jump")
				elif skeleton.transform.x.x == -1:
					play_animation("front_wall_jump")
			elif current_jumps > 0:
				$SoundEffects/Jump.play_jump("high")
				play_animation("jump_air")
				if direction == 1:
					if !velocity.x > base_speed:
						velocity.x = base_speed
				elif direction == -1:
					if !velocity.x < - base_speed:
						velocity.x = -base_speed
				#elif direction == 0:
					#velocity.x = 0
				velocity.y = jump_strength
				current_jumps -= 1
		
		if direction != 0:
			if (velocity.x > base_speed and direction > 0) or \
			(velocity.x < -base_speed and direction < 0):
				pass
			else:
				velocity.x = move_toward(velocity.x, direction * base_speed, base_speed / 20)
	
	if Input.is_action_pressed("shoot"):
		shooting_visuals()
		gun_holder.player_shoot()
	else:
		$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -85
		$Skeleton2D/Base/Body/ArmR.rotation_degrees = 16
		$Skeleton2D/Base/Body/Head.rotation_degrees = 0
		


func _process(delta: float) -> void:
	if current_health > 0:
		process_input()

func process_input():
	pass

func take_damage(damage: int):
	current_health -= damage
	$SoundEffects/Hit.play_hit("high", current_health)
	
func shooting_visuals():
	if global_position.x < get_global_mouse_position().x:
		if skeleton.transform.x.x != 1:
			skeleton.transform.x.x = 1
		if Input.is_action_pressed("left") and current_animation == "strafe":
			animation_player.speed_scale = -1
	elif global_position.x > get_global_mouse_position().x:
		if skeleton.transform.x.x != -1:
			skeleton.transform.x.x = -1
		if Input.is_action_pressed("right") and current_animation == "strafe":
			animation_player.speed_scale = -1

	$Skeleton2D/Base/Body/ArmR.look_at(get_global_mouse_position())
	$Skeleton2D/Base/Body/Head.look_at(get_global_mouse_position())
	$Skeleton2D/Base/Body/ArmR/ForearmR.rotation_degrees = -90
	
func play_animation(animation_name: String):
	if animation_name != current_animation:
		animation_player.play(animation_name)
		current_animation = animation_name
		
func respawn_player():
	current_health = base_health
	set_collision_layer_value(2, true)
	visible = true
	ragdoll_spawn = false
	respawn_countdown = respawn_timer
	
	
