extends Node2D

var sndInterval = 3;
var sndCounter = 0;
var setSound = false;
var setMusic = false;
func _ready() -> void:
	update_settings();
	
func update_settings():
	$"music-slider".value = Data.data["musicVol"]
	$"sound-slider".value = Data.data["soundVol"];
	$"path-ghost-toggle".toggle(Data.path_ghosts);
func onSoundSliderValueChanged(value: float) -> void:
	if not setSound: 
		setSound = true;
		return;
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
	
	Data.SetMusicVolume(value);
	Data.SaveGame();
	sndCounter += 1;
	if sndCounter % sndInterval == 0:
		$MusicSliderSnd.play();
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value));

func _on_pathghosttoggle_wasToggled(toggled:bool) -> void:
	Data.path_ghosts = toggled;
	Data.SaveGame();
	$BtnSound.play();
