extends Node2D
class_name PirateSpawner
export(PackedScene) var pirateShip;
onready var pirateIndicator = get_node("PirateShipIndicator")
onready var gm = get_node("/root/GameScene/GameManager")
onready var sndPirateSpawned = get_node("PirateRevealSnd")
var treasureDir;
func enterEditMode():
	print(self.get_path())
	var treasure;
	for o in gm.obstacles:
		if o is Treasure:
			treasure = o;
	if treasure:
		pirateIndicator.visible = true;
		var indicatorBG = pirateIndicator.get_node("BG") as AnimatedSprite
		treasureDir = (treasure.global_position - global_position).normalized() as Vector2
		indicatorBG.rotation = treasureDir.angle() - PI/2
func spawn(playSound):
	if playSound:
		sndPirateSpawned.play();
	pirateIndicator.visible = false;
	var shipInst = pirateShip.instance();
	get_parent().add_child(shipInst);
	shipInst.global_position = global_position - treasureDir * 100;
	gm.ships.append(shipInst);
