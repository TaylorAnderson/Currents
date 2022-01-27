extends Node2D
class_name GameManager

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum States {
	EDIT,
	PLAY
}
export(NodePath) var playBtnPath;
export(NodePath) var editBtnPath;
export(NodePath) var nextLevelBtnPath;

export(NodePath) var currentsPath
export(NodePath) var windsPath

export(NodePath) var permCurrentsPath;
export(NodePath) var permWindPath;

var currents
var winds

var permCurrents;
var permWinds;

var playBtn:TextureButton;
var editBtn:TextureButton;
var currentButton:TextureButton;

var nextLevelBtn:TextureButton;
var state = States.EDIT
var allPoints = [];
var islands = [];
var obstacles = [];
var ships = [];
var switchDelay = 0;
var levelComplete = false;
export(NodePath) var levelCompleteMenuPath;
var levelCompleteMenu:Node2D

var showMinPaths = false;

onready var gameCompleteMenu = get_node("/root/GameScene/gameComplete");
onready var levelManager = get_node("/root/GameScene/LevelManager");

onready var titleTxt:RichTextLabel = get_node("/root/GameScene/CanvasLayer/Title") as RichTextLabel
onready var minPathsTxt:RichTextLabel = get_node("/root/GameScene/CanvasLayer/MinPaths") as RichTextLabel
var permanentPathRootPath:String = "res://PermanentPaths/"

onready var gameIntro = get_node("/root/GameScene/gameIntro");

onready var pathTut = get_node("/root/GameScene/PathTut");

onready var sndButtonClick = get_node("ButtonClickSound") as AudioStreamPlayer

onready var pauseScreen = get_node("/root/GameScene/pauseMenu");

onready var pauseButton = get_node("/root/GameScene/buttons/PauseButton");

var paused = false;
var saveDataPath = "user://save.json";

onready var settingsMenu = get_node("/root/GameScene/pauseMenu/settings")
onready var creditsMenu = get_node("/root/GameScene/pauseMenu/credits");

onready var pathToggle:PathToggle = get_node("/root/GameScene/buttons/PathToggle");
var activePath # can be currents or winds

func _ready() -> void:
	deleteSave();
	levelCompleteMenu = get_node(levelCompleteMenuPath) as Node2D;
	playBtn = get_node(playBtnPath) as TextureButton
	editBtn = get_node(editBtnPath) as TextureButton
	nextLevelBtn = get_node(nextLevelBtnPath) as TextureButton;
	
	currents = get_node(currentsPath);
	winds = get_node(windsPath);
	
	permCurrents = get_node(permCurrentsPath);
	permWinds = get_node(permWindPath);
	
	onPathToggled();

func _process(delta: float) -> void:
	if currents.finishedOnePath or winds.finishedOnePath:
		pathTut.visible = false;
		titleTxt.visible = true;

	switchDelay -= delta;
	if (Input.is_key_pressed(KEY_SPACE) and switchDelay < 0):
		onButtonPressed();
	nextLevelBtn.visible = levelComplete && state == States.EDIT;

	
func onButtonPressed():
	switchDelay = 0.7

	sndButtonClick.play();
	if (state == States.EDIT):
		state = States.PLAY
		# so now we're in play state, so we shld show edit btn
		playBtn.visible = false;
		editBtn.visible = true;
		currentButton = editBtn;
	else:
		state = States.EDIT
		# so now we're in edit state, so we shld show play btn
		editBtn.visible = false;
		playBtn.visible = true;
		currentButton = playBtn;
	changeState();

func changeState():
	if state == States.PLAY:
		allPoints = [];
		allPoints.append_array(currents.getPoints());
		allPoints.append_array(winds.getPoints());
		allPoints.append_array(permCurrents.getPoints());
		allPoints.append_array(permWinds.getPoints())
		activePath.disabled = true;

		for isle in islands:
			isle.onPlayModeStart();
	
	if state == States.EDIT:
		gameCompleteMenu.visible = false;
		levelCompleteMenu.visible = false;
		activePath.disabled = false;
		for ship in ships:
			if is_instance_valid(ship):
				ship.queue_free();
		ships = [];
		for isle in islands:
			isle.onEditModeStart();

