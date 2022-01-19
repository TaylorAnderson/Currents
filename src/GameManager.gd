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

export(NodePath) var currentsPath
export(NodePath) var windsPath

var currents
var winds

var playBtn:TextureButton;
var editBtn:TextureButton;
var currentButton:TextureButton;
var state = States.EDIT
var allPoints = [];
export(Array, NodePath) var islandPaths = [];
var islands = [];
var ships = [];
var switchDelay = 0;
var obstacles = [];
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playBtn = get_node(playBtnPath) as TextureButton
	editBtn = get_node(editBtnPath) as TextureButton
	
	currents = get_node(currentsPath);
	winds = get_node(windsPath);
	
	for path in islandPaths:
		islands.append(get_node(path))
	
	var test:Vector2;
func _process(delta: float) -> void:
	switchDelay -= delta;
	if (Input.is_key_pressed(KEY_SPACE) and switchDelay < 0):
		onButtonPressed();

	
func onButtonPressed():
	switchDelay = 1
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
		winds.disabled = true;
		currents.disabled = true;
		
		for isle in islands:
			# this is temp: later we'd want to turn on ship spawning instead of just direct spawn
			isle.onPlayModeStart();
	if state == States.EDIT:
		winds.disabled = false;
		currents.disabled = false;
		for ship in ships:
			if ship.get_parent():
				ship.get_parent().remove_child(ship);
		ships = [];
		obstacles = [];
		for isle in islands:
			isle.onEditModeStart();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
