extends Node2D

var fps
var enemy_count
func _ready() -> void:
	#Engine.time_scale = .2
	pass
	

func _process(delta: float) -> void:
	

	#if Input.is_action_just_pressed("pause"):
		#if get_tree().paused == false:
			#get_tree().paused = true
		#elif get_tree().paused == true:
			#get_tree().paused = false
	
	
	fps = Engine.get_frames_per_second()
	#$CanvasLayer/Label.text = str($Player.velocity.x)
	#$CanvasLayer/Label.text = str($Player.ray)
	$CanvasLayer/Label.text = str($Player.velocity.y)
	#$CanvasLayer/Label.text = str($Player.current_animation)
	#$CanvasLayer/Label.text = str($Player.animation_player.current_animation_position)
	#$CanvasLayer/Label.text = str(fps)
	#$CanvasLayer/Label.text = str(fps)
	
	enemy_count = get_tree().get_nodes_in_group("Enemies").size()
	
	#$CanvasLayer/Label2.text = str(enemy_count)
	
	
	
	pass
