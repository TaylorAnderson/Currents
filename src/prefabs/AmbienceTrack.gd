extends Node2D
class_name AmbienceTrack
onready var track = get_node("Track");
onready var tween = get_node("Tween")
var currentVol = 0;
func fadeIn(volume_db, duration):
	currentVol = volume_db;
	tween.interpolate_property(track, "volume_db", -80, volume_db, duration);
	tween.start();
	
func fadeOut(duration):
	tween.interpolate_property(track, "volume_db", currentVol, -80, duration);
	tween.start()
