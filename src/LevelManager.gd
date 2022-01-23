extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var levelParent = get_node("/root/GameScene/Level")
export(Array, PackedScene) var levels:Array;
var levelIndex = -1;
var currentLevel;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func loadNextLevel():
	levelIndex+=1;
	if (levelIndex > levels.size()-1):
		return false;
	if (levelParent.get_child_count() > 0):
		levelParent.remove_child(levelParent.get_child(0))
	var level = levels[levelIndex].instance();
	currentLevel = level
	levelParent.add_child(level)
	level.remove_child(level.get_node("Frame"))
	level.remove_child(level.get_node("Bg"))
	return true;

func doneAllLevels():
	return levelIndex == levels.size()-1;


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
	


func onNextLvlBtnPress() -> void:
	loadNextLevel();
