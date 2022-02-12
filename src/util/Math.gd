extends Node
class_name Math
static func scale (number, inMin, inMax, outMin, outMax):
		return (number - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
static func getZIndex(yValue):
	return scale(yValue, 0, Global.height, 0, 50)
