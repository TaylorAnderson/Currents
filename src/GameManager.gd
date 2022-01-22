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
onready var levelManager = get_node("/root/GameScene/LevelManager");
var permanentPathRootPath:String = "res://src/prefabs/Levels/Permanent Paths/"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	levelCompleteMenu = get_node(levelCompleteMenuPath) as Node2D;
	playBtn = get_node(playBtnPath) as TextureButton
	editBtn = get_node(editBtnPath) as TextureButton
	nextLevelBtn = get_node(nextLevelBtnPath) as TextureButton;
	
	currents = get_node(currentsPath);
	winds = get_node(windsPath);
	
	permCurrents = get_node(permCurrentsPath);
	permWinds = get_node(permWindPath);
	
	goToNextLevel();
func _process(delta: float) -> void:
	switchDelay -= delta;
	if (Input.is_key_pressed(KEY_SPACE) and switchDelay < 0):
		onButtonPressed();
	nextLevelBtn.visible = levelComplete && state == States.EDIT;

	
func onButtonPressed():
	switchDelay = 0.7
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
		winds.disabled = true;
		currents.disabled = true;

		for isle in islands:
			isle.onPlayModeStart();
	
	if state == States.EDIT:
		levelCompleteMenu.visible = false;
		winds.disabled = false;
		currents.disabled = false;
		for ship in ships:
			if ship.get_parent():
				ship.get_parent().remove_child(ship);
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
		showLevelCompleteMenu();
		
func showLevelCompleteMenu():
	levelCompleteMenu.visible = true;

func goToNextLevel():
	currents.clear();
	winds.clear();
	permCurrents.clear();
	permWinds.clear();
	levelComplete = false;
	levelManager.loadNextLevel();
	islands = levelManager.currentLevel.get_node("Islands").get_children()
	obstacles = levelManager.currentLevel.get_node("Obstacles").get_children();

	var path = permanentPathRootPath + (levelManager.currentLevel.name)
	permCurrents.loadJson(path);
	permWinds.loadJson(path);

	if (state == States.PLAY):
		state = States.EDIT;
		changeState();

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_NextLevelBtn_pressed() -> void:
	goToNextLevel();
	levelCompleteMenu.visible = false;



func onSavePressed() -> void:
	saveJson();

func _on_DeleteBtn_pressed() -> void:
	deleteJson();


func saveJson():
	var obj = {}
	obj["current"] = currents.getJson();
	obj["wind"] = winds.getJson();
	var jsonToSave = to_json(obj);
	var path = permanentPathRootPath + (levelManager.currentLevel as Node2D).name
	var file = File.new();
	file.open(path, File.WRITE);
	file.store_string(jsonToSave);
	file.close();
func deleteJson():
	var dir = Directory.new();
	dir.remove(permanentPathRootPath + (levelManager.currentLevel as Node2D).name)
