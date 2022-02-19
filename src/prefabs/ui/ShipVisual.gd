extends Sprite

export (float, 1, 1000) var frequency = 5;
export (float, 1000) var amplitude = 150
var time = 0;
func _process(delta: float) -> void:
	time += delta;
	var movement = cos(time * frequency) * amplitude;
	position.y += movement;
