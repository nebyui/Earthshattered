extends Node2D

var player
var distance_to_player
var current_spawn_point

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	current_spawn_point = find_child("PlayerSpawn1")

func _process(delta: float) -> void:
	pass
	
	
func _physics_process(delta: float) -> void:
	for spawn_point in get_children():
		distance_to_player = (spawn_point.global_position - player.global_position).length()
		if distance_to_player < 1000:
			current_spawn_point = spawn_point
