extends Node2D
class_name Ship

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var vel:Vector2 = Vector2(0,0);
var accel:Vector2 = Vector2(0,0);
var currentPoint:Vector2;
var radius = 20
var drag = 0.99
var accelMax = 0.11 # 0.15;
var velMax = 3 # 2;
var island
var setFrame = false;
var toBeKilled = false;
onready var spr = get_node("Sprite") as AnimatedSprite;
onready var deadSpr = get_node("DeadSprite") as AnimatedSprite;
onready var explosion = get_node("Explosion") as AnimatedSprite;
onready var gm:GameManager = get_node("/root/GameScene/GameManager") as GameManager
var dead = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_as_relative = false
	
func _draw() -> void:
	pass;
	# at some point we'll make a water trail here
	
func _process(delta: float) -> void:
	if toBeKilled: dead = true;
	if island != null and not setFrame:
		setFrame = true;
		spr.frame = island.dest.img.frame;
		deadSpr.frame = island.dest.img.frame;
		
	if not dead:
		for point in gm.allPoints:
			if (global_position.distance_to(point.pos) < radius + point.radius):
				accel += point.vec * point.strength
		
		if accel.length() > accelMax:
			accel = accel.normalized() * accelMax
		vel += accel * (delta * 70);
		vel *= drag;
		if (vel.length() > velMax):
			vel = vel.normalized() * velMax 
		accel = Vector2.ZERO;
		global_position += vel;
	
		z_index = Math.getZIndex(global_position.y);
		for ship in gm.ships:
			if (global_position.distance_to(ship.global_position) < radius + ship.radius) and ship != self and not ship.dead:
				explode();
				
		for obstacle in gm.obstacles:
			if obstacle is Obstacle:
				if obstacle.collides(self):
					explode();
			if obstacle is Whirlpool:
				if (global_position.distance_to(obstacle.global_position) < radius + obstacle.radius):
					var whirlpoolCenter = obstacle.global_position + Vector2.DOWN * obstacle.offsetY
					var velToCenter = (whirlpoolCenter - global_position).normalized();
					vel += velToCenter * 0.1;
		
		if island:
			if global_position.distance_to(island.dest.global_position) < radius + island.dest.radius:
				island.dest.acceptShip();
				get_parent().remove_child(self);
		
func explode():
	toBeKilled = true;
	
	spr.visible = false;
	deadSpr.visible = true;
	explosion.play();
	explosion.visible = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Explosion_animation_finished() -> void:
	explosion.playing = false;
	explosion.visible = false;
