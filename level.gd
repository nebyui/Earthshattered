# level.gd

extends Node2D

signal player_exiting_level
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	player.global_position = find_child("PlayerSpawn1").global_position
	player.player_dead.connect(_on_player_dead)

func _on_area_2d_body_entered(body: Node2D) -> void:
	#player_exiting_level.emit()
	call_deferred("go_to_menu", body)
		
func go_to_menu(body):
	if body.name == "Player":
		TransitionScreen.transition_to_scene("menu_scene")
		

func _on_player_dead():
	TransitionScreen.respawn_transition()
	await TransitionScreen.transition_ready
	player.respawn_player()
	player.global_position = $PlayerSpawnPoints.current_spawn_point.global_position
	
	
