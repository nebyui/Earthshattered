extends Node2D

var enemy = preload("res://Enemy/enemy.tscn")
@onready var player_group = get_tree().get_nodes_in_group("Player")
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	for spawn_point in get_children():
		if (player.global_position - spawn_point.global_position).length() <= 8000:
			var enemy_instance = enemy.instantiate()
			enemy_instance.global_position = spawn_point.global_position
			get_tree().root.add_child(enemy_instance)
			spawn_point.queue_free()
		


func _process(delta: float) -> void:
	pass
