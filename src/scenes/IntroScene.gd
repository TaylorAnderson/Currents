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
