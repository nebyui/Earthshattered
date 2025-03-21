# transition_screen.gd

extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer


var scene_dictionary = {
	
	"main_scene": preload("res://main.tscn"),
	"test_scene": preload("res://stage.tscn"),
	"menu_scene": preload("res://menu.tscn")
}

var new_scene: PackedScene

func _ready() -> void:
	color_rect.visible = false


func transition_to_scene(scene_name: String):
	if not scene_dictionary.has(scene_name):
		push_error("Scene does not exist in scene dictionary")
		print("Scene does not exist in scene dictionary")
		return
	
	new_scene = scene_dictionary[scene_name]
	
	color_rect.visible = true
	animation_player.play("fade_out")
	await animation_player.animation_finished
	await get_tree().process_frame
	get_tree().change_scene_to_packed(new_scene)
	animation_player.play("fade_in")
	await animation_player.animation_finished
	color_rect.visible = false
