# collision_polygon.gd

@tool
extends CollisionPolygon2D

var current_polygon: PackedVector2Array
var old_polygon: PackedVector2Array

func _ready() -> void:
	if Engine.is_editor_hint():
		update_polygon()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_polygon()
	
func update_polygon():
	current_polygon = get_polygon()
	if current_polygon != old_polygon:
		if $Polygon2D:
			$Polygon2D.set_polygon(current_polygon)
			old_polygon = current_polygon
		else:
			print("Polygon 2D ERROR")
	