func checkLevelComplete():
	var allIslandsComplete = true;
	for isle in islands:
		if not isle.completed:
			allIslandsComplete = false;
	if allIslandsComplete:
		levelComplete = true;
		if levelManager.doneAllLevels():
			showGameCompleteMenu();
		else:
			showLevelCompleteMenu();
		
func showGameCompleteMenu():
	gameCompleteMenu.visible = true;

func showLevelCompleteMenu():
	levelCompleteMenu.visible = true;

func goToNextLevel():
	currents.clear();
	winds.clear();
	permCurrents.clear();
	permWinds.clear();
	levelComplete = false;
	levelManager.loadNextLevel();
	saveGame();
	var metadata = levelManager.currentLevel.get_node("Metadata")
	titleTxt.bbcode_text = "[center]" + metadata.levelName + "[/center]"
	minPathsTxt.bbcode_text = "[center]Minimum paths: " + str(metadata.minPathsToSolve) + "[/center]";
	islands = levelManager.currentLevel.get_node("Islands").get_children()
	obstacles = levelManager.currentLevel.get_node("Obstacles").get_children();
	var path = permanentPathRootPath + (levelManager.currentLevel.name) + ".json";
	permCurrents.loadJson(path);
	permWinds.loadJson(path);
	if (state == States.PLAY):
		onButtonPressed();

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_NextLevelBtn_pressed() -> void:
	sndButtonClick.play();
	goToNextLevel();
	levelCompleteMenu.visible = false;


func onSavePressed() -> void:
	sndButtonClick.play();
	savePathJson();

func _on_DeleteBtn_pressed() -> void:
	sndButtonClick.play();
	deletePathJson();


func savePathJson():
	var obj = {}
	obj["current"] = currents.getJson();
	obj["wind"] = winds.getJson();
	var jsonToSave = to_json(obj);
	var path = permanentPathRootPath + (levelManager.currentLevel as Node2D).name + ".json";
	var file = File.new();
	file.open(path, File.WRITE);
	file.store_line(jsonToSave);
	file.close();

func deletePathJson():
	var dir = Directory.new();
	dir.remove(permanentPathRootPath + (levelManager.currentLevel as Node2D).name + ".json")

func _on_restartBtn_pressed() -> void:
	levelManager.levelIndex = -1;
	goToNextLevel();

func _on_exitBtn_pressed() -> void:
	get_tree().quit();
	
func startGame() -> void:
	pathTut.visible = true;
	loadGame();
	goToNextLevel();
	changeState();
	pauseButton.visible = true;
	playBtn.visible = true;
	gameIntro.visible = false;
	
	
func quickStartGame():
	pathTut.visible = false;
	titleTxt.visible = true;
	playBtn.visible = true;
	pauseButton.visible = true;
func saveGame() -> void:
	var file = File.new();
	file.open(saveDataPath, File.WRITE);
	file.store_line(str(levelManager.levelIndex));
	file.close();
func loadGame() -> void:
	var file = File.new()
	var error = file.open(saveDataPath, File.READ);
	if not error:
		quickStartGame();
		levelManager.levelIndex = int(file.get_as_text()) - 1;
		file.close()

func deleteSave() -> void:
	var dir = Directory.new();
	dir.remove(saveDataPath);


func onPausePressed() -> void:
	togglePause();
	
func onSettingsPressed() -> void:
	settingsMenu.visible = !settingsMenu.visible;

func onCreditsPressed() -> void:
	creditsMenu.visible = !creditsMenu.visible;


func onUnpausePressed() -> void:
	togglePause();

func togglePause():
	paused = !paused;
	pauseScreen.visible = paused;
	currents.disabled = paused or state == States.PLAY
	winds.disabled = paused or state == States.PLAY;
	
	if paused:
		settingsMenu.visible = false;
		creditsMenu.visible = false;

func onSoundSliderValueChange(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), value)

func onPathToggled() -> void:
	if pathToggle.pathIsCurrent():
		activePath = currents;
		currents.isActive = true;
		winds.isActive = false;
	if pathToggle.pathIsWind():
		activePath = winds;
		currents.isActive = false;
		winds.isActive = true;
	if (state == States.EDIT):
		activePath.disabled = false;
	else:
		activePath.disabled = true;
