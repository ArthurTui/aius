extends Node2D

const DAMAGE = 10
const KNOCKBACK = 10
const EYE_POS = [Vector2(-9, -220), Vector2(9, -220)]
const LASER_TIMER = 5
const MAX_ENERGY = 2

var bar
var in_cooldown = false
var targets = []
var time = 0

func _ready():
	$Lasers/Left.add_point(EYE_POS[0])
	$Lasers/Right.add_point(EYE_POS[1])
	
	bar = TextureProgress.new()
	bar.fill_mode = bar.FILL_CLOCKWISE
	bar.texture_progress = load("res://stages/temple/reticle.png")
	bar.max_value = 1
	bar.value = 0
	bar.step = .01
	bar.rect_min_size = Vector2(160, 160)
	bar.rect_position = Vector2(-80, -80)
	bar.modulate = Color(1, 1, 1, .7)
	bar.show_behind_parent = true


func _process(delta):
	if in_cooldown:
		return
	
	var factor = 0
	
	if targets.size():
		time += delta
		factor = time / LASER_TIMER
		if time >= LASER_TIMER:
			shoot(targets[0])
	
	$Flares/Light2D.energy = factor * MAX_ENERGY
	$Flares/Sprite.modulate = Color(1, 1, 1, factor)
	bar.value = factor


func shoot(target):
	in_cooldown = true
	$Cooldown.start()
	
	time  = 0
	
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
	$Tween.interpolate_property(bar, "modulate", Color(1, 1, 1, .7),
		Color(1, 1, 1, 0), d, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($Flares/Light2D, "energy", MAX_ENERGY, 0, d,
		Tween.TRANS_BACK, Tween.EASE_IN)
	$Tween.start()
	
	for i in range(4):
		yield($Tween, "tween_completed")
	$Lasers/Left.remove_point(1)
	$Lasers/Right.remove_point(1)
	bar.value = 0
	bar.modulate = Color(1, 1, 1, .7)


func _on_DetectionArea_body_entered(body):
	if !targets.size():
		body.add_child(bar)
	targets.append(body)


func _on_DetectionArea_body_exited(body):
	if body == targets[0]:
		time = 0
		body.remove_child(bar)
		if targets.size() > 1:
			targets[1].add_child(bar)
	targets.erase(body)


func _on_Cooldown_timeout():
	in_cooldown = false
