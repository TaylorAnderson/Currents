extends Node2D
class_name Obstacle

var radius:float
var offset:Vector2

func _ready() -> void:
	z_index = Math.getZIndex(global_position.y);
func collides(ship):
	return ship.global_position.distance_to(global_position + offset) < ship.radius + radius;
