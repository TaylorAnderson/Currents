extends TextureButton

export(NodePath) onready var pauseScreen = get_node(pauseScreen) as PauseMenu

func onPressed() -> void:
	pauseScreen.show();
