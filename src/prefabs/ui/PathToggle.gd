extends TextureButton
class_name PathToggle
enum PathType {
	CURRENT,
	WIND
}
export(Texture) var currentTexture:Texture
export(Texture) var windTexture:Texture
var currentPath = PathType.CURRENT;

signal pathToggled;
func onPressed() -> void:
	if (currentPath == PathType.CURRENT):
		currentPath = PathType.WIND
		texture_normal = windTexture
	else:
		currentPath = PathType.CURRENT
		texture_normal = currentTexture;
	emit_signal("pathToggled")

func pathIsWind():
	return currentPath == PathType.WIND
	
func pathIsCurrent():
	return currentPath == PathType.CURRENT
