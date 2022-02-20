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

onready var sndButtonClick = get_node("BtnSound") as AudioStreamPlayer
onready var sndPlayButtonBlip = get_node("PlayModeBlip") as AudioStreamPlayer
export(NodePath) onready var bgAmbience = get_node(bgAmbience)
var currentButton:TextureButton;

var state = States.INTRO
var allPoints = [];
var islands = [];
var obstacles = [];
var ships = [];
var pirateSpawners = [];
var switchDelay = 0;
var levelComplete = false;

var showMinPaths = false;

var permanentPathRootPath:String = "res://PermanentPaths/"

var activePath # can be currents or winds

var paused = false;
# signals

signal onStateChanged(new_state)

var startedGame = false;

var shownLevelComplete = false;
func _ready() -> void:
	bgAmbience.fadeIn(-5, 0.3);
	defaultButtons.visible = false;
	defaultUI.visible = false;
	gameIntro.visible = true;
	onPathToggled(); # to set current path before we start

func _process(delta: float) -> void:
	if not startedGame: 
		startedGame = true;
		startGame();
	for island in islands:
		island.get_node("Btn").visible = not activePath.isDrawing;

	switchDelay -= delta;
	if (Input.is_key_pressed(KEY_SPACE) and switchDelay < 0):
		onButtonPressed();
	nextLevelBtn.visible = levelComplete && state == States.EDIT;

	
func onButtonPressed(playSound = true):
	switchDelay = 0.7
	if playSound:
		sndButtonClick.play();
	if (state == States.EDIT):
		if (playSound):
			$Tween.interpolate_property(playBtn, "rect_scale", Vector2.ONE, Vector2.ONE * 1.2, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.interpolate_property(playBtn, "rect_scale", Vector2.ONE * 1.2, Vector2.ONE, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT, 0.1)
			$Tween.start();
		changeState(States.PLAY);
	else:
		if (playSound):
			$Tween.interpolate_property(editBtn, "rect_scale", Vector2.ONE, Vector2.ONE * 1.2, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
			$Tween.interpolate_property(editBtn, "rect_scale", Vector2.ONE * 1.2, Vector2.ONE, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT, 0.1)
			$Tween.start();
		changeState(States.EDIT);

func changeState(newState):
	state = newState;
	if state == States.PLAY:
		sndPlayButtonBlip.play();
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
		for spawner in pirateSpawners:
			spawner.spawn(pirateSpawners.find(spawner) == 0);
	if state == States.EDIT:
		playBtn.visible = false;
		editBtn.visible = true;
		currentButton = editBtn;
		gameCompleteMenu.visible = false;
		levelCompleteMenu.hide();
		activePath.disabled = false;
		for ship in ships:
			if is_instance_valid(ship):
				ship.queue_free();
		ships = [];
		
		for obst in obstacles:
			if obst is Treasure:
				obst.respawn();

		for isle in islands:
			isle.onEditModeStart();
		for spawner in pirateSpawners:
			spawner.enterEditMode();
	if state == States.INTRO:
		defaultButtons.visible = false;

func checkLevelComplete():
	var allIslandsComplete = true;
	for isle in islands:
		if not isle.completed:
			allIslandsComplete = false;
	if allIslandsComplete:
		var allLevelsComplete = true;
		for level in Data.data.levelArr:
			if (not level.complete):
				allLevelsComplete = false;
		if allLevelsComplete and not Data.data.shownComplete:
			Data.SetShownCompleteScreen();
			get_node("/root/GameScene/UILayer/SceneTransition").transition("res://src/scenes/GameCompleteScene.tscn")
		else:
			levelComplete = true;
			showLevelCompleteMenu();

func showLevelCompleteMenu():
	if (shownLevelComplete): return;
	shownLevelComplete = true;
	levelCompleteMenu.show();
	Data.OnLevelComplete(currents.paths.size() + winds.paths.size())
	$LevelCompleteSnd.play();
	if (Data.CurrentLevelIsLast()):
		levelCompleteMenu.get_node("nextLevelBtn").visible = false;

func goToNextLevel():
	currents.clear();
	winds.clear();
	permCurrents.clear();
	permWinds.clear();
	levelComplete = false;
	shownLevelComplete = false;
	levelManager.loadNextLevel();
	Data.SaveGame();
	processLevel();
	if (state == States.PLAY):
		onButtonPressed(false);

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
	for ob in obstacles:
		if ob is PirateSpawner:
			pirateSpawners.append(ob);
	var path = permanentPathRootPath + (levelManager.currentLevel.name) + ".json";
	permCurrents.loadJson(path);
	permWinds.loadJson(path);

func _on_NextLevelBtn_pressed() -> void:
	goToNextLevel();
	levelCompleteMenu.hide();


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
	goToNextLevel();
	setupUI();
	changeState(States.EDIT);
	if (Data.currentLevel == 0):
		tutorialPrompt.visible = true;
	gameIntro.visible = false;
	
func setupUI():
	defaultButtons.visible = true;
	defaultUI.visible = true;

func togglePause(forcePause = null):
	$BtnSound.play();
	paused = forcePause or !paused;
	currents.disabled = paused or state != States.EDIT
	winds.disabled = paused or state != States.EDIT
	# defaultUI.visible = not paused;
	
	if paused:
		settingsMenu.visible = false;
		creditsMenu.visible = false;


func onPathToggled(toggledByHand = false) -> void:
	if toggledByHand:
		$BtnSound.play()
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
	tutorialWindow.visible = true;
	tutorialPrompt.visible = false;
	togglePause(true);
	pass # Replace with function body.


func onTutWindowClose() -> void:
	sndButtonClick.play();
	togglePause(false);
	tutorialWindow.visible = false;

func onLevelSelectBtnPressed() -> void:
	get_node("/root/GameScene/UILayer/SceneTransition").transition("res://src/scenes/LevelSelectScene.tscn")


func pauseButtonPressed() -> void:
	$BtnSound.play();
	pauseMenu.visible = true;
	togglePause(true);
	
func _input(event: InputEvent) -> void:
	if event.is_action_released("Grab Thumbnails"):
		getLevelThumbnail();
func getLevelThumbnail():
	defaultButtons.hide();
	defaultUI.hide();
	yield(VisualServer, "frame_post_draw")
	defaultButtons.show();
	defaultUI.show();
	Data.SaveLevelThumbnail(levelManager.currentLevel);
	pass;
