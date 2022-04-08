extends Node

export var waveInterval = 1.0
export var timer = 0;
export var padding = 20;
export(PackedScene) var waveScene;
func _process(delta: float) -> void:
	timer += delta;
	if timer > waveInterval:
		timer -= waveInterval;
		var waveInst = waveScene.instance() as AnimatedSprite;
		waveInst.global_position.x = rand_range(padding, Global.width - padding);
		waveInst.global_position.y = rand_range(padding, Global.height - padding);
		add_child(waveInst);
