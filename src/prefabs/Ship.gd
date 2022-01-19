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
var accelMax = 0.09 # 0.15;
var velMax = 3 # 2;
var island
var setFrame = false;

onready var spr = get_node("AnimatedSprite") as AnimatedSprite;
onready var explosion = get_node("Explosion") as AnimatedSprite;
onready var gm:GameManager = get_node("/root/GameScene/GameManager") as GameManager
var dead = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;
	
func _draw() -> void:
	pass;
	# at some point we'll make a water trail here
	
func _process(delta: float) -> void:
	if island != null and not setFrame:
		setFrame = true;
		spr.frame = island.dest.img.frame;
		
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
		
		for ship in gm.ships:
			if (global_position.distance_to(ship.global_position) < radius + ship.radius) and ship != self and not ship.dead:
				explode();
		
		if island:
			if global_position.distance_to(island.dest.global_position) < radius + island.dest.radius:
				island.dest.acceptShip();
				get_parent().remove_child(self);
		
func explode():
	dead = true;
	spr.visible = false;
	explosion.play();
	explosion.visible = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Explosion_animation_finished() -> void:
	explosion.playing = false;
	explosion.visible = false;
