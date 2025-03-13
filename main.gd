extends Node2D

var fps

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fps = Engine.get_frames_per_second()
	$CanvasLayer/Label.text = str(fps)
	pass
