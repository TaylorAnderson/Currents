extends Ship
class_name PirateShip
var speed = 1
func _ready() -> void:
	self.accelMax = 0.22
	self.radius = self.radius * 2
	self.type = ShipType.Pirate
	self.currentStrengthMultiplier = 0.02;
func _process(delta):
	if not dead:
		var foundTreasure = false;
		for o in gm.obstacles:
			if o is Treasure and not o.collected: 
				foundTreasure = true;
				var destVec = (o.global_position - global_position).normalized()
				accel = destVec * speed;
		if not foundTreasure:
			for ship in gm.ships:
				if is_instance_valid(ship) and ship.collectedTreasure:
					var destVec = (ship.global_position - global_position).normalized()
					accel = destVec * speed;

func get_class(): return "PirateShip"
