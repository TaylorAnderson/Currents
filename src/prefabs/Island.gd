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
var initialShipVel = 0.5;
var hovered = false;
var arrowInterval = 20;
var currentMouse;
var shipsExpecting = 0;
var shipsReceived = 0;
var completed = false;
export(Texture) var pathArrowTex:Texture
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	img.frame = colorFrames.find(islandColor);
	dest = get_node(destPath) as Island;
	if dest:
		dest.shipsExpecting+=1;
	
func _process(_delta: float) -> void:
	pass;
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
	var ship = shipPrefab.instance() as Ship
	add_child(ship);
	gm.ships.append(ship);
	ship.island = self;
	# ship.z_index = z_index - 1;
	ship.global_position += destVec * radius;
	ship.vel = destVec * initialShipVel;
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.position.distance_to(global_position) < radius:
			hovered = true;
		else:
			hovered = false;
		update();
		
func acceptShip():
	winAnim.play("ship_add");
	shipsReceived +=1;
	if shipsReceived == shipsExpecting:
		playVictory();

func playVictory():
	completed = true;
	winAnim.play("all_ships_added");

func onEditModeStart():
	winAnim.frame = 0;
	winAnim.visible = false;

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
