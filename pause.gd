extends Node


func _ready() -> void:
	set_process_input(true)
	print("Thing 2")


func _process(delta: float) -> void:

	print("Thing")

	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			get_tree().paused = true
		elif get_tree().paused == true:
			get_tree().paused = false
