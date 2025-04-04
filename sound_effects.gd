extends AudioStreamPlayer2D

var entity
var pitch_shift_temp

func _ready() -> void:
	
	entity = get_parent().get_parent()

		

func play_footstep():
	
	if entity.current_animation == "run":
		pitch_scale = randf_range(0.9, 1.3)
	elif entity.current_animation == "sprint":
		pitch_scale = randf_range(1.1, 1.5)
	if "Enemy" in entity.name:
		pitch_scale -= 0.4
			
	play()

	
func play_explosion():
	pitch_scale = randf_range(0.8, 1.2)
	#if entity.is_in_group("Enemies"):
		#pitch_scale -= 0.4
	play()
	
func play_jump(pitch_parameter: String):

	pitch_scale = randf_range(1, 1.5)
	if pitch_parameter == "high":
		pitch_scale += .5
	elif pitch_parameter == "low":
		pass
	play()


func play_wall_grab():
	pitch_scale = randf_range(0.8, 1.2)
	play()
	
func play_hit(pitch_parameter: String, pitch_shift_interval: int):
	
	pitch_shift_temp = 1 - (pitch_shift_interval / 100.0)
	
	if pitch_parameter == "high":
		pitch_scale = randf_range(2.0, 2.3)
	elif pitch_parameter == "low":
		pitch_scale = 1.0 + (pitch_shift_temp * 1.2)
	play()
