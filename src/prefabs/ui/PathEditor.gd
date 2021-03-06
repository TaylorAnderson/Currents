extends Node2D
class_name PathEditor

class PathPoint: 
	var vec:Vector2
	var pos:Vector2
	var radius:int
	var strength:float

var isDrawing = false;
var boundary = 80;
var paths:Array = []; 
var currentPath:Array = [];
var lastPoint:Vector2 = Vector2.ZERO;
var currentPoint:Vector2 = Vector2.ZERO;
var disabled = true;

export(String, "current", "wind") var type:String

export(int) var radius = 0;
export(Color) var color = Color.red;
export(Texture) var arrowTex:Texture;
export(int) var arrowInterval = 5;
export(int) var mouseButton = 1;

var padRadius = 0;

export(float) var strength = 1;

export(float) var ambienceVolume = -10
export(float) var ambienceFadeInDuration = 0.1
export(float) var ambienceFadeOutDuration = 0.3
export(AudioStream) var ambienceTrack;

onready var currentSnd = get_node("CurrentPlaceSnd")
onready var windSnd = get_node("WindPlaceSnd");
onready var ambienceSnd = get_node("PathAmbience")
onready var deleteSnd = get_node("PathDeleteSound")
var soundInterval = 7;
var soundCounter = 0;
var finishedOnePath = false;
var isActive # whether we're the active pat

export(NodePath) var ghostPathNodePath
var ghostPath;
export(bool) var isGhostPath = false;

signal start_drawing
signal end_drawing

var set_track = false;
func _ready() -> void:
	padRadius = radius/4
	if (ghostPathNodePath):
		ghostPath = get_node(ghostPathNodePath);

func _process(_delta: float) -> void:
	if (isGhostPath):
		visible = Data.path_ghosts;
	if (Input.is_key_pressed(KEY_R) and not disabled):
		paths = [];
		update();

func clear():
	paths = [];
	currentPath = [];
	if (ghostPath): ghostPath.clear();
	update();

func _draw() -> void:
	for path in paths:
		for point in path:
			draw_circle(point.pos, radius, color);
			
	var arrowIntervalCounter = 0;
	for path in paths:
		for point in path:
			arrowIntervalCounter+=1;
			if (arrowIntervalCounter % arrowInterval == 0):
				if not isGhostPath: 
					draw_set_transform(point.pos, point.vec.angle() + PI/2, Vector2.ONE);
					draw_texture(arrowTex, Vector2.LEFT * arrowTex.get_width()/2 + Vector2.UP * arrowTex.get_height()/2)
					draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _unhandled_input(event: InputEvent) -> void:
	if disabled or not isActive: return;
	if event is InputEventMouseButton:
		var mEvent = event as InputEventMouseButton
		if mEvent.pressed:
			if isOnBoundary(mEvent.position):
				isDrawing = true;
				startDrawing();
				currentPath = [];
				paths.append(currentPath);
				currentPoint = mEvent.position;
				addPoint()
		else:
			stopDrawing();
			if isDrawing:
				if not isOnBoundary(mEvent.position) or currentPath.size() < 10:
					paths.pop_back()
					currentPath = [];
					pass
				else:
					finishedOnePath = true;
			else:
				deletePathOverMouse(mEvent.position);
			isDrawing = false;
	if event is InputEventMouseMotion:
		var mEvent = event as InputEventMouseMotion;
		if mEvent.button_mask != mouseButton: return;
		if isDrawing:
			if mEvent.position.distance_to(getLastPoint()) > padRadius:
				currentPoint = mEvent.position;
				if mEvent.position.distance_to(getLastPoint()) > padRadius * 2:
					var startPoint = getLastPoint()
					var iterPos = startPoint
					for i in range(floor(startPoint.distance_to(mEvent.position)/padRadius)):
						iterPos += (currentPoint - startPoint).normalized() * padRadius;
						currentPoint = iterPos
						addPoint()
				
	update()

func isOnBoundary(pos:Vector2):
	return pos.x < boundary or pos.x > Global.width - boundary or pos.y < boundary or pos.y > Global.height - boundary

func addPoint():
	soundCounter+=1;
	if soundCounter > soundInterval:
		if (type == "current"):
			currentSnd.play();
		else:
			windSnd.play();
		soundCounter = 0;

	var point = PathPoint.new();
	point.pos = currentPoint;
	point.vec = currentPoint - getLastPoint();
	point.radius = radius;
	point.strength = strength;
	currentPath.append(point);

func getLastPoint(offset = 0):
	if currentPath.size() == 0: return currentPoint;
	return currentPath[currentPath.size()-1 + offset].pos;

func deletePathOverMouse(position:Vector2):
	for i in range(paths.size()):
		var path = paths[i];
		var deletingPath = false;
		for point in path:
			if position.distance_to(point.pos) < radius:
				deletingPath = true;
				break;
		if deletingPath:
			if ghostPath:
				ghostPath.setPath(paths[i]);
			paths.remove(i);
			deleteSnd.play();
			break;

func getPoints():
	var pointArr = [];
	for path in paths:
		for point in path:
			pointArr.append(point);
	return pointArr;
	
func setPath(path):
	self.paths = [path];
	update();
func getJson():
	var objPoints = [];
	for path in paths:
		var pathPointArr = [];
		for point in path:
			pathPointArr.append({
				"vec": {"x": point.vec.x, "y": point.vec.y},
				"pos": {"x": point.pos.x, "y": point.pos.y},
				"radius": point.radius,
				"strength": point.strength
			})
		objPoints.append(pathPointArr);
	return objPoints;

func startDrawing():
	if not set_track:
		set_track = true;
		var player = ambienceSnd.get_node("Track") as AudioStreamPlayer;
		player.stream = ambienceTrack;
		player.play();
	emit_signal("start_drawing")
	ambienceSnd.fadeIn(ambienceVolume, ambienceFadeInDuration)
func stopDrawing():
	emit_signal("end_drawing")
	ambienceSnd.fadeOut(ambienceFadeOutDuration)
	
	
