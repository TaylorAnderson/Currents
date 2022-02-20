extends Node2D

func _ready() -> void:
	Data.LoadGame();

func onPlayBtnPressed() -> void:
	$BtnSound.play()
	get_node("SceneTransition").transition("res://src/scenes/LevelSelectScene.tscn");


func onSettingsBtnPressed() -> void:
	$BtnSound.play()
	var settings = get_node("SettingsMenu")
	settings.visible = true;
	


func onSettingsXPressed() -> void:
	$BtnSound.play()
	var settings = get_node("SettingsMenu")
	settings.visible = false; 
	
func _input(event: InputEvent) -> void:
	# dev only
	if (event.is_action_released("Grab Thumbnails")):
		Data.SaveThumbnails(self);
