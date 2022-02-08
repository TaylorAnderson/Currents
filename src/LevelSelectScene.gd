extends Node2D

export(PackedScene) var levelRow:PackedScene
export(String, DIR) var levelDirectory;
export(NodePath) onready var levelContainer = get_node(levelContainer) as VBoxContainer

func _ready() -> void:
	var dir = Directory.new()
	if dir.open(levelDirectory) == OK:
		dir.list_dir_begin();
		var file_name = dir.get_next();
		while file_name != "":
			if not dir.current_is_dir():
				print(levelDirectory + "/" + file_name);
				var levelScene = load(levelDirectory + "/" + file_name) as PackedScene;
				var levelInst = levelScene.instance();
				var levelData = levelInst.get_node("Metadata") as Metadata;
				
				var row = levelRow.instance();
				var rowTitle = row.get_node("ContentRow/Title") as RichTextLabel
				rowTitle.bbcode_text = "[center]" + levelData.levelName + "[/center]"
				
				var rowMinPaths = row.get_node("ContentRow/MinPaths") as RichTextLabel;
				rowMinPaths.bbcode_text = "[center]" + str(levelData.minPathsToSolve) + "[/center]" 
				levelContainer.add_child(row);
			file_name = dir.get_next();
		dir.list_dir_end();

