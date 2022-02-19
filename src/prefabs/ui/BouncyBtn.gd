extends TextureButton

onready var tween = Tween.new();
onready var initScale = rect_scale;

signal press_anim_complete;
func _ready():
	add_child(tween);
	rect_pivot_offset.x = rect_size.x/2;
	rect_pivot_offset.y = rect_size.y/2;
	
func _pressed() -> void:
	print("hello");
	tween.interpolate_property(self, "rect_scale", initScale, initScale * 1.1, 0.07);
	tween.start()
	yield(tween, "tween_all_completed")
	tween.interpolate_property(self, "rect_scale", initScale * 1.1, initScale, 0.07);
	tween.start()
	yield(tween, "tween_all_completed");
	emit_signal("press_anim_complete");
