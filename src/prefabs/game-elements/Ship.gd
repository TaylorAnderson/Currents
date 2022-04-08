extends Node2D
class_name Ship

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum ShipType {
	Normal,
	Pirate
}
var type = ShipType.Normal;
var vel:Vector2 = Vector2(0,0);
var accel:Vector2 = Vector2(0,0);
var currentPoint:Vector2;
var radius = 20
var drag = 0.99
var accelMax = 0.06 # 0.15;
var velMax = 3 # 2;
var island
var setFrame = false;
var toBeKilled = false;
var collectedTreasure = false;
onready var spr = get_node("Sprite") as AnimatedSprite;
onready var deadSpr = get_node("DeadSprite") as AnimatedSprite;
onready var explosion = get_node("Explosion") as AnimatedSprite;
onready var gm:GameManager = get_node("/root/GameScene/GameManager")
onready var particles:CPUParticles2D = get_node("Particles2D")
export(PackedScene) var onHitDestIslandParticles:PackedScene
var dead = false;

var waterTrail = [];
var waterInitRadius = 10;
var waterTrailInterval = 5;
var waterTrailCounter = 0;
var currentStrengthMultiplier = 1;
onready var sndExplosion = get_node("ExplosionSnd");
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_node("IdleSound"));
	z_as_relative = false;
	
func _process(delta: float) -> void:
	if toBeKilled: dead = true;
	if island != null and not setFrame:
		setFrame = true;
		spr.frame = island.dest.img.frame;
		deadSpr.frame = island.dest.img.frame;
		
	particles.visible = false;
	if not dead:
		particles.visible = true;
	if not dead:
		for point in gm.allPoints:
			if (global_position.distance_to(point.pos) < radius + point.radius):
				accel += (point.vec * point.strength) * currentStrengthMultiplier;
		
		if accel.length() > accelMax:
			accel = accel.normalized() * accelMax
		vel += accel * (delta * 70);
		vel *= drag;
		spr.flip_h = vel.x < 0
		if (vel.length() > velMax):
			vel = vel.normalized() * velMax 
		accel = Vector2.ZERO;
		global_position += vel;
		particles.direction = Vector2.RIGHT * vel * -1;
		particles.initial_velocity = vel.length() * 20
		particles.update();
		z_index = Math.getZIndex(global_position.y);
		for ship in gm.ships:
			if is_instance_valid(ship):
				if (global_position.distance_to(ship.global_position) < radius + ship.radius - 2) and ship != self and not ship.dead:
					explode();
					if ship.type == ShipType.Normal:
						ship.explode();
				
		for obstacle in gm.obstacles:
			if obstacle is Obstacle:
				if obstacle.collides(self):
					explode();
			if obstacle is Whirlpool:
				if (global_position.distance_to(obstacle.global_position) < radius + obstacle.radius):
					var whirlpoolCenter = obstacle.global_position + Vector2.DOWN * obstacle.offsetY
					var velToCenter = (whirlpoolCenter - global_position).normalized();
					vel += velToCenter * 0.05;
			if obstacle is Treasure and not obstacle.collected:
				if global_position.distance_to(obstacle.global_position) < radius + obstacle.radius:
					obstacle.collect();
					collectedTreasure = true;
		if island:
			if global_position.distance_to(island.dest.global_position) < radius + island.dest.radius:
				island.dest.acceptShip(self);
				queue_free();
				dead = true;
		
func explode():
	sndExplosion.play();
	get_node("IdleSound").stop();
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
