extends PathEditor

export(String, "current", "wind") var pathType;
func _ready() -> void:
	._ready();
	disabled = true;
func loadJson(path):
	var file = File.new();
	var error = file.open(path, File.READ);
	if not error:
		var obj:Dictionary = JSON.parse(file.get_as_text()).result
		file.close();
		for path in obj.get(pathType):
			var pathArr = [];
			for point in path:
				var newPoint = PathPoint.new();
				newPoint.radius = point.radius;
				newPoint.vec = Vector2(point.vec.x, point.vec.y);
				newPoint.pos = Vector2(point.pos.x, point.pos.y);
				newPoint.strength = point.strength;
				pathArr.append(newPoint)
			paths.append(pathArr);
	update()
	
