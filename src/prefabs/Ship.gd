extends Node2D
class_name Ship

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var vel:Vector2 = Vector2(0,0);
var accel:Vector2 = Vector2(0,0);
var currentPoint:Vector2;
var radius = 40
var drag = 0.99
var accelMax = 0.15;
var velMax = 2;
var island
var setFrame = false;
onready var spr = get_node("AnimatedSprite") as AnimatedSprite;
# onready var gm:GameManager = get_node("/root/GameScene/GameManager") as GameManager
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
	# for point in gm.allPoints:
		# if (global_position.distance_to(point.pos) < radius + point.radius):
			# accel += point.vec;
	
	if accel.length() > accelMax:
		accel = accel.normalized() * accelMax
	vel += accel;
	vel *= drag;
	if (vel.length() > velMax):
		vel = vel.normalized() * velMax 
	accel = Vector2.ZERO;
	global_position += vel;
	
	if island:
		if global_position.distance_to(island.dest.global_position) < radius + island.dest.radius:
			get_parent().remove_child(self);
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
