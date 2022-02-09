extends Node2D

onready var settingsMenu = get_node("settings")
onready var creditsMenu = get_node("credits")
func onSettingsPressed() -> void:
	settingsMenu.visible = !settingsMenu.visible;

func onCreditsPressed() -> void:
	creditsMenu.visible = !creditsMenu.visible;

func onSoundSliderValueChange(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), value)


func onPlayBtnPressed() -> void:
	self.visible = false;
