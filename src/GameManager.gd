extends Node2D
class_name GameManager

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum States {
	EDIT,
	PLAY,
	INTRO,
}

export(NodePath) onready var currents = get_node(currents);
export(NodePath) onready var winds = get_node(winds)

export(NodePath) onready var permCurrents = get_node(permCurrents);
export(NodePath) onready var permWinds = get_node(permWinds)

export(NodePath) onready var playBtn = get_node(playBtn) as TextureButton
export(NodePath) onready var editBtn = get_node(editBtn) as TextureButton
export(NodePath) onready var nextLevelBtn = get_node(nextLevelBtn) as TextureButton
export(NodePath) onready var pauseBtn = get_node(pauseBtn) as TextureButton
export(NodePath) onready var tutorialBtn = get_node(tutorialBtn) as TextureButton

export(NodePath) onready var defaultButtons = get_node(defaultButtons) as Node2D
export(NodePath) onready var defaultUI = get_node(defaultUI) as Node2D

export(NodePath) onready var pathToggle = get_node(pathToggle) as PathToggle;

export(NodePath) onready var levelCompleteMenu = get_node(levelCompleteMenu)
export(NodePath) onready var gameCompleteMenu = get_node(gameCompleteMenu);
export(NodePath) onready var settingsMenu = get_node(settingsMenu);
export(NodePath) onready var creditsMenu = get_node(creditsMenu);
export(NodePath) onready var pauseMenu = get_node(pauseMenu);
export(NodePath) onready var gameIntro = get_node(gameIntro);

export(NodePath) onready var levelManager = get_node(levelManager);

export(NodePath) onready var titleTxt = get_node(titleTxt) as RichTextLabel
export(NodePath) onready var minPathsTxt = get_node(minPathsTxt) as RichTextLabel

export(NodePath) onready var tutorialWindow = get_node(tutorialWindow)

export(NodePath) onready var tutorialPrompt = get_node(tutorialPrompt) as RichTextLabel

onready var sndButtonClick = get_node("ButtonClickSound") as AudioStreamPlayer

var currentButton:TextureButton;

var state = States.INTRO
var allPoints = [];
var islands = [];
var obstacles = [];
var ships = [];
var switchDelay = 0;
var levelComplete = false;

var showMinPaths = false;

var permanentPathRootPath:String = "res://PermanentPaths/"


var activePath # can be currents or winds

var paused = false;
# signals

signal onStateChanged(new_state)

func _ready() -> void:
	Data.DeleteSave();
	defaultButtons.visible = false;
	defaultUI.visible = false;
	gameIntro.visible = true;
	onPathToggled(); # to set current path before we start
	changeState(States.INTRO)

func _process(delta: float) -> void:
	for island in islands:
		island.get_node("Btn").visible = not activePath.isDrawing;

	switchDelay -= delta;
	if (Input.is_key_pressed(KEY_SPACE) and switchDelay < 0):
		onButtonPressed();
	nextLevelBtn.visible = levelComplete && state == States.EDIT;

	
func onButtonPressed():
	switchDelay = 0.7
	sndButtonClick.play();
	if (state == States.EDIT):
		changeState(States.PLAY);
	else:
		changeState(States.EDIT);

func changeState(newState):
	state = newState;
	if state == States.PLAY:
		editBtn.visible = false;
		playBtn.visible = true;
		currentButton = playBtn;
		allPoints = [];
		allPoints.append_array(currents.getPoints());
		allPoints.append_array(winds.getPoints());
		allPoints.append_array(permCurrents.getPoints());
		allPoints.append_array(permWinds.getPoints())
		activePath.disabled = true;

		for isle in islands:
			isle.onPlayModeStart();
	
	if state == States.EDIT:
		playBtn.visible = false;
		editBtn.visible = true;
		currentButton = editBtn;
		gameCompleteMenu.visible = false;
		levelCompleteMenu.visible = false;
		activePath.disabled = false;
		for ship in ships:
			if is_instance_valid(ship):
				ship.queue_free();
		ships = [];
		for isle in islands:
			isle.onEditModeStart();
	
	if state == States.INTRO:
		defaultButtons.visible = false;
func checkLevelComplete():
	var allIslandsComplete = true;
	for isle in islands:
		if not isle.completed:
			allIslandsComplete = false;
	if allIslandsComplete:
		levelComplete = true;
		showLevelCompleteMenu();

func showLevelCompleteMenu():
	levelCompleteMenu.visible = true;
	if (Data.CurrentLevelIsLast()):
		levelCompleteMenu.get_node("nextLevelBtn").visible = false;

func goToNextLevel():
	currents.clear();
	winds.clear();
	permCurrents.clear();
	permWinds.clear();
	levelComplete = false;
	levelManager.loadNextLevel();
	Data.SaveGame();
	processLevel();
	if (state == States.PLAY):
		onButtonPressed();
func processLevel():
	var metadata = levelManager.currentLevel.get_node("Metadata") as Metadata
	titleTxt.bbcode_text = "[center]" + metadata.levelName + "[/center]"
	minPathsTxt.bbcode_text = "[center]Minimum paths: " + str(metadata.minPathsToSolve) + "[/center]";
	tutorialWindow.get_node("Description/Txt").bbcode_text="[center]" + str(metadata.tutorialHint) + "[/center]"
	if (metadata.tutorialHint.length() == 0):
		tutorialBtn.visible = false;
	else:
		tutorialBtn.visible = true;
	islands = levelManager.currentLevel.get_node("Islands").get_children()
	obstacles = levelManager.currentLevel.get_node("Obstacles").get_children();
	var path = permanentPathRootPath + (levelManager.currentLevel.name) + ".json";
	permCurrents.loadJson(path);
	permWinds.loadJson(path);

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
	Data.LoadGame();
	goToNextLevel();
	setupUI();
	changeState(States.EDIT);
	gameIntro.visible = false;
	
func setupUI():
	defaultButtons.visible = true;
	defaultUI.visible = true;

func onPausePressed() -> void:
	togglePause();
	sndButtonClick.play();
	pauseMenu.visible = paused;

func onUnpausePressed() -> void:
	sndButtonClick.play();
	pauseMenu.visible = false;
	togglePause();

func togglePause(forcePause = null):
	paused = forcePause or !paused;
	currents.disabled = paused or state != States.EDIT
	winds.disabled = paused or state != States.EDIT
	
	defaultButtons.visible = not paused;
	# defaultUI.visible = not paused;
	
	if paused:
		settingsMenu.visible = false;
		creditsMenu.visible = false;


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

func onTutorialBtnPressed() -> void:
	sndButtonClick.play();
	tutorialWindow.visible = true;
	tutorialPrompt.visible = false;
	togglePause(true);
	pass # Replace with function body.


func onTutWindowClose() -> void:
	sndButtonClick.play();
	togglePause(false);
	tutorialWindow.visible = false;
