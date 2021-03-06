extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
export(NodePath) onready var levelParent = get_node(levelParent) as Node2D
var currentLevel;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func loadNextLevel():
	var level = Data.GetNextLevelScene().instance();
	return loadLevel(level);

func loadCurrentLevel():
	var level = Data.GetCurrentLevelScene().instance();
	return loadLevel(level);
	
func loadLevel(levelInstance):
	if not levelInstance: return false;
	if (levelParent.get_child_count() > 0):
		levelParent.remove_child(levelParent.get_child(0))
	currentLevel = levelInstance
	levelParent.add_child(levelInstance)
	levelInstance.get_node("Frame").queue_free();
	levelInstance.get_node("Bg").queue_free();
	return true;


func onNextLvlBtnPress() -> void:
	loadNextLevel();
