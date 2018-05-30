extends Node2D

const DAMAGE = 10
const KNOCKBACK = 10
const EYE_POS = [Vector2(-9, -220), Vector2(9, -220)]
const LASER_TIMER = 5
const MAX_ENERGY = 2

var in_cooldown = false
var targets = []
var times = []

func _ready():
	$Lasers/Left.add_point(EYE_POS[0])
	$Lasers/Right.add_point(EYE_POS[1])


func _process(delta):
	if in_cooldown:
		return
	
	for i in range(times.size()):
		times[i] += delta
	
	var factor = 0
	
	if times.size() > 0:
		factor = times[0] / LASER_TIMER
		if times[0] >= LASER_TIMER:
			shoot(targets[0])
			for i in range(times.size()):
				times[i] = 0
	
	$Flares/Light2D.energy = factor * MAX_ENERGY
	$Flares/Sprite.modulate = Color(1, 1, 1, factor)


func shoot(target):
	in_cooldown = true
	$Cooldown.start()
	
	var local_target_pos = target.position - position
	var dir = local_target_pos.normalized()
	target.take_damage(DAMAGE, dir, KNOCKBACK)
	
	$Lasers/Left.add_point(local_target_pos)
	$Lasers/Right.add_point(local_target_pos)
	$Lasers.modulate = Color(1, 1, 1, 1)
	
	var d = .5 # Tween duration
	$Tween.interpolate_property($Lasers, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), d, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Flares/Sprite, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), d, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Flares/Light2D, "energy", MAX_ENERGY, 0, d,
		Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	$Lasers/Left.remove_point(1)
	$Lasers/Right.remove_point(1)


func _on_DetectionArea_body_entered(body):
	targets.append(body)
	times.append(0)


func _on_DetectionArea_body_exited(body):
	times.remove(targets.find(body))
	targets.erase(body)


func _on_Cooldown_timeout():
	in_cooldown = false
