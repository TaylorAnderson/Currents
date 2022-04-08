extends Node2D
class_name Island
enum IslandColors {
	GREEN,
	BLUE,
	ORANGE,
	RED,
	YELLOW
}

export(IslandColors) var islandColor = IslandColors.BLUE;
export(PackedScene) var shipPrefab:PackedScene = null;
var colorFrames = [
	IslandColors.RED,
	IslandColors.ORANGE,
	IslandColors.GREEN,
	IslandColors.YELLOW,
	IslandColors.BLUE
]
var radius = 50;

export(NodePath) var destPath;
var dest:Node2D
onready var img = get_node("AnimatedSprite") as AnimatedSprite;
onready var gm:GameManager = get_node("/root/GameScene/GameManager") as GameManager
onready var winAnim:AnimatedSprite = get_node("WinAnim") as AnimatedSprite;
onready var treasureIndicator = get_node("TreasureIndicator") as AnimatedSprite
var initialShipVel = 1.5;
var hovered = false;
var arrowInterval = 20;
var currentMouse;
var shipsExpecting = 0;
var shipsReceived = 0;
var completed = false;
export var wantsTreasure = false;
var collectedTreasure = false;
export(Texture) var pathArrowTex:Texture

onready var sndAcceptShip = get_node("AcceptShipSnd")
onready var sndAllShipsAccepted = get_node("AllShipsAcceptedSnd")

signal onPathShown(island);
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = Math.getZIndex(global_position.y);
	img.frame = colorFrames.find(islandColor);
	dest = get_node(destPath) as Island;
	if dest:
		dest.shipsExpecting+=1;
	
func _process(_delta: float) -> void:
	treasureIndicator.visible = wantsTreasure;
	if collectedTreasure: treasureIndicator.frame = 0;
	else: treasureIndicator.frame = 1;
	# if dest.dest:
		# if (dest.dest == self): arrowInterval = 30;
func _draw() -> void:

	if hovered and dest:
		var currentPos = Vector2.DOWN * 10;
		var pixelsTravelled = 0;
		var vec = ((dest.global_position + Vector2.DOWN * 10) - (global_position + Vector2.DOWN * 10)) as Vector2
		for _i in range(vec.length()):
			currentPos += vec.normalized();
			pixelsTravelled+=1;
			if (pixelsTravelled > arrowInterval):
				var pw = pathArrowTex.get_width();
				var ph = pathArrowTex.get_height();
				draw_set_transform(currentPos, vec.angle()+PI/2, Vector2.ONE);
				draw_texture(pathArrowTex, Vector2.LEFT * pw/2 + Vector2.UP * ph/2, Color(1, 1, 1, 0.3));
				draw_set_transform(Vector2.ZERO, 0, Vector2.ONE);
				pixelsTravelled = 0;

func spawnShip():
	var destVec = (dest.global_position - global_position).normalized();
	var ship = shipPrefab.instance()
	get_parent().add_child(ship);
	gm.ships.append(ship);
	ship.island = self;
	ship.global_position = global_position + destVec * radius;
	ship.vel = destVec * initialShipVel;
		
func acceptShip(ship):
	sndAcceptShip.play();
	winAnim.play("ship_add");
	shipsReceived += 1;
	if (ship.collectedTreasure):
		collectedTreasure = true;
	if shipsReceived == shipsExpecting and (not wantsTreasure or collectedTreasure):
		playVictory();
		yield(get_tree().create_timer(0.1), "timeout")
		sndAllShipsAccepted.play();

func playVictory():
	completed = true;
	winAnim.play("all_ships_added");

func onEditModeStart():
	
	completed = false;
	winAnim.frame = 0;
	winAnim.visible = false;
	
	collectedTreasure = false;
			
			

func onPlayModeStart():
	if shipsExpecting == 0:
		completed = true;
	shipsReceived = 0;
	winAnim.frame = 0;
	winAnim.visible = true;
	if dest: spawnShip()
	
func _on_WinAnim_animation_finished() -> void:
	if completed:
		gm.checkLevelComplete();
	winAnim.playing = false;
	winAnim.frame = 13;


func onBtnDown() -> void:
	hovered = true;
	emit_signal("onPathShown", self);
	update();


func onBtnUp() -> void:
	hovered = false;
	update();
