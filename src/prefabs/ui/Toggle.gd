extends TextureButton

export(Texture) var toggledTex;
export(Texture) var untoggledTex;
export(bool) var toggled = false;
signal wasToggled(toggled);

func _ready() -> void:
	update_display();
func update_display():
	if toggled:
		texture_normal = toggledTex;
	else:
		texture_normal = untoggledTex;
func toggle(force_value = null):
	toggled = !toggled;
	if force_value != null:
		toggled = force_value
	else:
		emit_signal("wasToggled", toggled);
	update_display();
