extends Node2D

var sndInterval = 3;
var sndCounter = 0;
func onSoundSliderValueChanged(value: float) -> void:
	sndCounter+= 1;
	if sndCounter % sndInterval == 0:
		$SoundSliderSnd.play();
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), value)
	
