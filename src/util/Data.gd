extends Node
var saveDataPath = "user://savegame.save";
var levelDirectory = "res://src/prefabs/Levels"
var data:Dictionary;
var currentLevel:int
var levelOrderResPath = "res://src/LevelOrder.tres";
var levelOrderResource:LevelOrder;
func _ready() -> void:
	levelOrderResource = ResourceLoader.load(levelOrderResPath) as LevelOrder;
func _buildData():
	print("building data");
	self.data.levelArr = [];
	self.data.shownComplete = false;
	for levelScene in levelOrderResource.levels:
		var levelInst = levelScene.instance();
		var levelData = levelInst.get_node("Metadata") as Metadata;
		var object = {
			levelName = levelData.levelName,
			levelPaths = levelData.minPathsToSolve,
			complete = false,
			completeOnPar = false
		}
		self.data.levelArr.append(object);

func SaveGame() -> void:
	var file = File.new();
	file.open(saveDataPath, File.WRITE);
	file.store_line(to_json(data));
	file.close();

func LoadGame() -> void:
	print("loading game");
	var file = File.new()
	var error = file.open(saveDataPath, File.READ);
	if error != OK:
		_buildData();
		return;
	var fileTxt = file.get_as_text();
	var jsonError = validate_json(fileTxt);
	assert(jsonError.empty(), str("Invalid JSON ", jsonError))
	var jsonResult = parse_json(fileTxt);
	if typeof(jsonResult) != TYPE_DICTIONARY:
		_buildData();
		return;
	data = jsonResult;

func DeleteSave() -> void:
	var dir = Directory.new();
	dir.remove(saveDataPath);
	
func SetCurrentLevel(index):
	currentLevel = index;

func OnLevelComplete(numPaths):
	var metPar = numPaths <= data.levelArr[currentLevel].levelPaths;
	data.levelArr[currentLevel].complete = true;
	data.levelArr[currentLevel].completeOnPar = metPar or data.levelArr[currentLevel].completeOnPar;

func GetCurrentLevelScene():
	return levelOrderResource.levels[currentLevel]

# This advances to the next level
func GetNextLevelScene():
		currentLevel+=1;
		print(currentLevel);
		if CurrentLevelIsLast():
			return false;
		return levelOrderResource.levels[currentLevel]

func CurrentLevelIsLast():
	return currentLevel >= levelOrderResource.levels.size()

func SetShownCompleteScreen():
	self.data.shownComplete = true;
	SaveGame();