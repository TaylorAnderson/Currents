extends Node
var saveDataPath = "user://savegame.save";
var levelDirectory = "res://src/prefabs/Levels"
var data:Dictionary;
var currentLevel:int
var levelOrderResPath = "res://src/LevelOrder.tres";
var levelOrderResource:LevelOrder;
var thumbnailPath = "res://assets/thumbnails/"
var levelsUnlocked = 1;
var currentBlockStars = 0;
var levelBlocks = [
	{start=0, end=0},
	{start= 1, end= 1},
	{start= 2, end= 5},
	{start= 6, end= 9},
	{start=10, end=13},
	{start=14, end=17},
	{start=17, end=18}
]
var path_ghosts = false;
var currentBlock = 0;
var lastBlockSinceLevelSelect = 0;
var levelSelected = 0;
var isOnStandalone = OS.has_feature("standalone");
func _ready() -> void:
	levelOrderResource = load(levelOrderResPath);
	LoadGame();
func _buildData():
	self.data["musicVol"] = 0.5;
	self.data["soundVol"] = 0.5;
	self.data["path_ghosts"] = false;
	self.data["currentBlock"] = 0;
	self.data["lastBlockSinceLevelSelect"] = 0;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(data["musicVol"]));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(data["soundVol"]));
	self.data["levelArr"] = [];
	self.data["shownComplete"] = false;
	for levelScene in levelOrderResource.levels:
		var levelInst = levelScene.instance();
		var levelData = levelInst.get_node("Metadata") as Metadata;
		var object = {
			levelName = levelData.levelName,
			levelPaths = levelData.minPathsToSolve,
			complete = false,
			completeOnPar = false,
			completeUnderPar = false,
			pathsUsed = 0
		}
		self.data["levelArr"].append(object);

func SaveGame() -> void:
	data["currentBlock"] = currentBlock;
	data["path_ghosts"] = path_ghosts;
	self.data["lastBlockSinceLevelSelect"] = lastBlockSinceLevelSelect;
	var file = File.new();
	file.open(saveDataPath, File.WRITE);
	file.store_line(var2str(data));
	file.close();

func LoadGame() -> void:
	var file = File.new()
	var error = file.open(saveDataPath, File.READ);
	if error != OK:
		_buildData();
		return;
	var fileTxt = file.get_as_text();
	var result = str2var(fileTxt);
	if typeof(result) != TYPE_DICTIONARY:
		_buildData();
		return;
	if not result.get("levelArr"):
		_buildData();
		return;
	self.data = result;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(data["musicVol"]));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(data["soundVol"]));
	currentBlock = data["currentBlock"];
	if (data.get("path_ghosts")):
		path_ghosts = data["path_ghosts"];
	else: path_ghosts = false;
	if data.get("lastBlockSinceLevelSelect"):
		lastBlockSinceLevelSelect = data["lastBlockSinceLevelSelect"];
	else: lastBlockSinceLevelSelect = currentBlock;
	Data.CheckLevelBlocks();

func DeleteSave() -> void:
	var dir = Directory.new();
	dir.remove(saveDataPath);
	
func SetCurrentLevel(index):
	currentLevel = index;

func OnLevelComplete(numPaths):
	var metPar = numPaths <= data["levelArr"][currentLevel].levelPaths;
	data["levelArr"][currentLevel].pathsUsed = numPaths;
	data["levelArr"][currentLevel].complete = true;
	data["levelArr"][currentLevel].completeOnPar = metPar or data["levelArr"][currentLevel].completeOnPar;
	data["levelArr"][currentLevel]["completeUnderPar"] = numPaths < data["levelArr"][currentLevel]["levelPaths"] or data["levelArr"][currentLevel]["completeUnderPar"]
	print(data["levelArr"][currentLevel]["completeUnderPar"])
	CheckLevelBlocks()

func GetCurrentLevelScene():
	return levelOrderResource.levels[currentLevel]

func CheckLevelBlocks():
	var blockProgress = Data.CheckLevelBlockProgress();
	if (blockProgress.current >= blockProgress.total and currentBlock < levelBlocks.size()-1):
		currentBlock += 1;

# This advances to the next level
func GetNextLevelScene():
		currentLevel+=1;
		return levelOrderResource.levels[currentLevel]

func CurrentLevelIsLast():
	return currentLevel >= levelOrderResource.levels.size() - 1

func SetShownCompleteScreen():
	self.data["shownComplete"] = true;
	SaveGame();

func SaveThumbnails(parent):
	for i in range(Data.levelOrderResource.levels.size()):
		var thumbnail = Data.levelOrderResource.levels[i].instance() as Node2D
		thumbnail.position.x = 33;
		thumbnail.position.y = 18;
		parent.add_child(thumbnail);
		thumbnail.z_index = 250;
		yield(VisualServer, "frame_post_draw");
		SaveLevelThumbnail(thumbnail);
		parent.remove_child(thumbnail);	
	
		
func SaveLevelThumbnail(levelInstance):
	print("saving level thumbnail")
	var thumbnail_image = get_tree().get_root().get_texture().get_data() as Image;
	thumbnail_image.flip_y();
	thumbnail_image.save_png(thumbnailPath + (levelInstance.get_node("Metadata") as Metadata).levelName + ".png")
	
func SetSoundVolume(vol):
	data["soundVol"] = vol;
	
func SetMusicVolume(vol):
	data["musicVol"] = vol;

func CheckLevelBlockProgress():
	print(currentBlock);
	var currentLevelBlock = levelBlocks[currentBlock];
	var total = (((currentLevelBlock.end+1)*2))
	if (currentBlock == 0 or currentBlock == 1):
		total = currentBlock+1;
	return {total = total, current = GetStarsInCurrentLevelBlock()}
func GetStarsInCurrentLevelBlock():
	var stars = 0;
	for i in range(0, levelBlocks[currentBlock].end+1):
		var lvlData = data["levelArr"][i];
		if lvlData["complete"]: stars += 1;

		if (i != 0 and i != 1):
			if lvlData["completeOnPar"]: stars += 1;
			if lvlData["completeUnderPar"]: stars += 1;

	return stars;
		
