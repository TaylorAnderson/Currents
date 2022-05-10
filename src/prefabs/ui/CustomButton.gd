extends TextureButton
class_name CustomButton

func _pressed() -> void:
	get_node("AudioStreamPlayer").play()
