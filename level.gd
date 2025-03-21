# level.gd

extends Node2D

signal player_exiting_level

func _on_area_2d_body_entered(body: Node2D) -> void:
	player_exiting_level.emit()
	#print("ENTERED")
	call_deferred("go_to_menu", body)
		
func go_to_menu(body):
	if body.name == "Player":
		TransitionScreen.transition_to_scene("menu_scene")
