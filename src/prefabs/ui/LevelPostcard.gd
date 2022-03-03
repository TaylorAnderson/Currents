extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func onBtnPressed() -> void:
	var tween = $Tween;
	print("hello");
	tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ONE * 1.05, 0.07);
	tween.start()
	yield(tween, "tween_all_completed")
	tween.interpolate_property(self, "rect_scale", Vector2.ONE * 1.05, Vector2.ONE, 0.07);
	tween.start()
	yield(tween, "tween_all_completed");
