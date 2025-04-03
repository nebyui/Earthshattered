# assault_rifle.gd

extends Node2D

var bullet = preload("res://bullet.tscn")
var fire_rate: int = 5
var fire_timer: int = fire_rate
var fire_ready: bool = true
var bullet_speed: int = 15000
var gun_damage: int = 15

var is_automatic = true


@onready var gun_barrel = $GunBarrel
@onready var gun_sound = $GunSound

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass
	
		

func _physics_process(delta: float) -> void:
	if fire_ready == false:
		
		if fire_timer <= 0:
			fire_ready = true
			fire_timer = fire_rate
		else:
			fire_timer -= 1


func trigger_pressed(character: String):
	if fire_ready == true:
		fire_ready = false
		var bullet_instance = bullet.instantiate()
		bullet_instance.speed = bullet_speed
		gun_sound.pitch_scale = randf_range(0.9, 1.1)
		if character == "player":
			bullet_instance.set_collision_mask_value(3, true)
		elif character == "enemy":
			bullet_instance.set_collision_mask_value(2, true)
			bullet_instance.speed /= 2
			gun_sound.pitch_scale -= .4
		bullet_instance.global_position = gun_barrel.global_position
		bullet_instance.rotation = global_rotation
		bullet_instance.bullet_damage = gun_damage
		get_tree().root.add_child(bullet_instance)
		gun_sound.play()

func trigger_released():
	pass
