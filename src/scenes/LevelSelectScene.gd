extends Node2D

export(PackedScene) var levelRow:PackedScene
export(String, DIR) var levelDirectory;
export(NodePath) onready var levelContainer = get_node(levelContainer) as VBoxContainer
export (NodePath) onready var parAmtTxt = get_node(parAmtTxt) as Label;
export(NodePath) onready var completeAmtTxt = get_node(completeAmtTxt) as Label;
var levelRows = [];
var paused = false;
func _ready() -> void:
	var allPars = 0;
	var allComplete = 0;
	var allLevels = Data.data.levelArr.size();
	for lvl in Data.data.levelArr:
		if lvl.completeOnPar: allPars += 1;
		if lvl.complete: allComplete += 1;
	parAmtTxt.text = str(allPars) + "/" + str(allLevels);
	completeAmtTxt.text = str(allComplete) + "/" + str(allLevels);
	for i in range(Data.data.levelArr.size()):
		var levelData = Data.data.levelArr[i]
		var row = levelRow.instance();

		var thumbnailImage = Image.new();
		var err = thumbnailImage.load(Data.thumbnailPath + levelData.levelName + ".png");
		if err == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(thumbnailImage, 0)
			var rowThumbnail = row.get_node("Content/ContentRow/Thumbnail") as TextureRect
			rowThumbnail.texture = texture;

		
		var rowBG = row.get_node("Content/BG") as NinePatchRect
		if (i % 2 == 0):
			rowBG.self_modulate = Color("#1384ab");
		else:
			rowBG.self_modulate = Color("#0275b0")
		var rowBtn = row.get_node("Content/Btn") as TextureButton
		rowBtn.connect("pressed", self, "onLevelRowPressed", [levelData]);
		var rowTitle = row.get_node("Content/ContentRow/V/Title") as Label
		rowTitle.text = levelData.levelName
		
		var rowMinPaths = row.get_node("Content/ContentRow/V/MinPaths") as Label;
		rowMinPaths.text = str(levelData.levelPaths)
		levelContainer.add_child(row);
		
		var rowCompleteIcon = row.get_node("Content/ContentRow/CompleteIcon/Icon");
		rowCompleteIcon.visible = levelData.complete;

		var rowCompleteOnParIcon = row.get_node("Content/ContentRow/PathsCompleteIcon/Icon");
		rowCompleteOnParIcon.visible = levelData.completeOnPar;
func onLevelRowPressed(levelData):
	$BtnSound.play();
	if paused: return;
	var index = Data.data.levelArr.find(levelData)
	#We do -1 because the GameScene only has functionality to load NEXT level
	#And I'm too lazy to change it.
	Data.SetCurrentLevel(index-1);
	get_node("SceneTransition").transition("res://src/scenes/GameScene.tscn")


func togglePause() -> void:
	$PauseMenu.visible = !$PauseMenu.visible;
	$BtnSound.play();
