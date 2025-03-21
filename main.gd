extends Node2D

var fps

#func _ready() -> void:
	

func _process(delta: float) -> void:
	fps = Engine.get_frames_per_second()
	$CanvasLayer/Label.text = str(fps)
	pass
