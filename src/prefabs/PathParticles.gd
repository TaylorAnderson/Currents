extends CPUParticles2D


func show_particles() -> void:
	global_position = get_viewport().get_mouse_position();
	restart();
