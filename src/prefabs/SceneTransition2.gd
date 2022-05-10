extends Node2D

onready var tween = get_node("Tween");
onready var underWave = get_node("Underwave")
onready var overWave = get_node("Overwave")
onready var shadowWave = get_node("Underwave Shadow")
signal finish_transition;
var initialPos = Vector2(-660, 1520);
var shadowOffset = Vector2(100, -100)
var delta = Vector2(1100, -1100);
var transitioning = false;
var currentPath = "";
var speed = 0.9;
var delay = 0.15;
var introSpeedOffset = -0.3;
var baseDelay = 0.3;
var onDryRun = false;
onready var waveSnd = get_node("AudioStreamPlayer") as AudioStreamPlayer
func _ready() -> void:
	endTransition();

func endTransition():
	visible = true;
	$MouseBlock.visible = true;
	waveSnd.play(1.2);
	underWave.position = initialPos + delta;
	shadowWave.position = initialPos + shadowOffset;
	tween.interpolate_property(underWave, "position", 
		initialPos + delta, initialPos, speed + introSpeedOffset, 
		Tween.TRANS_EXPO, Tween.EASE_IN, delay );
	tween.interpolate_property(shadowWave, "position",
		initialPos + shadowOffset + delta, initialPos + shadowOffset, speed + introSpeedOffset,
		Tween.TRANS_EXPO, Tween.EASE_IN, delay)
	tween.interpolate_property(overWave, "position",
		initialPos + delta, initialPos, speed + introSpeedOffset,
		Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start();
	yield(tween, "tween_all_completed");
	emit_signal("finish_transition")


func transition(scenePath, onDryRun = false):
	self.onDryRun = onDryRun;
	visible = true;
	$MouseBlock.visible = true;
	
	tween.interpolate_property(underWave, "position", 
		initialPos, initialPos + delta, speed, 
		Tween.TRANS_EXPO, Tween.EASE_OUT, baseDelay)
	tween.interpolate_property(shadowWave, "position", 
		initialPos + shadowOffset, initialPos + shadowOffset + delta, speed, 
		Tween.TRANS_EXPO, Tween.EASE_OUT, baseDelay)

	tween.interpolate_property(overWave, "position", 
		initialPos, initialPos + delta, speed, 
		Tween.TRANS_EXPO, Tween.EASE_OUT, baseDelay + delay)
	tween.start();

	transitioning = true;
	currentPath = scenePath
	yield(get_tree().create_timer(baseDelay-0.1), "timeout")
	waveSnd.play();
func onAnimationFinished():
	$MouseBlock.visible = false;
	if transitioning:
		if not onDryRun:
			get_tree().change_scene(currentPath);
		else:
			endTransition();
	transitioning = false;
	onDryRun = false;
	
