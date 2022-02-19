extends TextureButton
class_name CustomButton

func _pressed() -> void:
	print(get_node("AudioStreamPlayer"))
	get_node("AudioStreamPlayer").play()
