extends Node2D
class_name PauseMenu
export(NodePath) onready var settingsMenu = get_node(settingsMenu) as Node2D
export(NodePath) onready var credits = get_node(credits) as Node2D
export(NodePath) onready var levelSelectBtn = get_node(levelSelectBtn);
export(NodePath) onready var sceneTransition = get_node(sceneTransition);
export(bool) var includeLevelSelectBtn = true
signal on_show
signal on_hide

func _ready() -> void:
	if not includeLevelSelectBtn:
		levelSelectBtn.visible = false;
		
func show() -> void:
	self.visible = true;
	emit_signal("on_show");
func hide() -> void:
	self.visible = false;
	emit_signal("on_hide");

func onSettingsPressed() -> void:
	$BtnSound.play()
	settingsMenu.visible = !settingsMenu.visible;

func onCreditsPressed() -> void:
	$BtnSound.play();
	credits.visible = !credits.visible;

func onPlayBtnPressed() -> void:
	$BtnSound.play();
	hide();


func onLvlSelectBtnPressed() -> void:
	$BtnSound.play();
	sceneTransition.transition("res://src/scenes/LevelSelectScene.tscn")
