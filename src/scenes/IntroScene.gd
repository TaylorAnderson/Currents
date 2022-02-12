extends Node2D

func _ready() -> void:
	Data.LoadGame();
	print(Data.data);


func onPlayBtnPressed() -> void:
	get_tree().change_scene("res://src/Scenes/LevelSelectScene.tscn")


func onSettingsBtnPressed() -> void:
	var settings = get_node("SettingsMenu")
	settings.visible = true;
	


func onSettingsXPressed() -> void:
	var settings = get_node("SettingsMenu")
	settings.visible = false; 
