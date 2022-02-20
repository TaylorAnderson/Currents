extends Control


onready var tween = get_node("Tween")
func onBtnPressed() -> void:
	print("hello");
	tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.1, 0.07);
	tween.start()
	yield(tween, "tween_all_completed")
	tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.1, Vector2.ONE, 0.07);
	tween.start()
	yield(tween, "tween_all_completed");
