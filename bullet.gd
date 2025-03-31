# bullet.gd

extends CharacterBody2D

var speed: int
var lifetime: int = 60
var lifetime_counter: int  = lifetime
var collision: KinematicCollision2D
var previous_position: Vector2
var next_position: Vector2
var hit_target
var frame = 0
var bullet_damage: int

var interpolation_fraction

func _ready() -> void:
	velocity = Vector2(speed, 0).rotated(rotation)
	previous_position = global_position
	next_position = global_position
	pass 

func _process(delta: float) -> void:
	
	interpolation_fraction = Engine.get_physics_interpolation_fraction()
	$Sprite2D.global_position = previous_position.lerp(next_position, interpolation_fraction)
	
	

func _physics_process(delta: float) -> void:
	
	collision = move_and_collide(velocity * delta)
	
	if lifetime_counter <= 0:
		queue_free()
	else:
		lifetime_counter -= 1
	pass
	
	if collision:
		hit_target = collision.get_collider()
		if hit_target is CharacterBody2D:
			hit_target.take_damage(bullet_damage)
		queue_free()
		
	previous_position = next_position
	next_position = global_position
		
	
