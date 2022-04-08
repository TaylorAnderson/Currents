extends HBoxContainer

export (float, 1, 1000) var frequency = 5;
export (float, 1000) var amplitude = 150
export (float) var timeMultiplier = 1;
export (float) var letterTimeIncrement = 100;
export(NodePath) onready var player = get_node(player) as AnimationPlayer;
var time = 0;
func _ready() -> void:
	yield(get_tree().create_timer(0.02), "timeout")
	player.play("Logo Wipe")
func _process(delta: float) -> void:
	time += delta;
	
	for i in range(get_child_count()):
		var movement = cos((time * timeMultiplier) + (i * 100) * frequency) * amplitude;
		var child = get_child(i) as Label;
		child.rect_position.y = movement;
