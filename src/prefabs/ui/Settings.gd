extends Node2D

func onSoundSliderValueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), value)
