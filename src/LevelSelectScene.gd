extends Node2D

export(PackedScene) var levelRow:PackedScene
export(String, DIR) var levelDirectory;
export(NodePath) onready var levelContainer = get_node(levelContainer) as VBoxContainer
var levelRows = [];
var paused = false;
func _ready() -> void:
	for levelData in Data.data.levelArr:
		var row = levelRow.instance();
		var rowBtn = row.get_node("Btn") as TextureButton
		rowBtn.connect("pressed", self, "onLevelRowPressed", [levelData]);
		var rowTitle = row.get_node("ContentRow/Title") as RichTextLabel
		rowTitle.bbcode_text = "[center]" + levelData.levelName + "[/center]"
		
		var rowMinPaths = row.get_node("ContentRow/MinPaths") as RichTextLabel;
		rowMinPaths.bbcode_text = "[center]" + str(levelData.levelPaths) + "[/center]" 
		levelContainer.add_child(row);
		
		var rowCompleteIcon = row.get_node("ContentRow/CompleteIcon/Icon");
		rowCompleteIcon.visible = levelData.complete;

		var rowCompleteOnParIcon = row.get_node("ContentRow/PathsCompleteIcon/Icon");
		rowCompleteOnParIcon.visible = levelData.completeOnPar;
func onLevelRowPressed(levelData):
	if paused: return;
	var index = Data.data.levelArr.find(levelData)
	#We do -1 because the GameScene only has functionality to load NEXT level
	#And I'm too lazy to change it.
	print("happening");
	Data.SetCurrentLevel(index-1);
	get_tree().change_scene("res://src/Scenes/GameScene.tscn")


func togglePause(pause) -> void:
	paused = pause;
