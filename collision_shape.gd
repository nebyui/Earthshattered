@tool
extends CollisionPolygon2D

var collision_polygon



func _ready() -> void:
	pass # Replace with function body.



func _process(delta: float) -> void:
	collision_polygon = get_polygon()
	$Polygon2D.set_polygon(collision_polygon)
	
	#rotation += PI * delta
	
	
	
