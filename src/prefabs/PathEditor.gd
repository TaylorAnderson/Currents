extends Node2D

class PathPoint: 
	var vec:Vector2
	var pos:Vector2
	var radius:int

var isDrawing = false;
var boundary = 40;
var paths:Array = []; 
var currentPath:Array = [];
var lastPoint:Vector2 = Vector2.ZERO;
var currentPoint:Vector2 = Vector2.ZERO;
var disabled = false;

export(int) var radius = 0;
export(Color) var color = Color.red;
export(Texture) var arrowTex:Texture;
export(int) var arrowInterval = 5;
export(int) var mouseButton = 1;

var padRadius = 0;

func _ready() -> void:
	padRadius = radius/4

func _process(_delta: float) -> void:
	if (Input.is_key_pressed(KEY_R)):
		paths = [];

func _draw() -> void:
	
	for path in paths:
		for point in path:
			draw_circle(point.pos, radius, color);
			
	var arrowIntervalCounter = 0;
	for path in paths:
		for point in path:
			arrowIntervalCounter+=1;
			if (arrowIntervalCounter % arrowInterval == 0):
				draw_set_transform(point.pos, point.vec.angle() + PI/2, Vector2.ONE);
				draw_texture(arrowTex, Vector2.LEFT * arrowTex.get_width()/2 + Vector2.UP * arrowTex.get_height()/2)
				draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _unhandled_input(event: InputEvent) -> void:
	if disabled: return;
	if event is InputEventMouseButton:
		var mEvent = event as InputEventMouseButton
		if mEvent.button_index != mouseButton: return;
		if mEvent.pressed:
			if isOnBoundary(mEvent.position):
				isDrawing = true;
				currentPath = [];
				paths.append(currentPath);
				currentPoint = mEvent.position;
				addPoint()
		else:
			if isDrawing:
				if not isOnBoundary(mEvent.position):
					paths.pop_back()
					currentPath = [];
					pass
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
	var point = PathPoint.new();
	point.pos = currentPoint;
	point.vec = currentPoint - getLastPoint();
	point.radius = radius;
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
			paths.remove(i);
			break;
func getPoints():
	var pointArr = [];
	for path in paths:
		for point in path:
			pointArr.append(point);
	return pointArr;
