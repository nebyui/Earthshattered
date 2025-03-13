extends Skeleton2D

var timer = 60
var counter = timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if counter == 0:
		scale.x *= -1
		counter = timer
	else:
		counter -= 1
	
	pass
