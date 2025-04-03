# menu.gd

extends Control

func _ready() -> void:
	pass

func _on_start_pressed() -> void:
	
	TransitionScreen.transition_to_scene("tutorial_scene")
	

func _on_options_pressed() -> void:
	TransitionScreen.transition_to_scene("main_scene")


func _on_quit_pressed() -> void:
	get_tree().quit()
	
