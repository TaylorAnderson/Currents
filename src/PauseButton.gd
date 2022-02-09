extends TextureButton

export(NodePath) onready var pauseScreen = get_node(pauseScreen) as Node2D

func onPressed() -> void:
	pauseScreen.visible = true;
