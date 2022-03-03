extends Node2D

export(NodePath) onready var starTxt = get_node(starTxt) as Label

func _ready() -> void:
	var allStars = 0;
	var allLevels = Data.data.levelArr.size();
	for lvl in Data.data.levelArr:
		if lvl.completeOnPar: allStars += 1;
	starTxt.text = str(allStars) + "/" + str(allLevels);


func onLevelSelectPressed() -> void:
	$BtnSound.play();
	get_node("SceneTransition").transition("res://src/scenes/LevelSelectSceneV2.tscn")


func onExitBtnPressed() -> void:
	get_tree().quit();
