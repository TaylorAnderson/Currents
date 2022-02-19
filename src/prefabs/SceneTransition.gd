extends Node2D
onready var spr = get_node("AnimatedSprite") as AnimatedSprite
onready var transitioning = false;
onready var scene
var currentPath = "";
func _ready() -> void:
	spr.play("backwards", true);
func transition(scenePath):
	spr.stop();
	spr.play("forwards");
	currentPath = scenePath;
	transitioning = true;


func onAnimationFinished() -> void:
	print("hello");
	if transitioning:
		get_tree().change_scene(currentPath);
	
