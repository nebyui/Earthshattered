# dummy.gd

extends CharacterBody2D


var current_animation = "none"



var base_health = 100
var current_health = base_health


@onready var skeleton = find_child("Skeleton2D")
var ragdoll = preload("res://player_ragdoll.tscn")
var ragdoll_spawn = false
var respawn_timer = 120
var respawn_countdown = respawn_timer




func _ready() -> void:
	pass
	

func _physics_process(delta: float) -> void:
	
	if current_health <= 0:
		visible = false
		set_collision_layer_value(3, false)
		if ragdoll_spawn == false:
			ragdoll_spawn = true
			var ragdoll_instance = ragdoll.instantiate()
			ragdoll_instance.global_position = global_position
			
			var segment_group = ragdoll_instance.get_children()
		
			ragdoll_instance.modulate = Color.from_hsv(0.26, 0.5, 1, 1)
		
			for segment in segment_group:
				if segment is RigidBody2D:
					segment.linear_velocity = velocity * 1.5
					var vector_temp: Vector2 = Vector2(0, randf_range(-1000, 0))
					#var position_temp: Vector2 = Vector2(randf_range(-500, 500), randf_range(-500, 500))
					segment.apply_impulse(vector_temp * 4, Vector2.ZERO)
			
			get_tree().current_scene.add_child(ragdoll_instance)
		
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
		

	move_and_slide()
	
	
	
	
	
	
	
	
func _process(delta: float) -> void:
	#var ragdoll_instance = ragdoll.instantiate()
		#ragdoll_instance.global_position = global_position
		#ragdoll_instance.modulate = Color.from_hsv(0.26, 0.5, 1, 1 )
		#
		#var segment_group = ragdoll_instance.get_children()
		#
		#
		#for segment in segment_group:
			#if segment is RigidBody2D:
				#segment.linear_velocity = velocity * 1.5
				#var vector_temp: Vector2 = Vector2(0, randf_range(-1000, 0))
				##var position_temp: Vector2 = Vector2(randf_range(-500, 500), randf_range(-500, 500))
				#segment.apply_impulse(vector_temp * 4, Vector2.ZERO)
			#
		#get_tree().current_scene.add_child(ragdoll_instance)
		#
		#var children = ragdoll_instance.get_children()
		#for child in children:
			#var grandchildren = child.get_children()
			#for grandchild in grandchildren:
				#if grandchild is Sprite2D:
					#if grandchild.name == "HeadSprite":
						#grandchild.scale.x = -0.6
					#else:
						#grandchild.scale.x = -1
	pass
	

func take_damage(damage: int):
	current_health -= damage
	$SoundEffects/Hit.play_hit("low", current_health)
