extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(PackedScene) var levelThumbnail
onready var levelContainer = get_node("LevelContainer") as HBoxContainer
onready var incrementVal = Global.width*0.75 + levelContainer.get("custom_constants/separation");
onready var scrollAmt = 0;
onready var levels = [];
var currentLevel = 0;
var paused = false;
var playingUnlockAnim = false;
var aboutToUnlock = false;
var blockToUnlock = null;
# Called when the node enters the scene tree for the first time.
func _ready():
	#MusicFader.fade_in(get_node("Music"), -10)
	var postcardWidth = 0;
	if Data.currentBlock > Data.lastBlockSinceLevelSelect:
		Data.lastBlockSinceLevelSelect = Data.currentBlock;
		Data.SaveGame();
		aboutToUnlock = true;
		blockToUnlock = Data.levelBlocks[Data.currentBlock]

	for i in range(Data.data["levelArr"].size()):
		var levelData = Data.data["levelArr"][i]
		var th = levelThumbnail.instance() as Control;
		levels.append({
			data=levelData,
			thumbnail=th.get_node("Tex")
		})
		var center_container = CenterContainer.new();
		levelContainer.add_child(center_container)
		center_container.add_child(th);
		postcardWidth = th.rect_size.x;
		var rowBtn = th.get_node("Btn") as TextureButton
		rowBtn.connect("pressed", self, "onLevelPressed", [levelData]);
		var rowTitle = th.get_node("Inner/Content/Title") as Label
		rowTitle.text = levelData.levelName
		
		var rowMinPaths = th.get_node("Inner/Content/MinPaths") as Label;
		rowMinPaths.text = "Par: " + str(levelData.levelPaths)
		
		var rowPaths = th.get_node("Inner/Content/Paths") as Label;
		if (levelData.get("pathsUsed")):
			rowPaths.text = "Paths: " + str(levelData.get("pathsUsed"))
		else:
			rowPaths.visible = false;
		
		var completeCheckbox = th.get_node("Inner/Content/Icons/CompleteIcon/Icon") as CenterContainer
		var parCheckbox = th.get_node("Inner/Content/Icons/OnParIcon/Icon") as CenterContainer
		
		var parLabel = th.get_node("Inner/Content/Icons/OnParIcon/Label") as Label
		var underParLabel = th.get_node("Inner/Content/Icons/UnderParIcon/Label") as Label
		parLabel.text = str(levelData.levelPaths);
		underParLabel.text = "<" + str(levelData.levelPaths);
		if i == 0 or i == 1: 
			th.get_node("Inner/Content/Icons/OnParIcon").visible = false; 
			th.get_node("Inner/Content/Icons/UnderParIcon").visible = false;
			rowMinPaths.visible = false;
			rowPaths.visible = false;
		var rowCompleteIcon = completeCheckbox.get_node("Icon");
		rowCompleteIcon.visible = levelData.complete;

		var rowCompleteOnParIcon = parCheckbox.get_node("Icon");
		rowCompleteOnParIcon.visible = levelData.completeOnPar;
		
		var rowCompleteUnderParIcon = th.get_node("Inner/Content/Icons/UnderParIcon/Icon/Icon")
		rowCompleteUnderParIcon.visible = levelData.completeUnderPar
		print(levelData.get("completeUnderPar"))
		var showText = i == Data.levelBlocks[Data.currentBlock].end+1

		var lock = th.get_node("Lock") as Node2D
		lock.visible = i >= Data.levelBlocks[Data.currentBlock].end+1;
		if (aboutToUnlock):
			# we want to show a lock on what we're about to UNlock, even though we know
			# that that level isnt ACTUALLY locked
			# this whole system is hell, and im sorry
			lock.visible = i >= Data.levelBlocks[Data.currentBlock].start
		if (showText):
			th.get_node("Text").visible = true;
			var levelTxt = th.get_node("Text/HBoxContainer/Label")
			
			var levelBlockProgress = Data.CheckLevelBlockProgress();
			levelTxt.text = str(levelBlockProgress.current) + "/" + str(levelBlockProgress.total);
		for tex in th.get_node("Textures").get_children():
			if (tex.name.to_lower() == levelData.levelName.replace(" ", "").to_lower()):
				tex.visible = true;
	

	levelContainer.rect_position.x = Global.width/2 - postcardWidth/2;
	scrollToLevel(Data.levelSelected, true);
	if (aboutToUnlock):
		unlockLevels(blockToUnlock.start, blockToUnlock.end+1)
		
func _process(delta):
	levelContainer.rect_position.x = lerp(levelContainer.rect_position.x, scrollAmt, 0.1)

func _on_LeftArrow_pressed():
	if playingUnlockAnim: return;
	if currentLevel == 0: return;
	$BtnSound.play();
	scrollAmt += incrementVal;
	currentLevel -= 1;
	onLevelScrolled();


func _on_RightArrow_pressed():
	if playingUnlockAnim: return;
	if currentLevel >= Data.levelBlocks[Data.currentBlock].end+1 or currentLevel >= Data.data["levelArr"].size()-1: return;
	$BtnSound.play();
	scrollAmt -= incrementVal;
	currentLevel += 1;
	onLevelScrolled()

func scrollToLevel(level, instant=false):
	scrollAmt = -(incrementVal * level) - incrementVal/2 + Global.width/2;
	if (instant): levelContainer.rect_position.x = scrollAmt
	currentLevel = level;
	onLevelScrolled()

func onLevelScrolled():
	for i in range(levels.size()):
		var lvl = levels[i];
		var lvl_thumbnail = levels[i].thumbnail as Control;
		if (i) == currentLevel:
			lvl_thumbnail.self_modulate = Color.white;
			# lvl_thumbnail.rect_position.y = -5;
		else:
			lvl_thumbnail.self_modulate = Color.white.darkened(0.23);
			#lvl_thumbnail.rect_position.y = 0;
func onLevelPressed(levelData):
	if paused: return;
	$BtnSound.play();
	var index = Data.data["levelArr"].find(levelData)
	Data.levelSelected = index;
	#We do -1 because the GameScene only has functionality to load NEXT level
	#And I'm too lazy to change it.
	Data.SetCurrentLevel(index-1);
	get_node("SceneTransition").transition("res://src/scenes/GameScene.tscn")

func togglePaused():
	$PauseMenu.visible = !$PauseMenu.visible;
	$BtnSound.play();
func unlockLevel(levelNumber, scrollDelay = 1.0, explosionDelay = 1.5):
	if levelNumber > levels.size() - 1: return;
	yield(get_tree().create_timer(scrollDelay), "timeout");
	scrollToLevel(levelNumber);
	yield(get_tree().create_timer(explosionDelay), "timeout");
	levels[levelNumber].thumbnail.get_parent().unlock();
func unlockLevels(start, end):
	playingUnlockAnim = true;
	yield(get_tree().create_timer(1.0), "timeout");
	for i in range(start, end):
		unlockLevel(i, 0.1, 0.2);
		yield(get_tree().create_timer(1.5), "timeout");
	scrollToLevel(Data.levelSelected+1);
	yield(get_tree().create_timer(1), "timeout");
	playingUnlockAnim = false;
