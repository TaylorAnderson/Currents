extends Node

var transition_duration = 2;
var transition_type = 1 # TRANS_SINE
onready var tween_out = Tween.new();
onready var tween_in = Tween.new();

func _ready() -> void:
	tween_out.connect("tween_completed", self, "_on_TweenOut_tween_completed")
func fade_out(stream_player, defaultVolume): 
	stream_player.add_child(tween_out);
	# tween music volume down to 0
	tween_out.interpolate_property(stream_player, "volume_db", defaultVolume, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()

func fade_in(stream_player, defaultVolume):
	stream_player.add_child(tween_in);
	tween_in.interpolate_property(stream_player, "volume_db", -80, defaultVolume, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_in.start()
	# when the tween ends, the music will be stopped
func _on_TweenOut_tween_completed(object, key):
	tween_out.queue_free();
	# stop the music -- otherwise it continues to run at silent volume
	object.stop()
