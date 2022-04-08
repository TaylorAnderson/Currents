extends Node2D

var sndInterval = 3;
var sndCounter = 0;
var setSound = false;
var setMusic = false;
func _ready() -> void:
	$"music-slider".value = Data.data["musicVol"]
	$"sound-slider".value = Data.data["soundVol"];
func onSoundSliderValueChanged(value: float) -> void:
	if not setSound: 
		setSound = true;
		return;
	
	print("sound value change");
	Data.SetSoundVolume(value);
	Data.SaveGame();
	sndCounter+= 1;
	if sndCounter % sndInterval == 0:
		$SoundSliderSnd.play();
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(value))


func onMusicSliderValueChanged(value: float) -> void:
	if not setMusic: 
		setMusic = true;
		return;
	
	print("music value change");
	Data.SetMusicVolume(value);
	Data.SaveGame();
	sndCounter += 1;
	if sndCounter % sndInterval == 0:
		$MusicSliderSnd.play();
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value));
