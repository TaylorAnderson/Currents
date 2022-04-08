extends Node
var saveDataPath = "user://savegame.save";
var levelDirectory = "res://src/prefabs/Levels"
var data:Dictionary;
var currentLevel:int
var levelOrderResPath = "res://src/LevelOrder.tres";
var levelOrderResource:LevelOrder;
var thumbnailPath = "res://assets/thumbnails/"
func _ready() -> void:
	levelOrderResource = load(levelOrderResPath);
	DeleteSave();
	LoadGame();
func _buildData():
	self.data.musicVol = 0.5;
	self.data.soundVol = 0.5;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(data.musicVol));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(data.soundVol));
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

	var file = File.new()
	var error = file.open(saveDataPath, File.READ);
	if error != OK:
		_buildData();
		return;
	var fileTxt = file.get_as_text();
	print(fileTxt);
	var jsonError = validate_json(fileTxt);
	assert(jsonError.empty(), str("Invalid JSON ", jsonError))
	var jsonResult = parse_json(fileTxt);
	if typeof(jsonResult) != TYPE_DICTIONARY:
		_buildData();
		return;
	if not jsonResult.get("levelArr"):
		_buildData();
		return;
	self.data = jsonResult;
	print("data music vol" + str(data.musicVol))
	print("data sound vol" + str(data.soundVol))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(data.musicVol));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(data.soundVol));

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
		return levelOrderResource.levels[currentLevel]

func CurrentLevelIsLast():
	return currentLevel >= levelOrderResource.levels.size() - 1

func SetShownCompleteScreen():
	self.data.shownComplete = true;
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
	print("sound vol " + str(vol))
	data.soundVol = vol;
	
func SetMusicVolume(vol):
	print("music vol " + str(vol))
	data.musicVol = vol;
	
