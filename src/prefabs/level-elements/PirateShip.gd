extends Ship

var speed = 0.22
func _ready() -> void:
	self.accelMax = 0.22
func _process(delta):
	if not dead:
		for o in gm.obstacles:
			if o is Treasure and not o.collected: 
				var destVec = (o.global_position - global_position).normalized()
				accel = destVec * speed;
