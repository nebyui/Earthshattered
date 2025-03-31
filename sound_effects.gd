extends AudioStreamPlayer2D
var player


func _ready() -> void:
	
	player = get_tree().get_first_node_in_group("Player")
	if name == "Footsteps":
		volume_db = -10
		

func play_sound():
	
	if name == "Footsteps":
		if player.current_animation == "run":
			pitch_scale = randf_range(0.9, 1.3)
		elif player.current_animation == "sprint":
			pitch_scale = randf_range(1.1, 1.5)
			

	
	
	play()
