extends Node2D
class_name Treasure

var radius = 25;
var collected = false;
onready var collectAnim = get_node("Explosion");
onready var spr = get_node("AnimatedSprite") as AnimatedSprite;
func collect():
	print("collected");
	collected = true;
	spr.visible = false;
	collectAnim.visible = true;
	collectAnim.play("default");
func respawn():
	collectAnim.frame = 0;
	collectAnim.stop();
	spr.visible = true;
	collectAnim.visible = false;
	collected = false;
