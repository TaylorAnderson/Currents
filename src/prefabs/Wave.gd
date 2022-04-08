extends AnimatedSprite
func _ready() -> void:
	play();
func _process(delta: float) -> void:
	position += Vector2.RIGHT * 0.5;


func _on_Wave_animation_finished() -> void:
	queue_free()
