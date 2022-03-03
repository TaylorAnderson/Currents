extends Node2D

onready var tween = get_node("Tween")
onready var text = get_node("Text")
export(NodePath) onready var nextLevelBtn = get_node(nextLevelBtn) as TextureButton;
onready var text_reflection = get_node("Text-Reflection")
onready var initialPos = text.position;
onready var initialPos_reflection = text_reflection.position;
onready var destVec = Vector2(0, 14);

signal edit_clicked
signal nextlevel_clicked
signal levelselect_clicked
	
func show():
	text.position = initialPos;
	$AudioStreamPlayer.play();
	visible = true;
	tween.interpolate_property(text, "position", initialPos, initialPos + Vector2.UP * 70, 0.9, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_property(text_reflection, "position", initialPos_reflection, initialPos_reflection + Vector2.DOWN * 70, 0.9, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start();
func hide():
	visible = false;
func onBtnPressed():
	$BtnSound.play();

func _on_nextlevel_btn_pressed() -> void:
	emit_signal("nextlevel_clicked")


func _on_edit_btn_pressed() -> void:
	emit_signal("edit_clicked")


func _on_levelselect_btn_pressed() -> void:
	emit_signal("levelselect_clicked")
