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
# Called when the node enters the scene tree for the first time.
func _ready():
	if Data.currentBlock < Data.blockToUnlock:
		Data.currentBlock = Data.blockToUnlock;
		var blockToUnlock = Data.levelBlocks[Data.blockToUnlock]
		unlockLevels(blockToUnlock.start, blockToUnlock.end)
	#MusicFader.fade_in(get_node("Music"), -10)
	var postcardWidth = 0;
	for i in range(Data.data.levelArr.size()):
		var levelData = Data.data.levelArr[i]
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
		
		var rowCompleteIcon = th.get_node("Inner/Content/Icons/CompleteIcon/Icon");
		rowCompleteIcon.visible = levelData.complete;

		var rowCompleteOnParIcon = th.get_node("Inner/Content/Icons/PathsCompleteIcon/Icon");
		rowCompleteOnParIcon.visible = levelData.completeOnPar;
		
		var lock = th.get_node("Lock") as Node2D
		lock.visible = Data.levelsUnlocked <= i
		# if this level is at the start of the next block
		if (i == Data.levelBlocks[Data.currentBlock].end):
			th.get_node("Text").visible = true;
			var levelTxt = th.get_node("Text/HBoxContainer/Label")
			var levelBlockProgress = Data.CheckLevelBlockProgress();
			levelTxt.text = str(levelBlockProgress.current) + "/" + str(levelBlockProgress.total);
		var thumbnailImage = Image.new();
		var err = thumbnailImage.load(Data.thumbnailPath + levelData.levelName + ".png");
		if err == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(thumbnailImage, 0)
			var thumbnailTex = th.get_node("Tex") as TextureRect
			thumbnailTex.texture = texture;
	
	levelContainer.rect_position.x = Global.width/2 - postcardWidth/2;
	scrollToLevel(Data.levelSelected);
func _process(delta):
	levelContainer.rect_position.x = lerp(levelContainer.rect_position.x, scrollAmt, 0.1)

func _on_LeftArrow_pressed():
	if currentLevel == 0: return;
	$BtnSound.play();
	scrollAmt += incrementVal;
	currentLevel -= 1;
	onLevelScrolled();


func _on_RightArrow_pressed():
	if (currentLevel >= Data.levelBlocks[Data.currentBlock].end): return;
	$BtnSound.play();
	scrollAmt -= incrementVal;
	currentLevel += 1;
	onLevelScrolled()
func scrollToLevel(level):
	
	scrollAmt = -(incrementVal * level) - incrementVal/2 + Global.width/2;
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
	var index = Data.data.levelArr.find(levelData)
	Data.levelSelected = index;
	#We do -1 because the GameScene only has functionality to load NEXT level
	#And I'm too lazy to change it.
	Data.SetCurrentLevel(index-1);
	get_node("SceneTransition").transition("res://src/scenes/GameScene.tscn")

func togglePaused():
	$PauseMenu.visible = !$PauseMenu.visible;
	$BtnSound.play();
func unlockLevel(levelNumber, scrollDelay = 1.0, explosionDelay = 1.5):
	yield(get_tree().create_timer(scrollDelay), "timeout");
	scrollToLevel(levelNumber);
	yield(get_tree().create_timer(explosionDelay), "timeout");
	levels[levelNumber].thumbnail.get_parent().unlock();
func unlockLevels(start, end):
	yield(get_tree().create_timer(1.0), "timeout");
	for i in range(start, end):
		unlockLevel(i, 0.1, 0.2);
		yield(get_tree().create_timer(1.5), "timeout");
	scrollToLevel(Data.levelSelected);
