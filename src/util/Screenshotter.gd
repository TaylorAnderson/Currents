extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_released("Take Screenshot"):
		rand_seed(OS.get_unix_time())
		print("taking screenshot")
		var thumbnail_image = get_tree().get_root().get_texture().get_data() as Image;
		thumbnail_image.flip_y();
		thumbnail_image.save_png("res://assets/promo/screenshots/screenshot_" + str(rand_range(0, 1000)) + ".png")
